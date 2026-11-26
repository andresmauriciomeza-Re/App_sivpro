import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../auth/permisos.dart';
import '../../shared/app_header.dart';
import '../../shared/initials.dart';
import '../../theme/paleta_app.dart';
import '../notificaciones/notificacion.dart';
import '../notificaciones/notificaciones_repository.dart';
import '../services/indicators_service.dart';
import '../services/ventas_repository.dart';
import 'purchases_screen.dart';

/// "Hace 5 min", "Hace 2 h", "Ayer" o la fecha corta del panel. [ahora] y
/// [fecha] son hora de Bogotá.
String fechaRelativa(DateTime fecha, DateTime ahora) {
  final diferencia = ahora.difference(fecha);
  if (diferencia.inMinutes < 1) return 'Ahora';
  if (diferencia.inMinutes < 60) return 'Hace ${diferencia.inMinutes} min';
  final hoy = DateTime(ahora.year, ahora.month, ahora.day);
  final dia = DateTime(fecha.year, fecha.month, fecha.day);
  if (dia == hoy) return 'Hace ${diferencia.inHours} h';
  if (hoy.difference(dia).inDays == 1) return 'Ayer';
  return formatFechaHoraVenta(
    '${fecha.year.toString().padLeft(4, '0')}-'
    '${fecha.month.toString().padLeft(2, '0')}-'
    '${fecha.day.toString().padLeft(2, '0')}',
  );
}

/// Notificaciones del panel (Administrador y Empleado).
class NotificacionesScreen extends StatefulWidget {
  const NotificacionesScreen({super.key});

  @override
  State<NotificacionesScreen> createState() => _NotificacionesScreenState();
}

class _NotificacionesScreenState extends State<NotificacionesScreen> {
  final NotificacionesRepository _repositorio =
      NotificacionesRepository.instance;
  List<Notificacion>? _lista;

  @override
  void initState() {
    super.initState();
    _repositorio.addListener(_leer);
    _leer();
  }

  @override
  void dispose() {
    _repositorio.removeListener(_leer);
    super.dispose();
  }

  Future<void> _leer() async {
    final lista = await _repositorio.listar();
    if (mounted) setState(() => _lista = lista);
  }

  Future<void> _abrir(Notificacion notificacion) async {
    await _repositorio.marcarLeida(notificacion.id);
    if (!mounted) return;
    final permitido = switch (notificacion.destino) {
      DestinoNotificacion.ventas => Permisos.moduloVentas,
      DestinoNotificacion.insumos => Permisos.comprasInsumos,
    };
    if (!permitido) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('No tienes acceso a ese módulo.')),
        );
      return;
    }
    switch (notificacion.destino) {
      case DestinoNotificacion.ventas:
        navigateToBottomModule(context, 3);
      case DestinoNotificacion.insumos:
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => insumosScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final lista = _lista;
    final sinLeer = lista?.any((n) => !n.leida) ?? false;
    final ahora = ahoraBogota();
    return Scaffold(
      backgroundColor: pal.fondo(PurchasesScreen.page),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppHeader(
              title: 'La Sirena Pizza',
              onBack: () => Navigator.of(context).pop(),
              initials: currentUserInitials(),
              mostrarCampana: false,
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _repositorio.refrescar,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(17, 20, 17, 24),
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Notificaciones',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.montserrat(
                              color: pal.texto(PurchasesScreen.ink),
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: TextButton(
                            onPressed: sinLeer
                                ? _repositorio.marcarTodasLeidas
                                : null,
                            style: TextButton.styleFrom(
                              foregroundColor: pal.rojo(PurchasesScreen.red),
                            ),
                            child: Text(
                              'Marcar todas como leídas',
                              textAlign: TextAlign.right,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (lista == null)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (lista.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 48),
                        child: Column(
                          children: [
                            Icon(
                              Icons.notifications_none,
                              size: 56,
                              color: pal.atenuado(
                                PurchasesScreen.muted.withValues(alpha: 0.5),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No tienes notificaciones.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                color: pal.secundario(PurchasesScreen.muted),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      for (final (i, n) in lista.indexed) ...[
                        if (i > 0)
                          Divider(
                            height: 1,
                            color: pal.borde(const Color(0xFFE1D8D6)),
                          ),
                        _FilaNotificacion(
                          notificacion: n,
                          ahora: ahora,
                          alTocar: () => _abrir(n),
                        ),
                      ],
                  ],
                ),
              ),
            ),
            const ModuleBottomNav(selected: 0),
          ],
        ),
      ),
    );
  }
}

class _FilaNotificacion extends StatelessWidget {
  const _FilaNotificacion({
    required this.notificacion,
    required this.ahora,
    required this.alTocar,
  });

  final Notificacion notificacion;
  final DateTime ahora;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final n = notificacion;
    final icono = n.destino == DestinoNotificacion.ventas
        ? Icons.receipt_long_outlined
        : Icons.inventory_2_outlined;
    return InkWell(
      onTap: alTocar,
      child: Opacity(
        opacity: n.leida ? 0.6 : 1,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: pal.tarjeta(Colors.white),
                  shape: BoxShape.circle,
                  border: Border.all(color: pal.borde(const Color(0xFFE1D8D6))),
                ),
                child: Icon(
                  icono,
                  size: 20,
                  color: pal.texto(PurchasesScreen.ink),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      n.titulo,
                      style: GoogleFonts.poppins(
                        color: pal.texto(PurchasesScreen.ink),
                        fontSize: 14,
                        fontWeight: n.leida ? FontWeight.w500 : FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      n.mensaje,
                      style: GoogleFonts.poppins(
                        color: pal.secundario(PurchasesScreen.muted),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      fechaRelativa(n.fecha, ahora),
                      style: GoogleFonts.poppins(
                        color: pal.secundario(PurchasesScreen.muted),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (!n.leida) ...[
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Semantics(
                    label: 'Sin leer',
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: pal.rojo(PurchasesScreen.red),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
