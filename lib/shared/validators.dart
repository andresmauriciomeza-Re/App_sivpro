import 'dart:convert';

import 'package:flutter/services.dart';

/// Login: correo no vacío y de hasta 255 caracteres, como el backend.
String? loginEmailValidator(String? value) {
  if (value == null || value.trim().isEmpty) return 'Ingresa tu correo';
  if (value.length > 255) return 'El correo no puede superar 255 caracteres';
  return null;
}

/// Login: contraseña no vacía y de hasta 255 caracteres, como el backend.
String? loginPasswordValidator(String? value) {
  if (value == null || value.isEmpty) return 'Ingresa tu contraseña';
  if (value.length > 255) {
    return 'La contraseña no puede superar 255 caracteres';
  }
  return null;
}

/// Perfil: formato de correo válido, sin restricción de dominio (máx. 255).
String? profileEmailValidator(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) return 'El correo es obligatorio';
  if (email.length > 255) return 'El correo es demasiado largo';
  if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$').hasMatch(email)) {
    return 'Ingresa un correo válido';
  }
  return null;
}

/// Perfil: solo dígitos, de 7 a 15 (misma regla que el backend).
String? profilePhoneValidator(String? value) {
  final phone = value?.trim() ?? '';
  if (phone.isEmpty) return 'El teléfono es obligatorio';
  if (!RegExp(r'^\d{7,15}$').hasMatch(phone)) {
    return 'El teléfono debe tener solo números, entre 7 y 15 dígitos';
  }
  return null;
}

/// Formateadores del campo teléfono del perfil: solo dígitos, máximo 15.
List<TextInputFormatter> profilePhoneFormatters() => <TextInputFormatter>[
  FilteringTextInputFormatter.digitsOnly,
  LengthLimitingTextInputFormatter(15),
];

/// Valida los dos campos editables del perfil. Devuelve el primer error o null.
String? validateProfileContact(String correo, String telefono) {
  return profileEmailValidator(correo) ?? profilePhoneValidator(telefono);
}

// ---- Registro: mismas reglas que validarRegistro del backend ----

/// Largo del número de documento por tipo (CC, CE y PP de pasaporte).
const Map<String, (int, int)> limitesDocumento = {
  'CC': (6, 10),
  'CE': (6, 12),
  'PP': (6, 12),
};

/// Letras del nombre: incluye tildes, Ñ y Ü (mismo rango que el backend).
const String _letra = r'[A-Za-zÁ-ÖØ-Üá-öø-ü]';

final RegExp _nombre = RegExp('^$_letra+(?: $_letra+)*\$');

final RegExp _correo = RegExp(
  r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9-]+(?:\.[A-Za-z0-9-]+)*\.[A-Za-z]{2,}$',
);

const String correoInvalidoMensaje = 'Ingresa un correo válido y sin espacios.';

String? documentValidator(String? value, String tipo) {
  if (value == null || value.isEmpty) return 'Este campo es obligatorio';
  if (!RegExp(r'^\d+$').hasMatch(value)) return 'Solo se permiten números';
  final (minimo, maximo) = limitesDocumento[tipo]!;
  if (value.length < minimo || value.length > maximo) {
    return 'El documento debe tener entre $minimo y $maximo dígitos';
  }
  return null;
}

/// Se valida recortado: al backend se envía sin espacios al inicio ni al final.
String? nameValidator(String? value) {
  final nombre = value?.trim() ?? '';
  if (nombre.isEmpty) return 'Este campo es obligatorio';
  if (!_nombre.hasMatch(nombre)) {
    return 'Solo se permiten letras separadas por un espacio';
  }
  if (nombre.length < 2 || nombre.length > 100) {
    return 'El nombre debe tener entre 2 y 100 caracteres';
  }
  return null;
}

/// Sin lista de dominios; máximo 60 caracteres y la parte local no empieza
/// ni termina en punto.
String? emailValidator(String? value) {
  final correo = value?.trim() ?? '';
  if (correo.isEmpty) return 'Este campo es obligatorio';
  final local = correo.split('@').first;
  if (correo.length > 60 ||
      !_correo.hasMatch(correo) ||
      local.startsWith('.') ||
      local.endsWith('.')) {
    return correoInvalidoMensaje;
  }
  return null;
}

String? phoneValidator(String? value) {
  if (value == null || value.isEmpty) return 'Este campo es obligatorio';
  if (!RegExp(r'^\d{7,15}$').hasMatch(value)) {
    return 'El teléfono debe tener solo números, entre 7 y 15 dígitos.';
  }
  return null;
}

// Reglas de contraseña (registro y nueva contraseña): 8 a 72 caracteres y
// como mucho 72 bytes, sin espacios, con minúscula, mayúscula (Unicode: Ñ y
// tildes cuentan) y número.
bool contrasenaLongitudValida(String p) =>
    p.length >= 8 && p.length <= 72 && utf8.encode(p).length <= 72;
bool contrasenaTieneMayuscula(String p) =>
    RegExp(r'\p{Lu}', unicode: true).hasMatch(p);
bool contrasenaTieneMinuscula(String p) =>
    RegExp(r'\p{Ll}', unicode: true).hasMatch(p);
bool contrasenaTieneNumero(String p) => RegExp(r'\d').hasMatch(p);
bool contrasenaSinEspacios(String p) => !RegExp(r'\s').hasMatch(p);

String? passwordValidator(String? value) {
  if (value == null || value.isEmpty) return 'Este campo es obligatorio';
  if (!contrasenaSinEspacios(value)) {
    return 'La contraseña no puede tener espacios';
  }
  if (!contrasenaLongitudValida(value)) {
    return 'La contraseña debe tener entre 8 y 72 caracteres';
  }
  if (!contrasenaTieneMayuscula(value) ||
      !contrasenaTieneMinuscula(value) ||
      !contrasenaTieneNumero(value)) {
    return 'Incluye al menos una mayúscula, una minúscula y un número';
  }
  return null;
}

String? confirmPasswordValidator(String? value, String password) {
  if (value == null || value.isEmpty) return 'Este campo es obligatorio';
  if (value != password) return 'Las contraseñas no coinciden';
  return null;
}

/// Letras separadas por un único espacio; deja escribir el espacio final
/// mientras se teclea la palabra siguiente.
class NameInputFormatter extends TextInputFormatter {
  static final _allowed = RegExp('^(?:$_letra+(?: $_letra+)* ?)?\$');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return _allowed.hasMatch(newValue.text) ? newValue : oldValue;
  }
}

class EmailInputFormatter extends TextInputFormatter {
  static final _allowed = RegExp(r'^[A-Za-z0-9._%+@-]*$');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.toLowerCase();
    if (!_allowed.hasMatch(text) || '@'.allMatches(text).length > 1) {
      return oldValue;
    }
    return newValue.copyWith(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
