import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/testing.dart';
import 'package:sivpro_app/auth/auth_service.dart';
import 'package:sivpro_app/auth/check_email_screen.dart';
import 'package:sivpro_app/auth/login_screen.dart';
import 'package:sivpro_app/auth/register_screen.dart';
import 'package:sivpro_app/network/api_client.dart';
import 'package:sivpro_app/shared/validators.dart';

import 'support/backend_falso.dart';

const _registroOk = {
  'usuario': {'id': 9, 'correo': 'ana.perez@empresa.co'},
  'pendienteVerificacion': true,
  'correoEnviado': true,
};

Future<void> _montar(WidgetTester tester, Widget pantalla) async {
  tester.view.physicalSize = const Size(900, 2200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(home: pantalla));
  await tester.pumpAndSettle();
}

Finder _campo(int i) => find.byType(TextFormField).at(i);

/// Llena el registro (documento, nombre, correo, teléfono, contraseña y
/// confirmación) con datos válidos para el backend.
Future<void> _llenarRegistro(
  WidgetTester tester, {
  String documento = '1020304050',
  String correo = 'Ana.Perez@Empresa.co',
}) async {
  await tester.enterText(_campo(0), documento);
  await tester.enterText(_campo(1), 'María José Núñez');
  await tester.enterText(_campo(2), correo);
  await tester.enterText(_campo(3), '3001234567');
  await tester.enterText(_campo(4), 'Clave1234');
  await tester.enterText(_campo(5), 'Clave1234');
  await tester.pump();
}

Future<void> _crearCuenta(WidgetTester tester) async {
  await tester.tap(find.widgetWithText(ElevatedButton, 'Crear cuenta'));
  await tester.pump();
  await tester.pump();
}

Future<void> _elegirTipo(WidgetTester tester, String etiqueta) async {
  await tester.tap(find.byType(DropdownButtonFormField<String>));
  await tester.pumpAndSettle();
  await tester.tap(find.text(etiqueta).last);
  await tester.pumpAndSettle();
}

