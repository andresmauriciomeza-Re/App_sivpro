# Registro de errores — App_sivpro (La Sirena)

> **Fecha de auditoría:** 28 de septiembre de 2026
> **Alcance:** `lib/` (59 archivos Dart) + configuración de plataformas (Android, iOS, web) + higiene de git
> **Flutter:** 3.44.7 · **Dart:** 3.12.2

## Contexto importante

`flutter analyze` y `dart analyze` devuelven **0 errores y 0 advertencias**: el proyecto
**compila limpio**. Todos los problemas registrados aquí son de **ejecución**, **lógica de
negocio**, **configuración de plataforma** o **higiene del repositorio** — cosas que el
analizador estático no puede detectar.

**Convenciones de este documento:**

- Cada error tiene un ID estable (`C-`, `A-`, `M-`, `B-`) para poder referenciarlo.
- ✅ = verificado directamente (lectura del archivo + comprobación en disco).
- ⚠️ = detectado por auditoría de lectura del código; conviene confirmarlo al corregirlo.
- Los errores con la misma causa raíz se agrupan en un solo ítem, aunque afecten a varios archivos.

---

## Resumen

| Severidad | Cantidad | Significado |
| --------- | -------: | ----------- |
| 🔴 Crítico | 6 | Rompe el build, crashea al usuario o afecta dinero/seguridad |
| 🟠 Alto | 13 | Comportamiento incorrecto visible o pérdida de datos |
| 🟡 Medio | 24 | Incorrecciones funcionales secundarias |
| 🔵 Bajo | 15 | Higiene, código muerto, inconsistencias menores |
| **Total** | **58** | |

## Resumen por módulo

| Módulo | 🔴 | 🟠 | 🟡 | 🔵 | Total |
| ------ | -: | -: | -: | -: | ----: |
| `lib/auth/` | 3 | 3 | 3 | 0 | 9 |
| `lib/client/` | 2 | 4 | 11 | 4 | 21 |
| `lib/employee/` | 0 | 2 | 12 | 8 | 22 |
| `lib/admin/` | 0 | 2 | 9 | 3 | 14 |
| `lib/shared/` | 0 | 0 | 4 | 4 | 8 |
| Configuración / build / git | 1 | 2 | 8 | 4 | 15 |

> El mayor foco es **employee** (22) seguido de **client** (21). Ambos comparten el patrón de
> fondo: datos en memoria que se pierden o nunca se actualizan.

---

## Plan de ejecución sugerido

Los errores no son independientes. Respetar este orden evita repetir trabajo:

| Fase | Objetivo | Errores | Por qué en este orden |
| ----: | -------- | ------- | --------------------- |
| 1 | Que el proyecto **compile y arranque** | C-01, C-02, C-03 | Sin assets y sin Podfile nada más se puede probar |
| 2 | **Cobrar bien y no duplicar pedidos** | C-06, A-01 | Error de dinero; se nota en producción de inmediato |
| 3 | **No perder al usuario** (navegación) | A-04, A-12, A-13 | Cae al splash o pierde datos al navegar |
| 4 | **Autenticación real** | C-04, A-09, A-10, A-11 | La app "funciona" pero el acceso es falso |
| 5 | **Fugas y `setState` pós-`await`** | A-02, A-03, M-14, M-15 | Crashean de forma intermitente |
| 6 | **Persistencia de ediciones** | M-01, M-02 | El usuario "guarda" y el dato se pierde |
| 7 | **Datos coherentes** | M-03 … M-10 | Pantallas que se contradicen entre sí |
| 8 | **Publicación** (IDs, firma, git) | A-05, A-06, A-07, A-08, B-15 | Requisito para subir a las tiendas |
| 9 | **Limpieza y Release** | B-01 … B-14 | Optimización y mantenimiento |

---

# 🔴 Críticos (6)

### C-01 · Falta `ios/Podfile` — iOS no compila ✅

- **Módulo:** Configuración / build
- **Ubicación:** `ios/Podfile` (archivo inexistente)
- **Categoría:** build
- **Impacto:** No se pueden enlazar los 4 plugins nativos (`file_picker`, `sensors_plus`,
  `url_launcher_ios`, `path_provider_foundation`). **Todo `flutter build ios` / `flutter run`
  en iOS falla.**
- **Verificado:** ✅ `Test-Path ios/Podfile` → `False`. `ios/` solo contiene `.gitignore`,
  `Flutter/`, `Runner/`, `Runner.xcodeproj/`, `Runner.xcworkspace/`, `RunnerTests/`.
  Tampoco existe `Podfile.lock`.
- **Solución:** Crear `ios/Podfile` con `platform :ios, '13.0'`, los helpers `flutter_root` /
  `flutter_ios_podfile_setup` y el bloque `target 'Runner' do … flutter_install_all_ios_pods … end`.
  Luego `cd ios && pod install`.

### C-02 · Asset `Logo.png` inexistente — crashea el login ✅

- **Módulo:** `lib/auth/` · `lib/auth/login_screen.dart:314` · assets / crash
- **Impacto:** `Image.asset('assets/img/Logo.png')` lanza `Unable to load asset` → la pantalla
  de login nunca se dibuja. **Bloquea el acceso a la app.**
- **Verificado:** ✅ `Test-Path assets/img/Logo.png` → `False`. La carpeta contiene
  `logo_blanc7.png`, `icono_logo.png`, `fondo_splash_blanc4.png`.
- **Solución:** Agregar el archivo faltante al repositorio, o cambiar la línea 314 a
  `'assets/img/logo_blanc7.png'`.

### C-03 · Asset `Fondo2.jpeg` inexistente — banner roto en el inicio del cliente ✅

- **Módulo:** `lib/client/` · `lib/client/screens/home_screen.dart:173` · assets
- **Impacto:** El banner hero del inicio no carga. Hoy degrada al `errorBuilder` (contenedor
  oscuro plano), pero es un recurso roto silencioso.
- **Verificado:** ✅ `Test-Path assets/img/Fondo2.jpeg` → `False`. Confirmado en el grep de los
  57 usos de `assets/` en `lib/`.
- **Solución:** Agregar el archivo, o sustituir por uno existente, p. ej.
  `'assets/img/fondo_splash_blanc4.png'`.

### C-04 · "Cambiar contraseña" no cambia nada pero reporta éxito ✅

- **Módulo:** `lib/auth/` · `lib/auth/new_password_screen.dart:36-38` · auth / lógica
- **Código actual:**
  ```dart
  void _onCambiar() {
    Navigator.of(context).push(heroFadeRoute(const PasswordUpdatedScreen()));
  }
  ```
- **Impacto:** No valida la contraseña nueva, **no compara con la confirmación**, no escribe en
  `AuthService` y aun así muestra "contraseña actualizada". Las credenciales antiguas de
  `auth_service.dart:44-46` siguen funcionando.
