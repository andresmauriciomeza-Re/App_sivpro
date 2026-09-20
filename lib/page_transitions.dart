import 'dart:ui';
import 'package:flutter/material.dart';
import 'employee_more_screen.dart';

/// Nombre de ruta de la pantalla de módulos de Ventas (rol Empleado).
/// Permite volver a ella desde las pantallas internas de Devoluciones,
/// Clientes y Ventas usando [handleEmployeeBottomNav].
const String kVentasModulesRoute = '/ventas-empleado';

/// Comportamiento de la barra inferior en las pantallas internas del rol
/// Empleado (Devoluciones, Clientes, Ventas y detalle de venta).
/// - Inicio: lleva al dashboard (raíz del stack).
/// - Ventas: vuelve a la pantalla de módulos de Ventas.
/// - Más: abre la pantalla "Más".
/// - Compras / Producción: aviso de "próximamente".
void handleEmployeeBottomNav(BuildContext context, int index) {
  final navigator = Navigator.of(context);
  switch (index) {
    case 0:
      navigator.popUntil((route) => route.isFirst);
      break;
    case 3:
      navigator.popUntil(
        (route) =>
            route.settings.name == kVentasModulesRoute || route.isFirst,
      );
      break;
    case 4:
      navigator.push(
        MaterialPageRoute(builder: (_) => const EmployeeMoreScreen()),
      );
      break;
    default:
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Esta sección estará disponible próximamente.'),
        ),
      );
  }
}

Route<T> heroFadeRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionDuration: const Duration(milliseconds: 650),
    reverseTransitionDuration: const Duration(milliseconds: 500),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Curva con leve rebote, para el movimiento del contenido (idea 6)
      final bounceCurve = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeIn,
      );

      // Curva "limpia" (sin pasarse de 0-1), para blur/opacidad/cortina
      final cleanCurve = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );

      // --- Efectos de la pantalla que ENTRA ---
      final fade = Tween<double>(begin: 0.0, end: 1.0).animate(cleanCurve);
      final slide = Tween<Offset>(
        begin: const Offset(0, 0.08),
        end: Offset.zero,
      ).animate(bounceCurve);
      final scale = Tween<double>(begin: 0.94, end: 1.0).animate(bounceCurve);

      // Idea 1: blur de fondo que pasa de borroso a nítido
      final blurSigma = Tween<double>(begin: 6.0, end: 0.0).animate(cleanCurve);

      // Idea 2: destello oscuro que sube rápido y baja (como un flash)
      final darkenFlash = TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.25), weight: 30),
        TweenSequenceItem(tween: Tween(begin: 0.25, end: 0.0), weight: 70),
      ]).animate(cleanCurve);

      // Idea 5: cortina que revela el contenido desde el centro
      final curtain = Tween<double>(begin: 0.0, end: 1.0).animate(cleanCurve);

      // --- Efectos de la pantalla que SE VA (idea 4) ---
      final leavingSlide =
          Tween<Offset>(
            begin: Offset.zero,
            end: const Offset(-0.05, 0),
          ).animate(
            CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeOut),
          );
      final leavingDim = Tween<double>(begin: 0.0, end: 0.35).animate(
        CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeOut),
      );
      final leavingScale = Tween<double>(begin: 1.0, end: 0.96).animate(
        CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeOut),
      );

      // 1. Base: fade + slide + scale (con rebote)
      Widget content = FadeTransition(
        opacity: fade,
        child: SlideTransition(
          position: slide,
          child: ScaleTransition(scale: scale, child: child),
        ),
      );

      // 2. Idea 1: blur progresivo
      content = AnimatedBuilder(
        animation: blurSigma,
        builder: (context, c) {
          return ImageFiltered(
            imageFilter: ImageFilter.blur(
              sigmaX: blurSigma.value,
              sigmaY: blurSigma.value,
            ),
            child: c,
          );
        },
        child: content,
      );

      // 3. Idea 5: cortina que revela desde el centro
      content = AnimatedBuilder(
        animation: curtain,
        builder: (context, c) {
          return ClipRect(
            child: Align(
              alignment: Alignment.center,
              widthFactor: curtain.value.clamp(0.0, 1.0),
              child: c,
            ),
          );
        },
        child: content,
      );

      // 4. Idea 2: destello oscuro encima de todo
      content = Stack(
        children: [
          content,
          IgnorePointer(
            child: AnimatedBuilder(
              animation: darkenFlash,
              builder: (context, _) {
                return Container(
                  color: Colors.black.withValues(alpha: darkenFlash.value),
                );
              },
            ),
          ),
        ],
      );

      // 5. Idea 4: cómo se comporta ESTA pantalla cuando otra se abre encima
      content = SlideTransition(
        position: leavingSlide,
        child: ScaleTransition(
          scale: leavingScale,
          child: Stack(
            children: [
              content,
              IgnorePointer(
                child: AnimatedBuilder(
                  animation: leavingDim,
                  builder: (context, _) {
                    return Container(
                      color: Colors.black.withValues(alpha: leavingDim.value),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );

      return content;
    },
  );
}
