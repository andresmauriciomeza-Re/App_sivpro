import 'dart:ui';
import 'package:flutter/material.dart';
import '../employee/screens/employee_profile_screen.dart';
import '../employee/screens/employee_clients_screen.dart';
import '../employee/screens/employee_sales_management_screen.dart';
import '../employee/screens/employee_returns_screen.dart';

/// Nombre de ruta de la raíz de la sección Ventas (rol Empleado).
/// Permite volver a ella desde las pantallas internas de Devoluciones,
/// Clientes y Ventas usando [handleEmployeeBottomNav].
const String kVentasModulesRoute = '/ventas-empleado';

/// Nombre de ruta de la raíz de la sección Clientes (rol Empleado).
const String kClientesRoute = '/clientes-empleado';

/// Nombre de ruta de la raíz de la sección Devoluciones (rol Empleado).
const String kDevolucionesRoute = '/devoluciones-empleado';

/// Nombre de ruta de la raíz de la sección Perfil (rol Empleado).
const String kPerfilRoute = '/perfil-empleado';

/// Comportamiento de la barra inferior en las pantallas del rol Empleado.
/// - Inicio: lleva al dashboard (raíz del stack).
/// - Clientes: abre la pantalla de Clientes.
/// - Ventas: abre la Gestión de ventas.
/// - Devoluciones: abre el listado de Devoluciones.
/// - Perfil: abre directamente "Mi Perfil".
/// Cada sección se trae a foco si ya está en la pila o se abre encima de la
/// raíz, para que no se acumulen pantallas ni se rompa la flecha de volver.
void handleEmployeeBottomNav(BuildContext context, int index) {
  switch (index) {
    case 0:
      Navigator.of(context).popUntil((route) => route.isFirst);
      break;
    case 1:
      _openSection(context, kClientesRoute, const EmployeeClientsScreen());
      break;
    case 2:
      _openSection(
        context,
        kVentasModulesRoute,
        const EmployeeSalesManagementScreen(),
      );
      break;
    case 3:
      _openSection(context, kDevolucionesRoute, const EmployeeReturnsScreen());
      break;
    case 4:
      _openSection(context, kPerfilRoute, const EmployeeProfileScreen());
      break;
    default:
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Esta sección estará disponible próximamente.'),
        ),
      );
  }
}

/// Abre una sección del bottom nav sin duplicar pantallas: si ya existe una
/// ruta con [routeName] en la pila la trae a foco con [Navigator.popUntil];
/// si no, hace un push con ese nombre de ruta.
///
/// El recorrido se detiene en la primera ruta (la raíz del stack, el
/// dashboard) sin eliminarla, para que la flecha de volver y la opción
/// Inicio siempre aterricen en ella y nunca se quede el Navigator vacío.
void _openSection(BuildContext context, String routeName, Widget page) {
  final navigator = Navigator.of(context);
  var found = false;
  navigator.popUntil((route) {
    if (route.settings.name == routeName) {
      found = true;
      return true;
    }
    if (route.isFirst) {
      return true;
    }
    return false;
  });
  if (!found) {
    navigator.push(
      MaterialPageRoute<void>(
        settings: RouteSettings(name: routeName),
        builder: (_) => page,
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
