import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Tipos de botão disponíveis
enum AppButtonType {
  primary,
  secondary,
  outline,
  text,
  danger,
}

/// Tamanhos de botão disponíveis
enum AppButtonSize {
  small,
  medium,
  large,
}

/// Botão customizado padrão do app Aroma de Hortelã
/// Suporta diferentes tipos, tamanhos e estados
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final AppButtonSize size;
  final IconData? icon;
  final bool iconAtEnd;
  final bool isLoading;
  final bool isFullWidth;
  final double? width;
  final BorderRadius? borderRadius;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = AppButtonType.primary,
    this.size = AppButtonSize.medium,
    this.icon,
    this.iconAtEnd = false,
    this.isLoading = false,
    this.isFullWidth = false,
    this.width,
    this.borderRadius,
  });

  // ============================================
  // CONSTRUTORES DE CONVENIÊNCIA
  // ============================================

  /// Botão primário (verde)
  const AppButton.primary({
    super.key,
    required this.text,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.icon,
    this.iconAtEnd = false,
    this.isLoading = false,
    this.isFullWidth = false,
    this.width,
    this.borderRadius,
  }) : type = AppButtonType.primary;

  /// Botão secundário
  const AppButton.secondary({
    super.key,
    required this.text,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.icon,
    this.iconAtEnd = false,
    this.isLoading = false,
    this.isFullWidth = false,
    this.width,
    this.borderRadius,
  }) : type = AppButtonType.secondary;

  /// Botão outline (borda)
  const AppButton.outline({
    super.key,
    required this.text,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.icon,
    this.iconAtEnd = false,
    this.isLoading = false,
    this.isFullWidth = false,
    this.width,
    this.borderRadius,
  }) : type = AppButtonType.outline;

  /// Botão de texto
  const AppButton.text({
    super.key,
    required this.text,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.icon,
    this.iconAtEnd = false,
    this.isLoading = false,
    this.isFullWidth = false,
    this.width,
    this.borderRadius,
  }) : type = AppButtonType.text;

  /// Botão de perigo (vermelho)
  const AppButton.danger({
    super.key,
    required this.text,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.icon,
    this.iconAtEnd = false,
    this.isLoading = false,
    this.isFullWidth = false,
    this.width,
    this.borderRadius,
  }) : type = AppButtonType.danger;

  // ============================================
  // GETTERS DE ESTILO
  // ============================================

  /// Retorna a altura do botão baseado no tamanho
  double get _height {
    switch (size) {
      case AppButtonSize.small:
        return 36;
      case AppButtonSize.medium:
        return 48;
      case AppButtonSize.large:
        return 56;
    }
  }

  /// Retorna o padding horizontal baseado no tamanho
  double get _horizontalPadding {
    switch (size) {
      case AppButtonSize.small:
        return 12;
      case AppButtonSize.medium:
        return 20;
      case AppButtonSize.large:
        return 28;
    }
  }

  /// Retorna o tamanho da fonte baseado no tamanho
  double get _fontSize {
    switch (size) {
      case AppButtonSize.small:
        return 13;
      case AppButtonSize.medium:
        return 15;
      case AppButtonSize.large:
        return 17;
    }
  }

  /// Retorna o tamanho do ícone baseado no tamanho
  double get _iconSize {
    switch (size) {
      case AppButtonSize.small:
        return 16;
      case AppButtonSize.medium:
        return 20;
      case AppButtonSize.large:
        return 24;
    }
  }

  /// Retorna a cor de fundo do botão
  Color _getBackgroundColor(BuildContext context) {
    switch (type) {
      case AppButtonType.primary:
        return AppColors.primary;
      case AppButtonType.secondary:
        return AppColors.secondary;
      case AppButtonType.outline:
        return Colors.transparent;
      case AppButtonType.text:
        return Colors.transparent;
      case AppButtonType.danger:
        return AppColors.error;
    }
  }

  /// Retorna a cor do texto/ícone do botão
  Color _getForegroundColor(BuildContext context) {
    switch (type) {
      case AppButtonType.primary:
        return Colors.white;
      case AppButtonType.secondary:
        return AppColors.textPrimary;
      case AppButtonType.outline:
        return AppColors.primary;
      case AppButtonType.text:
        return AppColors.primary;
      case AppButtonType.danger:
        return Colors.white;
    }
  }

  /// Retorna a cor da borda do botão
  Color _getBorderColor(BuildContext context) {
    switch (type) {
      case AppButtonType.outline:
        return AppColors.primary;
      case AppButtonType.danger:
        return AppColors.error;
      default:
        return Colors.transparent;
    }
  }

  /// Retorna a cor de fundo desabilitada
  Color _getDisabledBackgroundColor(BuildContext context) {
    switch (type) {
      case AppButtonType.primary:
      case AppButtonType.secondary:
      case AppButtonType.danger:
        return AppColors.textDisabled.withOpacity(0.3);
      case AppButtonType.outline:
      case AppButtonType.text:
        return Colors.transparent;
    }
  }

  /// Retorna a cor do texto desabilitado
  Color _getDisabledForegroundColor(BuildContext context) {
    return AppColors.textDisabled;
  }

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null || isLoading;
    
    final backgroundColor = isDisabled
        ? _getDisabledBackgroundColor(context)
        : _getBackgroundColor(context);
    
    final foregroundColor = isDisabled
        ? _getDisabledForegroundColor(context)
        : _getForegroundColor(context);
    
    final borderColor = isDisabled
        ? AppColors.textDisabled.withOpacity(0.3)
        : _getBorderColor(context);

    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(12);

    // Conteúdo do botão
    Widget buttonContent = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Ícone no início
        if (icon != null && !iconAtEnd && !isLoading) ...[
          Icon(icon, size: _iconSize, color: foregroundColor),
          const SizedBox(width: 8),
        ],
        
        // Loading indicator
        if (isLoading) ...[
          SizedBox(
            width: _iconSize,
            height: _iconSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
            ),
          ),
          const SizedBox(width: 8),
        ],
        
        // Texto
        Text(
          isLoading ? 'Aguarde...' : text,
          style: TextStyle(
            fontSize: _fontSize,
            fontWeight: FontWeight.w600,
            color: foregroundColor,
          ),
        ),
        
        // Ícone no final
        if (icon != null && iconAtEnd && !isLoading) ...[
          const SizedBox(width: 8),
          Icon(icon, size: _iconSize, color: foregroundColor),
        ],
      ],
    );

    // Container do botão
    Widget button = Material(
      color: backgroundColor,
      borderRadius: effectiveBorderRadius,
      child: InkWell(
        onTap: isDisabled ? null : onPressed,
        borderRadius: effectiveBorderRadius,
        splashColor: foregroundColor.withOpacity(0.1),
        highlightColor: foregroundColor.withOpacity(0.05),
        child: Container(
          height: _height,
          width: width,
          padding: EdgeInsets.symmetric(horizontal: _horizontalPadding),
          decoration: BoxDecoration(
            borderRadius: effectiveBorderRadius,
            border: type == AppButtonType.outline
                ? Border.all(color: borderColor, width: 1.5)
                : null,
          ),
          child: buttonContent,
        ),
      ),
    );

    // Se for fullWidth, expande para ocupar toda a largura
    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }
}

/// Botão circular com ícone (FAB style)
class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;
  final String? tooltip;
  final bool isLoading;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size = 48,
    this.tooltip,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppColors.primary;
    final fgColor = iconColor ?? Colors.white;
    final isDisabled = onPressed == null || isLoading;

    Widget button = Material(
      color: isDisabled ? AppColors.textDisabled.withOpacity(0.3) : bgColor,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: isDisabled ? null : onPressed,
        customBorder: const CircleBorder(),
        splashColor: fgColor.withOpacity(0.2),
        child: SizedBox(
          width: size,
          height: size,
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: size * 0.5,
                    height: size * 0.5,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(fgColor),
                    ),
                  )
                : Icon(
                    icon,
                    size: size * 0.5,
                    color: isDisabled ? AppColors.textDisabled : fgColor,
                  ),
          ),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }
}
