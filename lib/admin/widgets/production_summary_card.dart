import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../network/api_exception.dart';
import '../services/production_summary_service.dart';

/// Tarjeta "Resumen de Hoy" con las órdenes de producción reales.
class ProductionSummaryCard extends StatefulWidget {
  const ProductionSummaryCard({super.key});

  @override
  State<ProductionSummaryCard> createState() => _ProductionSummaryCardState();
}

class _ProductionSummaryCardState extends State<ProductionSummaryCard> {
  static const _page = Color(0xFFFFFBFA);
  static const _ink = Color(0xFF211616);
  static const _muted = Color(0xFF6E5A58);
  static const _valueRed = Color(0xFFC62828);
  static const _valueGreen = Color(0xFF2E7D32);

  ProductionSummary? _summary;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final summary = await ProductionSummaryService.instance.cargar();
      if (!mounted) return;
      setState(() {
        _summary = summary;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error is ApiException
            ? error.message
            : 'No se pudo cargar el resumen de producción.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final summary = _summary;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(36, 34, 36, 36),
      decoration: BoxDecoration(
        color: _page,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFE8C7C4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumen de Hoy',
            style: GoogleFonts.poppins(
              color: _ink,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              Expanded(
                child: _summaryValue(
                  'ÓRDENES ACTIVAS',
                  summary == null ? '—' : '${summary.ordenesActivas}',
                  'Pendientes y en proceso',
                  _valueRed,
                ),
              ),
              Expanded(
                child: _summaryValue(
                  'COMPLETADAS HOY',
                  summary == null ? '—' : '${summary.completadasHoy}',
                  'Terminadas hoy',
                  _valueGreen,
                ),
              ),
            ],
          ),
          if (_loading) ...[
            const SizedBox(height: 16),
            const LinearProgressIndicator(minHeight: 2),
          ],
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(
              _error!,
              style: GoogleFonts.poppins(color: _valueRed, fontSize: 14),
            ),
            TextButton(onPressed: _load, child: const Text('Reintentar')),
          ],
        ],
      ),
    );
  }

  Widget _summaryValue(String label, String value, String hint, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: _muted,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Text(value, style: GoogleFonts.poppins(color: color, fontSize: 42)),
        Text(hint, style: GoogleFonts.poppins(color: _muted, fontSize: 12)),
      ],
    );
  }
}
