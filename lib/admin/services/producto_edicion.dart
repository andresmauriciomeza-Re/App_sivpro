/// Validación y armado del cuerpo de `PUT /productos/:id` (edición PARCIAL).
///
/// Función pura (sin interfaz ni red) para poder probarla. Reglas del
/// backend (validators/productos.validator.js y productos.service.js):
/// - Solo se modifican las claves presentes: aquí se envían SOLO los campos
///   que el usuario cambió, cada uno validado como lo valida el backend.
/// - `imagen: ''` BORRA la imagen: solo se envía si cambió (máx. 255).
///   `imagenes` (galería) no se edita desde la móvil.
/// - El tipo no se puede cambiar. En Reventa `precio_venta` se ignora.
/// - Elaborado: el precio no es obligatorio si no se toca (las pizzas nacen
///   sin precio y se fija al completar su primera orden). Si se envía, > 0.
/// - Pizzas: si se envía cualquiera de los dos precios, ambos deben ser > 0
///   y Grande > Mediana (el backend valida los valores finales).
/// - `nombre`: 2 a 100 caracteres (espacios dobles colapsados).
/// - `unidad_venta`: obligatoria, ≤ 20. `contenido` > 0.
/// - `contenido_unidad` ∈ {ml, L}; `unidad_compra` ∈ {und, paca, caja};
///   `unidades_por_empaque` entero ≥ 2 si la unidad de compra no es 'und'.
library;

const List<String> unidadesContenidoProducto = ['ml', 'L'];
const List<String> unidadesCompraProducto = ['und', 'paca', 'caja'];

/// Valores actuales del producto (antes de editar).
class ProductoOriginal {
  const ProductoOriginal({
    required this.tipo,
    required this.esPizza,
    required this.idCategoria,
    required this.nombre,
    required this.unidadVenta,
    required this.imagen,
    this.precio,
    this.precioGrande,
    this.contenido,
    this.contenidoUnidad,
    this.unidadCompra,
    this.unidadesPorEmpaque,
  });

  final String tipo;
  final bool esPizza;
  final int idCategoria;
  final String nombre;
  final String unidadVenta;
  final String imagen;
  final double? precio;
  final double? precioGrande;
  final double? contenido;
  final String? contenidoUnidad;
  final String? unidadCompra;
  final int? unidadesPorEmpaque;
}

/// Resultado: [cuerpo] listo para enviar, o [errores] por campo.
class EdicionProducto {
  const EdicionProducto._(this.cuerpo, this.errores);

  final Map<String, Object?> cuerpo;

  /// Clave = nombre del campo del backend ('_general' si no aplica a uno);
  /// valor = mensaje en español.
  final Map<String, String> errores;

  bool get valido => errores.isEmpty;
}

/// Colapsa espacios repetidos y recorta extremos.
String colapsarEspacios(String texto) =>
    texto.trim().replaceAll(RegExp(r'\s+'), ' ');

/// Número escrito por una persona: acepta "35000", "35.000", "35,000",
/// "35.000,50", "35,000.50", "12,5" y "1.5". Un grupo de miles nunca se
/// interpreta como decimal ("35.000" es 35000, no 35). Null si no es válido.
double? parsearNumeroUsuario(String texto) {
  var t = texto.trim().replaceAll(RegExp(r'[\s$]'), '');
  if (t.isEmpty) return null;
  if (RegExp(r'^\d{1,3}(\.\d{3})+$').hasMatch(t) ||
      RegExp(r'^\d{1,3}(,\d{3})+$').hasMatch(t)) {
    // Separadores de miles únicamente: "35.000", "1,250,000".
    t = t.replaceAll(RegExp(r'[.,]'), '');
  } else if (RegExp(r'^\d{1,3}(\.\d{3})+,\d+$').hasMatch(t)) {
    t = t.replaceAll('.', '').replaceAll(',', '.');
  } else if (RegExp(r'^\d{1,3}(,\d{3})+\.\d+$').hasMatch(t)) {
    t = t.replaceAll(',', '');
  } else {
    t = t.replaceAll(',', '.');
  }
  final valor = double.tryParse(t);
  return valor != null && valor.isFinite ? valor : null;
}

bool _igual(double? a, double? b) =>
    (a == null || a == 0) && (b == null || b == 0) ? true : a == b;

String _textoNumero(double? valor) {
  if (valor == null) return '';
  return valor == valor.roundToDouble()
      ? valor.toInt().toString()
      : valor.toString();
}

/// Texto inicial de un campo numérico (sin ".0" sobrante).
String textoInicialNumero(double? valor) => _textoNumero(valor);

