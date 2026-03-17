import 'package:flutter/foundation.dart';
import '../../data/models/agendamento_model.dart';
import '../../data/repositories/agendamento_repository.dart';

/// Provider para gerenciamento de estado dos Agendamentos
class AgendamentoProvider extends ChangeNotifier {
  final AgendamentoRepository _repository;

  // ============================================
  // ESTADO
  // ============================================
  
  List<AgendamentoModel> _agendamentos = [];
  List<AgendamentoModel> _agendamentosHoje = [];
  List<AgendamentoModel> _agendamentosDoCliente = [];
  List<AgendamentoModel> _agendamentosDoDia = [];
  AgendamentoModel? _agendamentoSelecionado;
  DateTime _dataSelecionada = DateTime.now();
  bool _isLoading = false;
  String? _erro;

  // ============================================
  // GETTERS
  // ============================================

  /// Lista de todos os agendamentos
  List<AgendamentoModel> get agendamentos => List.unmodifiable(_agendamentos);

  /// Lista de agendamentos de hoje
  List<AgendamentoModel> get agendamentosHoje => List.unmodifiable(_agendamentosHoje);

  /// Lista de agendamentos do cliente atual
  List<AgendamentoModel> get agendamentosDoCliente => List.unmodifiable(_agendamentosDoCliente);

  /// Alias para agendamentosDoCliente (compatibilidade)
  List<AgendamentoModel> get agendamentosCliente => List.unmodifiable(_agendamentosDoCliente);

  /// Lista de agendamentos do dia selecionado
  List<AgendamentoModel> get agendamentosDoDia => List.unmodifiable(_agendamentosDoDia);

  /// Alias para agendamentosDoDia (compatibilidade)
  List<AgendamentoModel> get agendamentosDia => List.unmodifiable(_agendamentosDoDia);

  /// Agendamento atualmente selecionado
  AgendamentoModel? get agendamentoSelecionado => _agendamentoSelecionado;

  /// Data atualmente selecionada
  DateTime get dataSelecionada => _dataSelecionada;

  /// Indica se está carregando dados
  bool get isLoading => _isLoading;

  /// Mensagem de erro (se houver)
  String? get erro => _erro;

  /// Total de agendamentos
  int get totalAgendamentos => _agendamentos.length;

  /// Total de agendamentos de hoje
  int get totalAgendamentosHoje => _agendamentosHoje.length;

  /// Total de agendamentos pendentes hoje
  int get totalPendentesHoje => _agendamentosHoje
      .where((a) => a.isPendente)
      .length;

  /// Total de agendamentos concluídos hoje
  int get totalConcluidosHoje => _agendamentosHoje
      .where((a) => a.isConcluido)
      .length;

  /// Próximo agendamento de hoje
  AgendamentoModel? get proximoAgendamentoHoje {
    final agora = DateTime.now();
    final pendentes = _agendamentosHoje
        .where((a) => a.isPendente && a.dataHora.isAfter(agora))
        .toList();
    
    if (pendentes.isEmpty) return null;
    
    pendentes.sort((a, b) => a.dataHora.compareTo(b.dataHora));
    return pendentes.first;
  }

  /// Agendamento em andamento (se houver)
  AgendamentoModel? get agendamentoEmAndamento {
    try {
      return _agendamentosHoje.firstWhere((a) => a.status == 'Em andamento');
    } catch (e) {
      return null;
    }
  }

  // ============================================
  // CONSTRUTOR
  // ============================================

  AgendamentoProvider({AgendamentoRepository? repository})
      : _repository = repository ?? AgendamentoRepository();

  // ============================================
  // MÉTODOS DE CARREGAMENTO
  // ============================================

