import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/form_validation_service.dart';

class EnhancedTextFormField extends StatefulWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String?)? onSaved;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool required;
  final String? initialValue;

  const EnhancedTextFormField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.helperText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onSaved,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.required = false,
    this.initialValue,
  });

  @override
  State<EnhancedTextFormField> createState() => _EnhancedTextFormFieldState();
}

class _EnhancedTextFormFieldState extends State<EnhancedTextFormField> {
  bool _obscureText = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Text(
                  widget.labelText!,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                if (widget.required)
                  const Text(
                    ' *',
                    style: TextStyle(color: Colors.red),
                  ),
              ],
            ),
          ),
        TextFormField(
          controller: widget.controller,
          initialValue: widget.initialValue,
          obscureText: _obscureText,
          keyboardType: widget.keyboardType,
          inputFormatters: widget.inputFormatters,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          maxLines: widget.obscureText ? 1 : widget.maxLines,
          minLines: widget.minLines,
          maxLength: widget.maxLength,
          decoration: InputDecoration(
            hintText: widget.hintText,
            helperText: widget.helperText,
            prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
            suffixIcon: widget.obscureText
                ? IconButton(
                    icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscureText = !_obscureText),
                  )
                : widget.suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
          ),
          validator: (value) {
            final error = widget.validator?.call(value);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() => _hasError = error != null);
              }
            });
            return error;
          },
          onChanged: widget.onChanged,
          onSaved: widget.onSaved,
        ),
      ],
    );
  }
}

class EmailFormField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final bool required;
  final void Function(String)? onChanged;
  final void Function(String?)? onSaved;

  const EmailFormField({
    super.key,
    this.controller,
    this.labelText = 'E-posta',
    this.hintText = 'ornek@email.com',
    this.required = true,
    this.onChanged,
    this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    return EnhancedTextFormField(
      controller: controller,
      labelText: labelText,
      hintText: hintText,
      required: required,
      keyboardType: TextInputType.emailAddress,
      prefixIcon: Icons.email_outlined,
      validator: FormValidationService().validateEmail,
      onChanged: onChanged,
      onSaved: onSaved,
    );
  }
}

class PhoneFormField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final bool required;
  final void Function(String)? onChanged;
  final void Function(String?)? onSaved;

  const PhoneFormField({
    super.key,
    this.controller,
    this.labelText = 'Telefon',
    this.hintText = '05xxxxxxxxx',
    this.required = false,
    this.onChanged,
    this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    return EnhancedTextFormField(
      controller: controller,
      labelText: labelText,
      hintText: hintText,
      required: required,
      keyboardType: TextInputType.phone,
      prefixIcon: Icons.phone_outlined,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(11),
      ],
      validator: FormValidationService().validatePhone,
      onChanged: onChanged,
      onSaved: onSaved,
    );
  }
}

class NameFormField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final bool required;
  final void Function(String)? onChanged;
  final void Function(String?)? onSaved;

  const NameFormField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.required = true,
    this.onChanged,
    this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    return EnhancedTextFormField(
      controller: controller,
      labelText: labelText,
      hintText: hintText,
      required: required,
      keyboardType: TextInputType.name,
      prefixIcon: Icons.person_outline,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZçğıöşüÇĞIİÖŞÜ\s]')),
        LengthLimitingTextInputFormatter(50),
      ],
      validator: (value) => FormValidationService().validateName(
        value,
        fieldName: labelText ?? 'Bu alan',
      ),
      onChanged: onChanged,
      onSaved: onSaved,
    );
  }
}

class PasswordFormField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final bool required;
  final void Function(String)? onChanged;
  final void Function(String?)? onSaved;

  const PasswordFormField({
    super.key,
    this.controller,
    this.labelText = 'Şifre',
    this.hintText,
    this.required = true,
    this.onChanged,
    this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    return EnhancedTextFormField(
      controller: controller,
      labelText: labelText,
      hintText: hintText,
      required: required,
      obscureText: true,
      prefixIcon: Icons.lock_outline,
      validator: FormValidationService().validatePassword,
      onChanged: onChanged,
      onSaved: onSaved,
    );
  }
}

class NumberFormField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final bool required;
  final double? min;
  final double? max;
  final bool allowDecimals;
  final void Function(String)? onChanged;
  final void Function(String?)? onSaved;

  const NumberFormField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.required = false,
    this.min,
    this.max,
    this.allowDecimals = false,
    this.onChanged,
    this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    return EnhancedTextFormField(
      controller: controller,
      labelText: labelText,
      hintText: hintText,
      required: required,
      keyboardType: TextInputType.numberWithOptions(decimal: allowDecimals),
      prefixIcon: Icons.numbers,
      inputFormatters: [
        if (allowDecimals)
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))
        else
          FilteringTextInputFormatter.digitsOnly,
      ],
      validator: (value) => FormValidationService().validateNumber(
        value,
        fieldName: labelText ?? 'Bu alan',
        required: required,
        min: min,
        max: max,
      ),
      onChanged: onChanged,
      onSaved: onSaved,
    );
  }
}

class MultilineFormField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final bool required;
  final int maxLines;
  final int? maxLength;
  final void Function(String)? onChanged;
  final void Function(String?)? onSaved;

  const MultilineFormField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.required = false,
    this.maxLines = 3,
    this.maxLength,
    this.onChanged,
    this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    return EnhancedTextFormField(
      controller: controller,
      labelText: labelText,
      hintText: hintText,
      required: required,
      maxLines: maxLines,
      maxLength: maxLength,
      keyboardType: TextInputType.multiline,
      validator: required
          ? (value) => FormValidationService().validateText(
                value,
                fieldName: labelText ?? 'Bu alan',
                required: required,
              )
          : null,
      onChanged: onChanged,
      onSaved: onSaved,
    );
  }
}

class SearchFormField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final void Function(String)? onChanged;
  final VoidCallback? onClear;

  const SearchFormField({
    super.key,
    this.controller,
    this.hintText = 'Ara...',
    this.onChanged,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: controller?.text.isNotEmpty == true
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  controller?.clear();
                  onClear?.call();
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      onChanged: onChanged,
    );
  }
}