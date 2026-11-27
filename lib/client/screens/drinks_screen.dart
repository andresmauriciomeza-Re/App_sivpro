import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';

import '../../theme/paleta_app.dart';
import '../../theme/tema_panel.dart';
import '../models/producto_catalogo.dart';
import '../services/tipos_bebida.dart';
import '../widgets/adiciones.dart';
import '../widgets/imagen_producto.dart';

/// Todas las bebidas, para agregarlas como adición del producto que se está
/// viendo. Usa las mismas cantidades que su detalle ([elegidas]).
///
/// Sin barra de navegación inferior: salir por ella perdería la selección.
class BebidasScreen extends StatelessWidget {
  const BebidasScreen({
    super.key,
    required this.bebidas,
    required this.elegidas,
    required this.nombreProducto,
  });

  final List<ProductoCatalogo> bebidas;
  final AdicionesElegidas elegidas;
  final String nombreProducto;

  @override
  Widget build(BuildContext context) => TemaCliente(
    child: _Bebidas(
      bebidas: bebidas,
      elegidas: elegidas,
      nombreProducto: nombreProducto,
    ),
  );
}

class _Bebidas extends StatefulWidget {
  const _Bebidas({
    required this.bebidas,
    required this.elegidas,
    required this.nombreProducto,
  });

  final List<ProductoCatalogo> bebidas;
  final AdicionesElegidas elegidas;
  final String nombreProducto;

  @override
  State<_Bebidas> createState() => _BebidasState();
}

class _BebidasState extends State<_Bebidas> {
  static const Color fondoClaro = Color(0xFFFCF7F5);
  static const Color splashRojo = Color(0xE6C32828);

  /// null = "Todas".
  TipoBebida? _filtro;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    // Solo los filtros que tienen al menos una bebida.
    final presentes = {for (final b in widget.bebidas) tipoDeBebida(b.nombre)};
    final visibles = [
      for (final b in widget.bebidas)
        if (_filtro == null || tipoDeBebida(b.nombre) == _filtro) b,
    ];
    final escala = MediaQuery.textScalerOf(context).scale(1);
    return Scaffold(
      backgroundColor: pal.fondo(fondoClaro),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 20, 4),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Volver',
                    icon: Icon(
                      Icons.arrow_back,
                      color: pal.texto(Colors.black87),
                    ),
                  ),
                  Text(
                    'Volver',
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      color: pal.texto(Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bebidas',
                    style: GoogleFonts.montserrat(
                      fontSize: 24,
                      color: pal.texto(Colors.black87),
                    ),
                  ),
                  Text(
                    'Adiciones para ${widget.nombreProducto}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: pal.texto(Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _chip(null, 'Todas'),
                      for (final tipo in TipoBebida.values)
                        if (presentes.contains(tipo))
                          _chip(tipo, tipo.etiqueta),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListenableBuilder(
                listenable: widget.elegidas,
                builder: (context, _) => GridView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  itemCount: visibles.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    // Como la cuadrícula de pizzas, algo más alta para el
                    // contador; crece con la letra del sistema.
                    childAspectRatio: escala <= 1
                        ? 0.55
                        : 0.55 / (1 + (escala - 1) * 0.4),
                  ),
                  itemBuilder: (context, i) => _TarjetaBebida(
                    key: ValueKey(visibles[i].id ?? visibles[i].nombre),
                    bebida: visibles[i],
                    elegidas: widget.elegidas,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(TipoBebida? tipo, String etiqueta) {
    final pal = context.pal;
    final elegido = _filtro == tipo;
    return ChoiceChip(
      label: Text(
        etiqueta,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: elegido ? Colors.white : pal.texto(Colors.black87),
        ),
      ),
      selected: elegido,
      showCheckmark: false,
      selectedColor: pal.rojoBoton(splashRojo),
      backgroundColor: pal.tarjeta(Colors.white),
      side: BorderSide(color: pal.borde(Colors.black12)),
      materialTapTargetSize: MaterialTapTargetSize.padded,
      onSelected: (_) => setState(() => _filtro = tipo),
    );
  }
}

/// Tarjeta de la cuadrícula, con el estilo de las de pizza.
class _TarjetaBebida extends StatelessWidget {
  const _TarjetaBebida({
    super.key,
    required this.bebida,
    required this.elegidas,
  });

  final ProductoCatalogo bebida;
  final AdicionesElegidas elegidas;

  static const Color splashRojo = Color(0xE6C32828);

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final precio = precioDeBebida(bebida);
    final tarjeta = Material(
      color: pal.tarjeta(Colors.white),
      // En oscuro, borde fino en lugar de sombra.
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: pal.oscuro
            ? const BorderSide(color: PaletaApp.bordeOscuro)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
        child: Column(
          children: [
            // La foto cede alto si el texto no cabe.
            Expanded(
              child: ImagenProducto(
                producto: bebida,
                width: double.infinity,
                fit: BoxFit.contain,
                respaldo: (context) => Icon(
                  Icons.local_drink,
                  color: pal.rojo(splashRojo),
                  size: 40,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              bebida.nombre,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: pal.texto(Colors.black87),
              ),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                precio,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: pal.secundario(Colors.black54),
                ),
              ),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: ContadorBebida(bebida: bebida, elegidas: elegidas),
            ),
          ],
        ),
      ),
    );
    return Semantics(
      container: true,
      label: '${bebida.nombre}, $precio, cantidad ${elegidas.de(bebida)}',
      child: bebida.estado == EstadoMenu.disponible
          ? tarjeta
          : Opacity(opacity: 0.5, child: tarjeta),
    );
  }
}
