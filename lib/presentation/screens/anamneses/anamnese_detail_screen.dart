import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/anamnese_model.dart';
import 'anamnese_form_screen.dart';

class AnamneseDetailScreen extends StatelessWidget {
  final AnamneseModel anamnese;

  const AnamneseDetailScreen({
    super.key,
    required this.anamnese,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Anamnese'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => AnamneseFormScreen(
                    clienteId: anamnese.clienteId,
                    clienteNome: anamnese.clienteNome,
                    anamnese: anamnese,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: theme.primaryColor.withOpacity(0.1),
                      child: Icon(
                        Icons.person,
                        size: 35,
                        color: theme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            anamnese.clienteNome,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Avaliação: ${dateFormat.format(anamnese.dataAvaliacao)}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Alertas importantes
            if (anamnese.isGestante || anamnese.temContraindicacoes)
              _buildAlertCard(context),

            // Queixa Principal
            _buildSection(
              context,
              icon: Icons.healing,
              title: 'Queixa Principal',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    anamnese.queixaPrincipal,
                    style: const TextStyle(fontSize: 16),
                  ),
                  if (anamnese.areasDor.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'Áreas com dor/desconforto:',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: anamnese.areasDor.map((area) {
                        return Chip(
                          label: Text(area),
                          backgroundColor: Colors.red[50],
                          labelStyle: TextStyle(color: Colors.red[700]),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),

            // Histórico de Saúde
            _buildSection(
              context,
              icon: Icons.medical_information,
              title: 'Histórico de Saúde',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (anamnese.condicoesSaude.isNotEmpty) ...[
                    const Text(
                      'Condições de saúde:',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: anamnese.condicoesSaude.map((condicao) {
                        return Chip(
                          label: Text(condicao),
                          backgroundColor: Colors.blue[50],
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                  ],
                  _buildInfoRow('Histórico Médico', anamnese.historicoMedico),
                  _buildInfoRow('Cirurgias', anamnese.cirurgias),
                  _buildInfoRow('Medicamentos em Uso', anamnese.medicamentosEmUso),
                  _buildInfoRow('Alergias', anamnese.alergias),
                ],
              ),
            ),

            // Estilo de Vida
            _buildSection(
              context,
              icon: Icons.self_improvement,
              title: 'Estilo de Vida',
              child: Column(
                children: [
                  _buildEstiloVidaRow(
                    Icons.psychology,
                    'Nível de Estresse',
                    anamnese.nivelEstresse,
                    _getCorEstresse(anamnese.nivelEstresse),
                  ),
                  const Divider(),
                  _buildEstiloVidaRow(
                    Icons.bed,
                    'Qualidade do Sono',
                    anamnese.qualidadeSono,
                    _getCorSono(anamnese.qualidadeSono),
                  ),
                  const Divider(),
                  _buildEstiloVidaRow(
                    Icons.fitness_center,
                    'Atividade Física',
                    anamnese.atividadeFisica,
                    Colors.blue,
                  ),
                  const Divider(),
                  _buildEstiloVidaRow(
                    Icons.water_drop,
                    'Consumo de Água',
                    anamnese.consumoAgua,
                    Colors.cyan,
                  ),
                ],
              ),
            ),

            // Objetivos e Preferências
            _buildSection(
              context,
              icon: Icons.flag,
              title: 'Objetivos e Preferências',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (anamnese.objetivos.isNotEmpty) ...[
                    const Text(
                      'Objetivos:',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: anamnese.objetivos.map((objetivo) {
                        return Chip(
                          label: Text(objetivo),
                          backgroundColor: Colors.green[50],
                          labelStyle: TextStyle(color: Colors.green[700]),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (anamnese.preferenciaPressao != null)
                    _buildInfoRow('Preferência de Pressão', anamnese.preferenciaPressao),
                  if (anamnese.temAreasEvitar) ...[
                    const SizedBox(height: 8),
                    const Text(
                      'Áreas a evitar:',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: anamnese.areasEvitar!.map((area) {
                        return Chip(
                          label: Text(area),
                          backgroundColor: Colors.orange[50],
                          labelStyle: TextStyle(color: Colors.orange[700]),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),

            // Contraindicações e Observações
            if (anamnese.temContraindicacoes || anamnese.observacoesGerais != null)
              _buildSection(
                context,
                icon: Icons.note,
                title: 'Observações Finais',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (anamnese.temContraindicacoes)
                      _buildInfoRow('Contraindicações', anamnese.contraindicacoes),
                    if (anamnese.observacoesGerais != null)
                      _buildInfoRow('Observações Gerais', anamnese.observacoesGerais),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // Metadados
            Center(
              child: Text(
                'Criado em: ${DateFormat('dd/MM/yyyy HH:mm').format(anamnese.createdAt)}\n'
                'Atualizado em: ${DateFormat('dd/MM/yyyy HH:mm').format(anamnese.updatedAt)}',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertCard(BuildContext context) {
    return Card(
      color: Colors.orange[50],
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange[700], size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Atenção Especial',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  if (anamnese.isGestante)
                    Text('• Cliente gestante', style: TextStyle(color: Colors.orange[800])),
                  if (anamnese.temContraindicacoes)
                    Text('• Possui contraindicações', style: TextStyle(color: Colors.orange[800])),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }

  Widget _buildEstiloVidaRow(IconData icon, String label, String value, Color color) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 12),
        Expanded(
          flex: 2, // ✅ Dá mais espaço pro label
          child: Text(label, style: const TextStyle(fontSize: 15)),
        ),
        const SizedBox(width: 8), // ✅ Espaço entre label e valor
        Expanded(
          flex: 3, // ✅ Dá espaço flexível pro valor
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              value,
              style: TextStyle(color: color, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
              maxLines: 2, // ✅ Permite quebrar em 2 linhas se necessário
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    ),
  );
}


  Color _getCorEstresse(String nivel) {
    switch (nivel) {
      case 'Baixo':
        return Colors.green;
      case 'Moderado':
        return Colors.amber;
      case 'Alto':
        return Colors.orange;
      case 'Muito alto':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getCorSono(String qualidade) {
    switch (qualidade) {
      case 'Excelente':
        return Colors.green;
      case 'Boa':
        return Colors.lightGreen;
      case 'Regular':
        return Colors.amber;
      case 'Ruim':
        return Colors.orange;
      case 'Muito ruim':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
