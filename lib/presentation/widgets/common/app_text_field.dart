import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';

/// Campo de texto customizado padrão do app Aroma de Hortelã
/// Suporta diferentes tipos, validação e máscaras
class AppTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final String? initialValue;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final TextCapitalization textCapitalization;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final int maxLines;
  final int? minLines;
  final int? maxLength;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final Widget? prefix;
  final Widget? suffix;
  final VoidCallback? onSuffixIconPressed;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final FormFieldValidator<String>? validator;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final EdgeInsetsGeometry? contentPadding;
  final bool showCounter;

  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.controller,
    this.initialValue,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.textCapitalization = TextCapitalization.none,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.prefix,
    this.suffix,
    this.onSuffixIconPressed,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.validator,
    this.inputFormatters,
    this.focusNode,
    this.contentPadding,
    this.showCounter = false,
  });

  // ============================================
  // CONSTRUTORES DE CONVENIÊNCIA
  // ============================================

  /// Campo de texto para nome
  factory AppTextField.nome({
    Key? key,
    TextEditingController? controller,
    String? initialValue,
    ValueChanged<String>? onChanged,
    FormFieldValidator<String>? validator,
    bool enabled = true,
  }) {
    return AppTextField(
      key: key,
      label: 'Nome',
      hint: 'Digite o nome completo',
      controller: controller,
      initialValue: initialValue,
      keyboardType: TextInputType.name,
      textCapitalization: TextCapitalization.words,
      prefixIcon: Icons.person_outline,
      onChanged: onChanged,
      validator: validator,
      enabled: enabled,
    );
  }

  /// Campo de texto para email
  factory AppTextField.email({
    Key? key,
    TextEditingController? controller,
    String? initialValue,
    ValueChanged<String>? onChanged,
    FormFieldValidator<String>? validator,
    bool enabled = true,
  }) {
    return AppTextField(
      key: key,
      label: 'E-mail',
      hint: 'exemplo@email.com',
      controller: controller,
      initialValue: initialValue,
      keyboardType: TextInputType.emailAddress,
      prefixIcon: Icons.email_outlined,
      onChanged: onChanged,
      validator: validator,
      enabled: enabled,
    );
  }

  /// Campo de texto para telefone
  factory AppTextField.telefone({
    Key? key,
    TextEditingController? controller,
    String? initialValue,
    ValueChanged<String>? onChanged,
    FormFieldValidator<String>? validator,
    bool enabled = true,
  }) {
    return AppTextField(
      key: key,
      label: 'Telefone',
      hint: '(00) 00000-0000',
      controller: controller,
      initialValue: initialValue,
      keyboardType: TextInputType.phone,
      prefixIcon: Icons.phone_outlined,
      onChanged: onChanged,
      validator: validator,
      enabled: enabled,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        _TelefoneInputFormatter(),
      ],
    );
  }

  /// Campo de texto para CPF
  factory AppTextField.cpf({
    Key? key,
    TextEditingController? controller,
    String? initialValue,
    ValueChanged<String>? onChanged,
    FormFieldValidator<String>? validator,
    bool enabled = true,
  }) {
    return AppTextField(
      key: key,
      label: 'CPF',
      hint: '000.000.000-00',
      controller: controller,
      initialValue: initialValue,
      keyboardType: TextInputType.number,
      prefixIcon: Icons.badge_outlined,
      onChanged: onChanged,
      validator: validator,
      enabled: enabled,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        _CpfInputFormatter(),
      ],
    );
  }

  /// Campo de texto para data
  factory AppTextField.data({
    Key? key,
    TextEditingController? controller,
    String? initialValue,
    String label = 'Data',
    ValueChanged<String>? onChanged,
    VoidCallback? onTap,
    FormFieldValidator<String>? validator,
    bool enabled = true,
    bool readOnly = true,
  }) {
    return AppTextField(
      key: key,
      label: label,
      hint: 'DD/MM/AAAA',
      controller: controller,
      initialValue: initialValue,
      keyboardType: TextInputType.datetime,
      prefixIcon: Icons.calendar_today_outlined,
      onChanged: onChanged,
      onTap: onTap,
      validator: validator,
      enabled: enabled,
      readOnly: readOnly,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        _DataInputFormatter(),
      ],
    );
  }

  /// Campo de texto para valor monetário
  factory AppTextField.dinheiro({
    Key? key,
    TextEditingController? controller,
    String? initialValue,
    String label = 'Valor',
    ValueChanged<String>? onChanged,
    FormFieldValidator<String>? validator,
    bool enabled = true,
  }) {
    return AppTextField(
      key: key,
      label: label,
      hint: 'R\$ 0,00',
      controller: controller,
      initialValue: initialValue,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      prefixIcon: Icons.attach_money,
      onChanged: onChanged,
      validator: validator,
      enabled: enabled,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        _DinheiroInputFormatter(),
      ],
    );
  }

  /// Campo de texto multilinhas
  factory AppTextField.multiline({
    Key? key,
    required String label,
    String? hint,
    TextEditingController? controller,
    String? initialValue,
    int maxLines = 5,
    int? minLines = 3,
    int? maxLength,
    ValueChanged<String>? onChanged,
    FormFieldValidator<String>? validator,
    bool enabled = true,
    bool showCounter = true,
  }) {
    return AppTextField(
      key: key,
      label: label,
      hint: hint,
      controller: controller,
      initialValue: initialValue,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      textInputAction: TextInputAction.newline,
      keyboardType: TextInputType.multiline,
      onChanged: onChanged,
      validator: validator,
      enabled: enabled,
      showCounter: showCounter,
    );
  }

  /// Campo de texto para busca
  factory AppTextField.busca({
    Key? key,
    TextEditingController? controller,
    String? hint = 'Buscar...',
    ValueChanged<String>? onChanged,
    VoidCallback? onClear,
    bool enabled = true,
  }) {
    return AppTextField(
      key: key,
      label: '',
      hint: hint,
      controller: controller,
      prefixIcon: Icons.search,
      suffixIcon: Icons.clear,
      onSuffixIconPressed: onClear,
      onChanged: onChanged,
      enabled: enabled,
      textInputAction: TextInputAction.search,
    );
  }

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscureText;
  late FocusNode _focusNode;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _hasFocus = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        if (widget.label.isNotEmpty) ...[
          Text(
            widget.label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: hasError 
                  ? AppColors.error 
                  : _hasFocus 
                      ? AppColors.primary 
                      : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
        ],
        
        // Campo de texto
        TextFormField(
          controller: widget.controller,
          initialValue: widget.initialValue,
          focusNode: _focusNode,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          textCapitalization: widget.textCapitalization,
          obscureText: _obscureText,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          autofocus: widget.autofocus,
          maxLines: widget.obscureText ? 1 : widget.maxLines,
          minLines: widget.minLines,
          maxLength: widget.maxLength,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          onTap: widget.onTap,
          validator: widget.validator,
          inputFormatters: widget.inputFormatters,
          style: TextStyle(
            fontSize: 16,
            color: widget.enabled ? AppColors.textPrimary : AppColors.textDisabled,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(
              color: AppColors.textHint,
              fontSize: 16,
            ),
            helperText: widget.helperText,
            helperStyle: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
            errorText: widget.errorText,
            errorStyle: TextStyle(
              color: AppColors.error,
              fontSize: 12,
            ),
            counterText: widget.showCounter ? null : '',
            prefixIcon: widget.prefix ?? (widget.prefixIcon != null
                ? Icon(
                    widget.prefixIcon,
                    color: hasError
                        ? AppColors.error
                        : _hasFocus
                            ? AppColors.primary
                            : AppColors.textHint,
                    size: 22,
                  )
                : null),
            suffixIcon: widget.suffix ?? _buildSuffixIcon(),
            contentPadding: widget.contentPadding ?? 
                EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: widget.maxLines > 1 ? 16 : 0,
                ),
            filled: true,
            fillColor: widget.enabled 
                ? AppColors.surface 
                : AppColors.divider.withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.divider,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.divider,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.error,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.error,
                width: 2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.divider.withOpacity(0.5),
                width: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget? _buildSuffixIcon() {
    // Se for campo de senha, mostra o botão de mostrar/ocultar
    if (widget.obscureText) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          color: AppColors.textHint,
          size: 22,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    }
    
    // Se tiver ícone de sufixo customizado
    if (widget.suffixIcon != null) {
      return IconButton(
        icon: Icon(
          widget.suffixIcon,
          color: AppColors.textHint,
          size: 22,
        ),
        onPressed: widget.onSuffixIconPressed,
      );
    }
    
    return null;
  }
}