- **Verificado:** ✅ Leído. `AuthService` no tiene ningún método `updatePassword`.
- **Solución:** Validar (mín. 6 caracteres, 1 mayúscula, 1 número) y comparar con la
  confirmación antes de navegar; agregar `updatePassword()` a `AuthService` y persistir.
  Requiere que `_cuentas` deje de ser `static const` (ver C-05).

### C-05 · Credenciales de los 3 roles en texto plano ✅

- **Módulo:** `lib/auth/` · `lib/auth/auth_service.dart:44-46` · security / secret
- **Código actual:**
  ```dart
  'gloria@lasirena.com':        _Cuenta('G123456', UserRole.admin),
  'maria.gonzalez@gmail.com':  _Cuenta('M123456', UserRole.empleado),
  'sebastianmorelo@gmail.com': _Cuenta('S123456', UserRole.cliente),
  ```
- **Impacto:** El mapa es `static const`, así que las contraseñas quedan embebidas en el binario
  y son recuperables decompilando la app publicada. Acceso administrativo trivial.
- **Verificado:** ✅ Leído. Se auditó el resto de `lib/` en busca de API keys, tokens y
  `client_secret`: **no hay otros secretos**.
- **Solución:** Mover la autenticación a un backend real. Mientras sea demo, no distribuir en
  release, o aislar las credenciales detrás de `--dart-define`.

### C-06 · El precio del producto no coincide con lo que cobra el carrito ✅

- **Módulo:** `lib/client/` · `product_detail_screen.dart:29-36` vs `cart_service.dart:33-36` · money
- **El detalle calcula:**
  ```dart
  int total = size.precio * _cantidad;
  for (final a in widget.item.adiciones) {
    total += a.precio * (_adicionesCantidad[a.nombre] ?? 0); // ← una sola vez
  }
  ```
- **El carrito cobra:** `int get subtotal => precioUnitario * cantidad;`
  donde `precioUnitario = precioBase + precioAdiciones`.
- **Impacto:** Con cantidad > 1 y adiciones seleccionadas, **el total mostrado es menor al real**.
  Ej.: tamaño $20.000 + adición $3.000 × 2 unidades → muestra $43.000, cobra $46.000.
- **Verificado:** ✅ Ambos getters leídos y comparados.
- **Solución:**
  ```dart
  int get _total {
    final size = widget.item.tamanos[_tamanoSeleccionado];
    int adiciones = 0;
    for (final a in widget.item.adiciones) {
      adiciones += a.precio * (_adicionesCantidad[a.nombre] ?? 0);
    }
    return (size.precio + adiciones) * _cantidad;
  }
  ```

---

# 🟠 Altos (13)

### A-01 · Números de pedido chocan cada 10 segundos ✅

- **Módulo:** `lib/client/` · `payment_method_screen.dart:376` y `transfer_data_screen.dart:99` · lógica
- **Código actual:** `'#ORD-${DateTime.now().millisecondsSinceEpoch % 10000}'`
- **Impacto:** Se repite cada 10 000 ms. Dos pedidos creados en la misma ventana comparten
  `numero`, y `OrdersRepository.byNumero` / `updateStatus` matchean el primero (el más nuevo):
  **se muestra o actualiza el pedido equivocado**.
- **Verificado:** ✅ Línea leída.
- **Solución:** ID monótono: `'#ORD-${DateTime.now().millisecondsSinceEpoch}'`. Además, hacer que
  `byNumero` falle ante duplicados o indexar por identidad en vez de por `numero`.

### A-02 · `setState()` después de `await` sin guardia `mounted` (2 archivos) ⚠️

- **Módulo:** `lib/client/` · `payment_method_screen.dart:325-336` · `transfer_data_screen.dart:130-141` · lifecycle
- **Impacto:** `_seleccionarComprobante` hace `setState` tras
  `await FilePicker.platform.pickFiles(...)` sin comprobar `mounted` (el `catch` sí lo tiene).
  Si el usuario cierra la hoja con el selector nativo abierto →
  **"setState() called after dispose()"**.
- **Solución:** Agregar `if (!mounted) return;` justo antes del
  `if (resultado != null …)` en ambos archivos.

### A-03 · `setState()` durante el layout en la paginación ⚠️

- **Módulo:** `lib/employee/`, `lib/admin/` · lifecycle
- **Ubicación:** `employee_clients_screen.dart:136-143` · `employee_sales_management_screen.dart:146-153` · `admin/…/clients.dart:202-209`
- **Impacto:** `NotificationListener<ScrollNotification>` también recibe
  `ScrollMetricsNotification`, que Flutter emite **durante el layout**. Si el umbral
  `pixels >= maxScrollExtent - 200` se cumple ahí (siempre cierto con `maxScrollExtent < 200`,
  p. ej. una lista filtrada de 6-10 tarjetas cortas) →
  **"setState() or markNeedsBuild() called during build"**.
- **Solución:**
  ```dart
  onNotification: (n) {
    if (n is! ScrollUpdateNotification) return false;
    if (n.metrics.extentAfter < 200) _loadMore();
    return false;
  },
  ```

### A-04 · La navegación del cliente devuelve al usuario al splash ✅

- **Módulo:** `lib/client/` · `profile_screen.dart:56-59` · `bottom_nav.dart:55-80` (usado en `cart_screen.dart:134`) · navegación
- **Impacto:** `main.dart:23` hace que `SplashScreen` sea `route.isFirst`, y
  `login_screen.dart:156` reemplaza Login con Home. Por eso:
  - `profile_screen.dart:58` → `popUntil((route) => route.isFirst)` manda al **splash** en vez
    de al dashboard desde el que se abrió la tienda.
  - `bottom_nav.dart` usa `pushReplacement` en cada pestaña, así que la flecha atrás del carrito
    y el gesto de Android sacan al **splash** en lugar de a otra pestaña.
- **Verificado:** ✅ `profile_screen.dart:58` leído; la cadena de rutas confirmada en
  `main.dart` y `login_screen.dart`.
- **Solución:** En `profile_screen.dart:58` usar `Navigator.of(context).pop()` (la tienda se
  apila sobre el dashboard con `push`). En `bottom_nav.dart:55` preservar la pila:
  ```dart
  Navigator.of(context).pushAndRemoveUntil(noAnimationRoute(_pageFor(index)), (r) => r.isFirst);
  ```
  y en `cart_screen.dart:134` reemplazar el `pop()` por un `pushAndRemoveUntil` a `HomeScreen`.

### A-05 · `applicationId` sigue siendo el placeholder de Flutter ✅

- **Módulo:** Configuración / Android · `android/app/build.gradle.kts:19` (y `namespace` en :8) · packaging
- **Impacto:** `com.example.sivpro_app` con el `// TODO: Specify your own unique Application ID`
  sin editar. **Google Play rechaza los paquetes `com.example.*`.**
