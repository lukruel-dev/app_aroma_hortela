import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/anamnese_model.dart';
import '../../providers/anamnese_provider.dart';
import 'anamnese_form_screen.dart';
import 'anamnese_detail_screen.dart';

class AnamneseListScreen extends StatefulWidget {
  final String? clienteId;
  final String? clienteNome;

  const AnamneseListScreen({
    super.key,
    this.clienteId,
    this.clienteNome,
  });

  @override
  State<AnamneseListScreen> createState() => _AnamneseListScreenState();
}

class _AnamneseListScreenState extends State<AnamneseListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _carregarAnamneses();
    });
  }

  Future<void> _carregarAnamneses() async {
    final provider = context.read<AnamneseProvider>();
    if (widget.clienteId != null) {
      await provider.carregarAnamnesesDoCliente(widget.clienteId!);
    } else {
      await provider.carregarAnamneses();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isClienteEspecifico = widget.clienteId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isClienteEspecifico
              ? 'Anamneses - ${widget.clienteNome}'
              : 'Todas as Anamneses',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _carregarAnamneses,
          ),
        ],
      ),
      body: Consumer<AnamneseProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.erro != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(provider.erro!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _carregarAnamneses,
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          final anamneses = isClienteEspecifico
              ? provider.anamnesesDoCliente
              : provider.anamneses;

          if (anamneses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhuma anamnese encontrada',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  if (isClienteEspecifico) ...[
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => _navegarParaFormulario(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Criar Anamnese'),
                    ),
                  ],
                ],
              ),
            );
          }

          // ✅ Lista com botão no topo
          return Column(
            children: [
              // ✅ Botão no topo (só para cliente específico)
              if (isClienteEspecifico)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _navegarParaFormulario(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Criar Anamnese'),
                    ),
                  ),
                ),
              // Lista
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _carregarAnamneses,
                  child: ListView.builder(
                    padding: EdgeInsets.only(
                      left: AppConstants.screenPadding,
                      right: AppConstants.screenPadding,
                      top: isClienteEspecifico ? 0 : AppConstants.screenPadding,
                      bottom: AppConstants.screenPadding,
                    ),
                    itemCount: anamneses.length,
                    itemBuilder: (context, index) {
                      final anamnese = anamneses[index];
                      return _AnamneseCard(
                        anamnese: anamnese,
                        mostrarNomeCliente: !isClienteEspecifico,
                        onTap: () => _navegarParaDetalhes(context, anamnese),
                        onEdit: () => _navegarParaEdicao(context, anamnese),
                        onDelete: () => _confirmarExclusao(context, anamnese),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
      // ✅ REMOVIDO o FloatingActionButton
    );
  }

  void _navegarParaFormulario(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AnamneseFormScreen(
          clienteId: widget.clienteId!,
          clienteNome: widget.clienteNome!,
        ),
      ),
    ).then((_) => _carregarAnamneses());
  }

  void _navegarParaDetalhes(BuildContext context, AnamneseModel anamnese) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AnamneseDetailScreen(anamnese: anamnese),
      ),
    ).then((_) => _carregarAnamneses());
  }

  void _navegarParaEdicao(BuildContext context, AnamneseModel anamnese) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AnamneseFormScreen(
          clienteId: anamnese.clienteId,
          clienteNome: anamnese.clienteNome,
          anamnese: anamnese,
        ),
      ),
    ).then((_) => _carregarAnamneses());
  }

  Future<void> _confirmarExclusao(BuildContext context, AnamneseModel anamnese) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Anamnese'),
        content: Text(
          'Deseja excluir a anamnese de ${DateFormat('dd/MM/yyyy').format(anamnese.dataAvaliacao)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmar == true && mounted) {
      final provider = context.read<AnamneseProvider>();
      final sucesso = await provider.excluirAnamnese(anamnese.id!);

      if (sucesso && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Anamnese excluída com sucesso'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}

class _AnamneseCard extends StatelessWidget {
  final AnamneseModel anamnese;
  final bool mostrarNomeCliente;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AnamneseCard({
    required this.anamnese,
    required this.mostrarNomeCliente,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.assignment,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (mostrarNomeCliente)
                          Text(
                            anamnese.clienteNome,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        Text(
                          dateFormat.format(anamnese.dataAvaliacao),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: mostrarNomeCliente ? 14 : 16,
                            fontWeight: mostrarNomeCliente ? null : FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') onEdit();
                      if (value == 'delete') onDelete();
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Editar'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Excluir', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Queixa: ${anamnese.queixaPrincipal}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[700]),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  _buildChip(Icons.psychology, anamnese.nivelEstresse),
                  _buildChip(Icons.bed, anamnese.qualidadeSono),
                  if (anamnese.isGestante)
                    _buildChip(Icons.pregnant_woman, 'Gestante', Colors.pink),
                  if (anamnese.temContraindicacoes)
                    _buildChip(Icons.warning, 'Contraindicações', Colors.orange),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(IconData icon, String label, [Color? color]) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (color ?? Colors.grey).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color ?? Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: color ?? Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
