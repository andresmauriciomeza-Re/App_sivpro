import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/modulos_moviles.dart';
import '../../shared/pending_sales_service.dart';
import '../../theme/paleta_app.dart';
import 'sales_pending_badge.dart';

/// Rojo de la píldora activa en modo claro (el de la barra del cliente).
const Color _rojoPildora = Color(0xE6C32828);

/// Separación horizontal entre ítems (y de la píldora con su ítem).
const double _hueco = 2;

/// Ítem de la barra inferior del Administrador y el Empleado.
@immutable
class ItemBarraAdmin {
  const ItemBarraAdmin({
    required this.id,
    required this.icono,
    required this.iconoActivo,
    required this.etiqueta,
    this.contador,
  });

  /// 0 Inicio, 1 Compras, 2 Producción, 3 Ventas, 4 Mi Perfil.
  final int id;
  final IconData icono;
  final IconData iconoActivo;
  final String etiqueta;

  /// Contador del badge numérico (solo se ve si es mayor que 0).
  final ValueListenable<int>? contador;
}

/// Ítems de la barra según los módulos del usuario: Inicio y Mi Perfil
/// siempre; Compras, Producción y Ventas solo si tiene ese módulo.
List<ItemBarraAdmin> itemsBarraAdmin(List<ModuloMovil> modulos) => [
  const ItemBarraAdmin(
    id: 0,
    icono: Icons.home_outlined,
    iconoActivo: Icons.home,
    etiqueta: 'Inicio',
  ),
  if (modulos.contains(ModuloMovil.compras))
    const ItemBarraAdmin(
      id: 1,
      icono: Icons.shopping_cart_outlined,
      iconoActivo: Icons.shopping_cart,
      etiqueta: 'Compras',
    ),
  if (modulos.contains(ModuloMovil.produccion))
    const ItemBarraAdmin(
      id: 2,
      icono: Icons.factory_outlined,
      iconoActivo: Icons.factory,
      etiqueta: 'Producción',
    ),
  if (modulos.contains(ModuloMovil.ventas))
    ItemBarraAdmin(
      id: adminSalesNavIndex,
      icono: Icons.receipt_long_outlined,
      iconoActivo: Icons.receipt_long,
      etiqueta: 'Ventas',
      contador: PendingSalesService.instance.count,
    ),
  const ItemBarraAdmin(
    id: 4,
    icono: Icons.person_outline,
    iconoActivo: Icons.person,
    etiqueta: 'Mi Perfil',
  ),
];

/// Barra inferior flotante en forma de píldora (mismo diseño que la del
/// cliente) con el ítem activo relleno de rojo.
///
/// Cada módulo es una pantalla nueva con su propia barra, así que la barra
/// recuerda el último ítem activo y, al aparecer (pantalla nueva o al volver
/// a una pantalla que estaba debajo, como Inicio), desliza la píldora desde
/// él hasta [seleccionado].
class BarraNavegacionAdmin extends StatefulWidget {
  const BarraNavegacionAdmin({
    super.key,
    required this.items,
    required this.seleccionado,
    required this.alTocar,
  });

  final List<ItemBarraAdmin> items;

  /// ID del ítem activo.
  final int seleccionado;

  /// Recibe el ID del ítem tocado.
  final ValueChanged<int> alTocar;

  static const Duration duracion = Duration(milliseconds: 260);

  /// Último ítem mostrado como activo, compartido por todas las barras.
  static int? _ultimo;

  /// Barras montadas: al llegar a 0 (cierre de sesión) se olvida [_ultimo].
  static int _montadas = 0;

  @override
  State<BarraNavegacionAdmin> createState() => _BarraNavegacionAdminState();
}

