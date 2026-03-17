import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/anamnese_model.dart';
import '../../providers/anamnese_provider.dart';

class AnamneseFormScreen extends StatefulWidget {
  final String clienteId;
  final String clienteNome;
  final AnamneseModel? anamnese;

  const AnamneseFormScreen({
    super.key,
    required this.clienteId,
    required this.clienteNome,
    this.anamnese,
  });

  @override
  State<AnamneseFormScreen> createState() => _AnamneseFormScreenState();
}

class _AnamneseFormScreenState extends State<AnamneseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _queixaPrincipalController;
  late final TextEditingController _historicoMedicoController;
  late final TextEditingController _cirurgiasController;
  late final TextEditingController _medicamentosController;
  late final TextEditingController _alergiasController;  
  late final TextEditingController _observacoesController;

  late List<String> _areasDorSelecionadas;
  late List<String> _condicoesSaudeSelecionadas;
  late List<String> _objetivosSelecionados;
  late List<String> _areasEvitarSelecionadas;

  late String _nivelEstresse;
  late String _qualidadeSono;
  late String _atividadeFisica;
  late String _consumoAgua;
  String? _preferenciaPressao;

  bool _isLoading = false;
  int _currentStep = 0;

  bool get _isEdicao => widget.anamnese != null;

  @override
  void initState() {
    super.initState();
    final a = widget.anamnese;

    _queixaPrincipalController = TextEditingController(text: a?.queixaPrincipal ?? '');
    _historicoMedicoController = TextEditingController(text: a?.historicoMedico ?? '');
    _cirurgiasController = TextEditingController(text: a?.cirurgias ?? '');
    _medicamentosController = TextEditingController(text: a?.medicamentosEmUso ?? '');
    _alergiasController = TextEditingController(text: a?.alergias ?? '');   
    _observacoesController = TextEditingController(
      text: _juntarTextos(a?.contraindicacoes, a?.observacoesGerais),
    );

    _areasDorSelecionadas = List.from(a?.areasDor ?? []);
    _condicoesSaudeSelecionadas = List.from(a?.condicoesSaude ?? []);
    _objetivosSelecionados = List.from(a?.objetivos ?? []);
    _areasEvitarSelecionadas = List.from(a?.areasEvitar ?? []);

    _nivelEstresse = a?.nivelEstresse ?? 'Moderado';
    _qualidadeSono = a?.qualidadeSono ?? 'Regular';
    _atividadeFisica = a?.atividadeFisica ?? 'Sedentário';
    _consumoAgua = a?.consumoAgua ?? '1 a 2 litros';
    _preferenciaPressao = a?.preferenciaPressao;
  }

  // ✅ Adiciona esse método auxiliar
  String _juntarTextos(String? texto1, String? texto2) {
    final partes = <String>[];
    if (texto1 != null && texto1.trim().isNotEmpty) partes.add(texto1.trim());
    if (texto2 != null && texto2.trim().isNotEmpty) partes.add(texto2.trim());
    return partes.join('\n');
  }

  @override
  void dispose() {
    _queixaPrincipalController.dispose();
    _historicoMedicoController.dispose();
    _cirurgiasController.dispose();
    _medicamentosController.dispose();
    _alergiasController.dispose();    
    _observacoesController.dispose();
    super.dispose();
  }

