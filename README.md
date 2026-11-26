# S.I.V.PRO — App móvil (Pizzería La Sirena)

App Flutter para clientes y personal de la pizzería. Por defecto se conecta al
backend de producción en Render: `https://sivpro-backend.onrender.com/api`.

## Requisitos

- Flutter 3.47 o superior
- Android Studio (con el SDK de Android)
- Java 17

## Instalación

```bash
flutter pub get
```

## Ejecutar

Con `flutter devices` puedes ver los dispositivos disponibles. En VS Code
también puedes elegir una de las configuraciones de **Ejecutar y depurar**.

### Contra Render (producción)

```bash
flutter run
```

El plan gratuito de Render puede tardar casi un minuto en despertar, así que la
primera petición puede demorarse.

### Contra el backend local

El backend debe estar corriendo en tu PC, en el puerto 3000.

En el emulador de Android (`10.0.2.2` apunta a tu PC):

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api
```

En un celular físico, conectado a la misma red que el PC (cambia `IP_DEL_PC`
por la IP local del equipo, que puedes ver con `ipconfig`):

```bash
flutter run --dart-define=API_BASE_URL=http://IP_DEL_PC:3000/api
```

En VS Code, para la configuración **Local - celular físico**, reemplaza primero
`CAMBIAR_IP_DEL_PC` en `.vscode/launch.json`.

## Generar el APK

```bash
flutter build apk --release
```

El archivo queda en `build/app/outputs/flutter-apk/app-release.apk` y usa el
backend de Render. Por ahora se firma con la clave de depuración: sirve para
instalar y probar, no para publicar en Play Store.

## Aviso sobre los datos

**La base de datos de Neon es compartida.** Todo lo que hagas contra Render
afecta datos reales: no borres, anules ni modifiques información real al probar.
