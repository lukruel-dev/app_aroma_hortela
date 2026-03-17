import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/cliente_model.dart';
import '../../../data/models/agendamento_model.dart';
import '../../../data/models/anamnese_model.dart';
import '../../providers/cliente_provider.dart';
import '../../providers/agendamento_provider.dart';
import '../../providers/anamnese_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/loading_widget.dart';
import 'cliente_form_screen.dart';
import '../agendamentos/agendamento_form_screen.dart';
import '../anamneses/anamnese_form_screen.dart';
import '../anamneses/anamnese_detail_screen.dart';

/// Tela de detalhes do cliente
class ClienteDetailScreen extends StatefulWidget {
  final ClienteModel cliente;

  const ClienteDetailScreen({
    super.key,
    required this.cliente,
  });

  @override
  State<ClienteDetailScreen> createState() => _ClienteDetailScreenState();
}

class _ClienteDetailScreenState extends State<ClienteDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ClienteModel _cliente;
  bool _dadosCarregados = false;

  @override
  void initState() {
    super.initState();
    _cliente = widget.cliente;
    _tabController = TabController(length: 3, vsync: this);
    
    // Carrega dados após o frame atual
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _carregarDados();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _carregarDados() async {
    if (_cliente.id != null && mounted) {
      await Future.wait([
        context.read<AgendamentoProvider>().carregarAgendamentosPorCliente(_cliente.id!),
        context.read<AnamneseProvider>().carregarAnamnesesDoCliente(_cliente.id!),
      ]);
      if (mounted) {
        setState(() => _dadosCarregados = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              flexibleSpace: FlexibleSpaceBar(
                background: _buildHeader(),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _editarCliente(),
                  tooltip: 'Editar',
                ),
                PopupMenuButton<String>(
                  onSelected: _onMenuSelected,
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'agendar',
                      child: Row(
                        children: [
                          Icon(Icons.event, color: AppColors.textPrimary),
                          const SizedBox(width: 12),
                          const Text('Novo agendamento'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'anamnese',
                      child: Row(
                        children: [
                          Icon(Icons.assignment, color: AppColors.textPrimary),
                          const SizedBox(width: 12),
                          const Text('Nova anamnese'),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem(
                      value: _cliente.isAtivo ? 'desativar' : 'ativar',
                      child: Row(
                        children: [
                          Icon(
                            _cliente.isAtivo ? Icons.person_off : Icons.person,
                            color: _cliente.isAtivo
                                ? AppColors.error
                                : AppColors.success,
                          ),
                          const SizedBox(width: 12),
                          Text(_cliente.isAtivo ? 'Desativar' : 'Ativar'),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem(
                      value: 'excluir',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: AppColors.error),
                          const SizedBox(width: 12),
                          const Text('Excluir'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
              bottom: TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabAlignment: TabAlignment.center,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 13,
                ),
                labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                tabs: const [
                  Tab(text: 'Informações'),
                  Tab(text: 'Anamnese'),
                  Tab(text: 'Agendamentos'),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildTabInformacoes(),
            _buildTabAnamnese(),
            _buildTabAgendamentos(),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }


  /// FAB dinâmico baseado na aba selecionada
  Widget _buildFAB() {
    return ListenableBuilder(
      listenable: _tabController,
      builder: (context, child) {
        if (_tabController.index == 0) {
          return const SizedBox.shrink();
        }
        
        if (_tabController.index == 1) {
          return FloatingActionButton(
            onPressed: () => _novaAnamnese(),
            backgroundColor: AppColors.primary,
            tooltip: 'Nova Anamnese',
            child: const Icon(Icons.add),
          );
        }
        
        return FloatingActionButton(
          onPressed: () => _novoAgendamento(),
          backgroundColor: AppColors.primary,
          tooltip: 'Novo Agendamento',
          child: const Icon(Icons.add),
        );
      },
    );
  }

  /// Header com avatar e informações principais
  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 48, 16, 48),
          child: Row(
            children: [
              _buildAvatar(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _cliente.nome,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _cliente.telefoneFormatado,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    if (!_cliente.isAtivo) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'INATIVO',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildAvatar() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white30, width: 2),
      ),
      child: Center(
        child: Text(
          _cliente.iniciais,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  /// Tab de informações
  Widget _buildTabInformacoes() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSecao(
          titulo: 'Contato',
          icon: Icons.contact_phone_outlined,
          children: [
            _buildInfoItem(
              icon: Icons.phone_outlined,
              label: 'Telefone',
              value: _cliente.telefoneFormatado,
              onTap: () => _copiarParaClipboard(
                _cliente.telefone,
                'Telefone copiado',
              ),
              actionIcon: Icons.copy,
            ),
            if (_cliente.email != null && _cliente.email!.isNotEmpty)
              _buildInfoItem(
                icon: Icons.email_outlined,
                label: 'E-mail',
                value: _cliente.email!,
                onTap: () => _copiarParaClipboard(
                  _cliente.email!,
                  'E-mail copiado',
                ),
                actionIcon: Icons.copy,
              ),
          ],
        ),
        const SizedBox(height: 16),
        _buildSecao(
          titulo: 'Dados Pessoais',
          icon: Icons.person_outline,
          children: [
            if (_cliente.cpf != null && _cliente.cpf!.isNotEmpty)
              _buildInfoItem(
                icon: Icons.badge_outlined,
                label: 'CPF',
                value: _cliente.cpfFormatado ?? _cliente.cpf!,
              ),
            if (_cliente.dataNascimento != null)
              _buildInfoItem(
                icon: Icons.cake_outlined,
                label: 'Data de Nascimento',
                value: _cliente.dataNascimentoFormatada!,
                subtitle: _cliente.idade != null ? '${_cliente.idade} anos' : null,
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (_cliente.endereco != null && _cliente.endereco!.isNotEmpty) ...[
          _buildSecao(
            titulo: 'Endereço',
            icon: Icons.location_on_outlined,
            children: [
              _buildInfoItem(
                icon: Icons.map_outlined,
                label: 'Endereço',
                value: _cliente.endereco!,
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
        if (_cliente.observacoes != null && _cliente.observacoes!.isNotEmpty) ...[
          _buildSecao(
            titulo: 'Observações',
            icon: Icons.notes_outlined,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _cliente.observacoes!,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
        _buildSecao(
          titulo: 'Cadastro',
          icon: Icons.info_outline,
          children: [
            _buildInfoItem(
              icon: Icons.calendar_today_outlined,
              label: 'Data de cadastro',
              value: _formatarDataHora(_cliente.dataCadastro),
            ),
            _buildInfoItem(
              icon: Icons.circle,
              label: 'Status',
              value: _cliente.isAtivo ? 'Ativo' : 'Inativo',
              valueColor: _cliente.isAtivo ? AppColors.success : AppColors.error,
            ),
          ],
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  /// Tab de anamnese
  Widget _buildTabAnamnese() {
    return Consumer<AnamneseProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const ListLoadingWidget(itemCount: 2);
        }

        if (provider.anamnesesDoCliente.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.assignment_outlined,
            title: 'Nenhuma anamnese',
            subtitle: 'Este cliente ainda não possui ficha de anamnese',
            actionText: 'Criar Anamnese',
            onAction: () => _novaAnamnese(),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.anamnesesDoCliente.length + 1,
          itemBuilder: (context, index) {
            if (index == provider.anamnesesDoCliente.length) {
              return const SizedBox(height: 80);
            }

            final anamnese = provider.anamnesesDoCliente[index];
            return _buildAnamneseCard(anamnese, isRecente: index == 0);
          },
        );
      },
    );
  }

  Widget _buildAnamneseCard(AnamneseModel anamnese, {bool isRecente = false}) {
  final dateFormat = DateFormat('dd/MM/yyyy');

  return AppListCard(
    margin: const EdgeInsets.only(bottom: 12),
    title: 'Avaliação ${dateFormat.format(anamnese.dataAvaliacao)}',
    subtitle: anamnese.queixaPrincipal,
    leading: Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isRecente
            ? AppColors.primary.withOpacity(0.1)
            : AppColors.textHint.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Icon(
          Icons.assignment,
          color: isRecente ? AppColors.primary : AppColors.textHint,
          size: 24,
        ),
      ),
    ),
    trailing: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (isRecente)
          AppTag(
            text: 'Mais recente',
            backgroundColor: AppColors.success.withOpacity(0.1),
            textColor: AppColors.success,
            isSmall: true,
          ),
        if (anamnese.isGestante)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: AppTag(
              text: 'Gestante',
              backgroundColor: Colors.pink.withOpacity(0.1),
              textColor: Colors.pink,
              isSmall: true,
            ),
          ),
        if (anamnese.temContraindicacoes)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: AppTag(
              text: 'Atenção',
              backgroundColor: AppColors.warning.withOpacity(0.1),
              textColor: AppColors.warning,
              isSmall: true,
            ),
          ),
      ],
    ),
    onTap: () => _verAnamnese(anamnese),
    onLongPress: () => _mostrarOpcoesAnamnese(anamnese),
  );
}

  /// Tab de agendamentos
Widget _buildTabAgendamentos() {
  return Consumer<AgendamentoProvider>(
    builder: (context, provider, _) {
      if (provider.isLoading) {
        return const ListLoadingWidget(itemCount: 3);
      }

      if (provider.agendamentosCliente.isEmpty) {
        return EmptyStateWidget(
          icon: Icons.event_outlined,
          title: 'Nenhum agendamento',
          subtitle: 'Este cliente ainda não possui agendamentos',
          actionText: 'Novo Agendamento',
          onAction: () => _novoAgendamento(),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.agendamentosCliente.length + 1,
        itemBuilder: (context, index) {
          if (index == provider.agendamentosCliente.length) {
            return const SizedBox(height: 80);
          }

          final agendamento = provider.agendamentosCliente[index];
          return _buildAgendamentoCard(agendamento);
        },
      );
    },
  );
}

void _mostrarOpcoesAgendamento(AgendamentoModel agendamento) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.visibility_outlined),
            title: const Text('Ver detalhes'),
            onTap: () {
              Navigator.pop(ctx);
              _mostrarDetalhesAgendamento(agendamento);
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: const Text('Editar'),
            onTap: () {
              Navigator.pop(ctx);
              _editarAgendamento(agendamento);
            },
          ),
          ListTile(
            leading: Icon(Icons.delete_outline, color: AppColors.error),
            title: Text('Excluir', style: TextStyle(color: AppColors.error)),
            onTap: () {
              Navigator.pop(ctx);
              _confirmarExclusaoAgendamento(agendamento);
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}

void _editarAgendamento(AgendamentoModel agendamento) async {
  final resultado = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => AgendamentoFormScreen(agendamento: agendamento),
    ),
  );
  
  if (resultado == true && mounted) {
    _carregarDados();
  }
}

void _confirmarExclusaoAgendamento(AgendamentoModel agendamento) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Excluir agendamento?'),
      content: Text(
        'Deseja excluir o agendamento de ${agendamento.procedimento} '
        'do dia ${agendamento.dataFormatada}?\n\n'
        'Esta ação não pode ser desfeita.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(ctx);
            final provider = context.read<AgendamentoProvider>();
            final sucesso = await provider.excluirAgendamento(agendamento.id!);
            
            if (mounted) {
              if (sucesso) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Agendamento excluído'),
                    backgroundColor: AppColors.success,
                  ),
                );
                _carregarDados();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(provider.erro ?? 'Erro ao excluir agendamento'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            }
          },
          style: TextButton.styleFrom(foregroundColor: AppColors.error),
          child: const Text('Excluir'),
        ),
      ],
    ),
  );
}

Widget _buildAgendamentoCard(AgendamentoModel agendamento) {
  return AppListCard(
    margin: const EdgeInsets.only(bottom: 12),
    title: agendamento.procedimento,
    subtitle: '${agendamento.dataFormatada} às ${agendamento.horaFormatada}',
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
    onLongPress: () => _mostrarOpcoesAgendamento(agendamento),
  );
}


  Widget _buildSecao({
    required String titulo,
    required IconData icon,
    required List<Widget> children,
  }) {
    return AppCard.simple(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  titulo,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.divider),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    String? subtitle,
    Color? valueColor,
    VoidCallback? onTap,
    IconData? actionIcon,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.textHint),
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
                      fontSize: 15,
                      color: valueColor ?? AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (actionIcon != null)
              Icon(actionIcon, size: 18, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }

  // ============================================
  // HELPERS
  // ============================================

  String _formatarDataHora(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/'
        '${data.month.toString().padLeft(2, '0')}/'
        '${data.year} às '
        '${data.hour.toString().padLeft(2, '0')}:'
        '${data.minute.toString().padLeft(2, '0')}';
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

  void _copiarParaClipboard(String texto, String mensagem) {
    Clipboard.setData(ClipboardData(text: texto));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ============================================
  // AÇÕES
  // ============================================

  void _onMenuSelected(String value) {
    switch (value) {
      case 'agendar':
        _novoAgendamento();
        break;
      case 'anamnese':
        _novaAnamnese();
        break;
      case 'ativar':
      case 'desativar':
        _alternarStatus();
        break;
      case 'excluir':
        _confirmarExclusao();
        break;
    }
  }

  void _editarCliente() async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ClienteFormScreen(cliente: _cliente),
      ),
    );

    if (resultado == true && mounted) {
      final provider = context.read<ClienteProvider>();
      final clienteAtualizado = provider.buscarPorIdLocal(_cliente.id!);
      if (clienteAtualizado != null) {
        setState(() {
          _cliente = clienteAtualizado;
        });
      }
    }
  }

  void _novoAgendamento() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AgendamentoFormScreen(clienteSelecionado: _cliente),
      ),
    );
    if (mounted) _carregarDados();
  }

  void _novaAnamnese() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AnamneseFormScreen(
          clienteId: _cliente.id!,
          clienteNome: _cliente.nome,
        ),
      ),
    );
    if (mounted) _carregarDados();
  }

  void _verAnamnese(AnamneseModel anamnese) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AnamneseDetailScreen(anamnese: anamnese),
      ),
    );
    if (mounted) _carregarDados();
  }

  void _mostrarOpcoesAnamnese(AnamneseModel anamnese) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('Ver detalhes'),
              onTap: () {
                Navigator.pop(ctx);
                _verAnamnese(anamnese);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Editar'),
              onTap: () async {
                Navigator.pop(ctx);
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AnamneseFormScreen(
                      clienteId: _cliente.id!,
                      clienteNome: _cliente.nome,
                      anamnese: anamnese,
                    ),
                  ),
                );
                if (mounted) _carregarDados();
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: AppColors.error),
              title: Text('Excluir', style: TextStyle(color: AppColors.error)),
              onTap: () {
                Navigator.pop(ctx);
                _confirmarExclusaoAnamnese(anamnese);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmarExclusaoAnamnese(AnamneseModel anamnese) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir anamnese?'),
        content: const Text('Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final provider = context.read<AnamneseProvider>();
              final sucesso = await provider.excluirAnamnese(anamnese.id!);
              if (sucesso && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Anamnese excluída'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  void _alternarStatus() async {
    final provider = context.read<ClienteProvider>();
    final clienteAtualizado = _cliente.copyWith(ativo: !_cliente.isAtivo);
    final sucesso = await provider.atualizarCliente(clienteAtualizado);

    if (mounted) {
      if (sucesso) {
        setState(() {
          _cliente = clienteAtualizado;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Cliente ${_cliente.isAtivo ? 'ativado' : 'desativado'}',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.erro ?? 'Erro ao atualizar cliente'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _confirmarExclusao() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir cliente?'),
        content: Text(
          'Deseja realmente excluir "${_cliente.nome}"?\n\n'
          'Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _excluirCliente();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  Future<void> _excluirCliente() async {
    final provider = context.read<ClienteProvider>();
    final sucesso = await provider.excluirCliente(_cliente.id!);

    if (mounted) {
      if (sucesso) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cliente excluído com sucesso'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.erro ?? 'Erro ao excluir cliente'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _mostrarDetalhesAgendamento(AgendamentoModel agendamento) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            Text(
              agendamento.procedimento,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetalheItem(
              icon: Icons.schedule,
              label: 'Data e Hora',
              value: '${agendamento.dataFormatada} às ${agendamento.horaFormatada}',
            ),
            _buildDetalheItem(
              icon: Icons.info_outline,
              label: 'Status',
              value: agendamento.status,
              valueColor: _getStatusColor(agendamento.status),
            ),
            if (agendamento.observacoes != null &&
                agendamento.observacoes!.isNotEmpty)
              _buildDetalheItem(
                icon: Icons.notes,
                label: 'Observações',
                value: agendamento.observacoes!,
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
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