// ✅ Widget auxiliar para dropdown padronizado
Widget _buildDropdownField({
  required String label,
  required String value,
  required List<String> items,
  required ValueChanged<String?> onChanged,
}) {
  return DropdownButtonFormField<String>(
    value: value,
    isExpanded: true,
    decoration: InputDecoration(
      labelText: label,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      border: const OutlineInputBorder(),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 20, // ✅ Aumenta de 18 para 20
      ),
    ),
    items: items.map((item) {
      return DropdownMenuItem(
        value: item,
        child: Text(
          item,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }).toList(),
    onChanged: onChanged,
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdicao ? 'Editar Anamnese' : 'Nova Anamnese'),
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          currentStep: _currentStep,
          onStepContinue: _onStepContinue,
          onStepCancel: _onStepCancel,
          onStepTapped: (step) => setState(() => _currentStep = step),
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                children: [
                  if (_currentStep < 4)
                    ElevatedButton(
                      onPressed: details.onStepContinue,
                      child: const Text('Próximo'),
                    )
                  else
                    ElevatedButton(
                      onPressed: _isLoading ? null : _salvar,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Salvar'),
                    ),
                  const SizedBox(width: 12),
                  if (_currentStep > 0)
                    TextButton(
                      onPressed: details.onStepCancel,
                      child: const Text('Voltar'),
                    ),
                ],
              ),
            );
          },
          steps: [
            _buildStepQueixaPrincipal(),
            _buildStepHistoricoSaude(),
            _buildStepEstiloVida(),
            _buildStepObjetivos(),
            _buildStepObservacoes(),
          ],
        ),
      ),
    );
  }

  Step _buildStepQueixaPrincipal() {
    return Step(
      title: const Text('Queixa Principal'),
      subtitle: const Text('Motivo da consulta'),
      isActive: _currentStep >= 0,
      state: _currentStep > 0 ? StepState.complete : StepState.indexed,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cliente: ${widget.clienteNome}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _queixaPrincipalController,
            decoration: const InputDecoration(
              labelText: 'Queixa Principal *',
              hintText: AppConstants.placeholderQueixaPrincipal,
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Informe a queixa principal';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          const Text(
            'Áreas com dor ou desconforto:',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppConstants.areasDor.map((area) {
              final selecionada = _areasDorSelecionadas.contains(area);
              return FilterChip(
                label: Text(area),
                selected: selecionada,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _areasDorSelecionadas.add(area);
                    } else {
                      _areasDorSelecionadas.remove(area);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Step _buildStepHistoricoSaude() {
    return Step(
      title: const Text('Histórico de Saúde'),
      subtitle: const Text('Condições médicas'),
      isActive: _currentStep >= 1,
      state: _currentStep > 1 ? StepState.complete : StepState.indexed,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Condições de saúde:',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppConstants.condicoesSaude.map((condicao) {
              final selecionada = _condicoesSaudeSelecionadas.contains(condicao);
              return FilterChip(
                label: Text(condicao),
                selected: selecionada,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _condicoesSaudeSelecionadas.add(condicao);
                    } else {
                      _condicoesSaudeSelecionadas.remove(condicao);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _historicoMedicoController,
            decoration: const InputDecoration(
              labelText: 'Histórico Médico',
              hintText: AppConstants.placeholderHistoricoMedico,
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _cirurgiasController,
            decoration: const InputDecoration(
              labelText: 'Cirurgias Anteriores',
              hintText: AppConstants.placeholderCirurgias,
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _medicamentosController,
            decoration: const InputDecoration(
              labelText: 'Medicamentos em Uso',
              hintText: AppConstants.placeholderMedicamentos,
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _alergiasController,
            decoration: const InputDecoration(
              labelText: 'Alergias',
              hintText: AppConstants.placeholderAlergias,
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

// ✅ CORRIGIDO: Labels menores e mais espaço
Step _buildStepEstiloVida() {
  return Step(
    title: const Text('Estilo de Vida'),
    subtitle: const Text('Hábitos e rotina'),
    isActive: _currentStep >= 2,
    state: _currentStep > 2 ? StepState.complete : StepState.indexed,
    content: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8), // ✅ ADICIONA ESPAÇO NO TOPO
        _buildDropdownField(
          label: 'Estresse',
          value: _nivelEstresse,
          items: AppConstants.niveisEstresse,
          onChanged: (value) => setState(() => _nivelEstresse = value!),
        ),
        const SizedBox(height: 16),
        _buildDropdownField(
          label: 'Sono',
          value: _qualidadeSono,
          items: AppConstants.qualidadesSono,
          onChanged: (value) => setState(() => _qualidadeSono = value!),
        ),
        const SizedBox(height: 16),
        _buildDropdownField(
          label: 'Atividade Física',
          value: _atividadeFisica,
          items: AppConstants.niveisAtividadeFisica,
          onChanged: (value) => setState(() => _atividadeFisica = value!),
        ),
        const SizedBox(height: 16),
        _buildDropdownField(
          label: 'Consumo de Água',
          value: _consumoAgua,
          items: AppConstants.consumoAgua,
          onChanged: (value) => setState(() => _consumoAgua = value!),
        ),
      ],
    ),
  );
}

  Step _buildStepObjetivos() {
    return Step(
      title: const Text('Objetivos'),
      subtitle: const Text('Expectativas do tratamento'),
      isActive: _currentStep >= 3,
      state: _currentStep > 3 ? StepState.complete : StepState.indexed,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Objetivos com a massoterapia:',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppConstants.objetivosMassoterapia.map((objetivo) {
              final selecionado = _objetivosSelecionados.contains(objetivo);
              return FilterChip(
                label: Text(objetivo),
                selected: selecionado,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _objetivosSelecionados.add(objetivo);
                    } else {
                      _objetivosSelecionados.remove(objetivo);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _preferenciaPressao,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Preferência de Pressão',
              floatingLabelBehavior: FloatingLabelBehavior.always,
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 18),
            ),
            items: const [
              DropdownMenuItem(value: null, child: Text('Não informado')),
              DropdownMenuItem(value: 'Leve', child: Text('Leve')),
              DropdownMenuItem(value: 'Moderada', child: Text('Moderada')),
              DropdownMenuItem(value: 'Firme', child: Text('Firme')),
            ],
            onChanged: (value) => setState(() => _preferenciaPressao = value),
          ),
          const SizedBox(height: 16),
          const Text(
            'Áreas a evitar durante a massagem:',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppConstants.areasDor.map((area) {
              final selecionada = _areasEvitarSelecionadas.contains(area);
              return FilterChip(
                label: Text(area),
                selected: selecionada,
                selectedColor: Colors.red[100],
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _areasEvitarSelecionadas.add(area);
                    } else {
                      _areasEvitarSelecionadas.remove(area);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

// ✅ CORRIGIDO: Apenas um campo de observações
Step _buildStepObservacoes() {
  return Step(
    title: const Text('Observações'),
    subtitle: const Text('Informações adicionais'),
    isActive: _currentStep >= 4,
    state: StepState.indexed,
    content: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _observacoesController,
          decoration: const InputDecoration(
            labelText: 'Observações',
            hintText: 'Contraindicações, restrições, preferências especiais...',
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
          maxLines: 5,
        ),
      ],
    ),
  );
}

  void _onStepContinue() {
    if (_currentStep == 0) {
      if (_queixaPrincipalController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Informe a queixa principal')),
        );
        return;
      }
    }
    if (_currentStep < 4) {
      setState(() => _currentStep++);
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  // ✅ CORRIGIDO: Com debug para encontrar o problema
  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final provider = context.read<AnamneseProvider>();

      final anamnese = AnamneseModel(
        id: widget.anamnese?.id,
        clienteId: widget.clienteId,
        clienteNome: widget.clienteNome,
        dataAvaliacao: widget.anamnese?.dataAvaliacao ?? DateTime.now(),
        queixaPrincipal: _queixaPrincipalController.text.trim(),
        areasDor: _areasDorSelecionadas,
        historicoMedico: _historicoMedicoController.text.trim().isEmpty
            ? null
            : _historicoMedicoController.text.trim(),
        condicoesSaude: _condicoesSaudeSelecionadas,
        cirurgias: _cirurgiasController.text.trim().isEmpty
            ? null
            : _cirurgiasController.text.trim(),
        medicamentosEmUso: _medicamentosController.text.trim().isEmpty
            ? null
            : _medicamentosController.text.trim(),
        alergias: _alergiasController.text.trim().isEmpty
            ? null
            : _alergiasController.text.trim(),
        nivelEstresse: _nivelEstresse,
        qualidadeSono: _qualidadeSono,
        atividadeFisica: _atividadeFisica,
        consumoAgua: _consumoAgua,
        objetivos: _objetivosSelecionados,
        preferenciaPressao: _preferenciaPressao,
        areasEvitar: _areasEvitarSelecionadas.isEmpty ? null : _areasEvitarSelecionadas,
        contraindicacoes: null, // Não usa mais separado            
        observacoesGerais: _observacoesController.text.trim().isEmpty
            ? null
            : _observacoesController.text.trim(),
        createdAt: widget.anamnese?.createdAt,
      );

      // ✅ DEBUG
      debugPrint('🔍 Salvando anamnese...');
      debugPrint('🔍 clienteId: ${anamnese.clienteId}');
      debugPrint('🔍 clienteNome: ${anamnese.clienteNome}');
      debugPrint('🔍 isEdicao: $_isEdicao');

      bool sucesso;
      if (_isEdicao) {
        sucesso = await provider.atualizarAnamnese(anamnese);
        debugPrint('🔍 Resultado atualização: $sucesso');
      } else {
        final id = await provider.criarAnamnese(anamnese);
        debugPrint('🔍 ID retornado: $id');
        sucesso = id != null;
      }

      // ✅ DEBUG: Verificar erro do provider
      if (provider.erro != null) {
        debugPrint('❌ Erro do provider: ${provider.erro}');
      }

      if (mounted) {
        if (sucesso) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isEdicao ? 'Anamnese atualizada!' : 'Anamnese criada!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // ✅ Retorna true para indicar sucesso
        } else {
          final erro = provider.erro;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(erro ?? 'Erro ao salvar anamnese'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e, stack) {
      debugPrint('❌ Exception: $e');
      debugPrint('❌ Stack: $stack');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
