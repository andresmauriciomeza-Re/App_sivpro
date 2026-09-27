import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';

// ============================================================================
// MODELO DE DATOS: Insumo
// ============================================================================
// Representa un insumo (materia prima) con su información de stock.
// Incluye identificador, nombre, cantidad actual en existencia,
// cantidad mínima de alerta, cantidad máxima de capacidad y unidad de medida.
// ============================================================================

/// Modelo de datos para un insumo (materia prima).
class Insumo {
  const Insumo({
    required this.id,
    required this.nombre,
    required this.cantidadActual,
    required this.cantidadMinima,
    required this.cantidadMaxima,
    required this.unidadDeMedida,
  });

  /// Identificador único del insumo (ej: 'INS-001').
  final String id;

  /// Nombre descriptivo del insumo (ej: 'Harina de trigo').
  final String nombre;

  /// Cantidad actual en existencia.
  final int cantidadActual;

  /// Cantidad mínima antes de generar alerta de stock bajo.
  final int cantidadMinima;

  /// Cantidad máxima de capacidad de almacenamiento.
  final int cantidadMaxima;

  /// Unidad de medida (ej: 'kg', 'und', 'lt').
  final String unidadDeMedida;

  /// Retorna el porcentaje de existencia (0.0 a 1.0) basado en el máximo.
  double get porcentajeExistencia {
    if (cantidadMaxima <= 0) return 0.0;
    return (cantidadActual / cantidadMaxima).clamp(0.0, 1.0);
  }

  /// Retorna true si el insumo está en o por debajo del mínimo.
  bool get esStockBajo => cantidadActual <= cantidadMinima;

  /// Retorna true si el insumo está cerca del mínimo (dentro del 20% acima).
  bool get esStockCercaMinimo {
    if (cantidadMinima <= 0) return false;
    final umbral = cantidadMinima * 1.2;
    return cantidadActual <= umbral && cantidadActual > cantidadMinima;
  }

  /// Crea una copia del insumo con valores actualizables.
  Insumo copyWith({
    String? id,
    String? nombre,
    int? cantidadActual,
    int? cantidadMinima,
    int? cantidadMaxima,
    String? unidadDeMedida,
  }) {
    return Insumo(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      cantidadActual: cantidadActual ?? this.cantidadActual,
      cantidadMinima: cantidadMinima ?? this.cantidadMinima,
      cantidadMaxima: cantidadMaxima ?? this.cantidadMaxima,
      unidadDeMedida: unidadDeMedida ?? this.unidadDeMedida,
    );
  }
}

// ============================================================================
// SERVICIO DE NOTIFICACIONES LOCALES
// ============================================================================
// Gestiona el envío de notificaciones locales cuando un insumo
// alcanza o desciende por debajo de su nivel mínimo de stock.
// Utiliza el paquete flutter_local_notifications para mostrar
// notificaciones en el dispositivo móvil.
// ============================================================================

/// Servicio singleton para notificaciones locales de stock bajo.
class InsumoNotificationService {
  InsumoNotificationService._();
  static final InsumoNotificationService instance =
      InsumoNotificationService._();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Inicializa el plugin de notificaciones.
  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);
    _initialized = true;
  }

  /// Muestra una notificación local de stock bajo.
  Future<void> mostrarNotificacionStockBajo(Insumo insumo) async {
    await initialize();

    const androidDetails = AndroidNotificationDetails(
      'insumos_channel',
      'Alertas de Insumos',
      channelDescription:
          'Notificaciones cuando los insumos alcanzan el nivel mínimo',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      insumo.id.hashCode, // ID único basado en el insumo
      'Stock Bajo: ${insumo.nombre}',
      'El insumo ${insumo.nombre} (${insumo.id}) ha alcanzado el nivel '
          'mínimo. Cantidad actual: ${insumo.cantidadActual} '
          '${insumo.unidadDeMedida}',
      details,
    );
  }
}

// ============================================================================
// PANTALLA PRINCIPAL: InsumosScreen
// ============================================================================
// Widget principal que muestra el listado de insumos con su nivel de
// existencias, permitiendo consultar, visualizar alertas y gestionar
// notificaciones de stock bajo.
// ============================================================================