- **Verificado:** ✅ Leído el archivo.
- **Solución:** `applicationId = "com.lasirena.sivpro"`, actualizar `namespace` y mover
  `MainActivity.kt` a `android/app/src/main/kotlin/com/lasirena/sivpro/`.

### A-06 · Bundle ID de iOS: placeholder e inconsistente con Android ⚠️

- **Módulo:** Configuración / iOS · packaging
- **Ubicación:** `ios/Runner.xcodeproj/project.pbxproj` · `macos/Runner/Configs/AppInfo.xcconfig`
- **Impacto:** `PRODUCT_BUNDLE_IDENTIFIER = com.example.sivproApp` (placeholder que **App Store
  rechaza**) y además no coincide con Android (`sivproApp` vs `sivpro_app`).
- **Solución:** Unificar en `com.lasirena.sivpro` en las dos ocurrencias de `project.pbxproj`
  y en `AppInfo.xcconfig`.

### A-07 · El build `release` se firma con la keystore de debug ✅

- **Módulo:** Configuración / Android · `android/app/build.gradle.kts:32` · build
- **Impacto:** `signingConfig = signingConfigs.getByName("debug")` en el bloque `release`.
  Los APK de producción quedan firmados con una clave pública y distribuida →
  **no se pueden subir a Play Store**.
- **Solución:** Crear un keystore real + `android/key.properties` (gitignored), declarar
  `signingConfigs { create("release") { … } }` y apuntar el bloque `release` a esa configuración.

### A-08 · `lib.zip` versionado en git con contenido obsoleto ✅

- **Módulo:** Higiene / git · `lib.zip` (raíz) · hygiene
- **Impacto:** Backup de 187 KB con 76 entradas frente a los 59 archivos actuales de `lib/`;
  **24 de ellos difieren en tamaño** respecto del código vivo. Contamina cualquier diff futuro.
- **Verificado:** ✅ `git ls-files --error-unmatch lib.zip` → `lib.zip` (está trackeado).
- **Solución:** `git rm --cached lib.zip`, borrar el archivo y añadir `lib.zip` / `*.zip` /
  `*.bak` al `.gitignore`.

### A-09 · El registro no comprueba que las contraseñas coincidan ⚠️

- **Módulo:** `lib/auth/` · `register_screen.dart:436-441` · validación
- **Impacto:** El validador de "Confirmar contraseña" solo revisa que no esté vacío, así que el
  formulario valida con dos contraseñas distintas y nada avisa al usuario.
- **Solución:** Comparar contra `_passwordController.text` y devolver
  `'Las contraseñas no coinciden'`.

### A-10 · La pantalla de código de verificación acepta cualquier valor ⚠️

- **Módulo:** `lib/auth/` · `verify_code_screen.dart:45-47` · validación
- **Impacto:** `_onVerificar` navega a la pantalla de contraseña sin comprobar que los 6 casillas
  estén llenas ni que el código coincida. **Todo el paso de verificación es sorteable.**
- **Solución:** Construir el código, exigir `length == 6` y compararlo con el generado;
  mostrar error y no navegar si no coincide.

### A-11 · "Continuar con Google/Apple" ejecuta el login normal ⚠️

- **Módulo:** `lib/auth/` · `login_screen.dart:476-542` (manejadores en 480 y 512; lógica en 237-240)
- **Impacto:** Ambos botones llaman a `_mostrarTerminosYContinuar`, cuyo "Aceptar" invoca
  `_onLogin()`. Valida lo que haya en los campos de correo y contraseña, así que **pulsar Google
  siempre produce "Correo o contraseña incorrectos"**.
- **Solución:** Quitar los dos botones, o conectarlos a un proveedor real
  (`google_sign_in` / `sign_in_with_apple`) y enrutar según el rol devuelto.

### A-12 · Las ventas del empleado se pierden al salir de la pantalla ⚠️

- **Módulo:** `lib/employee/` · `employee_sales_management_screen.dart:43-125` (declaración),
  128-131 (`dispose`), 336-363 (mutaciones) · data
- **Impacto:** `sales` es estado local del `State`, así que **todo cambio de estado y todo borrado
  se revierte** al hacer pop (cualquier toque de la barra inferior pasa por `popUntil`). La lista
  se reconstruye desde el hardcode original.
- **Solución:** Mover la lista a un `ChangeNotifier` singleton (igual que `ReturnService.instance`)
  o a `static final List<_Sale>`, siguiendo el patrón de `EmployeeClientsScreen.clients`.

### A-13 · `indexOf` sin guardia produce `RangeError` ⚠️

- **Módulo:** `lib/employee/` · `employee_sales_management_screen.dart:336-340` · crash
- **Código actual:** `final saleIndex = sales.indexOf(sale); sales[saleIndex] = sale.copyWith(status: status);`
- **Impacto:** Lanza `RangeError` si la venta ya no está en la lista (`indexOf` devuelve `-1`).
- **Solución:** `final i = sales.indexWhere((s) => s.index == sale.index); if (i == -1) return;`
  seguido de `sales[i] = sale.copyWith(status: status);`

---

# 🟡 Medios (24)

### M-01 · Los diálogos "Guardar" descartan todas las ediciones ⚠️

- **Módulo:** `lib/admin/`, `lib/employee/` · data

| Archivo | Línea | Qué se pierde |
| ------- | ----: | ------------- |
| `admin/…/clients.dart` | 791-811 | nombre, email, `active` |
| `admin/…/products.dart` | 1175-1182 | nombre, precio, stock, categoría |
| `admin/…/providers.dart` | 863-872 | teléfono, email, dirección, estado |
| `admin/…/production.dart` | 1095-1104 | fecha, hora, cantidad, estado, observación |
| `employee_clients_screen.dart` | 617-637, 945-966 | alta y edición de clientes |

- **Impacto:** Todos muestran "…actualizado correctamente" y hacen `pop()` sin escribir en el
  modelo. El usuario cree que guardó y el dato se pierde. Además `products.dart` no valida:
  acepta nombres vacíos y precios/stocks no numéricos o negativos.
- **Solución:** Validar con `int.tryParse` / `double.tryParse` antes de cerrar, mutar el elemento
  de la lista dentro de `setState`, y solo entonces mostrar el `SnackBar`. Requiere que `copyWith`
  acepte `name`/`email`.

### M-02 · Los "eliminar" no eliminan nada — listas `static const` ⚠️

- **Módulo:** `lib/admin/` · data
- **Ubicación:** `production.dart:13-19, 477-481, 504-536` · `products.dart:31-72, 471-475` ·
  `providers.dart:14-51, 458-464` · `supplies.dart:6-106, 430-446` · `purchase_management.dart:138, 323-333`
