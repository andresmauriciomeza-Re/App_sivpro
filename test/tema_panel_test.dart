import 'dart:async';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sivpro_app/admin/widgets/barra_navegacion_admin.dart';
import 'package:sivpro_app/admin/widgets/sales_pending_badge.dart';
import 'package:sivpro_app/auth/login_screen.dart';
import 'package:sivpro_app/auth/models/usuario.dart';
import 'package:sivpro_app/auth/splash_screen.dart';
import 'package:sivpro_app/shared/modulos_moviles.dart';
import 'package:sivpro_app/shared/pending_sales_service.dart';
import 'package:sivpro_app/theme/app_theme.dart';
import 'package:sivpro_app/theme/paleta_app.dart';
import 'package:sivpro_app/theme/tema_panel.dart';

Future<bool> _sesionPendiente() => Completer<bool>().future;

/// Brillo del tema que ve el primer [Text] del árbol.
Brightness _brilloDe(WidgetTester tester, Finder dentro) => Theme.of(
  tester.element(
    find.descendant(of: dentro, matching: find.byType(Text)).first,
  ),
).brightness;

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
  tearDown(() => PendingSalesService.instance.count.value = 0);

  test('el modo oscuro aplica a Administrador y Empleado con la preferencia; '
      'sin sesión siempre claro; el Cliente solo en pantallas migradas', () {
    for (final rol in [UserRole.admin, UserRole.empleado]) {
      for (final migrada in [false, true]) {
        expect(
          temaOscuroActivo(
            preferencia: true,
            rol: rol,
            pantallaClienteMigrada: migrada,
          ),
          isTrue,
        );
        expect(
          temaOscuroActivo(
            preferencia: false,
            rol: rol,
            pantallaClienteMigrada: migrada,
          ),
          isFalse,
        );
      }
    }
    for (final preferencia in [true, false]) {
      for (final migrada in [false, true]) {
        // Sin sesión: splash, login, registro y recuperar contraseña.
        expect(
          temaOscuroActivo(
            preferencia: preferencia,
            rol: null,
            pantallaClienteMigrada: migrada,
          ),
          isFalse,
        );
      }
      // Cliente fuera de [TemaCliente]: el tema base de la app (claro).
      expect(
        temaOscuroActivo(preferencia: preferencia, rol: UserRole.cliente),
        isFalse,
      );
    }
    expect(
      temaOscuroActivo(
        preferencia: true,
        rol: UserRole.cliente,
        pantallaClienteMigrada: true,
      ),
      isTrue,
    );
    expect(
      temaOscuroActivo(
        preferencia: false,
        rol: UserRole.cliente,
        pantallaClienteMigrada: true,
      ),
      isFalse,
    );
  });

  group('TemaSiempreClaro', () {
    testWidgets('en oscuro deja la pantalla en claro con barra de estado '
        'clara', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.oscuro,
          home: const TemaSiempreClaro(child: Scaffold(body: Text('acceso'))),
        ),
      );
      expect(_brilloDe(tester, find.byType(Scaffold)), Brightness.light);
      expect(
        Theme.of(tester.element(find.text('acceso'))).extension<PaletaApp>(),
        same(PaletaApp.claro),
      );
      final region = tester.widget<AnnotatedRegion<SystemUiOverlayStyle>>(
        find.byType(AnnotatedRegion<SystemUiOverlayStyle>),
      );
      expect(region.value.statusBarIconBrightness, Brightness.dark);
    });

    testWidgets('en claro no cambia nada (mismo tema, sin barra propia)', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.claro,
          home: const Scaffold(body: Text('acceso')),
        ),
      );
      final sinEnvoltorio = Theme.of(tester.element(find.text('acceso')));
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.claro,
          home: const TemaSiempreClaro(child: Scaffold(body: Text('acceso'))),
        ),
      );
      expect(Theme.of(tester.element(find.text('acceso'))), sinEnvoltorio);
      expect(find.byType(AnnotatedRegion<SystemUiOverlayStyle>), findsNothing);
    });

    testWidgets('al cambiar de modo conserva lo escrito en la pantalla', (
      tester,
    ) async {
      final tema = ValueNotifier<ThemeData>(AppTheme.claro);
      await tester.pumpWidget(
        ValueListenableBuilder<ThemeData>(
          valueListenable: tema,
          builder: (context, valor, _) => MaterialApp(
            theme: valor,
            home: const TemaSiempreClaro(child: Scaffold(body: TextField())),
          ),
        ),
      );
      await tester.enterText(find.byType(TextField), 'empleado@lasirena.com');
      final antes = tester.state(find.byType(EditableText));

      tema.value = AppTheme.oscuro;
      await tester.pumpAndSettle();
      expect(find.text('empleado@lasirena.com'), findsOneWidget);
      expect(tester.state(find.byType(EditableText)), same(antes));
    });
  });

  testWidgets('login y splash se ven en claro aunque el tema sea oscuro', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.oscuro, home: const LoginScreen()),
    );
    await tester.pump(const Duration(seconds: 2));
    expect(_brilloDe(tester, find.byType(LoginScreen)), Brightness.light);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.oscuro,
        home: const SplashScreen(
          restaurarSesion: _sesionPendiente,
          usarSensores: false,
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 4));
    await tester.pump(const Duration(seconds: 5));
    expect(_brilloDe(tester, find.byType(SplashScreen)), Brightness.light);
  });

  testWidgets('los campos miden lo mismo en claro y en oscuro', (tester) async {
    Future<(Size, Size)> medir(ThemeData tema) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: tema,
          home: const Scaffold(
            body: Column(
              children: [
                TextField(
                  key: Key('borde'),
                  decoration: InputDecoration(
                    labelText: 'Observación',
                    border: OutlineInputBorder(),
                  ),
                ),
                TextField(
                  key: Key('normal'),
                  decoration: InputDecoration(labelText: 'Nombre'),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      return (
        tester.getSize(find.byKey(const Key('borde'))),
        tester.getSize(find.byKey(const Key('normal'))),
      );
    }

    final claro = await medir(AppTheme.claro);
    final oscuro = await medir(AppTheme.oscuro);
    expect(oscuro, claro);
    expect(AppTheme.oscuro.inputDecorationTheme.enabledBorder, isNull);
    expect(AppTheme.oscuro.inputDecorationTheme.border, isNull);
  });

  group('barra del Empleado en oscuro', () {
    final empleados = <String, (List<ModuloMovil>, List<String>)>{
      'solo Ventas (3 ítems)': (
        const [ModuloMovil.ventas, ModuloMovil.indicadores],
        ['Inicio', 'Ventas', 'Mi Perfil'],
      ),
      'Compras y Producción (4 ítems)': (
        const [ModuloMovil.compras, ModuloMovil.produccion],
        ['Inicio', 'Compras', 'Producción', 'Mi Perfil'],
      ),
    };
    for (final MapEntry(key: nombre, value: (modulos, etiquetas))
        in empleados.entries) {
      testWidgets(nombre, (tester) async {
        PendingSalesService.instance.count.value = 4;
        tester.view.physicalSize = const Size(360, 700);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final items = itemsBarraAdmin(modulos);
        final activo = items[1].id;
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.oscuro,
            home: Scaffold(
              body: Align(
                alignment: Alignment.bottomCenter,
                child: BarraNavegacionAdmin(
                  items: items,
                  seleccionado: activo,
                  alTocar: (_) {},
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        for (final etiqueta in etiquetas) {
          expect(find.text(etiqueta), findsOneWidget);
        }

        final caja = tester
            .widgetList<Container>(
              find.descendant(
                of: find.byType(BarraNavegacionAdmin),
                matching: find.byType(Container),
              ),
            )
            .first;
        expect(
          (caja.decoration! as BoxDecoration).color,
          PaletaApp.tarjetaOscura,
        );
        expect(
          ((caja.foregroundDecoration! as BoxDecoration).border! as Border)
              .top
              .color,
          PaletaApp.bordeOscuro,
        );

        final pildora = find.byWidgetPredicate(
          (w) =>
              w is DecoratedBox &&
              w.decoration is BoxDecoration &&
              (w.decoration as BoxDecoration).color ==
                  PaletaApp.rojoBotonOscuro,
        );
        expect(
          tester.getSize(pildora).width,
          closeTo((360 - 32 - 12) / etiquetas.length - 4, 0.01),
        );
        expect(
          tester.widget<Icon>(find.byIcon(Icons.person_outline)).color,
          PaletaApp.secundarioOscuro,
        );

        final badge = find.byType(SalesPendingBadge);
        if (activo == adminSalesNavIndex) {
          final fondo = tester.widget<Container>(
            find.descendant(of: badge, matching: find.byType(Container)),
          );
          expect((fondo.decoration! as BoxDecoration).color, Colors.white);
        } else {
          expect(badge, findsNothing);
        }
      });
    }
  });
}