EdicionProducto construirEdicionProducto({
  required ProductoOriginal original,
  required String? idCategoria,
  required String nombre,
  required String unidadVenta,
  required String imagen,
  required String precio,
  required String precioGrande,
  required String contenido,
  required String? contenidoUnidad,
  required String? unidadCompra,
  required String unidadesPorEmpaque,
}) {
  final errores = <String, String>{};
  final cuerpo = <String, Object?>{};
  final esReventa = original.tipo == 'Reventa';
  final esElaborado = original.tipo == 'Elaborado';

  final categoria = int.tryParse(idCategoria ?? '');
  if (categoria == null) {
    errores['id_categoria'] = 'Selecciona una categoría.';
  } else if (categoria != original.idCategoria) {
    cuerpo['id_categoria'] = categoria;
  }

  final nombreLimpio = colapsarEspacios(nombre);
  if (nombreLimpio != colapsarEspacios(original.nombre)) {
    if (nombreLimpio.length < 2 || nombreLimpio.length > 100) {
      errores['nombre'] = 'El nombre debe tener entre 2 y 100 caracteres.';
    } else {
      cuerpo['nombre'] = nombreLimpio;
    }
  }

  // En Reventa la unidad de venta no se edita desde la móvil.
  if (!esReventa) {
    final unidad = unidadVenta.trim();
    if (unidad != original.unidadVenta.trim()) {
      if (unidad.isEmpty || unidad.length > 20) {
        errores['unidad_venta'] =
            'La unidad de venta es obligatoria (máximo 20 caracteres).';
      } else {
        cuerpo['unidad_venta'] = unidad;
      }
    }
  }

  // Solo si el usuario cambió la imagen ('' significa borrarla).
  final imagenNueva = imagen.trim();
  if (imagenNueva != original.imagen.trim()) {
    if (imagenNueva.length > 255) {
      errores['imagen'] = 'La imagen no puede superar 255 caracteres.';
    } else {
      cuerpo['imagen'] = imagenNueva;
    }
  }

  if (esElaborado) {
    final mediana = parsearNumeroUsuario(precio);
    final medianaInvalida = precio.trim().isNotEmpty && mediana == null;
    final cambioMediana = medianaInvalida || !_igual(mediana, original.precio);
    if (original.esPizza) {
      final grande = parsearNumeroUsuario(precioGrande);
      final grandeInvalida = precioGrande.trim().isNotEmpty && grande == null;
      final cambioGrande =
          grandeInvalida || !_igual(grande, original.precioGrande);
      if (cambioMediana || cambioGrande) {
        // El backend valida los precios finales de ambas porciones.
        if (mediana == null || mediana <= 0) {
          errores['precio_venta'] =
              'Ingresa el precio Mediana mayor que 0 (ej. 35.000).';
        }
        if (grande == null || grande <= 0) {
          errores['precio_grande'] =
              'Ingresa el precio Grande mayor que 0 (ej. 45.000).';
        } else if (mediana != null && mediana > 0 && grande <= mediana) {
          errores['precio_grande'] =
              'El precio Grande debe ser mayor que el de Mediana.';
        }
        if (!errores.containsKey('precio_venta') &&
            !errores.containsKey('precio_grande')) {
          cuerpo['precio_venta'] = mediana;
          cuerpo['precio_grande'] = grande;
        }
      }
    } else if (cambioMediana) {
      if (mediana == null || mediana <= 0) {
        errores['precio_venta'] = 'Ingresa un precio mayor que 0 (ej. 35.000).';
      } else {
        cuerpo['precio_venta'] = mediana;
      }
    }
  } else if (esReventa) {
    final contenidoTexto = contenido.trim();
    final valor = parsearNumeroUsuario(contenidoTexto);
    final contenidoInvalido = contenidoTexto.isNotEmpty && valor == null;
    if (contenidoInvalido || !_igual(valor, original.contenido)) {
      if (valor == null || valor <= 0) {
        errores['contenido'] = 'Ingresa un contenido mayor que 0.';
      } else {
        cuerpo['contenido'] = valor;
      }
    }
    if (contenidoUnidad != null &&
        contenidoUnidad != original.contenidoUnidad) {
      if (!unidadesContenidoProducto.contains(contenidoUnidad)) {
        errores['contenido_unidad'] = 'Elige ml o L.';
      } else {
        cuerpo['contenido_unidad'] = contenidoUnidad;
      }
    }
    final cambioUnidadCompra =
        unidadCompra != null && unidadCompra != original.unidadCompra;
    if (cambioUnidadCompra && !unidadesCompraProducto.contains(unidadCompra)) {
      errores['unidad_compra'] = 'Elige und, paca o caja.';
    } else {
      if (cambioUnidadCompra) cuerpo['unidad_compra'] = unidadCompra;
      final unidadFinal = unidadCompra ?? original.unidadCompra;
      if (unidadFinal != null && unidadFinal != 'und') {
        final texto = unidadesPorEmpaque.trim();
        final unidades = int.tryParse(texto);
        final cambioUnidades =
            unidades != original.unidadesPorEmpaque ||
            (texto.isNotEmpty && unidades == null);
        if (cambioUnidadCompra || cambioUnidades) {
          if (unidades == null || unidades < 2) {
            errores['unidades_por_empaque'] =
                'Ingresa un número entero mayor o igual a 2.';
          } else {
            cuerpo['unidades_por_empaque'] = unidades;
          }
        }
      }
    }
  }

  if (errores.isEmpty && cuerpo.isEmpty) {
    errores['_general'] = 'No hay cambios que guardar.';
  }

  return EdicionProducto._(errores.isEmpty ? cuerpo : const {}, errores);
}
