import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'app_button.dart';

/// Widget de loading padrão do app
class LoadingWidget extends StatelessWidget {
  final String? message;
  final double size;
  final Color? color;

  const LoadingWidget({
    super.key,
    this.message,
    this.size = 40,
    this.color,
  });

  /// Loading pequeno para botões e inline
  const LoadingWidget.small({
    super.key,
    this.message,
    this.color,
  }) : size = 20;

  /// Loading médio padrão
  const LoadingWidget.medium({
    super.key,
    this.message,
    this.color,
  }) : size = 40;

  /// Loading grande para tela cheia
  const LoadingWidget.large({
    super.key,
    this.message,
    this.color,
  }) : size = 60;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: size > 30 ? 4 : 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? AppColors.primary,
              ),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Widget de loading que ocupa a tela inteira
class LoadingOverlay extends StatelessWidget {
  final String? message;
  final bool isLoading;
  final Widget child;

  const LoadingOverlay({
    super.key,
    this.message,
    required this.isLoading,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: LoadingWidget(message: message),
          ),
      ],
    );
  }
}

/// Widget para estados vazios (lista vazia, sem resultados, etc.)
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionText;
  final VoidCallback? onAction;
  final double iconSize;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionText,
    this.onAction,
    this.iconSize = 80,
  });

  /// Estado vazio para lista de clientes
  const EmptyStateWidget.clientes({
    super.key,
    this.actionText = 'Cadastrar Cliente',
    this.onAction,
  })  : icon = Icons.people_outline,
        title = 'Nenhum cliente cadastrado',
        subtitle = 'Comece cadastrando seu primeiro cliente',
        iconSize = 80;

  /// Estado vazio para lista de agendamentos
  const EmptyStateWidget.agendamentos({
    super.key,
    this.actionText = 'Novo Agendamento',
    this.onAction,
  })  : icon = Icons.calendar_today_outlined,
        title = 'Nenhum agendamento',
        subtitle = 'Você não possui agendamentos para este período',
        iconSize = 80;

  /// Estado vazio para agendamentos de hoje
  const EmptyStateWidget.agendamentosHoje({
    super.key,
    this.actionText = 'Novo Agendamento',
    this.onAction,
  })  : icon = Icons.event_available_outlined,
        title = 'Sem agendamentos hoje',
        subtitle = 'Aproveite para organizar sua agenda',
        iconSize = 80;

  /// Estado vazio para anamneses
  const EmptyStateWidget.anamneses({
    super.key,
    this.actionText = 'Nova Anamnese',
    this.onAction,
  })  : icon = Icons.assignment_outlined,
        title = 'Nenhuma anamnese',
        subtitle = 'Este cliente ainda não possui ficha de anamnese',
        iconSize = 80;

  /// Estado vazio para busca sem resultados
  const EmptyStateWidget.semResultados({
    super.key,
    String? termo,
  })  : icon = Icons.search_off_outlined,
        title = 'Nenhum resultado encontrado',
        subtitle = termo != null
            ? 'Não encontramos resultados para "$termo"'
            : 'Tente buscar com outros termos',
        actionText = null,
        onAction = null,
        iconSize = 80;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ícone
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: iconSize,
                color: AppColors.primary.withOpacity(0.6),
              ),
            ),

            const SizedBox(height: 24),

            // Título
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),

            // Subtítulo
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            // Botão de ação
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 24),
              AppButton.primary(
                text: actionText!,
                onPressed: onAction,
                icon: Icons.add,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Widget para estados de erro
class ErrorStateWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? actionText;
  final VoidCallback? onRetry;
  final IconData icon;

  const ErrorStateWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.actionText = 'Tentar novamente',
    this.onRetry,
    this.icon = Icons.error_outline,
  });

  /// Erro de conexão
  const ErrorStateWidget.conexao({
    super.key,
    this.onRetry,
  })  : icon = Icons.wifi_off_outlined,
        title = 'Sem conexão',
        subtitle = 'Verifique sua conexão com a internet',
        actionText = 'Tentar novamente';

  /// Erro genérico
  const ErrorStateWidget.generico({
    super.key,
    this.onRetry,
  })  : icon = Icons.error_outline,
        title = 'Ops! Algo deu errado',
        subtitle = 'Ocorreu um erro inesperado',
        actionText = 'Tentar novamente';

  /// Erro de carregamento
  const ErrorStateWidget.carregamento({
    super.key,
    this.onRetry,
    String? mensagem,
  })  : icon = Icons.cloud_off_outlined,
        title = 'Erro ao carregar',
        subtitle = mensagem ?? 'Não foi possível carregar os dados',
        actionText = 'Tentar novamente';

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ícone
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: AppColors.error.withOpacity(0.8),
              ),
            ),

            const SizedBox(height: 24),

            // Título
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),

            // Subtítulo
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            // Botão de retry
            if (actionText != null && onRetry != null) ...[
              const SizedBox(height: 24),
              AppButton.outline(
                text: actionText!,
                onPressed: onRetry,
                icon: Icons.refresh,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Widget Shimmer simplificado para loading de conteúdo
class ShimmerLoading extends StatelessWidget {
  final Widget child;
  final bool isLoading;

  const ShimmerLoading({
    super.key,
    required this.child,
    this.isLoading = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading) {
      return child;
    }

    return Opacity(
      opacity: 0.6,
      child: child,
    );
  }
}

/// Widget placeholder para shimmer
class ShimmerPlaceholder extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const ShimmerPlaceholder({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = 8,
  });

  /// Placeholder para texto de uma linha
  factory ShimmerPlaceholder.text({
    Key? key,
    double width = double.infinity,
    double height = 16,
  }) {
    return ShimmerPlaceholder(
      key: key,
      width: width,
      height: height,
      borderRadius: 4,
    );
  }

  /// Placeholder para avatar circular
  factory ShimmerPlaceholder.avatar({
    Key? key,
    double size = 48,
  }) {
    return ShimmerPlaceholder(
      key: key,
      width: size,
      height: size,
      borderRadius: 100,
    );
  }

  /// Placeholder para card
  factory ShimmerPlaceholder.card({
    Key? key,
    double width = double.infinity,
    double height = 120,
  }) {
    return ShimmerPlaceholder(
      key: key,
      width: width,
      height: height,
      borderRadius: 16,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.divider,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Loading para lista de cards (shimmer)
class ListLoadingWidget extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final EdgeInsetsGeometry? padding;

  const ListLoadingWidget({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 80,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: padding ?? const EdgeInsets.all(16),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              height: itemHeight,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                children: [
                  ShimmerPlaceholder.avatar(),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ShimmerPlaceholder.text(width: 150),
                        const SizedBox(height: 8),
                        ShimmerPlaceholder.text(width: 100, height: 12),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
