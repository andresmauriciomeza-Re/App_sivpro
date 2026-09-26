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

/// Campo de búsqueda con el estilo unificado de la app: el de la barra de
/// búsqueda de "Gestión Ventas" (lib/admin/screens/purchases/sales.dart).
///
/// Caja crema clara, borde fino rosado que se pone rojo al enfocar, lupa
/// oscura a la izquierda, esquinas redondeadas y, opcionalmente, un botón para
/// limpiar la consulta.
class AppSearchField extends StatefulWidget {
  const AppSearchField({
    super.key,
    required this.hint,
    this.controller,
    this.onChanged,
    this.showClearButton = false,
  });

  final String hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  /// Muestra la "X" para limpiar la consulta. Requiere `controller`.
  final bool showClearButton;

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _hasText = widget.controller?.text.isNotEmpty ?? false;
    widget.controller?.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    final hasText = widget.controller?.text.isNotEmpty ?? false;
    if (hasText != _hasText) setState(() => _hasText = hasText);
  }

  void _clear() {
    widget.controller?.clear();
    widget.onChanged?.call('');
  }

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(20),
    borderSide: BorderSide(color: color),
  );

  @override
  Widget build(BuildContext context) {
    final showClear = widget.showClearButton && widget.controller != null;

    return TextField(
      controller: widget.controller,
      onChanged: widget.onChanged,
      style: GoogleFonts.poppins(color: AppColors.ink, fontSize: 15),
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search, color: AppColors.ink, size: 28),
        suffixIcon: showClear && _hasText
            ? IconButton(
                onPressed: _clear,
                icon: const Icon(Icons.close, color: AppColors.muted, size: 20),
                tooltip: 'Limpiar búsqueda',
              )
            : null,
        hintText: widget.hint,
        hintStyle: GoogleFonts.poppins(color: AppColors.ink, fontSize: 15),
        filled: true,
        fillColor: AppColors.searchFieldFill,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        enabledBorder: _border(AppColors.cardBorder),
        focusedBorder: _border(AppColors.red),
      ),
    );
  }
}
