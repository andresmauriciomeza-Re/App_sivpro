import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import 'initials.dart';

/// Un campo de la pantalla Mi Perfil: ícono, label, controlador y reglas.
///
/// Las apps (Admin y Empleado) construyen su propia lista de campos; así solo
/// cambian el rol, los datos y los botones propios de cada app.
class ProfileField {
  const ProfileField({
    required this.icon,
    required this.label,
    required this.controller,
    required this.editable,
    this.keyboardType = TextInputType.text,
    this.note,
    this.normalize,
  });

  final IconData icon;
  final String label;
  final TextEditingController controller;

  /// Si es editable (campo habilitado en modo edición).
  final bool editable;

  final TextInputType keyboardType;

  /// Mensaje pequeño que se muestra debajo del campo (p. ej. "no editable").
  final String? note;

  /// Transforma el valor escrito antes de persistirlo (trim, quitar guiones…).
  final String Function(String)? normalize;
}

/// Cuerpo compartido de la pantalla Mi Perfil (Admin y Empleado).
///
/// Es dueño del modo edición: editar/guardar/cancelar y la validación. Las apps
/// pasan los controladores, la validación y las acciones propias de cada rol,
/// de modo que el aspecto visual queda idéntico.
class ProfileBody extends StatefulWidget {
  const ProfileBody({
    super.key,
    required this.name,
    required this.roleLabel,
    required this.subtitle,
    required this.fields,
    required this.validate,
    required this.onSave,
    required this.onSignOut,
    required this.onGoHome,
    required this.successMessage,
    required this.footerLines,
  });

  final String name;
  final String roleLabel;
  final String subtitle;
  final List<ProfileField> fields;

  /// Retorna un mensaje de error o null si los campos son válidos.
  final String? Function() validate;

  /// Persiste los valores ya normalizados de los campos.
  final void Function() onSave;

  final VoidCallback onSignOut;
  final VoidCallback onGoHome;
  final String successMessage;
  final List<String> footerLines;

  @override
  State<ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<ProfileBody> {
  bool _editing = false;
  List<String> _savedValues = const [];

  void _startEditing() {
    setState(() {
      _savedValues = [for (final f in widget.fields) f.controller.text];
      _editing = true;
    });
  }

  void _cancelEditing() {
    setState(() {
      for (var i = 0; i < widget.fields.length; i++) {
        widget.fields[i].controller.text = _savedValues[i];
      }
      _editing = false;
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _saveProfile() {
    FocusScope.of(context).unfocus();
    final error = widget.validate();
    if (error != null) {
      _showMessage(error);
      return;
    }
    for (final field in widget.fields) {
      field.controller.text =
          field.normalize?.call(field.controller.text) ??
              field.controller.text.trim();
    }
    widget.onSave();
    setState(() => _editing = false);
    _showMessage(widget.successMessage);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mi Perfil',
          style: Theme.of(context).textTheme.headlineSmall!.copyWith(
            color: AppColors.ink,
            fontSize: 26,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          widget.subtitle,
          style: GoogleFonts.poppins(
            color: AppColors.muted,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 12),
        _headerCard(),
        const SizedBox(height: 12),
        _fieldsCard(),
        const SizedBox(height: 14),
        _actions(),
      ],
    );
  }

  Widget _headerCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.profileCardBorder),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.red,
            child: Text(
              getInitials(widget.name),
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.name,
                  maxLines: 2,
                  style: GoogleFonts.poppins(
                    color: AppColors.ink,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.roleLabel,
                  style: GoogleFonts.poppins(
                    color: AppColors.muted,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: _editing ? _saveProfile : _startEditing,
            icon: Icon(_editing ? Icons.check : Icons.edit_outlined, size: 16),
            label: Text(_editing ? 'Guardar' : 'Editar'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.red,
              foregroundColor: Colors.white,
              shape: const StadiumBorder(),
              minimumSize: const Size(0, 36),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              textStyle: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fieldsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.profileCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < widget.fields.length; i++) ...[
            if (i > 0) const SizedBox(height: 14),
            _field(widget.fields[i]),
          ],
        ],
      ),
    );
  }

  Widget _field(ProfileField field) {
    final enabled = field.editable && _editing;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(field.icon, color: AppColors.profileLabelIcon, size: 18),
          const SizedBox(width: 8),
          Text(
            field.label,
            style: GoogleFonts.poppins(
              color: AppColors.profileLabel,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ]),
        const SizedBox(height: 6),
        SizedBox(
          height: 48,
          child: TextField(
            controller: field.controller,
            enabled: enabled,
            keyboardType: field.keyboardType,
            style: GoogleFonts.poppins(
              color: enabled
                  ? AppColors.ink
                  : AppColors.profileFieldDisabledText,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.profileFieldFill,
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        if (field.note != null)
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 5),
            child: Text(
              field.note!,
              style: GoogleFonts.poppins(
                color: AppColors.profileFieldDisabledText,
                fontSize: 11,
              ),
            ),
          ),
      ],
    );
  }

  Widget _actions() {
    if (_editing) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: _cancelEditing,
          icon: const Icon(Icons.close, size: 16),
          label: const Text('Cancelar'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.ink,
            side: const BorderSide(color: AppColors.cardBorder),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
            textStyle: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: widget.onGoHome,
            icon: const Icon(Icons.arrow_back, size: 16),
            label: const Text('Volver al inicio'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.profileLabel,
              backgroundColor: AppColors.buttonSoftBg,
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              textStyle: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: widget.onSignOut,
            icon: const Icon(Icons.logout, size: 16),
            label: const Text('Cerrar sesión'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.red,
              side: const BorderSide(color: AppColors.logOutBorder),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              textStyle: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        for (var i = 0; i < widget.footerLines.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          Center(
            child: Text(
              widget.footerLines[i],
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: AppColors.muted,
                fontSize: i == widget.footerLines.length - 1 ? 11 : 12,
              ),
            ),
          ),
        ],
      ],
    );
  }
}