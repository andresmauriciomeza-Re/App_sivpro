import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sivpro_app/auth/forgot_password_screen.dart';
import 'package:sivpro_app/auth/new_password_screen.dart';
import 'package:sivpro_app/auth/password_updated_screen.dart';
import 'package:sivpro_app/auth/verify_code_screen.dart';

import 'support/backend_falso.dart';

const _codigoEnviado =
    'Si el correo está registrado, enviamos un código de verificación.';

Future<void> _montar(WidgetTester tester, Widget pantalla) async {
  tester.view.physicalSize = const Size(900, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(home: pantalla));
}

/// Raíz (como el login) con la pantalla [pantalla] encima.
Future<void> _montarSobreRaiz(WidgetTester tester, Widget pantalla) async {
  await _montar(tester, const Scaffold(body: Text('raíz')));
  tester
      .state<NavigatorState>(find.byType(Navigator))
      .push(MaterialPageRoute<void>(builder: (_) => pantalla));
  await tester.pumpAndSettle();
}

Future<void> _cerrarAvisos(WidgetTester tester) async {
  tester
      .state<ScaffoldMessengerState>(find.byType(ScaffoldMessenger))
      .clearSnackBars();
  await tester.pumpAndSettle();
}

void main() {
  late BackendFalso backend;

  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
  setUp(() => backend = BackendFalso());

  group('1. solicitar el código', () {
    testWidgets('valida el formato del correo antes de llamar', (tester) async {
      await _montar(tester, const ForgotPasswordScreen());
      await tester.enterText(find.byType(TextField), 'ana@correo');
      await tester.tap(find.text('Enviar código'));
      await tester.pump();
      expect(
        find.text('Ingresa un correo válido y sin espacios.'),
        findsOneWidget,
      );
      expect(backend.peticiones, isEmpty);
    });

    testWidgets('envía el correo en minúsculas y pasa a verificar', (
      tester,
    ) async {
      backend.rutas['POST /auth/recuperar/solicitar'] = (_) =>
          respuesta({'mensaje': _codigoEnviado});
      await _montar(tester, const ForgotPasswordScreen());
      await tester.enterText(find.byType(TextField), '  Ana@Correo.COM ');
      await tester.tap(find.text('Enviar código'));
      await tester.pumpAndSettle();

      final envio = backend.a('POST /auth/recuperar/solicitar').single;
      expect(backend.cuerpo(envio), {'correo': 'ana@correo.com'});
      expect(
        tester.widget<VerifyCodeScreen>(find.byType(VerifyCodeScreen)).email,
        'ana@correo.com',
      );

      // Atrás conserva el correo escrito.
      tester.state<NavigatorState>(find.byType(Navigator)).pop();
      await tester.pumpAndSettle();
      expect(find.text('  Ana@Correo.COM '), findsOneWidget);
    });

    testWidgets('un 429 muestra el mensaje del backend y no avanza', (
      tester,
    ) async {
      const limite = 'Espera un momento antes de pedir otro código.';
      backend.rutas['POST /auth/recuperar/solicitar'] = (_) =>
          errorBackend(429, limite);
      await _montar(tester, const ForgotPasswordScreen());
      await tester.enterText(find.byType(TextField), 'ana@correo.com');
      await tester.tap(find.text('Enviar código'));
      await tester.pump();
      await tester.pump();
      expect(find.text(limite), findsOneWidget);
      expect(find.byType(VerifyCodeScreen), findsNothing);
      expect(find.text('Enviar código'), findsOneWidget); // sin carga colgada
    });
  });

  group('2. verificar el código', () {
    testWidgets('exige 6 dígitos y admite pegar el código', (tester) async {
      backend.rutas['POST /auth/recuperar/verificar'] = (_) =>
          respuesta({'valido': true});
      await _montar(tester, const VerifyCodeScreen(email: 'ana@correo.com'));

      await tester.enterText(find.byType(TextField).first, '12345');
      await tester.pump();
      // Se repartió en las cinco primeras casillas; falta una.
      await tester.tap(find.widgetWithText(ElevatedButton, 'Verificar código'));
      await tester.pump();
      expect(find.text('Ingresa los 6 dígitos del código.'), findsOneWidget);
      expect(backend.a('POST /auth/recuperar/verificar'), isEmpty);

      await tester.enterText(find.byType(TextField).first, '654321');
      await tester.pump();
      final casillas = tester.widgetList<TextField>(find.byType(TextField));
      expect(
        [for (final c in casillas) c.controller!.text],
        ['6', '5', '4', '3', '2', '1'],
      );

      await tester.tap(find.widgetWithText(ElevatedButton, 'Verificar código'));
      await tester.pumpAndSettle();
      final envio = backend.a('POST /auth/recuperar/verificar').single;
      expect(backend.cuerpo(envio), {
        'correo': 'ana@correo.com',
        'codigo': '654321',
      });
      final siguiente = tester.widget<NewPasswordScreen>(
        find.byType(NewPasswordScreen),
      );
      expect((siguiente.email, siguiente.codigo), ('ana@correo.com', '654321'));
      await tester.pump(const Duration(seconds: 30));
    });

    for (final (estado, mensaje) in [
      (400, 'El código es incorrecto o venció.'),
      (429, 'Demasiados intentos. Solicita un nuevo código.'),
    ]) {
      testWidgets('$estado al verificar muestra el mensaje y se puede '
          'reintentar', (tester) async {
        backend.rutas['POST /auth/recuperar/verificar'] = (_) =>
            errorBackend(estado, mensaje);
        await _montar(tester, const VerifyCodeScreen(email: 'ana@correo.com'));
        await tester.enterText(find.byType(TextField).first, '111111');
        await tester.tap(
          find.widgetWithText(ElevatedButton, 'Verificar código'),
        );
        await tester.pump();
        await tester.pump();
        expect(find.text(mensaje), findsOneWidget);
        expect(find.byType(NewPasswordScreen), findsNothing);
        expect(
          find.widgetWithText(ElevatedButton, 'Verificar código'),
          findsOneWidget,
        );
        await tester.pump(const Duration(seconds: 30));
      });
    }

    testWidgets('reenviar código espera 30 s y maneja el 429', (tester) async {
      const limite = 'Espera un momento antes de pedir otro código.';
      backend.rutas['POST /auth/recuperar/solicitar'] = (_) =>
          respuesta({'mensaje': _codigoEnviado});
      await _montar(tester, const VerifyCodeScreen(email: 'ana@correo.com'));

      // El código se acaba de pedir: hay que esperar 30 s.
      expect(find.text('Reenviar código en 30 s'), findsOneWidget);
      await tester.tap(find.text('Reenviar código en 30 s'));
      await tester.pump(const Duration(seconds: 30));
      expect(backend.peticiones, isEmpty);

      await tester.tap(find.text('Reenviar código'));
      await tester.pump();
      await tester.pump();
      expect(
        backend.cuerpo(backend.a('POST /auth/recuperar/solicitar').single),
        {'correo': 'ana@correo.com'},
      );
      expect(find.text(_codigoEnviado), findsOneWidget);
      expect(find.text('Reenviar código en 30 s'), findsOneWidget);

      await tester.pump(const Duration(seconds: 30));
      await _cerrarAvisos(tester);
      backend.rutas['POST /auth/recuperar/solicitar'] = (_) =>
          errorBackend(429, limite);
      await tester.tap(find.text('Reenviar código'));
      await tester.pump();
      await tester.pump();
      expect(find.text(limite), findsOneWidget);
      expect(find.text('Reenviar código en 30 s'), findsOneWidget);
      await tester.pump(const Duration(seconds: 30));
    });
  });

  group('3. nueva contraseña', () {
    Future<void> escribir(WidgetTester tester, String clave) async {
      await tester.enterText(find.byType(TextField).at(0), clave);
      await tester.enterText(find.byType(TextField).at(1), clave);
      await tester.pump();
    }

    testWidgets('con espacios se rechaza sin llamar al backend', (
      tester,
    ) async {
      await _montar(
        tester,
        const NewPasswordScreen(email: 'ana@correo.com', codigo: '654321'),
      );
      await escribir(tester, 'Clave 1234');
      await tester.tap(find.text('Cambiar contraseña'));
      await tester.pump();
      expect(
        find.text('La contraseña no cumple los requisitos.'),
        findsOneWidget,
      );
      expect(backend.peticiones, isEmpty);
    });

    testWidgets('con Ñ y tildes se acepta y vuelve al login sin pantallas '
        'intermedias', (tester) async {
      backend.rutas['POST /auth/recuperar/restablecer'] = (_) => respuesta({
        'mensaje': 'Tu contraseña fue actualizada correctamente.',
      });
      await _montarSobreRaiz(
        tester,
        const NewPasswordScreen(email: 'ana@correo.com', codigo: '654321'),
      );
      await escribir(tester, 'ÑANDÚcito2024');
      await tester.tap(find.text('Cambiar contraseña'));
      await tester.pumpAndSettle();

      expect(
        backend.cuerpo(backend.a('POST /auth/recuperar/restablecer').single),
        {
          'correo': 'ana@correo.com',
          'codigo': '654321',
          'contrasena': 'ÑANDÚcito2024',
        },
      );
      expect(find.byType(PasswordUpdatedScreen), findsOneWidget);

      // Atrás vuelve directo a la raíz (el login): no queda la de la clave.
      tester.state<NavigatorState>(find.byType(Navigator)).pop();
      await tester.pumpAndSettle();
      expect(find.text('raíz'), findsOneWidget);
      expect(find.byType(NewPasswordScreen), findsNothing);
    });
  });
}
