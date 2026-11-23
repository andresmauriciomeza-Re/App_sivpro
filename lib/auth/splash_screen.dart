import 'dart:async';
import 'dart:math';
import 'dart:ui' show FrameTiming;
import 'package:flutter/foundation.dart' show kDebugMode, visibleForTesting;
import 'package:flutter/scheduler.dart' show SchedulerBinding, TimingsCallback;
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'login_screen.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import '../admin/screens/purchases_screen.dart' show adminHomeScreen;
import '../client/screens/home_screen.dart';
import '../network/api_exception.dart';
import 'auth_service.dart';
import '../theme/tema_panel.dart';

/// Calidad de la animación del splash según el dispositivo.
///
/// - [alta]: animación completa (polvo, inclinación con acelerómetro,
///   ondas al tocar, pulso del botón y arrastre elástico del logo).
/// - [media]: animación completa sin acelerómetro ni polvo.
/// - [baja]: misma composición final con una animación mínima (el logo sube
///   y aparecen el texto y el botón en ~400 ms), sin efectos.
/// - [estatica]: sin animación (accesibilidad: "quitar animaciones").
/// La imagen final, los colores y la composición son iguales en todos.
enum NivelSplash { alta, media, baja, estatica }

/// Nivel inicial con señales disponibles sin dependencias: preferencia de
/// accesibilidad y resolución física. Durante la animación el nivel puede
/// bajar a [NivelSplash.baja] si los frames tardan demasiado.
NivelSplash nivelInicialSplash({
  required bool sinAnimaciones,
  required Size tamano,
  required double densidad,
}) {
  if (sinAnimaciones) return NivelSplash.estatica;
  final ladoCortoFisico = tamano.shortestSide * densidad;
  if (ladoCortoFisico < 600) return NivelSplash.baja;
  if (ladoCortoFisico < 1080) return NivelSplash.media;
  return NivelSplash.alta;
}

/// Posiciones del splash calculadas como fracciones de la pantalla.
typedef LayoutSplash = ({
  double logoSize,
  double logoTopFinal,
  double textTop,
  double buttonBottom,
  double buttonWidth,
});

/// Calcula el layout para que el logo, el texto y el botón quepan sin
/// solaparse: si el espacio vertical no alcanza, reduce el logo (mínimo
/// 96) y los espacios entre bloques hasta que todo quepa. Respeta los
/// insets (notch y barra de gestos) mediante [padding].
LayoutSplash calcularLayoutSplash(Size size, EdgeInsets padding) {
  final ancho = size.width;
  final alto = size.height;
  const buttonHeight = 58.0;
  // Alto estimado del bloque de texto: 2 líneas del título (30 px, altura
  // 1.15) + espacio + subtítulo, con la fuente del sistema limitada a 1.15x.
  final altoTexto = 2 * 30 * 1.15 * 1.15 + 14 + 14 * 1.5 * 1.15;

  final buttonBottom = padding.bottom + max(24.0, alto * 0.05);
  final logoTopFinal = padding.top + alto * 0.06;
  final buttonWidth = min(230.0, ancho - 64.0);

  double logoSize = min(ancho * 0.44, alto * 0.24).clamp(110.0, 190.0);
  double textGap = 32.0;

  double espacioLibre() =>
      (alto - buttonBottom - buttonHeight) -
      (logoTopFinal + logoSize + textGap + altoTexto);

  while (espacioLibre() < 12.0 && (logoSize > 96 || textGap > 20)) {
    if (logoSize > 96) {
      logoSize = max(96.0, logoSize - 4);
    } else if (textGap > 20) {
      textGap = max(20.0, textGap - 2);
    }
  }

  return (
    logoSize: logoSize,
    logoTopFinal: logoTopFinal,
    textTop: logoTopFinal + logoSize + textGap,
    buttonBottom: buttonBottom,
    buttonWidth: buttonWidth,
  );
}