  /// Carrega todos os agendamentos do Firebase
  Future<void> carregarAgendamentos() async {
    _setLoading(true);
    _limparErro();

    try {
      _agendamentos = await _repository.listarTodos();
      notifyListeners();
    } catch (e) {
      _setErro('Erro ao carregar agendamentos: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Carrega os agendamentos de hoje
  Future<void> carregarAgendamentosHoje() async {
    _setLoading(true);
    _limparErro();

    try {
      _agendamentosHoje = await _repository.listarHoje();
      _agendamentosDoDia = List.from(_agendamentosHoje);
      notifyListeners();
    } catch (e) {
      _setErro('Erro ao carregar agendamentos de hoje: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Carrega os agendamentos de uma data específica
  Future<void> carregarAgendamentosPorData(DateTime data) async {
    _setLoading(true);
    _limparErro();
    _dataSelecionada = data;

    try {
      _agendamentosDoDia = await _repository.listarPorData(data);
      notifyListeners();
    } catch (e) {
      _setErro('Erro ao carregar agendamentos da data: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Carrega os agendamentos de um cliente específico
  Future<void> carregarAgendamentosDoCliente(String clienteId) async {
    _setLoading(true);
    _limparErro();

    try {
      _agendamentosDoCliente = await _repository.listarPorCliente(clienteId);
      notifyListeners();
    } catch (e) {
      _setErro('Erro ao carregar agendamentos do cliente: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Alias para carregarAgendamentosDoCliente (compatibilidade)
  Future<void> carregarAgendamentosPorCliente(String clienteId) async {
    await carregarAgendamentosDoCliente(clienteId);
  }

  /// Carrega um agendamento específico pelo ID
  Future<AgendamentoModel?> carregarAgendamento(String id) async {
    _setLoading(true);
    _limparErro();

    try {
      final agendamento = await _repository.buscarPorId(id);
      if (agendamento != null) {
        _agendamentoSelecionado = agendamento;
        notifyListeners();
      }
      return agendamento;
    } catch (e) {
      _setErro('Erro ao carregar agendamento: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Recarrega os agendamentos
  Future<void> recarregar() async {
    await Future.wait([
      carregarAgendamentos(),
      carregarAgendamentosHoje(),
    ]);
  }

  // ============================================
  // MÉTODOS DE CRUD
  // ============================================

  /// Cria um novo agendamento
  Future<String?> criarAgendamento(AgendamentoModel agendamento) async {
    _setLoading(true);
    _limparErro();

    try {
      // Verifica conflito de horário
      final temConflito = await _repository.verificarConflito(agendamento);
      if (temConflito) {
        _setErro('Já existe um agendamento neste horário');
        return null;
      }

      final id = await _repository.criar(agendamento);
      
      // Adiciona o novo agendamento às listas locais
      final novoAgendamento = agendamento.copyWith(id: id);
      _agendamentos.insert(0, novoAgendamento);
      _ordenarAgendamentos();
      
      // Atualiza lista de hoje se for hoje
      if (novoAgendamento.isHoje) {
        _agendamentosHoje.add(novoAgendamento);
        _ordenarAgendamentosHoje();
      }
      
      // Atualiza lista do dia selecionado
      if (_isMesmoDia(novoAgendamento.dataHora, _dataSelecionada)) {
        _agendamentosDoDia.add(novoAgendamento);
        _ordenarAgendamentosDoDia();
      }
      
      notifyListeners();
      return id;
    } catch (e) {
      _setErro('Erro ao criar agendamento: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Atualiza um agendamento existente
  Future<bool> atualizarAgendamento(AgendamentoModel agendamento) async {
    if (agendamento.id == null) {
      _setErro('ID do agendamento é obrigatório');
      return false;
    }

    _setLoading(true);
    _limparErro();

    try {
      // Verifica conflito de horário (excluindo o próprio agendamento)
      final temConflito = await _repository.verificarConflito(agendamento);
      if (temConflito) {
        _setErro('Já existe um agendamento neste horário');
        return false;
      }

      await _repository.atualizar(agendamento);
      
      // Atualiza nas listas locais
      _atualizarEmListas(agendamento);
      
      // Atualiza o agendamento selecionado se for o mesmo
      if (_agendamentoSelecionado?.id == agendamento.id) {
        _agendamentoSelecionado = agendamento;
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _setErro('Erro ao atualizar agendamento: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Exclui um agendamento
  Future<bool> excluirAgendamento(String id) async {
    _setLoading(true);
    _limparErro();

    try {
      await _repository.excluir(id);
      
      // Remove das listas locais
      _agendamentos.removeWhere((a) => a.id == id);
      _agendamentosHoje.removeWhere((a) => a.id == id);
      _agendamentosDoCliente.removeWhere((a) => a.id == id);
      _agendamentosDoDia.removeWhere((a) => a.id == id);
      
      // Limpa seleção se for o agendamento excluído
      if (_agendamentoSelecionado?.id == id) {
        _agendamentoSelecionado = null;
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _setErro('Erro ao excluir agendamento: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ============================================
  // MÉTODOS DE ATUALIZAÇÃO DE STATUS
  // ============================================

  /// Confirma um agendamento
  Future<bool> confirmarAgendamento(String id) async {
    return await _atualizarStatus(id, 'Confirmado');
  }

  /// Inicia um agendamento
  Future<bool> iniciarAgendamento(String id) async {
    return await _atualizarStatus(id, 'Em andamento');
  }

  /// Conclui um agendamento
  Future<bool> concluirAgendamento(String id) async {
    return await _atualizarStatus(id, 'Concluído');
  }

  /// Cancela um agendamento
  Future<bool> cancelarAgendamento(String id) async {
    return await _atualizarStatus(id, 'Cancelado');
  }

  /// Marca um agendamento como não compareceu
  Future<bool> marcarNaoCompareceu(String id) async {
    return await _atualizarStatus(id, 'Não compareceu');
  }

  /// Atualiza o status de um agendamento
  Future<bool> _atualizarStatus(String id, String novoStatus) async {
    _setLoading(true);
    _limparErro();

    try {
      await _repository.atualizarStatus(id, novoStatus);
      
      // Atualiza o status nas listas locais
      _atualizarStatusEmListas(id, novoStatus);
      
      // Atualiza o agendamento selecionado se for o mesmo
      if (_agendamentoSelecionado?.id == id) {
        _agendamentoSelecionado = _agendamentoSelecionado!.copyWith(status: novoStatus);
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _setErro('Erro ao atualizar status: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ============================================
  // MÉTODOS DE DATA E HORÁRIO
  // ============================================

  /// Seleciona uma data
  void selecionarData(DateTime data) {
    _dataSelecionada = data;
    carregarAgendamentosPorData(data);
  }

  /// Retorna os horários disponíveis para uma data
  Future<List<String>> buscarHorariosDisponiveis(DateTime data) async {
    try {
      return await _repository.horariosDisponiveis(data);
    } catch (e) {
      _setErro('Erro ao buscar horários disponíveis: $e');
      return [];
    }
  }

  /// Verifica se há conflito de horário
  Future<bool> verificarConflito(AgendamentoModel agendamento) async {
    try {
      return await _repository.verificarConflito(agendamento);
    } catch (e) {
      _setErro('Erro ao verificar conflito: $e');
      return false;
    }
  }

  // ============================================
  // MÉTODOS DE SELEÇÃO
  // ============================================

  /// Seleciona um agendamento
  void selecionarAgendamento(AgendamentoModel? agendamento) {
    _agendamentoSelecionado = agendamento;
    notifyListeners();
  }

  /// Limpa a seleção
  void limparSelecao() {
    _agendamentoSelecionado = null;
    notifyListeners();
  }

  // ============================================
  // MÉTODOS DE ESTATÍSTICAS
  // ============================================

  /// Retorna estatísticas do mês
  Future<Map<String, int>> estatisticasMes(int ano, int mes) async {
    try {
      return await _repository.estatisticasMes(ano, mes);
    } catch (e) {
      _setErro('Erro ao calcular estatísticas: $e');
      return {
        'total': 0,
        'agendados': 0,
        'confirmados': 0,
        'concluidos': 0,
        'cancelados': 0,
        'naoCompareceram': 0,
      };
    }
  }

  // ============================================
  // MÉTODOS AUXILIARES PRIVADOS
  // ============================================

  void _atualizarEmListas(AgendamentoModel agendamento) {
    // Lista geral
    final indexGeral = _agendamentos.indexWhere((a) => a.id == agendamento.id);
    if (indexGeral != -1) {
      _agendamentos[indexGeral] = agendamento;
    }
    
    // Lista de hoje
    final indexHoje = _agendamentosHoje.indexWhere((a) => a.id == agendamento.id);
    if (indexHoje != -1) {
      if (agendamento.isHoje) {
        _agendamentosHoje[indexHoje] = agendamento;
      } else {
        _agendamentosHoje.removeAt(indexHoje);
      }
    } else if (agendamento.isHoje) {
      _agendamentosHoje.add(agendamento);
      _ordenarAgendamentosHoje();
    }
    
    // Lista do cliente
    final indexCliente = _agendamentosDoCliente.indexWhere((a) => a.id == agendamento.id);
    if (indexCliente != -1) {
      _agendamentosDoCliente[indexCliente] = agendamento;
    }
    
    // Lista do dia
    final indexDia = _agendamentosDoDia.indexWhere((a) => a.id == agendamento.id);
    if (indexDia != -1) {
      if (_isMesmoDia(agendamento.dataHora, _dataSelecionada)) {
        _agendamentosDoDia[indexDia] = agendamento;
      } else {
        _agendamentosDoDia.removeAt(indexDia);
      }
    } else if (_isMesmoDia(agendamento.dataHora, _dataSelecionada)) {
      _agendamentosDoDia.add(agendamento);
      _ordenarAgendamentosDoDia();
    }
  }

  void _atualizarStatusEmListas(String id, String novoStatus) {
    // Lista geral
    final indexGeral = _agendamentos.indexWhere((a) => a.id == id);
    if (indexGeral != -1) {
      _agendamentos[indexGeral] = _agendamentos[indexGeral].copyWith(status: novoStatus);
    }
    
    // Lista de hoje
    final indexHoje = _agendamentosHoje.indexWhere((a) => a.id == id);
    if (indexHoje != -1) {
      _agendamentosHoje[indexHoje] = _agendamentosHoje[indexHoje].copyWith(status: novoStatus);
    }
    
    // Lista do cliente
    final indexCliente = _agendamentosDoCliente.indexWhere((a) => a.id == id);
    if (indexCliente != -1) {
      _agendamentosDoCliente[indexCliente] = _agendamentosDoCliente[indexCliente].copyWith(status: novoStatus);
    }
    
    // Lista do dia
    final indexDia = _agendamentosDoDia.indexWhere((a) => a.id == id);
    if (indexDia != -1) {
      _agendamentosDoDia[indexDia] = _agendamentosDoDia[indexDia].copyWith(status: novoStatus);
    }
  }

  bool _isMesmoDia(DateTime data1, DateTime data2) {
    return data1.year == data2.year &&
        data1.month == data2.month &&
        data1.day == data2.day;
  }

  void _ordenarAgendamentos() {
    _agendamentos.sort((a, b) => b.dataHora.compareTo(a.dataHora));
  }

  void _ordenarAgendamentosHoje() {
    _agendamentosHoje.sort((a, b) => a.dataHora.compareTo(b.dataHora));
  }

  void _ordenarAgendamentosDoDia() {
    _agendamentosDoDia.sort((a, b) => a.dataHora.compareTo(b.dataHora));
  }

  // ============================================
  // MÉTODOS DE ESTADO
  // ============================================

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setErro(String mensagem) {
    _erro = mensagem;
    notifyListeners();
  }

  void _limparErro() {
    _erro = null;
  }

  void limparErro() {
    _erro = null;
    notifyListeners();
  }

  void limparAgendamentosDoCliente() {
    _agendamentosDoCliente = [];
    notifyListeners();
  }

  void limparEstado() {
    _agendamentos = [];
    _agendamentosHoje = [];
    _agendamentosDoCliente = [];
    _agendamentosDoDia = [];
    _agendamentoSelecionado = null;
    _dataSelecionada = DateTime.now();
    _isLoading = false;
    _erro = null;
    notifyListeners();
  }
}
