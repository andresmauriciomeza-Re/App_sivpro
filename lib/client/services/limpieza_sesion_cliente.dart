import '../../auth/auth_service.dart';
import '../../shared/client_notification_service.dart';
import '../widgets/bottom_nav.dart';
import 'cart_service.dart';
import 'catalogo_repository.dart';
import 'pedidos_repository.dart';

bool _registrada = false;

/// Vacía carrito, pedidos, avisos, catálogo en caché y la última pestaña
/// de la barra del cliente al terminar una sesión (cierre, sesión vencida o
/// invalidada) y al iniciar otra, para que el siguiente usuario no vea lo
/// del anterior.
void registrarLimpiezaCliente() {
  if (_registrada) return;
  _registrada = true;
  AuthService.instance.addSessionClearedListener(() {
    CartService.instance.clear();
    PedidosRepository.instance.limpiar();
    ClientNotificationService.instance.limpiar();
    AppBottomNav.olvidarUltimo();
    CatalogoRepository.instance.limpiar();
  });
}
