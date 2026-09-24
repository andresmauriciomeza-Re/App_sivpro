/// Iniciales a partir de un nombre completo.
///
/// Regla: si hay varias palabras se toma la inicial de la primera y la de la
/// última (ej. "Gloria Inés Vargas" -> "GV"). Si hay una sola palabra se
/// devuelve solo su inicial. Se ignoran espacios extra y siempre devuelve
/// mayúsculas. Cadena vacía -> '?'.
String getInitials(String fullName) {
  final parts = fullName
      .trim()
      .split(RegExp(r'\s+'))
      .where((p) => p.isNotEmpty)
      .toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts.first[0].toUpperCase();
  return (parts.first[0] + parts.last[0]).toUpperCase();
}