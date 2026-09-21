import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'login_screen.dart'; // ajusta si tu archivo se llama distinto
import 'package:flutter_native_splash/flutter_native_splash.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

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

/// Textura sutil de puntitos sobre el fondo.
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

/// Idea 2: ondas que salen del punto donde se toca la pantalla.
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

/// Idea 6: nube sutil de "polvo" cuando el logo aterriza (efecto sello).
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

  late final AnimationController _controller;
  late final Animation<double> _dotOpacity;
  late final Animation<double> _expandProgress;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoScale; // ahora con rebote (idea 6)
  late final Animation<double> _logoDropProgress; // idea 6: cae desde arriba
  late final Animation<double> _logoPosition;
  late final Animation<double> _bottomOpacity;

  // Botón con pulso
  late final AnimationController _pulseController;
  late final Animation<double> _pulseScale;

  // Idea 6: partículas de "polvo" al aterrizar el logo
  late final AnimationController _dustController;
  bool _dustPlayed = false;
  final List<Offset> _dustDirections = List.generate(14, (i) {
    final angle = (2 * pi / 14) * i;
    return Offset(cos(angle), sin(angle));
  });

  // Idea 2: ondas al tocar la pantalla
  final List<_RippleData> _ripples = [];
  final ValueNotifier<int> _rippleTick = ValueNotifier<int>(0);

  // Idea 1: el bloque de texto se aleja del dedo
  Offset? _globalPointerPos;
  final GlobalKey _textBlockKey = GlobalKey();

  // Ideas 3+7: logo con tilt 3D + jelly al arrastrar, con rebote elástico
  Offset _logoDrag = Offset.zero;
  late final AnimationController _logoSpringController;
  Animation<Offset>? _logoSpringAnim;

  // Idea 4 y 8: parallax + sombra según inclinación del celular.
  // Se usa un ValueNotifier para que solo la capa del logo se repinte.
  StreamSubscription<AccelerometerEvent>? _accelSub;
  final ValueNotifier<Offset> _tiltNotifier = ValueNotifier<Offset>(Offset.zero);
  bool _imagenesPrecargadas = false;

  // Modo ligero (solo release): si varios frames seguidos superan los 40 ms
  // en la fase de revelado, se apagan la textura de puntos, las ondas y el
  // polvo, y se cancela el acelerómetro para cuidar el 60 fps en gama baja.
  final Stopwatch _frameTimer = Stopwatch();
  int _framesPesadosConsecutivos = 0;
  bool _modoLigero = false;

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

    // Idea 6: el logo "rebota" al llegar, como un sello
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
      curve: const Interval(
        _tExpandEnd,
        _tLogoInEnd,
        curve: Curves.bounceOut,
      ),
    );

    _logoPosition = CurvedAnimation(
      parent: _controller,
      curve: const Interval(_tLogoInEnd, _tLogoUpEnd, curve: Curves.easeInOut),
    );

    _bottomOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(_tLogoUpEnd, 1.0, curve: Curves.easeOut),
    );

    // Dispara el "polvo" justo cuando el logo termina de aterrizar
    _controller.addListener(() {
      if (!_dustPlayed && _controller.value >= _tLogoInEnd) {
        _dustPlayed = true;
        _dustController.forward(from: 0);
      }
    });

    // Botón con pulso infinito
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseScale = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Polvo (idea 6)
    _dustController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Rebote elástico del logo al soltar el arrastre (ideas 3+7)
    _logoSpringController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 600),
        )..addListener(() {
          if (_logoSpringAnim != null) {
            setState(() => _logoDrag = _logoSpringAnim!.value);
          }
        });

    // Acelerómetro para parallax + sombra (ideas 4 y 8). Escribe en un
    // ValueNotifier para no disparar rebuilds de todo el árbol.
    _accelSub = accelerometerEventStream(
      samplingPeriod: SensorInterval.uiInterval,
    ).listen(
      (event) {
        if (!mounted) return;
        final tiltX = (event.x / 9.8).clamp(-1.0, 1.0);
        final tiltY = (event.y / 9.8).clamp(-1.0, 1.0);
        final tilt = _tiltNotifier.value;
        if ((tiltX - tilt.dx).abs() > 0.03 || (tiltY - tilt.dy).abs() > 0.03) {
          _tiltNotifier.value = Offset(tiltX, tiltY);
        }
      },
      onError: (_) {},
    );

    // Mide la duración de cada frame durante el revelado para poder activar
    // el modo ligero si el dispositivo no da a basto.
    _controller.addListener(_monitorearFluidez);
  }

  @override
  void dispose() {
    _controller.dispose();
    _frameTimer.stop();
    _pulseController.dispose();
    _dustController.dispose();
    _logoSpringController.dispose();
    _accelSub?.cancel();
    for (final r in _ripples) {
      r.controller.dispose();
    }
    _rippleTick.dispose();
    _tiltNotifier.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_imagenesPrecargadas) return;
    _imagenesPrecargadas = true;

    final media = MediaQuery.of(context);
    final size = media.size;
    final dpr = media.devicePixelRatio;

    // Precache con tope de 1440 px de ancho: suficiente para pantallas muy
    // grandes (p. ej. 1440 píxeles lógicos × 3x = 4320 reales), y evita
    // descodificar imágenes gigantes en tabletas o PC.
    final layoutR = _calcularLayout(size, media.padding);
    final providerFondo = ResizeImage(
      AssetImage('assets/img/fondo_splash_blanc4.png'),
      width: min(size.width * dpr, 1440.0).round(),
    );
    final providerLogo = ResizeImage(
      AssetImage('assets/img/logo_blanc7.png'),
      width: (layoutR.logoSize * dpr).round(),
    );

    Future<void> precargarImagenes() async {
      try {
        await Future.wait([
          precacheImage(providerFondo, context),
          precacheImage(providerLogo, context),
        ]).timeout(const Duration(seconds: 3));
      } catch (_) {
        // Si la precarga falla o excede el timeout, el splash se muestra
        // igualmente (las imágenes se cargan luego bajo demanda).
      }
      if (!mounted) return;
      FlutterNativeSplash.remove();
      _controller.forward();
    }

    precargarImagenes();
  }

  /// Calcula el layout para que el logo, el texto y el botón quepan sin
  /// solaparse: si el espacio vertical no alcanza, reduce el logo (mínimo
  /// 96) y los espacios entre bloques hasta que todo quepa.
  ({double logoSize, double logoTopFinal, double textTop, double buttonBottom, double buttonWidth})
      _calcularLayout(Size size, EdgeInsets padding) {
    final ancho = size.width;
    final alto = size.height;
    const buttonHeight = 58.0;
    final altoTexto = 30 * 1.15 * 1.15 + 14 + 14 * 1.15;

    final buttonBottom = padding.bottom + max(24.0, alto * 0.05);
    final logoTopFinal = padding.top + alto * 0.06;
    final buttonWidth = min(230.0, ancho - 64.0);

    double logoSize = min(
      ancho * 0.44,
      alto * 0.24,
    ).clamp(110.0, 190.0).toDouble();
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

  /// Modo ligero: mide cuánto tarda cada frame del controlador. Si se acumulan
  /// 3 frames seguidos de más de 40 ms durante el revelado (entre _tRightEnd y
  /// _tLogoInEnd), se apagan las capas decorativas para recuperar el 60 fps.
  /// No hace nada en modo debug (kDebugMode) para no interferir con el
  /// desarrollo ni con los tests.
  void _monitorearFluidez() {
    if (_modoLigero || kDebugMode) return;
    final elapsed = _frameTimer.elapsedMilliseconds;
    if (_frameTimer.isRunning) {
      if (elapsed > 40) {
        _framesPesadosConsecutivos++;
        if (_framesPesadosConsecutivos >= 3 &&
            _controller.value >= _tRightEnd &&
            _controller.value <= _tLogoInEnd) {
          _activarModoLigero();
          return;
        }
      } else {
        _framesPesadosConsecutivos = 0;
      }
    }
    _frameTimer
      ..reset()
      ..start();
  }

  void _activarModoLigero() {
    _modoLigero = true;
    _frameTimer.stop();
    _tiltNotifier.value = Offset.zero;
    _accelSub?.cancel();
    _accelSub = null;
    _controller.animateTo(
      1.0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  void _goToLogin() {
    HapticFeedback.lightImpact();
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
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

  // Idea 2: agrega una nueva onda en el punto tocado
  void _addRipple(Offset position) {
    if (_modoLigero) return;
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

  // Idea 1: el bloque de texto se aleja del dedo (como un solo bloque)
  Offset _computeTextRepel() {
    if (_globalPointerPos == null) return Offset.zero;
    final box = _textBlockKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.attached) return Offset.zero;
    final center = box.localToGlobal(box.size.center(Offset.zero));
    final delta = center - _globalPointerPos!;
    final distance = delta.distance;
    const radius = 170.0;
    if (distance > radius || distance == 0) return Offset.zero;
    final strength = (1 - distance / radius) * 18;
    final direction = Offset(delta.dx / distance, delta.dy / distance);
    return direction * strength;
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final size = media.size;
    final dpr = media.devicePixelRatio;
    final textScaler = media.textScaler.clamp(maxScaleFactor: 1.15);

    return MediaQuery(
      data: media.copyWith(textScaler: textScaler),
      child: _buildSplash(size, media.padding, dpr),
    );
  }

  Widget _buildSplash(Size size, EdgeInsets padding, double dpr) {
    final layout = _calcularLayout(size, padding);
    final logoSize = layout.logoSize;
    final logoTopFinal = layout.logoTopFinal;
    final textTop = layout.textTop;
    final buttonBottom = layout.buttonBottom;
    final buttonWidth = layout.buttonWidth;
    final logoCenteredTop = (size.height - logoSize) / 2;
    final logoDropY = (-size.height * 0.25) * (1 - _logoDropProgress.value);
    final textRepel = _computeTextRepel();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (event) {
          if (_controller.value < 0.95) return;
          _addRipple(event.localPosition);
          setState(() => _globalPointerPos = event.localPosition);
        },
        onPointerMove: (event) {
          if (_controller.value < 0.95) return;
          setState(() => _globalPointerPos = event.localPosition);
        },
        onPointerUp: (event) {
          setState(() => _globalPointerPos = null);
        },
        onPointerCancel: (event) {
          setState(() => _globalPointerPos = null);
        },
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final t = _controller.value;

            return Stack(
              children: [
                // Punto rojo: aparece en el centro y rebota entre los 4 lados
                if (t < _tExpandEnd)
                  Align(
                    alignment: _fallingDotAlignment(t),
                    child: Opacity(
                      opacity: _dotOpacity.value,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
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

                // El punto se expande revelando la foto de fondo completa
                // (blanco + ingredientes en una sola imagen)
                if (t >= _tRightEnd)
                  Positioned.fill(
                    child: RepaintBoundary(
                      child: ClipPath(
                        clipper: _CircleRevealClipper(_expandProgress.value),
                        child: Image(
                          image: ResizeImage(
                            AssetImage('assets/img/fondo_splash_blanc4.png'),
                            width: min(size.width * dpr, 1440.0).round(),
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),

                // Textura sutil de puntitos (se apaga en modo ligero). El
                // RepaintBoundary aísla su capa para no repintarla cada frame.
                if (t >= _tRightEnd && !_modoLigero)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: RepaintBoundary(
                        child: CustomPaint(painter: const _DotTexturePainter()),
                      ),
                    ),
                  ),

                // Idea 2: ondas al tocar la pantalla (se apagan en modo
                // ligero). El RepaintBoundary evita repintar toda la escena
                // cuando solo cambia una onda.
                if (t >= _tRightEnd && !_modoLigero)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: RepaintBoundary(
                        child: ValueListenableBuilder<int>(
                          valueListenable: _rippleTick,
                          builder: (context, _, _) {
                            return CustomPaint(
                              painter: _RipplePainter(List.of(_ripples)),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                // Logo: cae con rebote (idea 6), sube arriba, y reacciona
                // al arrastre con tilt 3D + jelly (ideas 3+7) y al
                // acelerómetro (ideas 4 y 8). El RepaintBoundary + el
                // ValueNotifier evitan repintar toda la escena al inclinar.
                Positioned(
                  top:
                      logoCenteredTop +
                      (logoTopFinal - logoCenteredTop) * _logoPosition.value +
                      logoDropY,
                  left: 0,
                  right: 0,
                  child: RepaintBoundary(
                    child: ValueListenableBuilder<Offset>(
                      valueListenable: _tiltNotifier,
                      builder: (context, tilt, _) {
                        return Center(
                          child: Opacity(
                            opacity: _logoOpacity.value,
                            child: GestureDetector(
                              onPanUpdate: (details) {
                                setState(() {
                                  _logoDrag = Offset(
                                    (_logoDrag.dx + details.delta.dx / 40)
                                        .clamp(-1.0, 1.0),
                                    (_logoDrag.dy + details.delta.dy / 40)
                                        .clamp(-1.0, 1.0),
                                  );
                                });
                              },
                              onPanEnd: (details) {
                                _logoSpringAnim =
                                    Tween<Offset>(
                                        begin: _logoDrag, end: Offset.zero)
                                    .chain(CurveTween(curve: Curves.elasticOut))
                                    .animate(_logoSpringController);
                                _logoSpringController.forward(from: 0);
                              },
                              child: Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()
                                  ..setEntry(3, 2, 0.0015)
                                  ..rotateX(-_logoDrag.dy * 0.4 - tilt.dy * 0.15)
                                  ..rotateY(_logoDrag.dx * 0.4 + tilt.dx * 0.15)
                                  ..rotateZ(_logoDrag.dx * 0.05)
                                  ..scaleByDouble(
                                    _logoScale.value,
                                    _logoScale.value,
                                    _logoScale.value,
                                    1.0,
                                  ),
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width: logoSize,
                                      height: logoSize,
                                      decoration: const BoxDecoration(
                                        color: Colors.transparent,
                                      ),
                                      child: Image(
                                        image: ResizeImage(
                                          AssetImage(
                                            'assets/img/logo_blanc7.png',
                                          ),
                                          width: (logoSize * dpr).round(),
                                        ),
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    // Idea 6: polvo al aterrizar
                                    // (desactivado en modo ligero)
                                    if (!_modoLigero)
                                      AnimatedBuilder(
                                        animation: _dustController,
                                        builder: (context, _) {
                                          return CustomPaint(
                                            size: Size(logoSize, logoSize),
                                            painter: _DustPainter(
                                              progress: _dustController.value,
                                              center: Offset(
                                                logoSize / 2,
                                                logoSize / 2,
                                              ),
                                              directions: _dustDirections,
                                            ),
                                          );
                                        },
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Texto + botón, pegados justo debajo del logo
                Positioned(
                  top: textTop,
                  left: 32,
                  right: 32,
                  child: Opacity(
                    opacity: _bottomOpacity.value,
                    child: IgnorePointer(
                      ignoring: t < 0.98,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Idea 1: el bloque de texto se aleja del dedo
                            AnimatedContainer(
                              key: _textBlockKey,
                              duration: const Duration(milliseconds: 260),
                              curve: Curves.easeOut,
                              transform: Matrix4.translationValues(
                                textRepel.dx,
                                textRepel.dy,
                                0,
                              ),
                              child: Text(
                                textAlign: TextAlign.center,
                                'Sabores que enamoran\ndesde 1994',
                                style: GoogleFonts.montserrat(
                                  color: const Color(0xFF1A1A1A),
                                  fontSize: 30,
                                  fontWeight: FontWeight.w400,
                                  height: 1.15,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
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
                      ),
                    ),
                  ),
                ),

                // Botón "Comenzar" en la parte inferior
                Positioned(
                  bottom: buttonBottom,
                  left: 32,
                  right: 32,
                  child: Opacity(
                    opacity: _bottomOpacity.value,
                    child: IgnorePointer(
                      ignoring: t < 0.98,
                      child: SizedBox(
                        width: double.infinity,
                        child: Center(
                          child: AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _pulseScale.value,
                                child: child,
                              );
                            },
                            child: Container(
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
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Comenzar',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(width: 18),
                                    const Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 25,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
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
}
