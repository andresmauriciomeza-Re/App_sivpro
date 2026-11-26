/// Configuración de conexión con el backend.
///
/// Por defecto se usa el backend de producción en Render. Para desarrollo
/// local, la URL se puede sobrescribir al ejecutar o compilar:
///
/// - Emulador:
///   `flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api`
/// - Celular físico:
///   `flutter run --dart-define=API_BASE_URL=http://IP_DEL_PC:3000/api`
class ApiConfig {
  ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://sivpro-backend.onrender.com/api',
  );

  /// Render gratuito puede tardar casi un minuto en despertar.
  static const Duration timeout = Duration(seconds: 60);

  static const Duration inactivityTimeout = Duration(minutes: 15);
}