- **Impacto:** El borrado de órdenes, productos, proveedores e insumos, y el cambio de estado de
  compra, **solo muestran un `SnackBar` de éxito**. El elemento sigue en la lista porque el
  backing field es `static const` e inmutable. En `purchase_management.dart` además el destino
  está fijo en `'Recibido'` incluso para una orden anulada.
- **Solución:** Convertir a `static final List<…>` (o estado del `State`) y aplicar la mutación
  dentro del `setState` de la rama confirmada del diálogo.

### M-03 · Dos pantallas dan datos contradictorios de la misma venta ⚠️

- **Módulo:** `lib/employee/` · data
- **Ubicación:** `employee_dashboard_screen.dart:493-534` vs `employee_sales_management_screen.dart:43-125`
- **Impacto:** El mismo código de venta tiene montos y estados distintos según dónde se mire:
  - `VEN-2024-0156` → $144.000 / "En preparación" / Nequi  vs  $56.000 / "Por entregar" / Nequi
  - `VEN-2024-0155` → $92.000 / "Listo" / Efectivo  vs  $28.000 / "Por entregar" / Bancolombia
  - `VEN-2024-0153` → $156.000  vs  $32.000
- **Solución:** Extraer una única fuente de datos (`SalesRepository`) y renderizar ambas pantallas
  desde ella.

### M-04 · El detalle de venta muestra un producto hardcodeado ⚠️

- **Módulo:** `lib/admin/`, `lib/employee/` · data
- **Ubicación:** `admin/…/sales.dart:1975-1999, 2009-2023, 2059-2073` ·
  `employee_sale_detail_screen.dart:8-16, 195-219, 235-242`
- **Impacto:** Todas las ventas muestran "Margarita Clásica", "Cantidad: 2" y "$56.000" como
  línea y como total, sin importar qué venta se abra. Para `VEN-2024-0153` ($32.000, 2× Pizza
  Cañón) el detalle muestra un producto nunca vendido y un subtotal igual al total.
- **Solución:** Pasar `sale.products` al detalle y calcular el total con
  `items.fold(0, (s, e) => s + e.total)`.

### M-05 · El detalle de venta ignora el estado real ⚠️

- **Módulo:** `lib/employee/` · `employee_sale_detail_screen.dart:32`, 289-296 · lógica
- **Código actual:** `final status = returned ? 'Devolución' : 'Por entregar';`
- **Impacto:** La pantalla solo recibe un `bool returned`, así que **toda venta que no sea
  devolución se renderiza como "Por entregar"**, incluidas las que están "Por verificar" o
  "Completado". El historial además muestra "Por verificar" duplicado.
- **Solución:** Pasar `status: sale.status` en vez del booleano y usar
  `final status = widget.status;`.

### M-06 · `return_service` sobrescribe desde un registro viejo y admite doble resolución ⚠️

- **Módulo:** `lib/employee/` · `lib/employee/services/return_service.dart:112-126`
  (`resolveCanje`), 131-141 (`resolveMoney`) · data
- **Impacto:** Ambos métodos reconstruyen la entrada con `record.copyWith(...)` usando el
  **snapshot que envía el llamador** en vez de `_records[index]`, y no comprueban `isResuelta`.
  Resolver una devolución por segunda vez **borra en silencio los datos de la primera resolución**.
- **Solución:**
  ```dart
  final i = _records.indexWhere((r) => r.index == record.index);
  if (i == -1 || _records[i].isResuelta) return;
  _records[i] = _records[i].copyWith(status: 'resuelta', resolutionType: 'canje', …);
  ```

### M-07 · El resumen de producción son constantes fijas ⚠️

- **Módulo:** `lib/admin/` · `lib/admin/services/production_summary_service.dart:6-7`
  (usado en `admin_dashboard_screen.dart:75` y `production.dart:1348`) · data
- **Impacto:** "12 activas / 45 completadas" son constantes que nunca cambian y **contradicen los
  datos reales del módulo** (5 órdenes: 1 Completada, 1 En Proceso, 2 Pendiente, 1 Cancelada).
- **Solución:** Calcular con
  `orders.where((o) => o.status == 'Pendiente' || o.status == 'En Proceso').length`.

### M-08 · La gráfica de ventas tiene escala fija y etiqueta incorrecta ⚠️

- **Módulo:** `lib/admin/` · `admin_dashboard_screen.dart:505-514, 523` · lógica
- **Impacto:** El divisor de las barras está fijo en `450` mientras las etiquetas del eje se
  generan como `'$' + '${i * 100}k'` para `i = 0..4`, así que **la línea superior (450) queda
  etiquetada "$400k"**. El eje tampoco se reajusta por período.
- **Solución:** `final scale = (maxValue / 100).ceil() * 100;` y etiquetas
  `'\\$${i * scale ~/ 4}k'`.

### M-09 · Las ventas marcadas "Pérdida" cuentan como ingresos ⚠️

- **Módulo:** `lib/admin/` · `admin/…/sales.dart:1127-1201, 1779-1787` · lógica
- **Impacto:** El `PopupMenuButton` permite marcar "Venta" o "Pérdida" y la tarjeta se recolorea,
  pero **nada agrega o resta**: "Ventas hoy" del dashboard cuenta como ingreso una venta perdida.
- **Solución:** Filtrar `s.status == 'Venta'` antes de sumar los totales del dashboard y de
  cualquier agregado.

### M-10 · Perfil de empleado hardcodeado en 9 pantallas ⚠️

- **Módulo:** `lib/employee/` · data
- **Ubicación:** `employee_dashboard_screen.dart:37, 160` · `employee_sales_modules_screen.dart:98` ·
  `employee_sales_management_screen.dart:227` · `employee_returns_screen.dart:172, 737` ·
  `employee_refund_screen.dart:77` · `employee_exchange_screen.dart:80` ·
  `employee_sale_detail_screen.dart:43` · `employee_substitution_picker_screen.dart:92`
- **Impacto:** Todos los headers usan `getInitials('María González')` y el dashboard el saludo
  `'¡Buenos días, María! 👋'`. Tras editar el perfil en `EmployeeProfileScreen` (que sí lee
  `EmployeeProfileService.instance.profile`), **ninguna otra pantalla refleja el cambio**.
- **Solución:** Leer el valor vivo en cada punto; idealmente convertir `EmployeeProfileService`
  en `ChangeNotifier` y envolver los headers en `ListenableBuilder`.

### M-11 · El perfil del cliente tampoco persiste ni refresca el header ⚠️

- **Módulo:** `lib/client/` · `profile_screen.dart:31-37, 106, 126` · lógica
- **Impacto:** `_nombreController` / `_telefonoController` no tienen listener, así que el avatar y
  el nombre del header no se actualizan mientras se escribe; y nada escribe los valores editados
  de vuelta en `AuthService` — "Listo" descarta el cambio al navegar.
