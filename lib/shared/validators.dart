import 'package:flutter/services.dart';

// ignore: constant_identifier_names
const List<String> ALLOWED_EMAIL_DOMAINS = <String>[
  'gmail.com',
  'outlook.com',
  'hotmail.com',
  'lasirena.com',
];

const String allowedEmailMessage =
    'Solo se permiten correos @gmail.com, @outlook.com, @hotmail.com o @lasirena.com';

String? requiredValidator(String? value) {
  if (value == null || value.isEmpty) return 'Este campo es obligatorio';
  return null;
}

/// Login: el backend solo exige correo no vacío (sin restricción de dominio).
String? loginEmailValidator(String? value) {
  if (value == null || value.trim().isEmpty) return 'Ingresa tu correo';
  return null;
}

/// Login: el backend solo exige contraseña no vacía.
String? loginPasswordValidator(String? value) {
  if (value == null || value.isEmpty) return 'Ingresa tu contraseña';
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

String? documentValidator(String? value) {
  if (value == null || value.isEmpty) return 'Este campo es obligatorio';
  if (!RegExp(r'^\d+$').hasMatch(value)) return 'Solo se permiten números';
  if (value.length < 6 || value.length > 15) {
    return 'El documento debe tener entre 6 y 15 dígitos';
  }
  return null;
}

String? nameValidator(String? value) {
  if (value == null || value.isEmpty) return 'Este campo es obligatorio';
  if (!RegExp(
    r'^[A-Za-zÁÉÍÓÚÜÑáéíóúüñ]+(?: [A-Za-zÁÉÍÓÚÜÑáéíóúüñ]+)*$',
  ).hasMatch(value)) {
    return 'Solo se permiten letras';
  }
  return null;
}

String? emailValidator(String? value) {
  if (value == null || value.isEmpty) return 'Este campo es obligatorio';
  final email = value.toLowerCase();
  final match = RegExp(
    r'^[a-z0-9](?:[a-z0-9._-]*[a-z0-9])?@([a-z0-9-]+\.[a-z]{2,})$',
  ).firstMatch(email);
  if (match == null || !ALLOWED_EMAIL_DOMAINS.contains(match.group(1))) {
    return allowedEmailMessage;
  }
  return null;
}

String? phoneValidator(String? value) {
  if (value == null || value.isEmpty) return 'Este campo es obligatorio';
  if (!RegExp(r'^\d{10}$').hasMatch(value)) {
    return 'El teléfono debe tener 10 dígitos numéricos';
  }
  return null;
}

String? passwordValidator(String? value) {
  if (value == null || value.isEmpty) return 'Este campo es obligatorio';
  if (value.length < 8) {
    return 'La contraseña debe tener al menos 8 caracteres';
  }
  return null;
}

String? confirmPasswordValidator(String? value, String password) {
  if (value == null || value.isEmpty) return 'Este campo es obligatorio';
  if (value != password) return 'Las contraseñas no coinciden';
  return null;
}

class NameInputFormatter extends TextInputFormatter {
  static final _allowed = RegExp(
    r'^[A-Za-zÁÉÍÓÚÜÑáéíóúüñ]*(?: [A-Za-zÁÉÍÓÚÜÑáéíóúüñ]*)?$',
  );

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return _allowed.hasMatch(newValue.text) ? newValue : oldValue;
  }
}

class EmailInputFormatter extends TextInputFormatter {
  static final _allowed = RegExp(r'^[A-Za-z0-9._@-]*$');

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