/// Pantalla de gestión de insumos (materia prima).
class InsumosScreen extends StatefulWidget {
  const InsumosScreen({super.key});

  @override
  State<InsumosScreen> createState() => _InsumosScreenState();
}

class _InsumosScreenState extends State<InsumosScreen> {
  // --------------------------------------------------------------------------
  // DATOS DE EJEMPLO
  // --------------------------------------------------------------------------
  // Lista de insumos con datos de demostración.
  // En producción, estos datos vendrían de una API o base de datos local.
  // --------------------------------------------------------------------------
  static final List<Insumo> _insumos = [
    Insumo(
      id: 'INS-001',
      nombre: 'Harina de trigo',
      cantidadActual: 50,
      cantidadMinima: 20,
      cantidadMaxima: 100,
      unidadDeMedida: 'kg',
    ),
    Insumo(
      id: 'INS-002',
      nombre: 'Queso mozzarella',
      cantidadActual: 8,
      cantidadMinima: 10,
      cantidadMaxima: 50,
      unidadDeMedida: 'kg',
    ),
    Insumo(
      id: 'INS-003',
      nombre: 'Salsa de tomate',
      cantidadActual: 25,
      cantidadMinima: 15,
      cantidadMaxima: 60,
      unidadDeMedida: 'lt',
    ),
    Insumo(
      id: 'INS-004',
      nombre: 'Pepperoni',
      cantidadActual: 5,
      cantidadMinima: 12,
      cantidadMaxima: 40,
      unidadDeMedida: 'kg',
    ),
    Insumo(
      id: 'INS-005',
      nombre: 'Masa pre-elaborada',
      cantidadActual: 30,
      cantidadMinima: 15,
      cantidadMaxima: 80,
      unidadDeMedida: 'und',
    ),
    Insumo(
      id: 'INS-006',
      nombre: 'Champiñones',
      cantidadActual: 3,
      cantidadMinima: 8,
      cantidadMaxima: 25,
      unidadDeMedida: 'kg',
    ),
    Insumo(
      id: 'INS-007',
      nombre: 'Aceite de oliva',
      cantidadActual: 18,
      cantidadMinima: 10,
      cantidadMaxima: 40,
      unidadDeMedida: 'lt',
    ),
    Insumo(
      id: 'INS-008',
      nombre: 'Caja para pizza',
      cantidadActual: 150,
      cantidadMinima: 50,
      cantidadMaxima: 300,
      unidadDeMedida: 'und',
    ),
  ];

  // --------------------------------------------------------------------------
  // ESTADO DE LA PANTALLA
  // --------------------------------------------------------------------------
  String _query = ''; // Texto de búsqueda actual

  // --------------------------------------------------------------------------
  // INICIALIZACIÓN
  // --------------------------------------------------------------------------
  @override
  void initState() {
    super.initState();
    // Inicializar el servicio de notificiones al cargar la pantalla.
    InsumoNotificationService.instance.initialize();
  }

  // --------------------------------------------------------------------------
  // FILTRADO DE INSUMOS
  // --------------------------------------------------------------------------
  /// Filtra los insumos según el texto de búsqueda.
  /// Compara contra ID, nombre y unidad de medida.
  List<Insumo> get _insumosFiltrados {
    final query = _query.toLowerCase().trim();
    if (query.isEmpty) return _insumos;

    return _insumos.where((insumo) {
      return insumo.id.toLowerCase().contains(query) ||
          insumo.nombre.toLowerCase().contains(query) ||
          insumo.unidadDeMedida.toLowerCase().contains(query);
    }).toList();
  }

  // --------------------------------------------------------------------------
  // CONTADORES PARA RESUMEN
  // --------------------------------------------------------------------------
  int get _totalInsumos => _insumos.length;
  int get _stockBajo =>
      _insumos.where((i) => i.esStockBajo).length;
  int get _stockCercaMinimo =>
      _insumos.where((i) => i.esStockCercaMinimo).length;