- **Solución:** Añadir `_nombreController.addListener(() => setState(() {}))` (quitándolo en
  `dispose`) y persistir en `AuthService` al togglear `_editando`.

### M-12 · El perfil de empleado no se limpia al cerrar sesión ⚠️

- **Módulo:** `lib/employee/` · `employee_profile_service.dart:91-97` (`confirmEmployeeSignOut`) · data
- **Impacto:** `AuthService.instance.logout()` borra la sesión, pero
  `EmployeeProfileService._profile` (línea 45) conserva nombre, documento, correo y teléfono.
  **El siguiente login en la misma sesión ve los datos del empleado anterior.**
- **Solución:** Agregar un `reset()` que restaure el `EmployeeProfile` por defecto y llamarlo
  tras el `logout()`.

### M-13 · La tarjeta de perfil de admin siempre muestra el nombre constante ⚠️

- **Módulo:** `lib/admin/` · `admin/…/admin_profile.dart:170, 190, 204` (guardado en 106-117) · data
- **Impacto:** La tarjeta renderiza la constante `_fullName` en el avatar, las iniciales y el
  título, así que el nombre guardado en `_savedName` / `_nameController` **nunca se ve**.
- **Solución:** Renderizar `_savedName` y `getInitials(_savedName)`.

### M-14 · Fuga de `TextEditingController` en la edición de producto ⚠️

- **Módulo:** `lib/admin/` · `products.dart:888-893` (creado en 888) · leak
- **Impacto:** `TextEditingController(text: 'https://image...')` se construye **dentro de
  `build`**: se crea uno nuevo en cada reconstrucción y nunca se libera. Además **se pierde lo que
  el usuario escriba** en "URL de imagen" (p. ej. al cambiar la categoría, que dispara `setState`
  en :934).
- **Solución:** Promoverlo a campo de estado (`late final`), inicializarlo en `initState`,
  liberarlo en el `dispose()` existente (:820) y pasar el controller al `_textField`.

### M-15 · Fuga de controllers en `_readOnlyField` ⚠️

- **Módulo:** `lib/admin/` · `production.dart:1182-1189` (controller en 1185; invocado en 1058 y 1063) · leak
- **Impacto:** `_readOnlyField` crea `TextEditingController(text: value)` dentro de `build`; se
  llama 2 veces por reconstrucción y cada `setState` (p. ej. el desplegable de estado en :1229)
  filtra 2 controllers más.
- **Solución:** Usar `TextFormField(initialValue: value, readOnly: true, …)` en lugar de un
  `TextField` con controller.

### M-16 · `notifyReady` se dispara para pedidos de otros usuarios ⚠️

- **Módulo:** `lib/shared/` · `orders_repository.dart:37-39` · lógica
- **Impacto:** `updateStatus` notifica cualquier pedido que pase a `listoParaRecoger`, **sin
  comprobar que sea del usuario en sesión**. Marcar el pedido de otro incrementa el badge
  `unreadCount` del cliente actual.
- **Solución:** Comparar con `AuthService.instance.currentEmail` (requiere que el pedido lleve
  su propietario).

### M-17 · Se puede crear un pedido con el carrito vacío ⚠️

- **Módulo:** `lib/client/` · `payment_method_screen.dart:347-399` · payment
- **Impacto:** `_enviarComprobante` solo valida el comprobante adjunto. Con carrito vacío inserta
  un `OrderModel` con `articulos: 0`, `total: 0`, `productos: []`.
- **Solución:** Al inicio del método,
  `if (CartService.instance.estaVacio) { …SnackBar('Tu carrito está vacío'); return; }`.

### M-18 · Doble toque genera pantallas y hojas duplicadas ⚠️

- **Módulo:** `lib/client/` · `payment_method_screen.dart:21-41, 207` · `cart_screen.dart:211` · payment
- **Impacto:** Ningún handler se autodeshabilita, así que un toque rápido apila varias rutas
  `PaymentMethodScreen` o abre dos `showModalBottomSheet`, dejando una hoja huérfana con un
  carrito obsoleto.
- **Solución:** Bandera `_abriendo` que se active en el handler y se libere en el
  `whenComplete` (con `mounted`).

### M-19 · El carrito no es reactivo en la pantalla de pago ⚠️

- **Módulo:** `lib/client/` · `payment_method_screen.dart:45, 86, 117` · lógica
- **Impacto:** Se lee `CartService.instance` directamente dentro de `build` sin `AnimatedBuilder`,
  así que "N artículos" y "Total a pagar" quedan congelados con el valor del momento en que se
  empujó la ruta, y desincronizados del snapshot de `_ModalTransferencia` (:28).
- **Solución:** Envolver el `Scaffold` en
  `AnimatedBuilder(animation: CartService.instance, builder: …)`.

### M-20 · Toda orden se muestra como "Aprobado" y el método de pago es fijo ⚠️

- **Módulo:** `lib/client/` · `order_detail_screen.dart:171` (estado), 372-379 (método), 109-113 (icono) · lógica
- **Impacto:** El chip renderiza `cancelado ? 'Cancelada' : 'Aprobado'`, así que un pedido en
  `pagoPendiente` muestra un reloj de arena junto a la palabra "Aprobado". Y la fila del método
  imprime siempre `'Transferencia'` aunque el icono derive de `order.metodoPago` y el pedido se
  haya pagado con Nequi.
- **Solución:** Usar `order.estado.texto` en :171 y `order.metodoPago` en :373.

### M-21 · El mapa y el geocodificado no tienen red de seguridad ⚠️

- **Módulo:** `lib/client/` · `order_detail_screen.dart:46-92` (geocodificación), 426 (fallback),
  446-451 (`TileLayer`), 653-655 (línea de tiempo) · network
- **Impacto:** Tres problemas encadenados:
  1. `_geocodificar()` lanza una petición **sin caché** a Nominatim en cada apertura → abrir
     varios detalles seguidos viola la política de 1 req/s y recibe **HTTP 403**; sin reintento,
     el usuario queda con el icono gris para siempre.
  2. El `TileLayer` no tiene `errorTileCallback`: si ArcGIS responde 403/429 o el dispositivo
     está offline, el mapa se ve vacío sin aviso.
  3. Cada paso de la línea de tiempo deriva su hora de
     `order.fecha.add(Duration(minutes: index * 5))`, así que **pasos que aún no han ocurrido
     muestran horas inventadas**.
- **Solución:** Cachear el punto resuelto en un campo estático y saltarse la petición; añadir
  `errorTileCallback` y un botón "Reintentar"; ocultar la hora del paso activo hasta que ocurra.

### M-22 · `addItem` nunca fusiona líneas idénticas ⚠️

