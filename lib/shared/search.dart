import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

const Map<String, String> _diacritics = {
  'á': 'a',
  'à': 'a',
  'ä': 'a',
  'â': 'a',
  'ã': 'a',
  'å': 'a',
  'é': 'e',
  'è': 'e',
  'ë': 'e',
  'ê': 'e',
  'í': 'i',
  'ì': 'i',
  'ï': 'i',
  'î': 'i',
  'ó': 'o',
  'ò': 'o',
  'ö': 'o',
  'ô': 'o',
  'õ': 'o',
  'ú': 'u',
  'ù': 'u',
  'ü': 'u',
  'û': 'u',
  'ñ': 'n',
  'ç': 'c',
  'ý': 'y',
};

/// Normaliza un texto para búsquedas: minúsculas y sin tildes ni diacríticos.
String normalizeForSearch(String value) {
  final lower = value.toLowerCase();
  final buffer = StringBuffer();
  for (final rune in lower.runes) {
    final char = String.fromCharCode(rune);
    final normalized = _diacritics[char];
    buffer.write(normalized ?? char);
  }
  return buffer.toString();
}

/// Devuelve `true` si la consulta normalizada coincide con al menos uno de
/// los campos (sin distinguir mayúsculas ni tildes).
///
/// Una consulta vacía hace que todo coincida.
bool matchesSearchQuery(String query, Iterable<String> fields) {
  final normalizedQuery = normalizeForSearch(query.trim());
  if (normalizedQuery.isEmpty) return true;
  for (final field in fields) {
    if (normalizeForSearch(field).contains(normalizedQuery)) return true;
  }
  return false;
}

/// Widget de búsqueda reutilizable con el estilo de la barra de Gestión
/// Ventas: caja blanca, borde fino gris claro, lupa a la izquierda y botón
/// de limpiar (X) cuando hay texto.
class AppSearchField extends StatefulWidget {
  const AppSearchField({
    super.key,
    required this.controller,
    required this.hint,
    this.onChanged,
    this.borderRadius = 20,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final double borderRadius;

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _hasText = widget.controller.text.isNotEmpty;
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    final hasText = widget.controller.text.isNotEmpty;
    if (hasText != _hasText) setState(() => _hasText = hasText);
  }

  void _clear() {
    widget.controller.clear();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      onChanged: widget.onChanged,
      style: GoogleFonts.dmSerifDisplay(color: AppColors.ink, fontSize: 15),
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search, color: AppColors.muted, size: 24),
        suffixIcon: _hasText
            ? IconButton(
                onPressed: _clear,
                icon: const Icon(Icons.close, color: AppColors.muted, size: 20),
                tooltip: 'Limpiar búsqueda',
              )
            : null,
        hintText: widget.hint,
        hintStyle: GoogleFonts.dmSerifDisplay(
          color: AppColors.muted,
          fontSize: 15,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(widget.borderRadius),
          borderSide: const BorderSide(color: AppColors.fieldBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(widget.borderRadius),
          borderSide: const BorderSide(color: AppColors.red),
        ),
      ),
    );
  }
}