import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Card customizado padrão do app Aroma de Hortelã
/// Suporta diferentes variantes e estilos
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderRadius;
  final double? elevation;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isSelected;
  final bool isDisabled;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = 16,
    this.elevation,
    this.onTap,
    this.onLongPress,
    this.isSelected = false,
    this.isDisabled = false,
  });

  // ============================================
  // CONSTRUTORES DE CONVENIÊNCIA
  // ============================================

  /// Card simples sem interação
  const AppCard.simple({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = 16,
  })  : elevation = 0,
        onTap = null,
        onLongPress = null,
        isSelected = false,
        isDisabled = false;

  /// Card elevado com sombra
  const AppCard.elevated({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = 16,
    this.elevation = 4,
    this.onTap,
    this.onLongPress,
  })  : isSelected = false,
        isDisabled = false;

  /// Card com borda colorida
  factory AppCard.outlined({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry? padding = const EdgeInsets.all(16),
    EdgeInsetsGeometry? margin,
    Color borderColor = const Color(0xFFE0E0E0),
    double borderRadius = 16,
    VoidCallback? onTap,
  }) {
    return AppCard(
      key: key,
      padding: padding,
      margin: margin,
      borderColor: borderColor,
      borderRadius: borderRadius,
      elevation: 0,
      onTap: onTap,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor = isDisabled
        ? AppColors.divider.withOpacity(0.5)
        : isSelected
            ? AppColors.primaryLight.withOpacity(0.3)
            : backgroundColor ?? AppColors.surface;

    final effectiveBorderColor = isSelected
        ? AppColors.primary
        : borderColor ?? Colors.transparent;

    final cardContent = Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: effectiveBorderColor,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: elevation != null && elevation! > 0
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: elevation!,
                  offset: Offset(0, elevation! / 2),
                ),
              ]
            : null,
      ),
      child: child,
    );

    // Se for clicável, adiciona interação
    if (onTap != null || onLongPress != null) {
      return Padding(
        padding: margin ?? EdgeInsets.zero,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(borderRadius),
          child: InkWell(
            onTap: isDisabled ? null : onTap,
            onLongPress: isDisabled ? null : onLongPress,
            borderRadius: BorderRadius.circular(borderRadius),
            splashColor: AppColors.primary.withOpacity(0.1),
            highlightColor: AppColors.primary.withOpacity(0.05),
            child: cardContent,
          ),
        ),
      );
    }

    // Card sem interação
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: cardContent,
    );
  }
}

/// Card para exibição de informações em lista
class AppListCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? description;
  final Widget? leading;
  final Widget? trailing;
  final List<Widget>? tags;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isSelected;
  final EdgeInsetsGeometry? margin;

  const AppListCard({
    super.key,
    required this.title,
    this.subtitle,
    this.description,
    this.leading,
    this.trailing,
    this.tags,
    this.onTap,
    this.onLongPress,
    this.isSelected = false,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
        
    return AppCard(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      onLongPress: onLongPress,
      isSelected: isSelected,
      borderColor: AppColors.divider,
      child: Row(
        children: [
          // Leading (ícone ou avatar)
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 16),
          ],

          // Conteúdo principal
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                // Subtítulo
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                // Descrição
                if (description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    description!,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textHint,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                // Tags
                if (tags != null && tags!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: tags!,
                  ),
                ],
              ],
            ),
          ),

          // Trailing (ação ou indicador)
          if (trailing != null) ...[
            const SizedBox(width: 12),
            trailing!,
          ],
        ],
      ),
    );
  }
}

/// Card para estatísticas/métricas
class AppStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color? color;
  final VoidCallback? onTap;
  final double? width;

  const AppStatCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    this.color,
    this.onTap,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.primary;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      borderColor: AppColors.divider,
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ícone e título
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: effectiveColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: effectiveColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Valor
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            // Subtítulo
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textHint,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Card para ações rápidas
class AppActionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color? color;
  final VoidCallback? onTap;
  final bool isCompact;

  const AppActionCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.color,
    this.onTap,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.primary;

    if (isCompact) {
      return AppCard(
        onTap: onTap,
        padding: const EdgeInsets.all(12),
        borderColor: AppColors.divider,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: effectiveColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: effectiveColor,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
    }

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      borderColor: AppColors.divider,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: effectiveColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: effectiveColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: AppColors.textHint,
          ),
        ],
      ),
    );
  }
}

/// Tag/Chip para status ou categorias
class AppTag extends StatelessWidget {
  final String text;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final bool isSmall;

  const AppTag({
    super.key,
    required this.text,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.isSmall = false,
  });

  /// Tag de sucesso (verde)
  const AppTag.success({
    super.key,
    required this.text,
    this.icon,
    this.isSmall = false,
  })  : backgroundColor = const Color(0xFFE8F5E9),
        textColor = const Color(0xFF2E7D32);

  /// Tag de aviso (amarelo)
  const AppTag.warning({
    super.key,
    required this.text,
    this.icon,
    this.isSmall = false,
  })  : backgroundColor = const Color(0xFFFFF8E1),
        textColor = const Color(0xFFF57F17);

  /// Tag de erro (vermelho)
  const AppTag.error({
    super.key,
    required this.text,
    this.icon,
    this.isSmall = false,
  })  : backgroundColor = const Color(0xFFFFEBEE),
        textColor = const Color(0xFFC62828);

  /// Tag de informação (azul)
  const AppTag.info({
    super.key,
    required this.text,
    this.icon,
    this.isSmall = false,
  })  : backgroundColor = const Color(0xFFE3F2FD),
        textColor = const Color(0xFF1565C0);

  /// Tag primária (verde hortelã)
  const AppTag.primary({
    super.key,
    required this.text,
    this.icon,
    this.isSmall = false,
  })  : backgroundColor = const Color(0xFFE0F2F1),
        textColor = AppColors.primary;

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppColors.primaryLight.withOpacity(0.3);
    final fgColor = textColor ?? AppColors.primary;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 8 : 12,
        vertical: isSmall ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(isSmall ? 6 : 8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: isSmall ? 12 : 14,
              color: fgColor,
            ),
            SizedBox(width: isSmall ? 4 : 6),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: isSmall ? 11 : 12,
              fontWeight: FontWeight.w600,
              color: fgColor,
            ),
          ),
        ],
      ),
    );
  }
}
