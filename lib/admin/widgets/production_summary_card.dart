import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/production_summary_service.dart';

class ProductionSummaryCard extends StatelessWidget {
  const ProductionSummaryCard({super.key});

  static const _page = Color(0xFFFFFBFA);
  static const _ink = Color(0xFF211616);
  static const _muted = Color(0xFF6E5A58);
  static const _valueRed = Color(0xFFC62828);
  static const _valueGreen = Color(0xFF2E7D32);

  @override
  Widget build(BuildContext context) {
    final service = ProductionSummaryService.instance;
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
                  '${service.ordenesActivas}',
                  _valueRed,
                ),
              ),
              Expanded(
                child: _summaryValue(
                  'COMPLETADAS',
                  '${service.ordenesCompletadas}',
                  _valueGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryValue(String label, String value, Color color) {
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
        Text(
          value,
          style: GoogleFonts.poppins(color: color, fontSize: 42),
        ),
      ],
    );
  }
}