// ============================================
// FORMATADORES DE INPUT
// ============================================

/// Formatador para telefone: (00) 00000-0000
class _TelefoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    
    for (int i = 0; i < digits.length && i < 11; i++) {
      if (i == 0) buffer.write('(');
      if (i == 2) buffer.write(') ');
      if (i == 7) buffer.write('-');
      buffer.write(digits[i]);
    }
    
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

/// Formatador para CPF: 000.000.000-00
class _CpfInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    
    for (int i = 0; i < digits.length && i < 11; i++) {
      if (i == 3 || i == 6) buffer.write('.');
      if (i == 9) buffer.write('-');
      buffer.write(digits[i]);
    }
    
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

/// Formatador para data: DD/MM/AAAA
class _DataInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    
    for (int i = 0; i < digits.length && i < 8; i++) {
      if (i == 2 || i == 4) buffer.write('/');
      buffer.write(digits[i]);
    }
    
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

/// Formatador para valor monetário: R$ 0,00
class _DinheiroInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    
    if (digits.isEmpty) {
      return const TextEditingValue(
        text: 'R\$ 0,00',
        selection: TextSelection.collapsed(offset: 7),
      );
    }
    
    final value = int.parse(digits);
    final reais = value ~/ 100;
    final centavos = value % 100;
    
    final formatted = 'R\$ ${reais.toString()},${centavos.toString().padLeft(2, '0')}';
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
