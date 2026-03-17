import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/agendamento_model.dart';
import '../../providers/agendamento_provider.dart';
import '../../providers/cliente_provider.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/loading_widget.dart';
import 'agendamento_form_screen.dart';

/// Tela de listagem de agendamentos
class AgendamentoListScreen extends StatefulWidget {
  const AgendamentoListScreen({super.key});

  @override
  State<AgendamentoListScreen> createState() => _AgendamentoListScreenState();
}

class _AgendamentoListScreenState extends State<AgendamentoListScreen> {
  DateTime _dataSelecionada = DateTime.now();
  String _filtroStatus = 'todos';

  @override
  void initState() {
    super.initState();
    _carregarAgendamentos();
  }

  Future<void> _carregarAgendamentos() async {
    await context
        .read<AgendamentoProvider>()
        .carregarAgendamentosPorData(_dataSelecionada);
  }

  List<AgendamentoModel> _aplicarFiltros(List<AgendamentoModel> agendamentos) {
    if (_filtroStatus == 'todos') {
      return agendamentos;
    }
    return agendamentos.where((a) => a.status == _filtroStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Agendamentos'),
        actions: [
          // Filtro por status
          PopupMenuButton<String>(
            icon: Icon(
              Icons.filter_list,
              color: _filtroStatus != 'todos' ? AppColors.primary : null,
            ),
            tooltip: 'Filtrar por status',
            onSelected: (value) {
              setState(() {
                _filtroStatus = value;
              });
            },
            itemBuilder: (context) => [
              _buildFiltroItem('todos', 'Todos'),
              _buildFiltroItem('Agendado', 'Agendado'),
              _buildFiltroItem('Confirmado', 'Confirmado'),
              _buildFiltroItem('Em andamento', 'Em andamento'),
              _buildFiltroItem('Concluído', 'Concluído'),
              _buildFiltroItem('Cancelado', 'Cancelado'),
              _buildFiltroItem('Não compareceu', 'Não compareceu'),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Seletor de data
          _buildSeletorData(),

          // ✅ Botão de criar agendamento
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _novoAgendamento(),
                icon: const Icon(Icons.add),
                label: const Text('Criar Agendamento'),
              ),
            ),
          ),

          // Lista de agendamentos
          Expanded(
            child: Consumer<AgendamentoProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const ListLoadingWidget(itemCount: 5);
                }

                if (provider.erro != null) {
                  return ErrorStateWidget.carregamento(
                    mensagem: provider.erro,
                    onRetry: _carregarAgendamentos,
                  );
                }

                final agendamentosFiltrados = _aplicarFiltros(
                  provider.agendamentosDia,
                );

                if (agendamentosFiltrados.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.event_busy_outlined,
                    title: 'Nenhum agendamento',
                    subtitle: _filtroStatus != 'todos'
                        ? 'Nenhum agendamento com status "$_filtroStatus"'
                        : 'Não há agendamentos para ${_formatarDataExtenso(_dataSelecionada)}',
                  );
                }

                return RefreshIndicator(
                  onRefresh: _carregarAgendamentos,
                  color: AppColors.primary,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: agendamentosFiltrados.length,
                    itemBuilder: (context, index) {
                      final agendamento = agendamentosFiltrados[index];
                      return _buildAgendamentoCard(agendamento);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      // ✅ REMOVIDO o FloatingActionButton
    );
  }

  /// Item do menu de filtro
  PopupMenuItem<String> _buildFiltroItem(String value, String label) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(
            _filtroStatus == value
                ? Icons.radio_button_checked
                : Icons.radio_button_off,
            size: 20,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }

  /// Seletor de data com navegação
  Widget _buildSeletorData() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Navegação de data
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Botão anterior
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => _alterarData(-1),
                tooltip: 'Dia anterior',
              ),