class _BarraNavegacionAdminState extends State<BarraNavegacionAdmin>
    with SingleTickerProviderStateMixin {
  late final AnimationController _control = AnimationController(
    vsync: this,
    duration: BarraNavegacionAdmin.duracion,
    value: 1,
  );
  late final Animation<double> _avance = CurvedAnimation(
    parent: _control,
    curve: Curves.easeOut,
  );

  /// ID desde el que se desliza la píldora; null si no hay deslizamiento.
  int? _desde;
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    BarraNavegacionAdmin._montadas++;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final visible = ModalRoute.isCurrentOf(context) ?? true;
    if (visible && !_visible) _alAparecer();
    _visible = visible;
  }

  @override
  void dispose() {
    _control.dispose();
    if (--BarraNavegacionAdmin._montadas == 0) {
      BarraNavegacionAdmin._ultimo = null;
    }
    super.dispose();
  }

  void _alAparecer() {
    final anterior = BarraNavegacionAdmin._ultimo;
    BarraNavegacionAdmin._ultimo = widget.seleccionado;
    final ids = widget.items.map((item) => item.id);
    final desliza =
        anterior != null &&
        anterior != widget.seleccionado &&
        ids.contains(anterior) &&
        ids.contains(widget.seleccionado) &&
        !MediaQuery.disableAnimationsOf(context);
    _desde = desliza ? anterior : null;
    if (desliza) {
      _control.forward(from: 0);
    } else {
      _control.value = 1;
    }
  }

  int _posicion(int id) => widget.items.indexWhere((item) => item.id == id);

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final destino = _posicion(widget.seleccionado);
    final origen = _desde == null ? destino : _posicion(_desde!);
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.15,
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Container(
            height: 64,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: pal.tarjeta(Colors.white),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: pal.sombra(Colors.black.withValues(alpha: 0.08)),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            // En oscuro, borde fino en lugar de sombra (sin restar alto).
            foregroundDecoration: pal.oscuro
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: PaletaApp.bordeOscuro),
                  )
                : null,
            child: LayoutBuilder(
              builder: (context, caja) {
                final ancho = caja.maxWidth / widget.items.length;
                return AnimatedBuilder(
                  animation: _avance,
                  builder: (context, _) {
                    final t = _avance.value;
                    final posicion = origen + (destino - origen) * t;
                    return Stack(
                      children: [
                        if (destino >= 0)
                          Positioned(
                            left: posicion * ancho + _hueco,
                            top: 0,
                            bottom: 0,
                            width: ancho - 2 * _hueco,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: pal.rojoBoton(_rojoPildora),
                                borderRadius: BorderRadius.circular(32),
                              ),
                            ),
                          ),
                        Positioned.fill(
                          child: Row(
                            children: [
                              for (var i = 0; i < widget.items.length; i++)
                                Expanded(
                                  child: _item(
                                    widget.items[i],
                                    activo: i == destino,
                                    cobertura: (1 - (posicion - i).abs()).clamp(
                                      0.0,
                                      1.0,
                                    ),
                                    t: t,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  /// [cobertura]: cuánto tapa la píldora este ítem (0 a 1); de ella sale el
  /// color, que pasa del gris inactivo al blanco a medida que llega.
  Widget _item(
    ItemBarraAdmin item, {
    required bool activo,
    required double cobertura,
    required double t,
  }) {
    final color = Color.lerp(
      context.pal.secundario(Colors.black38),
      Colors.white,
      cobertura,
    )!;
    Widget icono = Transform.scale(
      scale: activo ? 0.9 + 0.1 * t : 1,
      child: Icon(
        activo ? item.iconoActivo : item.icono,
        size: 22,
        color: color,
      ),
    );
    final contador = item.contador;
    if (contador != null) {
      icono = ValueListenableBuilder<int>(
        valueListenable: contador,
        child: icono,
        builder: (context, total, icono) => total <= 0
            ? icono!
            : Stack(
                clipBehavior: Clip.none,
                children: [
                  icono!,
                  Positioned(
                    top: -8,
                    right: -11,
                    child: SalesPendingBadge(count: total, invertido: activo),
                  ),
                ],
              ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _hueco),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => widget.alTocar(item.id),
        child: Semantics(
          button: true,
          selected: activo,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icono,
              const SizedBox(height: 3),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  item.etiqueta,
                  maxLines: 1,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: activo ? FontWeight.w600 : FontWeight.w400,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
