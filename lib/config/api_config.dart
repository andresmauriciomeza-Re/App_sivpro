/// Configuración de conexión con el backend.
///
/// La URL se puede sobrescribir al compilar, por ejemplo:
/// `flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api`
class ApiConfig {
  ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.137.83.131:3000/api',
  );

  static const Duration timeout = Duration(seconds: 20);

  static const Duration inactivityTimeout = Duration(minutes: 15);
}