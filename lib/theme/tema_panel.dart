import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import '../auth/auth_service.dart';
import '../shared/gama_dispositivo.dart';
import '../shared/modo_oscuro_controller.dart';
import 'app_theme.dart';
import 'paleta_app.dart';

/// Regla única del modo oscuro (con la preferencia encendida):
/// - Administrador y Empleado: todo su panel.
/// - Cliente: sus pantallas, todas envueltas en [TemaCliente]; el tema base
///   de la app sigue en claro para él.
/// - Sin sesión (splash, login, registro, recuperar contraseña): claro.
bool temaOscuroActivo({
  required bool preferencia,
  required UserRole? rol,
  bool pantallaClienteMigrada = false,
}) =>
    preferencia &&
    switch (rol) {
      UserRole.admin || UserRole.empleado => true,
      UserRole.cliente => pantallaClienteMigrada,
      null => false,
    };

/// Barra de estado del modo oscuro (iconos claros). Al salir se restaura el
/// estilo claro en iOS; en Android no se fija nada en modo claro.
const SystemUiOverlayStyle barraEstadoOscura = SystemUiOverlayStyle(
  statusBarIconBrightness: Brightness.light,
  statusBarBrightness: Brightness.dark,
);
const SystemUiOverlayStyle barraEstadoClaraIos = SystemUiOverlayStyle(
  statusBarBrightness: Brightness.light,
);

/// Barra de estado clara (iconos oscuros) para las pantallas de acceso.
const SystemUiOverlayStyle _barraClara = SystemUiOverlayStyle(
  statusBarIconBrightness: Brightness.dark,
  statusBarBrightness: Brightness.light,
);

/// Mantiene en claro una pantalla de acceso (splash y login).
///
/// Al iniciar o restaurar una sesión de personal con modo oscuro, el tema
/// cambia mientras esa pantalla aún se ve saliendo; así no se oscurece. En
/// modo claro no altera nada.
class TemaSiempreClaro extends StatefulWidget {
  const TemaSiempreClaro({super.key, required this.child});

  final Widget child;

  @override
  State<TemaSiempreClaro> createState() => _TemaSiempreClaroState();
}

class _TemaSiempreClaroState extends State<TemaSiempreClaro> {
  /// Conserva el estado de la pantalla (campos, animaciones) al cambiar de modo.
  final GlobalKey _clave = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final contenido = Theme(
      key: _clave,
      data: AppTheme.claro,
      child: widget.child,
    );
    return context.pal.oscuro
        ? AnnotatedRegion<SystemUiOverlayStyle>(
            value: _barraClara,
            child: contenido,
          )
        : contenido;
  }
}

/// Pantalla del cliente: entra en modo oscuro con la preferencia encendida
/// (ver [temaOscuroActivo]). Toda pantalla nueva del cliente se envuelve en
/// ella. En claro no altera nada.
class TemaCliente extends StatefulWidget {
  const TemaCliente({super.key, required this.child});

  final Widget child;

  @override
  State<TemaCliente> createState() => _TemaClienteState();
}

class _TemaClienteState extends State<TemaCliente> {
  final Listenable _cambios = Listenable.merge([
    ModoOscuroController.instance.oscuro,
    AuthService.instance,
  ]);

  /// Conserva el estado de la pantalla (campos, barra) al cambiar de modo.
  final GlobalKey _clave = GlobalKey();
  bool _oscuro = false;

  /// Pantallas migradas montadas en oscuro. Al pasar de una oscura a otra, la
  /// vieja se desmonta después de pintar la nueva: la barra de estado solo
  /// vuelve a clara tras un cuadro en el que ya no queda ninguna.
  static int _oscuras = 0;

  void _marcarOscuro(bool oscuro) {
    if (oscuro == _oscuro) return;
    _oscuro = oscuro;
    _oscuras += oscuro ? 1 : -1;
    if (oscuro) return;
    WidgetsBinding.instance
      ..addPostFrameCallback((_) {
        if (_oscuras == 0) {
          SystemChrome.setSystemUIOverlayStyle(barraEstadoClaraIos);
        }
      })
      ..scheduleFrame();
  }

  @override
  void dispose() {
    _marcarOscuro(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _cambios,
      builder: (context, _) {
        final oscuro = temaOscuroActivo(
          preferencia: ModoOscuroController.instance.oscuro.value,
          rol: AuthService.instance.rol,
          pantallaClienteMigrada: true,
        );
        _marcarOscuro(oscuro);
        final contenido = AnimatedTheme(
          key: _clave,
          data: oscuro ? AppTheme.oscuro : AppTheme.claro,
          duration: GamaDispositivo.duracionTema,
          curve: Curves.easeInOut,
          child: widget.child,
        );
        return oscuro
            ? AnnotatedRegion<SystemUiOverlayStyle>(
                value: barraEstadoOscura,
                child: contenido,
              )
            : contenido;
      },
    );
  }
}
