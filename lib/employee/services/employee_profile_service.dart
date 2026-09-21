import 'package:flutter/material.dart';
import '../../auth/login_screen.dart';
import '../../auth/auth_service.dart';

/// Información del empleado que inició sesión (estado local en memoria).
class EmployeeProfile {
  final String fullName;
  final String documentNumber;
  final String email;
  final String phone;

  const EmployeeProfile({
    required this.fullName,
    required this.documentNumber,
    required this.email,
    required this.phone,
  });

  EmployeeProfile copyWith({
    String? fullName,
    String? documentNumber,
    String? email,
    String? phone,
  }) {
    return EmployeeProfile(
      fullName: fullName ?? this.fullName,
      documentNumber: documentNumber ?? this.documentNumber,
      email: email ?? this.email,
      phone: phone ?? this.phone,
    );
  }

  /// Iniciales a partir del nombre (p. ej. "María González" -> "MG").
  String get initials {
    final parts = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  /// Primera inicial, usada en avatares más pequeños.
  String get initial {
    final trimmed = fullName.trim();
    return trimmed.isEmpty ? '?' : trimmed[0].toUpperCase();
  }
}

/// Única fuente de verdad del perfil del empleado mientras la app está abierta.
/// El usuario no tiene teléfono ni documento registrados, por eso se cargan
/// datos de ejemplo.
class EmployeeProfileService {
  EmployeeProfileService._();
  static final EmployeeProfileService instance = EmployeeProfileService._();

  EmployeeProfile _profile = const EmployeeProfile(
    fullName: 'María González',
    documentNumber: '1035467890',
    email: 'maria.gonzalez@gmail.com',
    phone: '3001234567',
  );

  EmployeeProfile get profile => _profile;

  void update({
    required String fullName,
    required String documentNumber,
    required String email,
    required String phone,
  }) {
    _profile = _profile.copyWith(
      fullName: fullName.trim(),
      documentNumber: documentNumber.trim(),
      email: email.trim(),
      phone: phone.trim(),
    );
  }
}

/// Diálogo de confirmación y cierre de sesión. Limpia la sesión y va al login
/// reconstruyendo el stack, así no se puede volver con el botón de atrás.
Future<void> confirmEmployeeSignOut(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Cerrar sesión'),
      content: const Text('¿Está seguro de que desea cerrar sesión?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          style: FilledButton.styleFrom(backgroundColor: const Color(0xFFC9151E)),
          child: const Text('Cerrar sesión'),
        ),
      ],
    ),
  );

  if (confirmed == true && context.mounted) {
    AuthService.instance.logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }
}