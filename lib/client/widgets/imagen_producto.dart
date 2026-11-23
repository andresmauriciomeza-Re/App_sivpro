import 'package:material_ui/material_ui.dart';
import '../../config/api_config.dart';
import '../models/producto_catalogo.dart';

/// Fuentes de la imagen de un producto, en orden de prioridad:
/// 1. la del backend (`GET /productos/:id/imagen`) si `tiene_imagen`;
/// 2. la primera de su galería, si es una URL utilizable;
/// 3. la foto local de la app asociada a su nombre.
/// Si ninguna carga se usa el respaldo (placeholder).
List<String> fuentesImagen(ProductoCatalogo producto) => [
  if (producto.tieneImagen && producto.id != null)
    '${ApiConfig.baseUrl}/productos/${producto.id}/imagen',
  if (producto.galeria.isNotEmpty && _esUrl(producto.galeria.first))
    producto.galeria.first,
  ?producto.assetLocal,
];

bool _esUrl(String valor) =>
    valor.startsWith('https://') || valor.startsWith('http://');

/// Imagen del producto que cae a la fuente siguiente si una falla. Mientras
/// carga una imagen de red se ve el [respaldo].
class ImagenProducto extends StatelessWidget {
  const ImagenProducto({
    super.key,
    required this.producto,
    required this.respaldo,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  final ProductoCatalogo producto;
  final WidgetBuilder respaldo;
  final BoxFit fit;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) =>
      _desde(context, fuentesImagen(producto), 0);

  Widget _desde(BuildContext context, List<String> fuentes, int i) {
    if (i >= fuentes.length) return respaldo(context);
    Widget siguiente(BuildContext context, Object error, StackTrace? pila) =>
        _desde(context, fuentes, i + 1);
    final fuente = fuentes[i];
    if (_esUrl(fuente)) {
      return Image.network(
        fuente,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, progreso) =>
            progreso == null ? child : respaldo(context),
        errorBuilder: siguiente,
      );
    }
    return Image.asset(
      fuente,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: siguiente,
    );
  }
}