- **Módulo:** `lib/client/` · `cart_service.dart:54-57` (id nuevo en `product_detail_screen.dart:287`) · cart
- **Impacto:** `addItem` siempre agrega al final y `product_detail_screen.dart:287` genera un
  `microsecondsSinceEpoch` nuevo, así que **agregar dos veces la misma combinación (producto +
  tamaño + adiciones) crea dos líneas** en vez de sumar la cantidad.
- **Solución:** Buscar una línea coincidente por nombre/tamaño/precio y, si existe, sumar
  `cantidad`; si no, agregar.

### M-23 · Menú: productos duplicados y descripciones copiadas ⚠️

- **Módulo:** `lib/shared/` · `menu_item.dart:98, 109, 120, 131, 142, 153, 193, 214, 225` (descripciones),
  171-187 (Lasañas) · mock-data
- **Impacto:** Seis de las ocho entradas de "Pizzas" comparten el texto *"El sabor del sur de
  Italia, con anchoas y alcaparras."* (incluidas "Pizza de Jamon con Queso", "Maicitos", "Pollo"
  y "Tocineta"); "Pizza Maicitos" y "Peperoni" en "Favoritas" llevan la descripción hawaiana; y
  "Pizza Pollo" en "Favoritas" describe camarones. En "Lasañas" hay **dos entradas llamadas
  "Lasaña Mixta"** con idéntica descripción, y la segunda carga `lasaña_pollo.png`.
- **Solución:** Corregir cada descripción, renombrar la segunda lasaña a "Lasaña de Pollo" y
  eliminar los duplicados entre "Pizzas" y "Favoritas" (`Pizza Pollo` 142 vs 191, `Maicitos` 119
  vs 213, `Peperoni` 130 vs 224, `pizza de hawaii` 97 vs `Pizza Hawaiana` 202).

### M-24 · Cálculos y presentation con bugs menores ⚠️

| Ubicación | Problema |
| --------- | -------- |
| `admin/…/production.dart:1064` (helper en 878-883, 1235-1239) | La etiqueta dice "(20 min antes de …)" pero `_startTime` **resta una hora** completa (`hour - 1`); además produce `"-1:00"` inválido para entregas a medianoche |
| `auth/forgot_password_screen.dart:25-29` | `_onEnviarCodigo` navega sin validar el correo: se llega a "Código enviado a" con la dirección vacía |
| `auth/login_screen.dart:42-44, 109-161, 388-407` | El checklist de requisitos de contraseña es **decorativo**: puede mostrarse todo en verde mientras `_onLogin` falla, y no condiciona nada |
| `auth/login_screen.dart:164-176, 189-197` | El diálogo de términos es un `Column` con ~500 caracteres y sin `SingleChildScrollView` → **`RenderFlex overflowed`** con escala de texto grande |
| `auth/register_screen.dart:83-91` | "Crear cuenta" solo muestra `SnackBar('Creando cuenta…')`: no crea la cuenta, no navega y **el mensaje queda permanentemente en pantalla** |
| `employee_sales_management_screen.dart:774-783, 814-829` | La fila "Cambiar estado:" del diálogo renderiza 5 chips **sin `onTap`**: el usuario no puede cambiar el estado desde ahí |
| `employee_sales_management_screen.dart:424-429, 625-643` | El campo "Productos" está marcado `required` pero se renderiza **sin controller** (ilegible) y el guardado no lo valida: un pedido puede crearse con 0 productos |
| `employee_sales_management_screen.dart:29-33, 237` | La búsqueda solo mira `customer`, aunque el hint promete "Buscar por #, cliente o producto…", y no normaliza acentos |
| `employee_dashboard_screen.dart:196-204, 209-211` | El contador "Devoluciones" suma `pendientes + resueltas` y rotula "pendientes por atender"; es un 3 constante que no baja al resolver |
| `employee_substitution_picker_screen.dart:89-94, 135-183` | `AppHeader` no recibe `onBack` y la barra inferior no está conectada a `handleEmployeeBottomNav` → **sin forma de cancelar** el flujo salvo el gesto del sistema |
| `client/product_detail_screen.dart:459-464` | `didUpdateWidget` solo sincroniza el texto cuando `!_focusNode.hasFocus`: con el campo enfocado, `+`/`-` cambian `_cantidad` pero **el número visible queda obsoleto** |
| `client/menu_screen.dart:282-287` | `entry.value.first` sin comprobar vacío: una categoría sin productos lanzaría `StateError: No element` (hoy solo lo evita que las 3 listas hardcodeadas tengan elementos) |
| `shared/pending_sales_service.dart:18-22` | **Código muerto**: `setPendingCount` nunca se llama y `count` nunca se lee; su comentario afirma sincronizarse desde `_SalesManagementScreenState`, lo cual no ocurre |
| `client/order_detail_screen.dart:518` | El `AppBottomNav` embebido hace `pushReplacement` y **destruye el detalle del pedido**, dejando la flecha atrás sin a dónde volver |
| `auth/new_password_screen.dart:36-38` | Sin validación previa (relacionado con C-04) |

---

# 🔵 Bajos (15)

### B-01 · `markAllRead` no limpia `lastReadyOrder`
- **Ubicación:** `lib/shared/client_notification_service.dart:15-22`
- **Problema:** Solo pone `unreadCount` en 0 y deja `lastReadyOrder` con el pedido viejo, así que
  cualquier rebuild que lo lea (p. ej. `bottom_nav.dart:259`) sigue viendo un pedido "listo"
  obsoleto.
- **Solución:** `void markAllRead() { if (unreadCount.value != 0) unreadCount.value = 0; lastReadyOrder.value = null; }`

### B-02 · El repositorio entrega la lista global mutable
- **Ubicación:** `lib/shared/orders_repository.dart:13` (lista en `client/models/order_model.dart:101`)
- **Problema:** `List<OrderModel> get orders => mockOrders` expone la lista viva: cualquier
  consumidor puede insertar/quitar sin `notifyListeners()` y la UI queda desincronizada.
- **Solución:** `List<OrderModel> get orders => List.unmodifiable(mockOrders);`

### B-03 · `AppSearchField` no reacciona a un cambio de controller
- **Ubicación:** `lib/shared/search.dart:83-99`
- **Problema:** El listener se registra en `initState` y se quita en `dispose`, pero no hay
  `didUpdateWidget`: si el padre pasa otro controller, el campo sigue escuchando (y limpiando) el
  viejo.
- **Solución:** Implementar `didUpdateWidget` para quitar el listener del controller anterior,
  añadirlo al nuevo y refrescar `_hasText`.

### B-04 · `buttonWidth` puede quedar negativo
- **Ubicación:** `lib/auth/splash_screen.dart:358` (usado en 802)
- **Problema:** `min(230.0, ancho - 64.0)` no tiene cota inferior: en una ventana de menos de
  64 px lógicos, `Container(width: …)` lanza una aserción de tamaño negativo.