              // Data selecionada (clicável)
              InkWell(
                onTap: () => _selecionarData(),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    children: [
                      Text(
                        _formatarDataExtenso(_dataSelecionada),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _getDiaSemana(_dataSelecionada),
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Botão próximo
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => _alterarData(1),
                tooltip: 'Próximo dia',
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Atalhos de data
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildAtalhoData('Ontem', -1),
              const SizedBox(width: 8),
              _buildAtalhoData('Hoje', 0),
              const SizedBox(width: 8),
              _buildAtalhoData('Amanhã', 1),
            ],
          ),
        ],
      ),
    );
  }

  /// Botão de atalho de data
  Widget _buildAtalhoData(String label, int diasDiferenca) {
    final dataAlvo = DateTime.now().add(Duration(days: diasDiferenca));
    final isSelecionado = _isMesmaData(_dataSelecionada, dataAlvo);

    return InkWell(
      onTap: () {
        setState(() {
          _dataSelecionada = dataAlvo;
        });
        _carregarAgendamentos();
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelecionado
              ? AppColors.primary
              : AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelecionado ? Colors.white : AppColors.primary,
          ),
        ),
      ),
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
            width: 56,
            height: 48,
            decoration: BoxDecoration(
              color: _getStatusColor(agendamento.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                agendamento.horaFormatada,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: _getStatusColor(agendamento.status),
                ),
              ),
            ),
          ),
          tags: [
            AppTag(
              text: agendamento.status,
              backgroundColor: _getStatusColor(agendamento.status).withOpacity(0.1),
              textColor: _getStatusColor(agendamento.status),
              isSmall: true,
            ),
          ],
          onTap: () => _mostrarDetalhes(agendamento, nomeCliente),
          onLongPress: () => _mostrarOpcoes(agendamento, nomeCliente),
        );
      },
    );
  }

  /// Mostra detalhes do agendamento
  void _mostrarDetalhes(AgendamentoModel agendamento, String nomeCliente) {
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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getStatusColor(agendamento.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getStatusIcon(agendamento.status),
                    color: _getStatusColor(agendamento.status),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        agendamento.procedimento,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      AppTag(
                        text: agendamento.status,
                        backgroundColor: _getStatusColor(agendamento.status)
                            .withOpacity(0.1),
                        textColor: _getStatusColor(agendamento.status),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Informações
            _buildDetalheItem(
              icon: Icons.person_outline,
              label: 'Cliente',
              value: nomeCliente,
            ),
            _buildDetalheItem(
              icon: Icons.calendar_today_outlined,
              label: 'Data',
              value: agendamento.dataFormatada,
            ),
            _buildDetalheItem(
              icon: Icons.schedule,
              label: 'Horário',
              value: agendamento.horaFormatada,
            ),
            if (agendamento.observacoes != null &&
                agendamento.observacoes!.isNotEmpty)
              _buildDetalheItem(
                icon: Icons.notes,
                label: 'Observações',
                value: agendamento.observacoes!,
              ),

            const SizedBox(height: 24),

            // Botões de ação
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _editarAgendamento(agendamento);
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Editar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _alterarStatus(agendamento);
                    },
                    icon: const Icon(Icons.sync),
                    label: const Text('Status'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  /// Mostra opções do agendamento (long press)
  void _mostrarOpcoes(AgendamentoModel agendamento, String nomeCliente) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),

            // Título
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                '${agendamento.procedimento}\n$nomeCliente',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),

            // Opções
            ListTile(
              leading: Icon(Icons.visibility, color: AppColors.primary),
              title: const Text('Ver detalhes'),
              onTap: () {
                Navigator.pop(context);
                _mostrarDetalhes(agendamento, nomeCliente);
              },
            ),
            ListTile(
              leading: Icon(Icons.edit, color: AppColors.info),
              title: const Text('Editar'),
              onTap: () {
                Navigator.pop(context);
                _editarAgendamento(agendamento);
              },
            ),
            ListTile(
              leading: Icon(Icons.sync, color: AppColors.warning),
              title: const Text('Alterar status'),
              onTap: () {
                Navigator.pop(context);
                _alterarStatus(agendamento);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: AppColors.error),
              title: const Text('Excluir'),
              onTap: () {
                Navigator.pop(context);
                _confirmarExclusao(agendamento);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  /// Detalhe item
  Widget _buildDetalheItem({
    required IconData icon,
    required String label,
    required String value,
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
                    color: AppColors.textPrimary,
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

  // ============================================
  // HELPERS
  // ============================================

  String _formatarDataExtenso(DateTime data) {
    final meses = [
      'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];
    return '${data.day} de ${meses[data.month - 1]}';
  }

  String _getDiaSemana(DateTime data) {
    final dias = [
      'Segunda-feira', 'Terça-feira', 'Quarta-feira',
      'Quinta-feira', 'Sexta-feira', 'Sábado', 'Domingo'
    ];
    return dias[data.weekday - 1];
  }

  bool _isMesmaData(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

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
  // AÇÕES
  // ============================================

  void _alterarData(int dias) {
    setState(() {
      _dataSelecionada = _dataSelecionada.add(Duration(days: dias));
    });
    _carregarAgendamentos();
  }

  Future<void> _selecionarData() async {
    final dataSelecionada = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('pt', 'BR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (dataSelecionada != null) {
      setState(() {
        _dataSelecionada = dataSelecionada;
      });
      _carregarAgendamentos();
    }
  }

  void _novoAgendamento() async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AgendamentoFormScreen(dataSelecionada: _dataSelecionada),
      ),
    );

    if (resultado == true) {
      _carregarAgendamentos();
    }
  }

  void _editarAgendamento(AgendamentoModel agendamento) async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AgendamentoFormScreen(agendamento: agendamento),
      ),
    );

    if (resultado == true) {
      _carregarAgendamentos();
    }
  }

  void _alterarStatus(AgendamentoModel agendamento) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),

            Text(
              'Alterar Status',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            // Status options
            ..._buildStatusOptions(agendamento),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildStatusOptions(AgendamentoModel agendamento) {
    final statusList = [
      'Agendado',
      'Confirmado',
      'Em andamento',
      'Concluído',
      'Cancelado',
      'Não compareceu',
    ];

    return statusList.map((status) {
      final isAtual = agendamento.status == status;
      return ListTile(
        leading: Icon(
          _getStatusIcon(status),
          color: _getStatusColor(status),
        ),
        title: Text(status),
        trailing: isAtual
            ? Icon(Icons.check, color: AppColors.primary)
            : null,
        onTap: isAtual
            ? null
            : () async {
                Navigator.pop(context);
                await _atualizarStatus(agendamento, status);
              },
      );
    }).toList();
  }

  Future<void> _atualizarStatus(
    AgendamentoModel agendamento,
    String novoStatus,
  ) async {
    final provider = context.read<AgendamentoProvider>();
    final agendamentoAtualizado = agendamento.copyWith(status: novoStatus);
    final sucesso = await provider.atualizarAgendamento(agendamentoAtualizado);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            sucesso
                ? 'Status atualizado para "$novoStatus"'
                : provider.erro ?? 'Erro ao atualizar status',
          ),
          backgroundColor: sucesso ? AppColors.success : AppColors.error,
        ),
      );

      if (sucesso) {
        _carregarAgendamentos();
      }
    }
  }

  void _confirmarExclusao(AgendamentoModel agendamento) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir agendamento?'),
        content: Text(
          'Deseja realmente excluir o agendamento de '
          '"${agendamento.procedimento}"?\n\n'
          'Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _excluirAgendamento(agendamento);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  Future<void> _excluirAgendamento(AgendamentoModel agendamento) async {
    final provider = context.read<AgendamentoProvider>();
    final sucesso = await provider.excluirAgendamento(agendamento.id!);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            sucesso
                ? 'Agendamento excluído com sucesso'
                : provider.erro ?? 'Erro ao excluir agendamento',
          ),
          backgroundColor: sucesso ? AppColors.success : AppColors.error,
        ),
      );

      if (sucesso) {
        _carregarAgendamentos();
      }
    }
  }
}
