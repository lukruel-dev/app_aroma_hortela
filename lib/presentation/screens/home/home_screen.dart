import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/agendamento_model.dart';
import '../../providers/cliente_provider.dart';
import '../../providers/agendamento_provider.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/loading_widget.dart';
import '../clientes/cliente_list_screen.dart';
import '../clientes/cliente_form_screen.dart';
import '../agendamentos/agendamento_list_screen.dart';
import '../agendamentos/agendamento_form_screen.dart';

/// Tela inicial (Dashboard) do app Aroma de Hortelã
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    final clienteProvider = context.read<ClienteProvider>();
    final agendamentoProvider = context.read<AgendamentoProvider>();

    await Future.wait([
      clienteProvider.carregarClientes(),
      agendamentoProvider.carregarAgendamentosHoje(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(top: 16), // Empurra o logo pra baixo
          child: Image.asset(
            'assets/images/logo_icon.png',
            height: 170, // Aumentei de 150 pra 170
          ),
        ),
        centerTitle: true,
        toolbarHeight: 200, // Aumentei de 180 pra 200 pra acomodar
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _carregarDados,
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _carregarDados,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Saudação
              _buildSaudacao(),
              const SizedBox(height: 24),

              // Cards de estatísticas
              _buildEstatisticas(),
              const SizedBox(height: 24),

              // Ações rápidas
              _buildAcoesRapidas(),
              const SizedBox(height: 24),

              // Agendamentos de hoje
              _buildAgendamentosHoje(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }



  /// Saudação com base no horário
  Widget _buildSaudacao() {
    final hora = DateTime.now().hour;
    String saudacao;

    if (hora < 12) {
      saudacao = 'Bom dia';
    } else if (hora < 18) {
      saudacao = 'Boa tarde';
    } else {
      saudacao = 'Boa noite';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$saudacao! 👋',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Confira sua agenda de hoje',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  /// Cards de estatísticas
  Widget _buildEstatisticas() {
    return Consumer2<ClienteProvider, AgendamentoProvider>(
      builder: (context, clienteProvider, agendamentoProvider, _) {
        if (clienteProvider.isLoading || agendamentoProvider.isLoading) {
          return SizedBox(
            height: 120,
            child: ShimmerLoading(
              child: Row(
                children: [
                  Expanded(child: ShimmerPlaceholder.card(height: 120)),
                  const SizedBox(width: 12),
                  Expanded(child: ShimmerPlaceholder.card(height: 120)),
                ],
              ),
            ),
          );
        }

        return Row(
          children: [
            // Total de clientes
            Expanded(
              child: AppStatCard(
                title: 'Clientes',
                value: clienteProvider.totalClientesAtivos.toString(),
                subtitle: 'ativos',
                icon: Icons.people_outline,
                color: AppColors.primary,
                onTap: () => _navegarParaClientes(),
              ),
            ),
            const SizedBox(width: 12),
            // Agendamentos de hoje
            Expanded(
              child: AppStatCard(
                title: 'Hoje',
                value: agendamentoProvider.totalAgendamentosHoje.toString(),
                subtitle: 'agendamentos',
                icon: Icons.calendar_today_outlined,
                color: AppColors.secondary,
                onTap: () => _navegarParaAgendamentos(),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Ações rápidas
  Widget _buildAcoesRapidas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ações Rápidas',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: AppActionCard(
                title: 'Novo Cliente',
                icon: Icons.person_add_outlined,
                color: AppColors.primary,
                isCompact: true,
                onTap: () => _navegarParaNovoCliente(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppActionCard(
                title: 'Agendar',
                icon: Icons.event_outlined,
                color: AppColors.info,
                isCompact: true,
                onTap: () => _navegarParaNovoAgendamento(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppActionCard(
                title: 'Clientes',
                icon: Icons.people_outline,
                color: AppColors.warning,
                isCompact: true,
                onTap: () => _navegarParaClientes(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Lista de agendamentos de hoje
Widget _buildAgendamentosHoje() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(  // ← ADICIONA ISSO
            child: Text(
              'Agendamentos de Hoje',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,  // ← ADICIONA ISSO
            ),
          ),
          TextButton(
            onPressed: () => _navegarParaAgendamentos(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),  // ← REDUZ PADDING
              minimumSize: Size.zero,  // ← REMOVE TAMANHO MÍNIMO
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,  // ← COMPACTA
            ),
            child: Text(
              'Ver todos',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      Consumer<AgendamentoProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const ListLoadingWidget(itemCount: 3, itemHeight: 90);
          }

          if (provider.erro != null) {
            return ErrorStateWidget.carregamento(
              onRetry: _carregarDados,
            );
          }

          if (provider.agendamentosHoje.isEmpty) {
            return const EmptyStateWidget.agendamentosHoje();
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: provider.agendamentosHoje.length > 5
                ? 5
                : provider.agendamentosHoje.length,
            itemBuilder: (context, index) {
              final agendamento = provider.agendamentosHoje[index];
              return _buildAgendamentoCard(agendamento);
            },
          );
        },
      ),
    ],
  );
}


  /// Card de agendamento
  Widget _buildAgendamentoCard(AgendamentoModel agendamento) {
    return Consumer<ClienteProvider>(
      builder: (context, clienteProvider, _) {
        final cliente = clienteProvider.buscarPorIdLocal(agendamento.clienteId);
        final nomeCliente = cliente?.nome ?? 'Cliente não encontrado';

        return AppListCard(
          margin: const EdgeInsets.only(bottom: 12),
          title: nomeCliente,
          subtitle: '${agendamento.horaFormatada} - ${agendamento.procedimento}',
          description: agendamento.observacoes,
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getStatusColor(agendamento.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(
                _getStatusIcon(agendamento.status),
                color: _getStatusColor(agendamento.status),
                size: 24,
              ),
            ),
          ),
          trailing: AppTag(
            text: agendamento.status,
            backgroundColor: _getStatusColor(agendamento.status).withOpacity(0.1),
            textColor: _getStatusColor(agendamento.status),
            isSmall: true,
          ),
          onTap: () => _mostrarDetalhesAgendamento(agendamento),
        );
      },
    );
  }

  /// Retorna a cor baseada no status
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Agendado':
        return AppColors.info;
      case 'Confirmado':
        return AppColors.primary;
      case 'Em andamento':
        return AppColors.warning;
      case 'Concluído':
        return AppColors.success;
      case 'Cancelado':
        return AppColors.error;
      case 'Não compareceu':
        return AppColors.textDisabled;
      default:
        return AppColors.textSecondary;
    }
  }

  /// Retorna o ícone baseado no status
  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Agendado':
        return Icons.schedule;
      case 'Confirmado':
        return Icons.check_circle_outline;
      case 'Em andamento':
        return Icons.play_circle_outline;
      case 'Concluído':
        return Icons.task_alt;
      case 'Cancelado':
        return Icons.cancel_outlined;
      case 'Não compareceu':
        return Icons.person_off_outlined;
      default:
        return Icons.event;
    }
  }

  // ============================================
  // NAVEGAÇÃO
  // ============================================

  void _navegarParaClientes() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ClienteListScreen()),
    );
  }

  void _navegarParaNovoCliente() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ClienteFormScreen()),
    );
  }

  void _navegarParaAgendamentos() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AgendamentoListScreen()),
    );
  }

  void _navegarParaNovoAgendamento() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AgendamentoFormScreen()),
    );
  }

  void _mostrarDetalhesAgendamento(AgendamentoModel agendamento) {
    final clienteProvider = context.read<ClienteProvider>();
    final cliente = clienteProvider.buscarPorIdLocal(agendamento.clienteId);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Título
            Text(
              'Detalhes do Agendamento',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            // Cliente
            _buildDetalheItem(
              icon: Icons.person_outline,
              label: 'Cliente',
              value: cliente?.nome ?? 'Não encontrado',
            ),

            // Data e hora
            _buildDetalheItem(
              icon: Icons.schedule,
              label: 'Data e Hora',
              value: '${agendamento.dataFormatada} às ${agendamento.horaFormatada}',
            ),

            // Procedimento
            _buildDetalheItem(
              icon: Icons.spa_outlined,
              label: 'Procedimento',
              value: agendamento.procedimento,
            ),

            // Status
            _buildDetalheItem(
              icon: Icons.info_outline,
              label: 'Status',
              value: agendamento.status,
              valueColor: _getStatusColor(agendamento.status),
            ),

            // Observações
            if (agendamento.observacoes != null &&
                agendamento.observacoes!.isNotEmpty)
              _buildDetalheItem(
                icon: Icons.notes,
                label: 'Observações',
                value: agendamento.observacoes!,
              ),

            const SizedBox(height: 24),

            // Botão de fechar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fechar'),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildDetalheItem({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: valueColor ?? AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