void main() {
  late BackendFalso backend;

  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
  setUp(() => backend = BackendFalso());

  group('reglas locales del registro (iguales al backend)', () {
    test('número de documento según el tipo', () {
      const casos = {
        ('CC', '123456'): true,
        ('CC', '1234567890'): true,
        ('CC', '12345'): false,
        ('CC', '12345678901'): false,
        ('CE', '123456789012'): true,
        ('CE', '1234567890123'): false,
        ('PP', '123456'): true,
        ('PP', '123456789012'): true,
        ('PP', '12345'): false,
        ('CC', '12a456'): false,
      };
      for (final MapEntry(key: (tipo, numero), value: valido)
          in casos.entries) {
        expect(
          documentValidator(numero, tipo) == null,
          valido,
          reason: '$tipo $numero',
        );
      }
    });

    test('nombre', () {
      const casos = {
        'Ana': true,
        'María José Núñez': true,
        'Ñandú Güemes': true,
        'Ana ': true, // se envía recortado
        'Al': true,
        'A': false,
        'Ana  María': false,
        'Ana3': false,
        'Ana-María': false,
      };
      for (final MapEntry(key: nombre, value: valido) in casos.entries) {
        expect(nameValidator(nombre) == null, valido, reason: nombre);
      }
      expect(nameValidator('a' * 100), isNull);
      expect(nameValidator('a' * 101), isNotNull);
    });

    test('correo de cualquier dominio, máximo 60 caracteres', () {
      const casos = {
        'ana@gmail.com': true,
        'ana.perez@empresa.co': true,
        'ana_perez+promo@mi-dominio.com.co': true,
        'ANA%1@Correo.ORG': true,
        '.ana@correo.com': false,
        'ana.@correo.com': false,
        'ana perez@correo.com': false,
        'ana@correo': false,
        'ana@correo.c': false,
        'anacorreo.com': false,
      };
      for (final MapEntry(key: correo, value: valido) in casos.entries) {
        expect(emailValidator(correo) == null, valido, reason: correo);
      }
      final largo = '${'a' * 50}@correo.com'; // 61 caracteres
      expect(emailValidator(largo), 'Ingresa un correo válido y sin espacios.');
      expect(emailValidator('${'a' * 49}@correo.com'), isNull);
    });

    test('teléfono de 7 a 15 dígitos', () {
      expect(phoneValidator('1234567'), isNull);
      expect(phoneValidator('123456789012345'), isNull);
      expect(phoneValidator('123456'), isNotNull);
      expect(phoneValidator('1234567890123456'), isNotNull);
      expect(phoneValidator('300 123 4567'), isNotNull);
    });

    test('contraseña', () {
      const casos = {
        'Clave1234': true,
        'Ñandú2024': true, // Ñ cuenta como mayúscula
        'ÁRBOLé123': true,
        'clave1234': false, // sin mayúscula
        'CLAVE1234': false, // sin minúscula
        'ClaveSegura': false, // sin número
        'Clave 1234': false, // con espacio
        'Cla1': false, // corta
      };
      for (final MapEntry(key: clave, value: valida) in casos.entries) {
        expect(passwordValidator(clave) == null, valida, reason: clave);
      }
      expect(passwordValidator('Aa1${'b' * 69}'), isNull); // 72 caracteres
      expect(passwordValidator('Aa1${'b' * 70}'), isNotNull); // 73 caracteres
      // 70 caracteres pero 74 bytes en UTF-8.
      expect(passwordValidator('Aa1${'ñ' * 4}${'b' * 63}'), isNotNull);
      expect(confirmPasswordValidator('Clave1234', 'Clave1234'), isNull);
      expect(confirmPasswordValidator('Clave123', 'Clave1234'), isNotNull);
    });
  });

  group('pantalla de registro', () {
    testWidgets('envía exactamente los 6 campos, con PP para pasaporte, y '
        'pasa a "Revisa tu correo" sin iniciar sesión', (tester) async {
      backend.rutas['POST /auth/register'] = (_) => respuesta(_registroOk, 201);
      await _montar(tester, const RegisterScreen());
      await _elegirTipo(tester, 'Pasaporte');
      await _llenarRegistro(tester, documento: '123456789012');
      await _crearCuenta(tester);
      await tester.pumpAndSettle();

      final envio = backend.a('POST /auth/register').single;
      expect(backend.cuerpo(envio), {
        'tipoDocumento': 'PP',
        'numeroDocumento': '123456789012',
        'nombre': 'María José Núñez',
        'correo': 'ana.perez@empresa.co',
        'telefono': '3001234567',
        'contrasena': 'Clave1234',
      });
      expect(find.byType(CheckEmailScreen), findsOneWidget);
      expect(find.text('Revisa tu correo'), findsOneWidget);
      expect(find.textContaining('ana.perez@empresa.co'), findsOneWidget);
      expect(
        find.text(
          'No pudimos enviar el correo. Pulsa Reenviar para intentarlo de nuevo.',
        ),
        findsNothing,
      );
      expect(AuthService.instance.isAuthenticated, isFalse);
      expect(await const FlutterSecureStorage().readAll(), isEmpty);
    });

    testWidgets('al cambiar el tipo se revalida el número de documento', (
      tester,
    ) async {
      await _montar(tester, const RegisterScreen());
      await _elegirTipo(tester, 'Cédula de Extranjería');
      await tester.enterText(_campo(0), '123456789012');
      await tester.pump();
      expect(find.textContaining('entre 6 y'), findsNothing);

      await _elegirTipo(tester, 'Cédula de Ciudadanía');
      expect(
        find.text('El documento debe tener entre 6 y 10 dígitos'),
        findsOneWidget,
      );
    });

    for (final (estado, mensaje, campo) in [
      (400, 'El teléfono debe tener solo números, entre 7 y 15 dígitos.', 3),
      (409, 'Este correo ya está registrado.', 2),
      (409, 'Este documento ya está registrado.', 0),
      (
        429,
        'Alcanzaste el límite de 3 registros por hora desde esta conexión. '
            'Intenta de nuevo más tarde.',
        null,
      ),
    ]) {
      testWidgets('$estado muestra el mensaje del backend: $mensaje', (
        tester,
      ) async {
        backend.rutas['POST /auth/register'] = (_) =>
            errorBackend(estado, mensaje);
        await _montar(tester, const RegisterScreen());
        await _llenarRegistro(tester);
        await _crearCuenta(tester);

        expect(find.byType(CheckEmailScreen), findsNothing);
        if (campo == null) {
          expect(find.text(mensaje), findsOneWidget);
        } else {
          // En el aviso y resaltado bajo su campo.
          expect(find.text(mensaje), findsNWidgets(2));
          final error = find.descendant(
            of: _campo(campo),
            matching: find.text(mensaje),
          );
          expect(error, findsOneWidget);
        }
        expect(
          tester
              .widget<ElevatedButton>(
                find.widgetWithText(ElevatedButton, 'Crear cuenta'),
              )
              .onPressed,
          isNotNull,
        );
      });
    }

    testWidgets('sin conexión muestra el aviso de red', (tester) async {
      ApiClient.instance.clienteHttp = MockClient(
        (_) async => throw const SocketException('sin red'),
      );
      await _montar(tester, const RegisterScreen());
      await _llenarRegistro(tester);
      await _crearCuenta(tester);
      expect(
        find.text(
          'No se pudo crear la cuenta. Revisa tu conexión e inténtalo de nuevo.',
        ),
        findsOneWidget,
      );
    });
  });

  group('Revisa tu correo', () {
    testWidgets('avisa si el correo no salió; reenvía con cuenta regresiva y '
        'vuelve al login', (tester) async {
      backend.rutas['POST /auth/verificacion/reenviar'] = (_) => respuesta({
        'mensaje':
            'Si tu cuenta está pendiente, te enviamos un nuevo correo de '
            'confirmación.',
      });
      await _montar(
        tester,
        const CheckEmailScreen(
          correo: 'ana.perez@empresa.co',
          correoEnviado: false,
        ),
      );
      expect(
        find.text(
          'No pudimos enviar el correo. Pulsa Reenviar para intentarlo de nuevo.',
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Reenviar correo de confirmación'));
      await tester.pump();
      await tester.pump();
      final envio = backend.a('POST /auth/verificacion/reenviar').single;
      expect(backend.cuerpo(envio), {'correo': 'ana.perez@empresa.co'});
      expect(find.text('Reenviar en 60 s'), findsOneWidget);
      await tester.pump(const Duration(seconds: 60));
      expect(find.text('Reenviar correo de confirmación'), findsOneWidget);

      await tester.tap(find.text('Ir a iniciar sesión'));
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(CheckEmailScreen), findsNothing);
    });
  });
}
