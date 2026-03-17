import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/agendamento_model.dart';
import '../../../data/models/cliente_model.dart';
import '../../providers/agendamento_provider.dart';
import '../../providers/cliente_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';

/// Tela de cadastro/edição de agendamentos
class AgendamentoFormScreen extends StatefulWidget {
  final AgendamentoModel? agendamento;
  final ClienteModel? clienteSelecionado;
  final DateTime? dataSelecionada;

  const AgendamentoFormScreen({
    super.key,
    this.agendamento,
    this.clienteSelecionado,
    this.dataSelecionada,
  });

  @override
  State<AgendamentoFormScreen> createState() => _AgendamentoFormScreenState();
}

class _AgendamentoFormScreenState extends State<AgendamentoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _observacoesController = TextEditingController();
  final _dataController = TextEditingController();
  final _horaController = TextEditingController();
  final _valorController = TextEditingController();

  ClienteModel? _clienteSelecionado;
  String? _procedimentoSelecionado;
  String _statusSelecionado = 'Agendado';
  String _duracaoSelecionada = '1 hora';
  DateTime _dataSelecionada = DateTime.now();
  TimeOfDay _horaSelecionada = TimeOfDay.now();

  bool _isLoading = false;
  bool get _isEdicao => widget.agendamento != null;

  @override
  void initState() {
    super.initState();
    _inicializarDados();
  }

  @override
  void dispose() {
    _observacoesController.dispose();
    _dataController.dispose();
    _horaController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  void _inicializarDados() {
    if (_isEdicao) {
      final agendamento = widget.agendamento!;
      _procedimentoSelecionado = agendamento.tipoMassagem;
      _observacoesController.text = agendamento.observacoes ?? '';
      _statusSelecionado = agendamento.status;
      _duracaoSelecionada = agendamento.duracao;
      _dataSelecionada = agendamento.dataHora;
      _horaSelecionada = TimeOfDay.fromDateTime(agendamento.dataHora);
      if (agendamento.valor != null) {
        _valorController.text = agendamento.valor!.toStringAsFixed(2).replaceAll('.', ',');
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final clienteProvider = context.read<ClienteProvider>();
        setState(() {
          _clienteSelecionado = clienteProvider.buscarPorIdLocal(
            agendamento.clienteId,
          );
        });
      });
    } else {
      if (widget.clienteSelecionado != null) {
        _clienteSelecionado = widget.clienteSelecionado;
      }
      if (widget.dataSelecionada != null) {
        _dataSelecionada = widget.dataSelecionada!;
      }
    }

    _atualizarDataController();
    _atualizarHoraController();
  }

  void _atualizarDataController() {
    _dataController.text = _formatarData(_dataSelecionada);
  }

  void _atualizarHoraController() {
    _horaController.text = _formatarHora(_horaSelecionada);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEdicao ? 'Editar Agendamento' : 'Novo Agendamento'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Seção: Cliente
            _buildSecaoTitulo('Cliente'),
            const SizedBox(height: 16),
            _buildSeletorCliente(),
            const SizedBox(height: 24),

            // Seção: Procedimento
            _buildSecaoTitulo('Procedimento'),
            const SizedBox(height: 16),
            _buildSeletorProcedimento(),
            const SizedBox(height: 16),
            
            // Duração
            _buildSeletorDuracao(),
            const SizedBox(height: 16),
            
            // Valor
            AppTextField(
              controller: _valorController,
              label: 'Valor (R\$)',
              hint: '0,00',
              prefixIcon: Icons.attach_money,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 24),

            // Seção: Data e Hora
_buildSecaoTitulo('Data e Hora'),
const SizedBox(height: 16),
Row(
  children: [
    Expanded(
      flex: 3,
      child: AppTextField.data(
        controller: _dataController,
        label: 'Data',
        onTap: () => _selecionarData(),
        readOnly: true,
        validator: _validarData,
      ),
    ),
    const SizedBox(width: 16),
    Expanded(
      flex: 2,
      child: AppTextField(
        controller: _horaController,
        label: 'Hora',
        hint: '00:00',
        prefixIcon: Icons.access_time,
        readOnly: true,
        onTap: () => _selecionarHora(),
        validator: _validarHora,
      ),
    ),
  ],
),
const SizedBox(height: 24),

// Seção: Status (apenas em edição)
if (_isEdicao) ...[
  _buildSecaoTitulo('Status'),
  const SizedBox(height: 16),
  _buildSeletorStatus(),
  const SizedBox(height: 24),
],

// Seção: Observações
_buildSecaoTitulo('Observações'),
const SizedBox(height: 16),
AppTextField.multiline(
  controller: _observacoesController,
  label: 'Observações',
  hint: 'Informações adicionais sobre o agendamento...',
  maxLines: 4,
  minLines: 3,
  maxLength: 500,
),
const SizedBox(height: 32),

// Botões
_buildBotoes(),
const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }


  Widget _buildSecaoTitulo(String titulo) {
    return Text(
      titulo,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    );
  }

  /// Seletor de procedimento usando AppConstants
  Widget _buildSeletorProcedimento() {
    return DropdownButtonFormField<String>(
      value: _procedimentoSelecionado,
      decoration: InputDecoration(
        labelText: 'Procedimento *',
        prefixIcon: const Icon(Icons.spa_outlined),
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.error),
        ),
      ),
      hint: const Text('Selecione o procedimento'),
      items: AppConstants.tiposMassagem.map((procedimento) {
        return DropdownMenuItem(
          value: procedimento,
          child: Text(procedimento),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _procedimentoSelecionado = value;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Selecione um procedimento';
        }
        return null;
      },
    );
  }

  Widget _buildSeletorDuracao() {
    return DropdownButtonFormField<String>(
      value: _duracaoSelecionada,
      decoration: InputDecoration(
        labelText: 'Duração',
        prefixIcon: const Icon(Icons.timer_outlined),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.divider),
        ),
      ),
      items: AppConstants.duracoesSessao.map((duracao) {
        return DropdownMenuItem(
          value: duracao,
          child: Text(duracao),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _duracaoSelecionada = value;
          });
        }
      },
    );
  }

  Widget _buildSeletorCliente() {
    return Consumer<ClienteProvider>(
      builder: (context, provider, _) {
        final clientesAtivos = provider.clientes.where((c) => c.isAtivo).toList();

        return InkWell(
          onTap: () => _mostrarSeletorCliente(clientesAtivos),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _clienteSelecionado == null
                    ? AppColors.error.withOpacity(0.5)
                    : AppColors.divider,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _clienteSelecionado != null
                        ? AppColors.primary.withOpacity(0.1)
                        : AppColors.divider,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: _clienteSelecionado != null
                        ? Text(
                            _clienteSelecionado!.iniciais,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          )
                        : Icon(
                            Icons.person_add_outlined,
                            color: AppColors.textHint,
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _clienteSelecionado?.nome ?? 'Selecionar cliente *',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _clienteSelecionado != null
                              ? AppColors.textPrimary
                              : AppColors.textHint,
                        ),
                      ),
                      if (_clienteSelecionado != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          _clienteSelecionado!.telefoneFormatado,
                          style: TextStyle(
                            fontSize: 14,
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
          ),
        );
      },
    );
  }

  void _mostrarSeletorCliente(List<ClienteModel> clientes) {
    final searchController = TextEditingController();
    List<ClienteModel> clientesFiltrados = List.from(clientes);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          void filtrar(String termo) {
            setModalState(() {
              if (termo.isEmpty) {
                clientesFiltrados = List.from(clientes);
              } else {
                clientesFiltrados = clientes
                    .where((c) =>
                        c.nome.toLowerCase().contains(termo.toLowerCase()) ||
                        c.telefone.contains(termo))
                    .toList();
              }
            });
          }

          return Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
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
                        'Selecionar Cliente',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar cliente...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: filtrar,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: clientesFiltrados.isEmpty
                      ? Center(
                          child: Text(
                            'Nenhum cliente encontrado',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        )
                      : ListView.builder(
                          itemCount: clientesFiltrados.length,
                          itemBuilder: (context, index) {
                            final cliente = clientesFiltrados[index];
                            final isSelected =
                                _clienteSelecionado?.id == cliente.id;

                            return ListTile(
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    cliente.iniciais,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ),
                              title: Text(cliente.nome),
                              subtitle: Text(cliente.telefoneFormatado),
                              trailing: isSelected
                                  ? Icon(Icons.check, color: AppColors.primary)
                                  : null,
                              onTap: () {
                                setState(() {
                                  _clienteSelecionado = cliente;
                                });
                                Navigator.pop(context);
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSeletorStatus() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: AppConstants.statusAgendamento.map((status) {
        final isSelected = _statusSelecionado == status;
        return InkWell(
          onTap: () {
            setState(() {
              _statusSelecionado = status;
            });
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? _getStatusColor(status)
                  : _getStatusColor(status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _getStatusColor(status),
                width: isSelected ? 0 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getStatusIcon(status),
                  size: 18,
                  color: isSelected ? Colors.white : _getStatusColor(status),
                ),
                const SizedBox(width: 8),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : _getStatusColor(status),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBotoes() {
    return Column(
      children: [
        AppButton.primary(
          text: _isEdicao ? 'Salvar Alterações' : 'Agendar',
          icon: Icons.save,
          isFullWidth: true,
          isLoading: _isLoading,
          onPressed: _salvar,
        ),
        const SizedBox(height: 12),
        AppButton.outline(
          text: 'Cancelar',
          isFullWidth: true,
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  String? _validarData(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Data é obrigatória';
    }
    return null;
  }

  String? _validarHora(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Hora é obrigatória';
    }
    return null;
  }

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/'
        '${data.month.toString().padLeft(2, '0')}/'
        '${data.year}';
  }

  String _formatarHora(TimeOfDay hora) {
    return '${hora.hour.toString().padLeft(2, '0')}:'
        '${hora.minute.toString().padLeft(2, '0')}';
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

  Future<void> _selecionarData() async {
    final dataSelecionada = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
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
        _atualizarDataController();
      });
    }
  }

  Future<void> _selecionarHora() async {
    final horaSelecionada = await showTimePicker(
      context: context,
      initialTime: _horaSelecionada,
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

    if (horaSelecionada != null) {
      setState(() {
        _horaSelecionada = horaSelecionada;
        _atualizarHoraController();
      });
    }
  }

  Future<void> _salvar() async {
    if (_clienteSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Selecione um cliente'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = context.read<AgendamentoProvider>();

      final dataHora = DateTime(
        _dataSelecionada.year,
        _dataSelecionada.month,
        _dataSelecionada.day,
        _horaSelecionada.hour,
        _horaSelecionada.minute,
      );

      final agendamento = AgendamentoModel(
        id: widget.agendamento?.id,
        clienteId: _clienteSelecionado!.id!,
        clienteNome: _clienteSelecionado!.nome,
        dataHora: dataHora,
        tipoMassagem: _procedimentoSelecionado!,
        duracao: _duracaoSelecionada,
        valor: _valorController.text.isNotEmpty 
            ? double.tryParse(_valorController.text.replaceAll(',', '.'))
            : null,
        status: _isEdicao ? _statusSelecionado : 'Agendado',
        observacoes: _observacoesController.text.trim().isNotEmpty 
            ? _observacoesController.text.trim() 
            : null,
      );

      bool sucesso;
      if (_isEdicao) {
        sucesso = await provider.atualizarAgendamento(agendamento);
      } else {
        final id = await provider.criarAgendamento(agendamento);
        sucesso = id != null;
      }

      if (mounted) {
        if (sucesso) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isEdicao
                    ? 'Agendamento atualizado com sucesso!'
                    : 'Agendamento criado com sucesso!',
              ),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.erro ?? 'Erro ao salvar agendamento'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