  // ==========================================================================
  // CONSTRUCCIÓN DE LA INTERFAZ
  // ==========================================================================
  @override
  Widget build(BuildContext context) {
    final insumosFiltrados = _insumosFiltrados;

    return Scaffold(
      backgroundColor: const Color(0xFFFCFAF9),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Encabezado con título y botón de regreso
            _buildHeader(),

            // Contenido principal con lista de insumos
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(17, 20, 17, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título de la sección
                    Text(
                      'Insumos',
                      style: GoogleFonts.montserrat(
                        color: const Color(0xFF17243A),
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Chips de resumen (total, stock bajo, cerca mínimo)
                    _buildSummaryChips(),
                    const SizedBox(height: 20),

                    // Campo de búsqueda
                    _buildSearchField(),
                    const SizedBox(height: 20),

                    // Lista de insumos o mensaje de vacío
                    if (insumosFiltrados.isEmpty)
                      _buildEmptyState()
                    else
                      ...insumosFiltrados.map(
                        (insumo) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _InsumoCard(
                            insumo: insumo,
                            onNotificar: () =>
                                _notificarStockBajo(insumo),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // ENCABEZADO
  // --------------------------------------------------------------------------
  Widget _buildHeader() {
    return Container(
      height: 74,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: const BoxDecoration(
        color: Color(0xFFFCFAF9),
        border: Border(bottom: BorderSide(color: Color(0xFFEBCBC8))),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.black,
              size: 27,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 28),
          Text(
            'La Sirena Pizza',
            style: GoogleFonts.montserrat(
              color: Colors.black,
              fontSize: 24,
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // CHIPS DE RESUMEN
  // --------------------------------------------------------------------------
  Widget _buildSummaryChips() {
    return Row(
      children: [
        Expanded(
          child: _SummaryChip(
            count: '$_totalInsumos',
            label: 'Total insumos',
            backgroundColor: const Color(0xFFE8C7C4),
            textColor: const Color(0xFF17243A),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SummaryChip(
            count: '$_stockBajo',
            label: 'Stock bajo',
            backgroundColor: const Color(0xFFF5D9A5),
            textColor: const Color(0xFFB65D0A),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SummaryChip(
            count: '$_stockCercaMinimo',
            label: 'Cerca mín.',
            backgroundColor: const Color(0xFFF4C8CF),
            textColor: const Color(0xFFC9151E),
          ),
        ),
      ],
    );
  }

  // --------------------------------------------------------------------------
  // CAMPO DE BÚSQUEDA
  // --------------------------------------------------------------------------
  Widget _buildSearchField() {
    return TextField(
      onChanged: (value) => setState(() => _query = value),
      style: GoogleFonts.poppins(
        color: const Color(0xFF17243A),
        fontSize: 15,
      ),
      decoration: InputDecoration(
        hintText: 'Buscar por ID, nombre o unidad...',
        hintStyle: GoogleFonts.poppins(
          color: const Color(0xFF617492),
          fontSize: 15,
        ),
        prefixIcon: const Icon(
          Icons.search,
          color: Color(0xFF617492),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: Color(0xFFE3E1DE)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(
            color: Color(0xFFC9151E),
            width: 1.5,
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // ESTADO VACÍO
  // --------------------------------------------------------------------------
  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Center(
        child: Text(
          'No se encontraron insumos',
          style: GoogleFonts.poppins(
            color: const Color(0xFF617492),
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // NOTIFICACIÓN DE STOCK BAJO
  // --------------------------------------------------------------------------
  /// Envía una notificación local cuando un insumo está en stock bajo.
  Future<void> _notificarStockBajo(Insumo insumo) async {
    await InsumoNotificationService.instance
        .mostrarNotificacionStockBajo(insumo);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Notificación enviada: ${insumo.nombre} en stock bajo',
        ),
      ),
    );
  }
}

// ============================================================================
// WIDGET: Tarjeta de Insumo
// ============================================================================
// Muestra la información de un insumo individual con indicador visual
// de nivel de existencias (barra de progreso con colores).
// ============================================================================

class _InsumoCard extends StatelessWidget {
  const _InsumoCard({
    required this.insumo,
    required this.onNotificar,
  });

  final Insumo insumo;
  final VoidCallback onNotificar;

  // --------------------------------------------------------------------------
  // CORES DE ESTADO
  // --------------------------------------------------------------------------
  /// Retorna el color del indicador según el nivel de existencia:
  /// - Verde: stock normal (por encima del 20% sobre el mínimo)
  /// - Amarillo: cerca del mínimo (dentro del 20% sobre el mínimo)
  /// - Rojo: en o por debajo del mínimo
  Color get _colorEstado {
    if (insumo.esStockBajo) return const Color(0xFFC9151E); // Rojo
    if (insumo.esStockCercaMinimo) return const Color(0xFFF5A623); // Amarillo
    return const Color(0xFF3D824B); // Verde
  }

  /// Retorna el color de fondo del badge de estado.
  Color get _colorFondoEstado {
    if (insumo.esStockBajo) return const Color(0xFFFFE8EB);
    if (insumo.esStockCercaMinimo) return const Color(0xFFFFF3DF);
    return const Color(0xFFE3F2E5);
  }

  /// Retorna el texto del badge de estado.
  String get _textoEstado {
    if (insumo.esStockBajo) return 'Stock bajo';
    if (insumo.esStockCercaMinimo) return 'Cerca mín.';
    return 'Normal';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(13, 12, 13, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE1D8D6)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fila superior: ID, nombre y badge de estado
          Row(
            children: [
              Text(
                insumo.id,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF617492),
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  insumo.nombre,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF17243A),
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _colorFondoEstado,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Text(
                  _textoEstado,
                  style: GoogleFonts.poppins(
                    color: _colorEstado,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Unidad de medida
          Text(
            'Unidad: ${insumo.unidadDeMedida}',
            style: GoogleFonts.poppins(
              color: const Color(0xFF617492),
              fontSize: 12,
            ),
          ),
          const Divider(height: 18),

          // Información de stock
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF617492),
                          fontSize: 12,
                        ),
                        children: [
                          const TextSpan(text: 'Actual: '),
                          TextSpan(
                            text:
                                '${insumo.cantidadActual} ${insumo.unidadDeMedida}',
                            style: TextStyle(
                              color: insumo.esStockBajo
                                  ? const Color(0xFFC9151E)
                                  : const Color(0xFF17243A),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Mín: ${insumo.cantidadMinima} ${insumo.unidadDeMedida} · '
                      'Máx: ${insumo.cantidadMaxima} ${insumo.unidadDeMedida}',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF617492),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 18),

          // Barra de progreso de existencia
          _buildProgressIndicator(),
          const SizedBox(height: 12),

          // Botón de notificación (visible solo si hay stock bajo)
          if (insumo.esStockBajo)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onNotificar,
                icon: const Icon(Icons.notifications_active, size: 18),
                label: const Text('Enviar notificación de stock bajo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC9151E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // INDICADOR DE PROGRESO
  // --------------------------------------------------------------------------
  /// Barra de progreso que muestra el nivel de existencia del insumo.
  /// Cambia de color según el estado: verde (normal), amarillo (cerca
  /// mínimo) o rojo (en o por debajo del mínimo).
  Widget _buildProgressIndicator() {
    final porcentaje = insumo.porcentajeExistencia;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Nivel de existencia',
              style: GoogleFonts.poppins(
                color: const Color(0xFF617492),
                fontSize: 11,
              ),
            ),
            Text(
              '${(porcentaje * 100).toInt()}%',
              style: GoogleFonts.poppins(
                color: _colorEstado,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: porcentaje,
            minHeight: 8,
            backgroundColor: const Color(0xFFE8E0DE),
            valueColor: AlwaysStoppedAnimation<Color>(_colorEstado),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// WIDGET: Chip de Resumen
// ============================================================================
// Muestra un contador con su etiqueta en un contenedor redondeado.
// ============================================================================

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.count,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  final String count;
  final String label;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.poppins(
            color: textColor,
            fontSize: 12,
          ),
          children: [
            TextSpan(
              text: '$count ',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            TextSpan(text: label),
          ],
        ),
      ),
    );
  }
}