- **Solución:** `final buttonWidth = max(0.0, min(230.0, ancho - 64.0));`

### B-05 · `_wastes` crece sin límite y nunca se lee
- **Ubicación:** `lib/admin/screens/purchases/supplies.dart:108, 430-437`
- **Problema:** Lista `static final` a la que se añade en cada borrado de insumo, que nunca se
  limpia ni acota y que **nada en la app lee**.
- **Solución:** Exponer los datos en una lista "Desperdicios", moverla al estado de la pantalla y
  acotarla; si es global, limpiar en el cierre de sesión.

### B-06 · `_clients` de admin es estado global del `State`
- **Ubicación:** `lib/admin/screens/purchases/clients.dart:48, 173-180`
- **Problema:** Al ser `static final`, `_toggleClientActive` muta estado de todo el proceso que
  sobrevive a la pantalla; al reabrir "Gestión Clientes" se ven datos ya toggulados y las
  tarjetas Total/Activos/Inactivos reflejan estado obsoleto.
- **Solución:** Convertirla en campo de instancia
  (`late final List<_Client> _clients = List.of(_seedClients);`) o moverla a un repositorio si se
  quiere persistencia.

### B-07 · Contadores que ignoran el filtro de búsqueda
- **Ubicación:** `admin/…/purchase_management.dart:52` · `products.dart:109` · `sales.dart:717` · `production.dart:52`
- **Problema:** El encabezado "N compras/ventas/productos/órdenes registradas" usa siempre la
  longitud sin filtrar mientras la lista de abajo sí está filtrada → el contador contradice los
  resultados visibles.
- **Solución:** Calcular la lista filtrada antes del `Column` y usar `filtered.length`.

### B-08 · Navegación del hub de módulos decidida por comparación de texto
- **Ubicación:** `lib/admin/screens/purchases/sales.dart:181-202` (módulos en 11-37)
- **Problema:** `onTap: title == 'Gestión Clientes' ? … : …` enruta comparando el rótulo visible:
  renombrar o agregar un módulo manda al usuario a la pantalla equivocada.
- **Solución:** Guardar el `Widget` destino (o un enum) en el propio registro `_modules`.

### B-09 · Fecha del dashboard hardcodeada
- **Ubicación:** `lib/employee/screens/employee_dashboard_screen.dart:45` ·
  `lib/admin/screens/admin_dashboard_screen.dart:67`
- **Problema:** `'Viernes, 18 De Septiembre De 2026'` es un literal, y además **no coincide** con
  las fechas de devolución mock (2024-01-16..18) del `ReturnService`.
- **Solución:** Calcularla en `build` a partir de `DateTime.now()`, o con
  `MaterialLocalizations.of(context).formatMediumDate`.

### B-10 · Chips de filtro con contadores que ignoran la búsqueda
- **Ubicación:** `lib/employee/screens/employee_returns_screen.dart:103-124` (vs 54-76)
- **Problema:** Los chips se construyen con `todos.length` / `pendientes.length` /
  `resueltas.length` sin filtrar, mientras la lista muestra `resultados`.
- **Solución:** Pasar los conteos filtrados.

### B-11 · Encabezado duplicado en gestión de devoluciones
- **Ubicación:** `lib/employee/screens/employee_returns_screen.dart:676-683` y 805-815
- **Problema:** `'¿Cómo se resuelve esta devolución?'` se renderiza dos veces en la misma pantalla.
- **Solución:** Eliminar una de las dos ocurrencias.

### B-12 · Controllers liberados con el diálogo aún montado
- **Ubicación:** `employee_clients_screen.dart:663-667, 992-996` · `employee_sales_management_screen.dart:669-673`
- **Problema:** `showDialog(…).whenComplete(() => controller.dispose())` libera los controllers
  cuando el `Future` del diálogo completa, **mientras el `TextField` sigue en el árbol** durante
  la transición de salida → "A TextEditingController was used after being disposed".
- **Solución:** Mover los controllers a un `StatefulWidget` que sea el contenido del diálogo y
  liberarlos en su `dispose()`, devolviendo los valores con `Navigator.pop`.

### B-13 · Paginación no se reinicia al cambiar la búsqueda
- **Ubicación:** `lib/employee/screens/employee_sales_management_screen.dart:27, 234`
- **Problema:** A diferencia de `EmployeeClientsScreen` (:376), `_visibleSales` conserva el valor
  acumulado por `_loadMore()`: tras cargar páginas y luego buscar, se muestran más filas que la
  primera página.
- **Solución:** `onChanged: (value) => setState(() { _query = value; _visibleSales = _pageSize; });`

### B-14 · Temporizador no cancelable en la pantalla de comprobante
- **Ubicación:** `lib/client/screens/receipt_sent_screen.dart:16-25`
- **Problema:** El `Timer` de 2 s del `initState` nunca se cancela en `dispose`: si el usuario
  pulsa "Ver mi pedido" manualmente, el callback pendiente igual empuja **un segundo
  `MyOrdersScreen`** durante la transición.
- **Solución:** Guardar el `Timer` en un campo y cancelarlo en `dispose()`.

### B-15 · Higiene de plataforma, git y dependencias

