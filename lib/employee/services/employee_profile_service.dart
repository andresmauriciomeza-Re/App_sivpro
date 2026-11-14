import 'package:material_ui/material_ui.dart';
import '../../auth/login_screen.dart';
import '../../auth/auth_service.dart';

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
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFC9151E),
          ),
          child: const Text('Cerrar sesión'),
        ),
      ],
    ),
  );

  if (confirmed == true && context.mounted) {
    await AuthService.instance.logout();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }
}