const String _assetFondo = 'assets/img/fondo_splash_blanc4.jpg';
const String _assetLogo = 'assets/img/logo_blanc7.png';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    this.restaurarSesion,
    this.usarSensores = true,
  });

  /// Restauración de sesión; por defecto `AuthService.restoreSession`.
  /// Solo se reemplaza en pruebas.
  @visibleForTesting
  final Future<bool> Function()? restaurarSesion;

  /// Acelerómetro para la inclinación del logo (solo nivel alto). Las
  /// pruebas lo apagan porque no hay sensores.
  @visibleForTesting
  final bool usarSensores;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _CircleRevealClipper extends CustomClipper<Path> {
  final double progress;
  _CircleRevealClipper(this.progress);

  @override
  Path getClip(Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius =
        sqrt(size.width * size.width + size.height * size.height) / 2;
    final radius = maxRadius * progress;
    return Path()..addOval(Rect.fromCircle(center: center, radius: radius));
  }

  @override
  bool shouldReclip(covariant _CircleRevealClipper oldClipper) {
    return oldClipper.progress != progress;
  }
}

/// Textura sutil de puntitos sobre el fondo (se pinta una sola vez).
class _DotTexturePainter extends CustomPainter {
  const _DotTexturePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withValues(alpha: 0.04);
    const spacing = 26.0;
    for (double y = 0; y < size.height; y += spacing) {
      for (double x = 0; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), 1.4, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Ondas que salen del punto donde se toca la pantalla.
class _RippleData {
  final AnimationController controller;
  final Offset position;
  _RippleData({required this.controller, required this.position});
}

class _RipplePainter extends CustomPainter {
  final List<_RippleData> ripples;
  _RipplePainter(this.ripples);

  @override
  void paint(Canvas canvas, Size size) {
    for (final ripple in ripples) {
      final progress = ripple.controller.value;
      final radius = 170 * Curves.easeOut.transform(progress);
      final opacity = (1 - progress).clamp(0.0, 1.0) * 0.25;
      final paint = Paint()
        ..color = const Color(0xFFC32828).withValues(alpha: opacity);
      canvas.drawCircle(ripple.position, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RipplePainter oldDelegate) => true;
}

/// Nube sutil de "polvo" cuando el logo aterriza (efecto sello).
class _DustPainter extends CustomPainter {
  final double progress; // 0.0 a 1.0
  final Offset center;
  final List<Offset> directions;
  _DustPainter({
    required this.progress,
    required this.center,
    required this.directions,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final opacity = (1 - progress) * 0.4;
    final paint = Paint()
      ..color = const Color(0xFFC32828).withValues(alpha: opacity);
    for (final dir in directions) {
      final distance = 70 * progress;
      final pos = center + dir * distance;
      canvas.drawCircle(pos, 2.5 * (1 - progress) + 1, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DustPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  static const Color splashRojo = Color(0xE6C32828);
  static const Color splashRojoClaro = Color(0xFFB23A3A);
  static const Color splashRojoOscuro = Color(0xFF6E1414);

  // Línea de tiempo (fracciones de 0.0 a 1.0)
  static const double _tDotAppearEnd = 0.05;
  static const double _tTopEnd = 0.18;
  static const double _tLeftEnd = 0.31;
  static const double _tBottomEnd = 0.44;
  static const double _tRightEnd = 0.57;
  static const double _tExpandEnd = 0.72;
  static const double _tLogoInEnd = 0.85;
  static const double _tLogoUpEnd = 0.93;

  /// Tiempo mínimo del splash: corto, corre en paralelo con la sesión.
  static const Duration _esperaMinima = Duration(milliseconds: 600);

  /// Un frame que tarda más que esto se considera pesado.
  static const int _msFramePesado = 40;

  late final AnimationController _controller;
  late final Animation<double> _dotOpacity;
  late final Animation<double> _expandProgress;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoDropProgress;
  late final Animation<double> _logoPosition;
  late final Animation<double> _bottomOpacity;

  // Controladores opcionales: solo se crean en los niveles que los usan.
  AnimationController? _pulseController;
  Animation<double>? _pulseScale;
  AnimationController? _dustController;
  AnimationController? _springController;
  Animation<Offset>? _springAnim;
  bool _dustPlayed = false;

  final List<Offset> _dustDirections = List.generate(14, (i) {
    final angle = (2 * pi / 14) * i;
    return Offset(cos(angle), sin(angle));
  });

  // Ondas al tocar la pantalla.
  final List<_RippleData> _ripples = [];
  final ValueNotifier<int> _rippleTick = ValueNotifier<int>(0);

  // Estados que cambian con el dedo o el sensor: notificadores para no
  // reconstruir toda la pantalla en cada evento.
  final ValueNotifier<Offset?> _pointer = ValueNotifier<Offset?>(null);
  final ValueNotifier<Offset> _logoDrag = ValueNotifier<Offset>(Offset.zero);
  final ValueNotifier<Offset> _tilt = ValueNotifier<Offset>(Offset.zero);
  final GlobalKey _textBlockKey = GlobalKey();
  StreamSubscription<AccelerometerEvent>? _accelSub;

  NivelSplash _nivel = NivelSplash.media;
  bool _iniciado = false;
  TimingsCallback? _timingsCallback;
  int _framesMedidos = 0;
  int _framesPesados = 0;

  bool _restaurando = false;
  bool _errorDialogoAbierto = false;
  bool _navegando = false;

  bool get _conEfectos =>
      _nivel == NivelSplash.alta || _nivel == NivelSplash.media;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4800),
    );

    _dotOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, _tDotAppearEnd, curve: Curves.easeOut),
    );
    _expandProgress = CurvedAnimation(
      parent: _controller,
      curve: const Interval(_tRightEnd, _tExpandEnd, curve: Curves.easeIn),
    );
    _logoOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(_tExpandEnd, _tLogoInEnd, curve: Curves.easeOut),
    );
    // El logo "rebota" al llegar, como un sello.
    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          _tExpandEnd,
          _tLogoInEnd,
          curve: Curves.bounceOut,
        ),
      ),
    );
    _logoDropProgress = CurvedAnimation(
      parent: _controller,
      curve: const Interval(_tExpandEnd, _tLogoInEnd, curve: Curves.bounceOut),
    );
    _logoPosition = CurvedAnimation(
      parent: _controller,
      curve: const Interval(_tLogoInEnd, _tLogoUpEnd, curve: Curves.easeInOut),
    );
    _bottomOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(_tLogoUpEnd, 1.0, curve: Curves.easeOut),
    );

    _controller.addListener(_alAvanzar);

    // La sesión se restaura EN PARALELO con la animación.
    _restaurarSesion();
  }

  /// Dispara el polvo al aterrizar el logo y el pulso del botón cuando ya
  /// es visible (antes no se anima nada que no se vea).
  void _alAvanzar() {
    final t = _controller.value;
    if (!_dustPlayed && t >= _tLogoInEnd) {
      _dustPlayed = true;
      _dustController?.forward(from: 0);
    }
    if (_pulseController == null && _conEfectos && t >= _tLogoUpEnd) {
      final pulso = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1500),
      )..repeat(reverse: true);
      _pulseScale = Tween<double>(
        begin: 1.0,
        end: 1.04,
      ).animate(CurvedAnimation(parent: pulso, curve: Curves.easeInOut));
      setState(() => _pulseController = pulso);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_iniciado) return;
    _iniciado = true;

    final media = MediaQuery.of(context);
    _nivel = nivelInicialSplash(
      sinAnimaciones: media.disableAnimations,
      tamano: media.size,
      densidad: media.devicePixelRatio,
    );

    if (_nivel == NivelSplash.estatica) {
      // Composición final sin animación.
      _controller.value = 1.0;
    }
    if (_nivel == NivelSplash.alta) {
      _dustController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      );
      if (widget.usarSensores) _escucharAcelerometro();
    }
    // Medición real de frames para bajar de nivel si el equipo no da abasto
    // (no en debug: ahí los frames son lentos por diseño).
    if (_conEfectos && !kDebugMode) {
      _timingsCallback = _medirFrames;
      SchedulerBinding.instance.addTimingsCallback(_timingsCallback!);
    }

    _precargarYEmpezar(media);
  }

  /// Precarga las dos imágenes (al tamaño en que se muestran) antes de
  /// animar. Siempre retira el splash nativo, aunque esta pantalla ya se
  /// haya cerrado: si no, el primer frame quedaría congelado.
  Future<void> _precargarYEmpezar(MediaQueryData media) async {
    final layout = calcularLayoutSplash(media.size, media.padding);
    try {
      await Future.wait([
        precacheImage(_imagenFondo(media), context),
        precacheImage(_imagenLogo(layout.logoSize, media), context),
      ]).timeout(const Duration(seconds: 3));
    } catch (_) {
      // Si la precarga falla o excede el tiempo, el splash se muestra igual.
    }
    FlutterNativeSplash.remove();
    if (!mounted) return;
    switch (_nivel) {
      case NivelSplash.estatica:
        break;
      case NivelSplash.baja:
        _animacionMinima();
      case NivelSplash.alta:
      case NivelSplash.media:
        _controller.forward();
    }
  }

  ImageProvider _imagenFondo(MediaQueryData media) => ResizeImage(
    const AssetImage(_assetFondo),
    width: min(media.size.width * media.devicePixelRatio, 1440.0).round(),
  );

  ImageProvider _imagenLogo(double logoSize, MediaQueryData media) =>
      ResizeImage(
        const AssetImage(_assetLogo),
        width: (logoSize * media.devicePixelRatio).round(),
      );

  /// Nivel bajo: parte con el fondo revelado y el logo en el centro, y en
  /// ~400 ms sube el logo y aparecen el texto y el botón.
  void _animacionMinima() {
    if (_controller.value < _tLogoInEnd) _controller.value = _tLogoInEnd;
    _controller.animateTo(
      1.0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  void _escucharAcelerometro() {
    _accelSub =
        accelerometerEventStream(
          samplingPeriod: SensorInterval.uiInterval,
        ).listen((event) {
          if (!mounted) return;
          final tiltX = (event.x / 9.8).clamp(-1.0, 1.0);
          final tiltY = (event.y / 9.8).clamp(-1.0, 1.0);
          final tilt = _tilt.value;
          if ((tiltX - tilt.dx).abs() > 0.03 ||
              (tiltY - tilt.dy).abs() > 0.03) {
            _tilt.value = Offset(tiltX, tiltY);
          }
        }, onError: (_) {});
  }

  /// Gama baja automática: si 3 frames superan [_msFramePesado] ms en los
  /// primeros ~120 frames, se pasa a la animación mínima sin efectos.
  void _medirFrames(List<FrameTiming> timings) {
    for (final timing in timings) {
      _framesMedidos++;
      if (timing.totalSpan.inMilliseconds > _msFramePesado) _framesPesados++;
    }
    if (_framesPesados >= 3) {
      _quitarMedicion();
      if (mounted) _bajarANivelBajo();
    } else if (_framesMedidos >= 120) {
      _quitarMedicion();
    }
  }

  void _quitarMedicion() {
    final callback = _timingsCallback;
    if (callback == null) return;
    SchedulerBinding.instance.removeTimingsCallback(callback);
    _timingsCallback = null;
  }

  void _bajarANivelBajo() {
    _accelSub?.cancel();
    _accelSub = null;
    _tilt.value = Offset.zero;
    _pulseController?.dispose();
    _pulseController = null;
    _pulseScale = null;
    _dustController?.stop();
    setState(() => _nivel = NivelSplash.baja);
    if (!_controller.isCompleted) _animacionMinima();
  }

  Future<void> _restaurarSesion() async {
    if (_restaurando || _navegando) return;
    _restaurando = true;
    try {
      final restaurar =
          widget.restaurarSesion ?? AuthService.instance.restoreSession;
      final restauracion = restaurar();
      await Future<void>.delayed(_esperaMinima);
      final restaurada = await restauracion;
      _restaurando = false;
      if (!mounted) return;
      _navegando = true;
      if (restaurada) {
        _irAlPanel();
      } else {
        _goToLogin();
      }
    } on ApiException catch (error) {
      _restaurando = false;
      if (!mounted) return;
      await _mostrarErrorRestauracion(error.message);
    } catch (_) {
      // Error inesperado (no de red ni del backend): el splash no se queda
      // detenido; ofrece reintentar o ir al login.
      _restaurando = false;
      if (!mounted) return;
      await _mostrarErrorRestauracion('No se pudo completar la operación.');
    }
  }

  Future<void> _mostrarErrorRestauracion(String mensaje) async {
    if (_errorDialogoAbierto || !mounted) return;
    _errorDialogoAbierto = true;
    final reintentar = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sin conexión'),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Ir a iniciar sesión'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
    _errorDialogoAbierto = false;
    if (!mounted) return;
    if (reintentar == true) {
      await _restaurarSesion();
    } else {
      _goToLogin();
    }
  }

  void _irAlPanel() {
    // Rol no reconocido: no se deja una sesión abierta sin pantalla asignada.
    if (AuthService.instance.rol == null) {
      AuthService.instance.logout();
    }
    final pagina = switch (AuthService.instance.rol) {
      // Administrador y Empleado comparten el menú por permisos.
      UserRole.admin || UserRole.empleado => adminHomeScreen(),
      UserRole.cliente => const HomeScreen(),
      null => const LoginScreen(),
    };
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => pagina));
  }

  void _goToLogin() {
    HapticFeedback.lightImpact();
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  void dispose() {
    _quitarMedicion();
    FlutterNativeSplash.remove();
    _controller.dispose();
    _pulseController?.dispose();
    _dustController?.dispose();
    _springController?.dispose();
    _accelSub?.cancel();
    for (final r in _ripples) {
      r.controller.dispose();
    }
    _rippleTick.dispose();
    _pointer.dispose();
    _logoDrag.dispose();
    _tilt.dispose();
    super.dispose();
  }

  Alignment _fallingDotAlignment(double t) {
    Alignment fromEdge(double start, double end, Alignment edge) {
      final local = ((t - start) / (end - start)).clamp(0.0, 1.0);
      final eased = Curves.easeOut.transform(local);
      return Alignment.lerp(edge, Alignment.center, eased)!;
    }

    if (t < _tDotAppearEnd) {
      return Alignment.center;
    } else if (t < _tTopEnd) {
      return fromEdge(_tDotAppearEnd, _tTopEnd, const Alignment(0, -1.3));
    } else if (t < _tLeftEnd) {
      return fromEdge(_tTopEnd, _tLeftEnd, const Alignment(-1.3, 0));
    } else if (t < _tBottomEnd) {
      return fromEdge(_tLeftEnd, _tBottomEnd, const Alignment(0, 1.3));
    } else if (t < _tRightEnd) {
      return fromEdge(_tBottomEnd, _tRightEnd, const Alignment(1.3, 0));
    } else {
      return Alignment.center;
    }
  }

  // Agrega una nueva onda en el punto tocado.
  void _addRipple(Offset position) {
    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    late final _RippleData ripple;
    ripple = _RippleData(controller: controller, position: position);
    controller.addListener(() => _rippleTick.value++);
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _ripples.remove(ripple);
        controller.dispose();
        _rippleTick.value++;
      }
    });
    _ripples.add(ripple);
    controller.forward();
  }

  // El bloque de texto se aleja del dedo (como un solo bloque).
  Offset _computeTextRepel(Offset? pointer) {
    if (pointer == null) return Offset.zero;
    final box = _textBlockKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.attached) return Offset.zero;
    final center = box.localToGlobal(box.size.center(Offset.zero));
    final delta = center - pointer;
    final distance = delta.distance;
    const radius = 170.0;
    if (distance > radius || distance == 0) return Offset.zero;
    final strength = (1 - distance / radius) * 18;
    final direction = Offset(delta.dx / distance, delta.dy / distance);
    return direction * strength;
  }

  void _soltarLogo() {
    final spring = _springController ??= AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..addListener(() => _logoDrag.value = _springAnim!.value);
    _springAnim = Tween<Offset>(
      begin: _logoDrag.value,
      end: Offset.zero,
    ).chain(CurveTween(curve: Curves.elasticOut)).animate(spring);
    spring.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final textScaler = media.textScaler.clamp(maxScaleFactor: 1.15);
    return TemaSiempreClaro(
      child: MediaQuery(
        data: media.copyWith(textScaler: textScaler),
        child: _buildSplash(media),
      ),
    );
  }

  Widget _buildSplash(MediaQueryData media) {
    final size = media.size;
    final layout = calcularLayoutSplash(size, media.padding);
    final logoSize = layout.logoSize;
    final logoCenteredTop = (size.height - logoSize) / 2;
    final conEfectos = _conEfectos;

    // Partes estáticas: se crean una vez por build y el AnimatedBuilder las
    // reutiliza en cada frame sin reconstruirlas.
    final fondo = RepaintBoundary(
      child: Image(image: _imagenFondo(media), fit: BoxFit.cover),
    );
    final logoImagen = SizedBox(
      width: logoSize,
      height: logoSize,
      child: Image(image: _imagenLogo(logoSize, media), fit: BoxFit.contain),
    );
    final textos = _textos(conEfectos);
    final boton = RepaintBoundary(child: _boton(layout.buttonWidth));
    final logo = RepaintBoundary(child: _logo(logoImagen, logoSize));

    return Scaffold(
      backgroundColor: Colors.white,
      body: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (event) {
          if (!conEfectos || _controller.value < 0.95) return;
          _addRipple(event.localPosition);
          _pointer.value = event.localPosition;
        },
        onPointerMove: (event) {
          if (!conEfectos || _controller.value < 0.95) return;
          _pointer.value = event.localPosition;
        },
        onPointerUp: (_) => _pointer.value = null,
        onPointerCancel: (_) => _pointer.value = null,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = _controller.value;
            final logoDropY =
                (-size.height * 0.25) * (1 - _logoDropProgress.value);

            return Stack(
              children: [
                // Punto rojo: aparece en el centro y rebota entre los 4 lados
                if (t < _tExpandEnd)
                  Align(
                    alignment: _fallingDotAlignment(t),
                    child: Opacity(
                      opacity: _dotOpacity.value,
                      child: const SizedBox(
                        width: 36,
                        height: 36,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              center: Alignment(-0.3, -0.3),
                              radius: 0.9,
                              colors: [
                                splashRojoClaro,
                                splashRojo,
                                splashRojoOscuro,
                              ],
                              stops: [0.0, 0.55, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                // El punto se expande revelando la foto de fondo completa.
                if (t >= _tRightEnd)
                  Positioned.fill(
                    child: _expandProgress.value >= 1.0
                        ? fondo
                        : ClipPath(
                            clipper: _CircleRevealClipper(
                              _expandProgress.value,
                            ),
                            child: fondo,
                          ),
                  ),

                // Textura sutil de puntitos (estática, en todos los niveles).
                if (t >= _tRightEnd)
                  const Positioned.fill(
                    child: IgnorePointer(
                      child: RepaintBoundary(
                        child: CustomPaint(painter: _DotTexturePainter()),
                      ),
                    ),
                  ),

                // Ondas al tocar la pantalla (solo niveles alto y medio).
                if (t >= _tRightEnd && conEfectos)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: RepaintBoundary(
                        child: ValueListenableBuilder<int>(
                          valueListenable: _rippleTick,
                          builder: (context, _, _) => CustomPaint(
                            painter: _RipplePainter(List.of(_ripples)),
                          ),
                        ),
                      ),
                    ),
                  ),

                // Logo: cae con rebote, sube arriba y reacciona al arrastre
                // y (nivel alto) al acelerómetro.
                Positioned(
                  top:
                      logoCenteredTop +
                      (layout.logoTopFinal - logoCenteredTop) *
                          _logoPosition.value +
                      logoDropY,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Opacity(opacity: _logoOpacity.value, child: logo),
                  ),
                ),

                // Texto, justo debajo del logo
                Positioned(
                  top: layout.textTop,
                  left: 32,
                  right: 32,
                  child: Opacity(
                    opacity: _bottomOpacity.value,
                    child: IgnorePointer(ignoring: t < 0.98, child: textos),
                  ),
                ),

                // Botón "Comenzar" en la parte inferior
                Positioned(
                  bottom: layout.buttonBottom,
                  left: 32,
                  right: 32,
                  child: Opacity(
                    opacity: _bottomOpacity.value,
                    child: IgnorePointer(
                      ignoring: t < 0.98,
                      child: Center(child: boton),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Logo con rebote de escala; en niveles alto y medio se puede arrastrar
  /// (inclinación 3D + rebote elástico) y en el alto también se inclina con
  /// el acelerómetro.
  Widget _logo(Widget imagen, double logoSize) {
    if (!_conEfectos) {
      return AnimatedBuilder(
        animation: _logoScale,
        builder: (context, child) =>
            Transform.scale(scale: _logoScale.value, child: child),
        child: imagen,
      );
    }
    final polvo = _dustController;
    final contenido = Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        imagen,
        if (polvo != null)
          AnimatedBuilder(
            animation: polvo,
            builder: (context, _) => CustomPaint(
              size: Size(logoSize, logoSize),
              painter: _DustPainter(
                progress: polvo.value,
                center: Offset(logoSize / 2, logoSize / 2),
                directions: _dustDirections,
              ),
            ),
          ),
      ],
    );
    return GestureDetector(
      onPanUpdate: (details) {
        final drag = _logoDrag.value;
        _logoDrag.value = Offset(
          (drag.dx + details.delta.dx / 40).clamp(-1.0, 1.0),
          (drag.dy + details.delta.dy / 40).clamp(-1.0, 1.0),
        );
      },
      onPanEnd: (_) => _soltarLogo(),
      child: AnimatedBuilder(
        animation: Listenable.merge([_logoScale, _logoDrag, _tilt]),
        builder: (context, child) {
          final drag = _logoDrag.value;
          final tilt = _tilt.value;
          final escala = _logoScale.value;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0015)
              ..rotateX(-drag.dy * 0.4 - tilt.dy * 0.15)
              ..rotateY(drag.dx * 0.4 + tilt.dx * 0.15)
              ..rotateZ(drag.dx * 0.05)
              ..scaleByDouble(escala, escala, escala, 1.0),
            child: child,
          );
        },
        child: contenido,
      ),
    );
  }

  Widget _textos(bool conEfectos) {
    final titulo = Text(
      textAlign: TextAlign.center,
      'Sabores que enamoran\ndesde 1994',
      style: GoogleFonts.montserrat(
        color: const Color(0xFF1A1A1A),
        fontSize: 30,
        fontWeight: FontWeight.w400,
        height: 1.15,
        letterSpacing: 0.2,
      ),
    );
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // El bloque de texto se aleja del dedo (niveles alto y medio).
          if (conEfectos)
            ValueListenableBuilder<Offset?>(
              valueListenable: _pointer,
              builder: (context, pointer, child) {
                final repel = _computeTextRepel(pointer);
                return AnimatedContainer(
                  key: _textBlockKey,
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOut,
                  transform: Matrix4.translationValues(repel.dx, repel.dy, 0),
                  child: child,
                );
              },
              child: titulo,
            )
          else
            titulo,
          const SizedBox(height: 14),
          Text(
            'Tradición  ·  Calidad  ·  Pasión',
            style: GoogleFonts.poppins(
              color: const Color(0xFF1A1A1A),
              fontSize: 14,
              letterSpacing: 1.8,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _boton(double buttonWidth) {
    final boton = Container(
      width: buttonWidth,
      height: 58,
      decoration: BoxDecoration(
        color: const Color(0xFFF5EDE4),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _goToLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: const Color(0xFFB5161B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Comenzar',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 18),
              const Icon(Icons.arrow_forward_rounded, size: 25),
            ],
          ),
        ),
      ),
    );
    final pulso = _pulseScale;
    if (pulso == null) return boton;
    return AnimatedBuilder(
      animation: pulso,
      builder: (context, child) =>
          Transform.scale(scale: pulso.value, child: child),
      child: boton,
    );
  }
}