| Ubicación | Problema | Solución |
| --------- | -------- | -------- |
| `ios/Runner/Info.plist:10` | `CFBundleDisplayName` = `"Sivpro App"` mientras Android:4 usa `"La Sirena"` → la app se llama distinto según la plataforma | Poner `La Sirena` en `CFBundleDisplayName` y `CFBundleName` |
| `ios/Runner/Info.plist:62-73` | Permite `LandscapeLeft`/`LandscapeRight` mientras la UI es solo vertical y el manifest web fija `portrait-primary` | Quitar las dos entradas de `UISupportedInterfaceOrientations` (y de la variante `~ipad`) |
| `web/index.html:19, 30` | `<title>sivpro_app</title>` y `<meta description>` con el texto de plantilla | Poner el título y una descripción reales |
| `web/index.html:24` | Sin `<meta name="theme-color">` y con `apple-mobile-web-app-title` de plantilla | Cambiar el título a `La Sirena` y añadir `theme-color` |
| `web/manifest.json:2-8` | `name`/`short_name` = `sivpro_app`, descripción de plantilla, y `background_color`/`theme_color` en el azul `#0175C2` de Flutter (choca con el splash blanco) | Valores reales y `#FFFFFF` |
| `pubspec.yaml:3` | `description: "A new Flutter project."` (texto de plantilla, replicado en `README.md`) | Descripción real |
| `pubspec.yaml:9-10` | `environment:` no declara ningún mínimo de Flutter, aunque `pubspec.lock` registra `flutter: ">=3.44.0"` | Añadir `flutter: ">=3.44.0"` |
| `pubspec.yaml:41-45` | `flutter_native_splash` sin `image_path` → el splash nativo es un blanco vacío, pese a existir `fondo_splash_blanc4.png` y `logo_blanc7.png` | Añadir `image_path: "assets/img/logo_blanc7.png"` y reejecutar `dart run flutter_native_splash:create` |
| `pubspec.yaml:47-53` | `flutter_launcher_icons` sin clave `web:` → los iconos web siguen siendo los de Flutter | Añadir el bloque `web:` y reejecutar `dart run flutter_launcher_icons` |
| `pubspec.yaml` (fuentes) | `google_fonts` se usa en 35 lugares vía `GoogleFonts.montserrat/poppins`, pero **no hay sección `fonts:` ni ningún `.ttf` en el repo** → se descargan de `fonts.googleapis.com` en el primer arranque y **caen a la fuente del sistema sin internet** | Bajar los `.ttf` a `assets/fonts/`, declarar `fonts:` y usar `fontFamily` |
| `android/gradle.properties:4, 6` | `android.newDsl=false` y `android.builtInKotlin=false` deshabilitan el DSL nuevo de AGP 9.0.1, lo que rompe en el próximo salto de AGP | Quitar ambos flags y el bloque `subprojects { … }` de `android/build.gradle.kts:24-32` |
| `android/build.gradle.kts:1, 26, 29` | Importa `com.android.build.gradle.BaseExtension` (API legacy) y fuerza `compileSdk 36` a todos los subproyectos, pisando lo que declara cada plugin (`file_picker` 34, `jni` 35) | Borrar el import y el bloque `subprojects` |
| `assets/` (carpeta) | 38,4 MB en 22 archivos; los PNG de producto pesan 2,0-2,9 MB cada uno | Redimensionar a ~1024 px y reguardar como WebP (>90 % de reducción) |
| `.gitignore` + `android/build/reports/problems/problems-report.html` | Un artefacto generado de Gradle de 130 KB está versionado y `android/build/` no está ignorado | `git rm --cached …` y añadir `/android/build/`, `*.zip`, `*.bak` |
| `.metadata:11-19` | `migration.platforms` solo lista `root` y `web`: `android/`, `ios/`, `linux/`, `macos/` y `windows/` nunca se registran, así que `flutter migrate` no actualiza sus plantillas (y la revisión registrada no coincide con Flutter 3.44.7) | Añadir las cinco plataformas y ejecutar `flutter create --platforms=… .` |
| `pubspec.yaml:37-39` | `assets/images/` ya engloba `assets/images/products/` (declaración redundante) y conviven `assets/img/` y `assets/images/` para el mismo tipo de contenido | Colapsar a una sola nomenclatura |
| Archivos generados de plugin | 7 modificaciones sin commitear en `linux/flutter/generated_plugin_registrant.{cc,h}`, `generated_plugins.cmake`, `macos/Flutter/GeneratedPluginRegistrant.swift` y equivalentes de Windows | Commitear el estado actual y verificar que coincide con lo que regenera CI |

---

## Patrones sistémicos

Cinco problemas explican la mayoría de los ítems anteriores. Arreglarlos de raíz reduce el
conteo total mucho más que corregir caso por caso.

1. **Listas de datos mutables declaradas como `const` o locales al `State`.**
   Es la causa de A-12, M-01, M-02, B-05 y B-06. Mientras el backing store no se pueda mutar,
   todo "guardar", "eliminar" y "cambiar estado" es decorativo.
   → *Solución de fondo:* un único `ChangeNotifier` por dominio (patrón ya presente en
   `ReturnService.instance` y `CartService.instance`) del que las pantallas solo lean.

2. **Copy-paste de bloques de datos.** Duplicados en el menú (M-23), descripciones de pizzas, la
   tarjeta de detalle de venta hardcodeada (M-04) y el resumen de producción con constantes
   (M-07) son el mismo defecto: datos escritos en la vista en vez de en el modelo.
   → *Solución de fondo:* que cada pantalla reciba el registro y lo renderice.

3. **Recursos creados dentro de `build`.** M-14 y M-15, y en menor medida B-03 y B-12.
   → *Solución de fondo:* todo controller, `AnimationController` y `StreamSubscription` se crea
   en `initState` y se libera en `dispose()`.

4. **Valores de identidad y de fecha literales.** Perfil hardcodeado en 9 pantallas (M-10),
   fecha fija (B-09), nombres constantes (M-13, C-05).
   → *Solución de fondo:* leer siempre del servicio de sesión y formatear con `DateTime.now()`.

5. **Configuración de plantilla sin editar.** C-01, C-02, C-03, A-05, A-06, A-07, A-08 y la
   mayoría de B-15. Son residuos de `flutter create` sin personalizar.
   → *Solución de fondo:* una pasada de *release checklist* sobre paquete, firma, assets,
   nombres de app y gitignore.

---

## Verificado y correcto (sin acción)

Auditado y **no** es un problema:

- Permiso `INTERNET` presente en `AndroidManifest.xml:2`; SDK levels sin conflictos
  (`minSdk` 24, plugins requieren 21); `IPHONEOS_DEPLOYMENT_TARGET 13.0` cubre a todos los plugins.
- Todos los endpoints de red en `lib/` son **HTTPS** (`nominatim.openstreetmap.org`,
  `server.arcgisonline.com`, `waze.com`, `www.google.com`), así que **no** falta
  `usesCleartextTraffic` ni `NSAppTransportSecurity`.
- `file_picker` se usa solo con `FileType.custom` y extensiones → va por
  `UIDocumentPickerViewController`, **no** requiere `NSPhotoLibraryUsageDescription`.
- Versiones Java 17 / Kotlin JvmTarget 17 coherentes con AGP 9.0.1 y Gradle 9.1.0.
- `analysis_options.yaml` bien formado; **todas** las dependencias declaradas se usan
  (sin dependencias muertas).
- Las tres carpetas de assets declaradas en `pubspec.yaml` existen; los únicos assets
  referenciados que faltan son C-02 y C-03.
- `splash_screen.dart` libera los 5 `AnimationController`, el `Stopwatch`, la suscripción del
  acelerómetro y los ripples; `main.dart` tiene el orden correcto de binding/splash/orientación.
- `auth_service.dart` normaliza el correo igual que las claves de sus mapas, y `login`/`logout`
  limpian correctamente la sesión y la bandera `fromPanel`.
- `intials.dart` maneja entradas vacías; los Hero tags de `auth_logo` no se duplican.
- En `order_detail_screen.dart` todos los `await` van con guardia `mounted`, se valida el
  `statusCode` y se comprueba `datos.isEmpty` antes de `datos.first`.
- `cart_service.dart` remove ítems al llegar a 0 y notifica; `total`, `articulos` y `productos`
  del pedido se derivan del mismo snapshot del carrito, así que son consistentes entre sí.
