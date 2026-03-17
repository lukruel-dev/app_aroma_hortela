import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/cliente_model.dart';
import '../../providers/cliente_provider.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/loading_widget.dart';
import 'cliente_form_screen.dart';
import 'cliente_detail_screen.dart';

/// Tela de listagem de clientes
class ClienteListScreen extends StatefulWidget {
  const ClienteListScreen({super.key});

  @override
  State<ClienteListScreen> createState() => _ClienteListScreenState();
}

class _ClienteListScreenState extends State<ClienteListScreen> {
  final TextEditingController _buscaController = TextEditingController();
  String _filtroStatus = 'todos'; // todos, ativos, inativos

  @override
  void initState() {
    super.initState();
    _carregarClientes();
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  Future<void> _carregarClientes() async {
    await context.read<ClienteProvider>().carregarClientes();
  }

  void _buscar(String termo) {
    context.read<ClienteProvider>().buscarClientes(termo);
  }

  void _limparBusca() {
    _buscaController.clear();
    context.read<ClienteProvider>().limparBusca();
  }

  List<ClienteModel> _aplicarFiltros(List<ClienteModel> clientes) {
    switch (_filtroStatus) {
      case 'ativos':
        return clientes.where((c) => c.isAtivo).toList();
      case 'inativos':
        return clientes.where((c) => !c.isAtivo).toList();
      default:
        return clientes;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Clientes'),
        actions: [
          // Filtro por status
          PopupMenuButton<String>(
            icon: Icon(
              Icons.filter_list,
              color: _filtroStatus != 'todos' ? AppColors.primary : null,
            ),
            tooltip: 'Filtrar',
            onSelected: (value) {
              setState(() {
                _filtroStatus = value;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'todos',
                child: Row(
                  children: [
                    Icon(
                      _filtroStatus == 'todos'
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    const Text('Todos'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'ativos',
                child: Row(
                  children: [
                    Icon(
                      _filtroStatus == 'ativos'
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    const Text('Ativos'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'inativos',
                child: Row(
                  children: [
                    Icon(
                      _filtroStatus == 'inativos'
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    const Text('Inativos'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Campo de busca
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _buscaController,
              decoration: InputDecoration(
                hintText: 'Buscar cliente...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _buscaController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _limparBusca,
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.divider),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.divider),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
              onChanged: _buscar,
            ),
          ),

          // Lista de clientes
          Expanded(
            child: Consumer<ClienteProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const ListLoadingWidget();
                }

                if (provider.erro != null) {
                  return ErrorStateWidget.carregamento(
                    mensagem: provider.erro,
                    onRetry: _carregarClientes,
                  );
                }

                final clientesFiltrados = _aplicarFiltros(
                  provider.isBuscando
                      ? provider.clientesFiltrados
                      : provider.clientes,
                );

                if (clientesFiltrados.isEmpty) {
                  if (provider.isBuscando) {
                    return EmptyStateWidget(
                      icon: Icons.search_off,
                      title: 'Nenhum cliente encontrado',
                      subtitle: 'Tente buscar com outros termos',
                    );
                  }

                  return EmptyStateWidget.clientes(
                    onAction: () => _navegarParaNovoCliente(),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _carregarClientes,
                  color: AppColors.primary,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: clientesFiltrados.length,
                    itemBuilder: (context, index) {
                      final cliente = clientesFiltrados[index];
                      return _buildClienteCard(cliente);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navegarParaNovoCliente(),
        backgroundColor: AppColors.primary,
        tooltip: 'Novo Cliente',
        child: const Icon(Icons.add),
      ),
    );
  }


  /// Card de cliente
  Widget _buildClienteCard(ClienteModel cliente) {
    return AppListCard(
      margin: const EdgeInsets.only(bottom: 12),
      title: cliente.nome,
      subtitle: cliente.telefoneFormatado,
      description: cliente.email,
      leading: _buildAvatar(cliente),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!cliente.isAtivo)
            const AppTag(
              text: 'Inativo',
              backgroundColor: Color(0xFFFFEBEE),
              textColor: Color(0xFFC62828),
              isSmall: true,
            ),
          const SizedBox(width: 8),
          Icon(
            Icons.chevron_right,
            color: AppColors.textHint,
          ),
        ],
      ),
      onTap: () => _navegarParaDetalhes(cliente),
      onLongPress: () => _mostrarOpcoes(cliente),
    );
  }

  /// Avatar do cliente
  Widget _buildAvatar(ClienteModel cliente) {
    final iniciais = cliente.iniciais;
    final corIndex = cliente.nome.hashCode % _avatarColors.length;
    final cor = _avatarColors[corIndex];

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: cor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          iniciais,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: cor,
          ),
        ),
      ),
    );
  }

  /// Cores para avatares
  final List<Color> _avatarColors = [
    AppColors.primary,
    AppColors.secondary,
    AppColors.info,
    AppColors.warning,
    const Color(0xFF9C27B0), // Purple
    const Color(0xFF3F51B5), // Indigo
    const Color(0xFF009688), // Teal
    const Color(0xFFFF5722), // Deep Orange
  ];

  /// Mostra opções do cliente (long press)
  void _mostrarOpcoes(ClienteModel cliente) {
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

            // Nome do cliente
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                cliente.nome,
                style: TextStyle(
                  fontSize: 18,
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
                _navegarParaDetalhes(cliente);
              },
            ),
            ListTile(
              leading: Icon(Icons.edit, color: AppColors.info),
              title: const Text('Editar'),
              onTap: () {
                Navigator.pop(context);
                _navegarParaEditar(cliente);
              },
            ),
            ListTile(
              leading: Icon(Icons.event, color: AppColors.warning),
              title: const Text('Novo agendamento'),
              onTap: () {
                Navigator.pop(context);
                _navegarParaNovoAgendamento(cliente);
              },
            ),
            ListTile(
              leading: Icon(
                cliente.isAtivo ? Icons.person_off : Icons.person,
                color: cliente.isAtivo ? AppColors.error : AppColors.success,
              ),
              title: Text(cliente.isAtivo ? 'Desativar' : 'Ativar'),
              onTap: () {
                Navigator.pop(context);
                _alternarStatusCliente(cliente);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: AppColors.error),
              title: const Text('Excluir'),
              onTap: () {
                Navigator.pop(context);
                _confirmarExclusao(cliente);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  /// Confirma exclusão de cliente
  void _confirmarExclusao(ClienteModel cliente) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir cliente?'),
        content: Text(
          'Deseja realmente excluir "${cliente.nome}"?\n\n'
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
              await _excluirCliente(cliente);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  /// Exclui o cliente
  Future<void> _excluirCliente(ClienteModel cliente) async {
    final provider = context.read<ClienteProvider>();
    final sucesso = await provider.excluirCliente(cliente.id!);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            sucesso
                ? 'Cliente excluído com sucesso'
                : provider.erro ?? 'Erro ao excluir cliente',
          ),
          backgroundColor: sucesso ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  /// Alterna status do cliente (ativo/inativo)
  Future<void> _alternarStatusCliente(ClienteModel cliente) async {
    final provider = context.read<ClienteProvider>();
    final clienteAtualizado = cliente.copyWith(ativo: !cliente.isAtivo);
    final sucesso = await provider.atualizarCliente(clienteAtualizado);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            sucesso
                ? 'Cliente ${clienteAtualizado.isAtivo ? 'ativado' : 'desativado'}'
                : provider.erro ?? 'Erro ao atualizar cliente',
          ),
          backgroundColor: sucesso ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  // ============================================
  // NAVEGAÇÃO
  // ============================================

  void _navegarParaNovoCliente() async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const ClienteFormScreen()),
    );

    if (resultado == true) {
      _carregarClientes();
    }
  }

  void _navegarParaDetalhes(ClienteModel cliente) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ClienteDetailScreen(cliente: cliente),
      ),
    );
  }

  void _navegarParaEditar(ClienteModel cliente) async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ClienteFormScreen(cliente: cliente),
      ),
    );

    if (resultado == true) {
      _carregarClientes();
    }
  }

  void _navegarParaNovoAgendamento(ClienteModel cliente) {
    // TODO: Implementar navegação para formulário de agendamento
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidade em desenvolvimento')),
    );
  }
}
