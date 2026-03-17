import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/cliente_model.dart';
import '../../providers/cliente_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';

/// Tela de cadastro/edição de clientes
class ClienteFormScreen extends StatefulWidget {
  final ClienteModel? cliente;

  const ClienteFormScreen({
    super.key,
    this.cliente,
  });

  @override
  State<ClienteFormScreen> createState() => _ClienteFormScreenState();
}

class _ClienteFormScreenState extends State<ClienteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _cpfController = TextEditingController();
  final _dataNascimentoController = TextEditingController();
  final _enderecoController = TextEditingController();
  final _observacoesController = TextEditingController();

  bool _isLoading = false;
  bool get _isEdicao => widget.cliente != null;

  @override
  void initState() {
    super.initState();
    if (_isEdicao) {
      _preencherDados();
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _telefoneController.dispose();
    _emailController.dispose();
    _cpfController.dispose();
    _dataNascimentoController.dispose();
    _enderecoController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  void _preencherDados() {
    final cliente = widget.cliente!;
    _nomeController.text = cliente.nome;
    _telefoneController.text = cliente.telefone;
    _emailController.text = cliente.email ?? '';
    _cpfController.text = cliente.cpf ?? '';
    _dataNascimentoController.text = cliente.dataNascimentoFormatada ?? '';
    _enderecoController.text = cliente.endereco ?? '';
    _observacoesController.text = cliente.observacoes ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEdicao ? 'Editar Cliente' : 'Novo Cliente'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Seção: Dados Pessoais
            _buildSecaoTitulo('Dados Pessoais'),
            const SizedBox(height: 16),

            // Nome
            AppTextField.nome(
              controller: _nomeController,
              validator: _validarNome,
            ),
            const SizedBox(height: 16),

            // Telefone
            AppTextField.telefone(
              controller: _telefoneController,
              validator: _validarTelefone,
            ),
            const SizedBox(height: 16),

            // Email
            AppTextField.email(
              controller: _emailController,
              validator: _validarEmail,
            ),
            const SizedBox(height: 16),

            // CPF
            AppTextField.cpf(
              controller: _cpfController,
              validator: _validarCpf,
            ),
            const SizedBox(height: 16),

            // Data de nascimento
            AppTextField.data(
              controller: _dataNascimentoController,
              label: 'Data de Nascimento',
              onTap: () => _selecionarData(),
              readOnly: true,
            ),
            const SizedBox(height: 24),

            // Seção: Endereço
            _buildSecaoTitulo('Endereço'),
            const SizedBox(height: 16),

            // Endereço completo
            AppTextField(
              label: 'Endereço',
              hint: 'Rua, número, bairro, cidade',
              controller: _enderecoController,
              prefixIcon: Icons.location_on_outlined,
              textCapitalization: TextCapitalization.words,
              maxLines: 2,
            ),
            const SizedBox(height: 24),

            // Seção: Observações
            _buildSecaoTitulo('Observações'),
            const SizedBox(height: 16),

            // Observações
            AppTextField.multiline(
              label: 'Observações',
              hint: 'Informações adicionais sobre o cliente...',
              controller: _observacoesController,
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

  /// Título de seção
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

  /// Botões de ação
  Widget _buildBotoes() {
    return Column(
      children: [
        // Botão salvar
        AppButton.primary(
          text: _isEdicao ? 'Salvar Alterações' : 'Cadastrar Cliente',
          icon: Icons.save,
          isFullWidth: true,
          isLoading: _isLoading,
          onPressed: _salvar,
        ),
        const SizedBox(height: 12),

        // Botão cancelar
        AppButton.outline(
          text: 'Cancelar',
          isFullWidth: true,
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  // ============================================
  // VALIDAÇÕES
  // ============================================

  String? _validarNome(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nome é obrigatório';
    }
    if (value.trim().length < 3) {
      return 'Nome deve ter pelo menos 3 caracteres';
    }
    if (value.trim().length > 100) {
      return 'Nome deve ter no máximo 100 caracteres';
    }
    return null;
  }

  String? _validarTelefone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Telefone é obrigatório';
    }
    // Remove formatação para validar
    final telefoneNumeros = value.replaceAll(RegExp(r'\D'), '');
    if (telefoneNumeros.length < 10 || telefoneNumeros.length > 11) {
      return 'Telefone inválido';
    }
    return null;
  }

  String? _validarEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Email é opcional
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Email inválido';
    }
    return null;
  }

  String? _validarCpf(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // CPF é opcional
    }
    // Remove formatação para validar
    final cpfNumeros = value.replaceAll(RegExp(r'\D'), '');
    if (cpfNumeros.length != 11) {
      return 'CPF inválido';
    }
    // Validação básica de CPF (todos dígitos iguais)
    if (RegExp(r'^(\d)\1*$').hasMatch(cpfNumeros)) {
      return 'CPF inválido';
    }
    return null;
  }

  // ============================================
  // AÇÕES
  // ============================================

  /// Abre o seletor de data
  Future<void> _selecionarData() async {
    final dataAtual = DateTime.now();
    
    // Define a data inicial
    DateTime dataInicial;
    if (widget.cliente?.dataNascimentoDateTime != null) {
      dataInicial = widget.cliente!.dataNascimentoDateTime!;
    } else {
      dataInicial = DateTime(dataAtual.year - 30);
    }

    final dataSelecionada = await showDatePicker(
      context: context,
      initialDate: dataInicial,
      firstDate: DateTime(1900),
      lastDate: dataAtual,
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
        _dataNascimentoController.text = _formatarData(dataSelecionada);
      });
    }
  }

  /// Formata data para DD/MM/AAAA
  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/'
        '${data.month.toString().padLeft(2, '0')}/'
        '${data.year}';
  }

  /// Converte "dd/MM/yyyy" para "yyyy-MM-dd" (formato ISO)
  String? _formatarParaISO(String texto) {
    if (texto.isEmpty) return null;
    try {
      final partes = texto.split('/');
      if (partes.length == 3) {
        return '${partes[2]}-${partes[1].padLeft(2, '0')}-${partes[0].padLeft(2, '0')}';
      }
    } catch (_) {}
    return null;
  }

  /// Salva o cliente
  Future<void> _salvar() async {
    // Valida o formulário
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = context.read<ClienteProvider>();
      
      // Cria o modelo do cliente
      final cliente = ClienteModel(
        id: widget.cliente?.id,
        nome: _nomeController.text.trim(),
        telefone: _telefoneController.text.replaceAll(RegExp(r'\D'), ''),
        email: _emailController.text.trim().isNotEmpty
            ? _emailController.text.trim()
            : null,
        cpf: _cpfController.text.replaceAll(RegExp(r'\D'), '').isNotEmpty
            ? _cpfController.text.replaceAll(RegExp(r'\D'), '')
            : null,
        dataNascimento: _dataNascimentoController.text.isNotEmpty
            ? _formatarParaISO(_dataNascimentoController.text) 
            : null,
        endereco: _enderecoController.text.trim().isNotEmpty
            ? _enderecoController.text.trim()
            : null,
        observacoes: _observacoesController.text.trim().isNotEmpty
            ? _observacoesController.text.trim()
            : null,
        isAtivo: widget.cliente?.isAtivo ?? true,        
      );

      bool sucesso;
      if (_isEdicao) {
        sucesso = await provider.atualizarCliente(cliente);
      } else {
        final id = await provider.criarCliente(cliente);
        sucesso = id != null;
      }

      if (mounted) {
        if (sucesso) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isEdicao
                    ? 'Cliente atualizado com sucesso!'
                    : 'Cliente cadastrado com sucesso!',
              ),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.erro ?? 'Erro ao salvar cliente'),
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
