import 'package:flutter/foundation.dart';
import '../../data/models/anamnese_model.dart';
import '../../data/repositories/anamnese_repository.dart';

/// Provider para gerenciamento de estado das Anamneses
/// Utiliza ChangeNotifier para notificar a UI sobre mudanças
class AnamneseProvider extends ChangeNotifier {
  final AnamneseRepository _repository;

  // ============================================
  // ESTADO
  // ============================================
  
  List<AnamneseModel> _anamneses = [];
  List<AnamneseModel> _anamnesesDoCliente = [];
  AnamneseModel? _anamneseSelecionada;
  bool _isLoading = false;
  String? _erro;

  // ============================================
  // GETTERS
  // ============================================

  /// Lista de todas as anamneses
  List<AnamneseModel> get anamneses => List.unmodifiable(_anamneses);

  /// Lista de anamneses do cliente atual
  List<AnamneseModel> get anamnesesDoCliente => List.unmodifiable(_anamnesesDoCliente);

  /// Anamnese atualmente selecionada
  AnamneseModel? get anamneseSelecionada => _anamneseSelecionada;

  /// Indica se está carregando dados
  bool get isLoading => _isLoading;

  /// Mensagem de erro (se houver)
  String? get erro => _erro;

  /// Total de anamneses
  int get totalAnamneses => _anamneses.length;

  /// Total de anamneses do cliente atual
  int get totalAnamnesesDoCliente => _anamnesesDoCliente.length;

  /// Anamnese mais recente do cliente atual
  AnamneseModel? get anamneseMaisRecente {
    if (_anamnesesDoCliente.isEmpty) return null;
    return _anamnesesDoCliente.first; // Já vem ordenada por data desc
  }

  // ============================================
  // CONSTRUTOR
  // ============================================

  AnamneseProvider({AnamneseRepository? repository})
      : _repository = repository ?? AnamneseRepository();

  // ============================================
  // MÉTODOS DE CARREGAMENTO
  // ============================================

  /// Carrega todas as anamneses do Firebase
  Future<void> carregarAnamneses() async {
    _setLoading(true);
    _limparErro();

    try {
      _anamneses = await _repository.listarTodas();
      notifyListeners();
    } catch (e) {
      _setErro('Erro ao carregar anamneses: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Carrega as anamneses de um cliente específico
  Future<void> carregarAnamnesesDoCliente(String clienteId) async {
    _setLoading(true);
    _limparErro();

    try {
      _anamnesesDoCliente = await _repository.listarPorCliente(clienteId);
      notifyListeners();
    } catch (e) {
      _setErro('Erro ao carregar anamneses do cliente: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Carrega uma anamnese específica pelo ID
  Future<AnamneseModel?> carregarAnamnese(String id) async {
    _setLoading(true);
    _limparErro();

    try {
      final anamnese = await _repository.buscarPorId(id);
      if (anamnese != null) {
        _anamneseSelecionada = anamnese;
        notifyListeners();
      }
      return anamnese;
    } catch (e) {
      _setErro('Erro ao carregar anamnese: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Carrega a anamnese mais recente de um cliente
  Future<AnamneseModel?> carregarAnamneseMaisRecente(String clienteId) async {
    _setLoading(true);
    _limparErro();

    try {
      final anamnese = await _repository.buscarMaisRecentePorCliente(clienteId);
      if (anamnese != null) {
        _anamneseSelecionada = anamnese;
        notifyListeners();
      }
      return anamnese;
    } catch (e) {
      _setErro('Erro ao carregar anamnese mais recente: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Recarrega a lista de anamneses
  Future<void> recarregar() async {
    await carregarAnamneses();
  }

  /// Recarrega a lista de anamneses do cliente
  Future<void> recarregarDoCliente(String clienteId) async {
    await carregarAnamnesesDoCliente(clienteId);
  }

  // ============================================
  // MÉTODOS DE CRUD
  // ============================================

  /// Cria uma nova anamnese
  /// Retorna o ID da anamnese criada ou null em caso de erro
  Future<String?> criarAnamnese(AnamneseModel anamnese) async {
    _setLoading(true);
    _limparErro();

    try {
      final id = await _repository.criar(anamnese);
      
      // Adiciona a nova anamnese às listas locais
      final novaAnamnese = anamnese.copyWith(id: id);
      _anamneses.insert(0, novaAnamnese);
      
      // Se for do cliente atual, adiciona também à lista do cliente
      if (_anamnesesDoCliente.isNotEmpty && 
          _anamnesesDoCliente.first.clienteId == anamnese.clienteId) {
        _anamnesesDoCliente.insert(0, novaAnamnese);
      }
      
      notifyListeners();
      return id;
    } catch (e) {
      _setErro('Erro ao criar anamnese: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Atualiza uma anamnese existente
  Future<bool> atualizarAnamnese(AnamneseModel anamnese) async {
    if (anamnese.id == null) {
      _setErro('ID da anamnese é obrigatório');
      return false;
    }

    _setLoading(true);
    _limparErro();

    try {
      await _repository.atualizar(anamnese);
      
      // Atualiza a anamnese na lista geral
      final indexGeral = _anamneses.indexWhere((a) => a.id == anamnese.id);
      if (indexGeral != -1) {
        _anamneses[indexGeral] = anamnese;
      }
      
      // Atualiza a anamnese na lista do cliente
      final indexCliente = _anamnesesDoCliente.indexWhere((a) => a.id == anamnese.id);
      if (indexCliente != -1) {
        _anamnesesDoCliente[indexCliente] = anamnese;
      }
      
      // Atualiza a anamnese selecionada se for a mesma
      if (_anamneseSelecionada?.id == anamnese.id) {
        _anamneseSelecionada = anamnese;
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _setErro('Erro ao atualizar anamnese: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Exclui uma anamnese
  Future<bool> excluirAnamnese(String id) async {
    _setLoading(true);
    _limparErro();

    try {
      await _repository.excluir(id);
      
      // Remove a anamnese das listas locais
      _anamneses.removeWhere((a) => a.id == id);
      _anamnesesDoCliente.removeWhere((a) => a.id == id);
      
      // Limpa seleção se for a anamnese excluída
      if (_anamneseSelecionada?.id == id) {
        _anamneseSelecionada = null;
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _setErro('Erro ao excluir anamnese: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Exclui todas as anamneses de um cliente
  Future<bool> excluirAnamnesesDoCliente(String clienteId) async {
    _setLoading(true);
    _limparErro();

    try {
      await _repository.excluirPorCliente(clienteId);
      
      // Remove as anamneses das listas locais
      _anamneses.removeWhere((a) => a.clienteId == clienteId);
      _anamnesesDoCliente.clear();
      
      // Limpa seleção se pertencer ao cliente
      if (_anamneseSelecionada?.clienteId == clienteId) {
        _anamneseSelecionada = null;
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _setErro('Erro ao excluir anamneses do cliente: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ============================================
  // MÉTODOS DE SELEÇÃO
  // ============================================

  /// Seleciona uma anamnese
  void selecionarAnamnese(AnamneseModel? anamnese) {
    _anamneseSelecionada = anamnese;
    notifyListeners();
  }

  /// Limpa a seleção
  void limparSelecao() {
    _anamneseSelecionada = null;
    notifyListeners();
  }

  // ============================================
  // MÉTODOS DE CONSULTA
  // ============================================

  /// Verifica se um cliente possui anamnese
  Future<bool> clientePossuiAnamnese(String clienteId) async {
    try {
      return await _repository.clientePossuiAnamnese(clienteId);
    } catch (e) {
      _setErro('Erro ao verificar anamnese: $e');
      return false;
    }
  }

  /// Busca anamneses por condição de saúde
  Future<List<AnamneseModel>> buscarPorCondicaoSaude(String condicao) async {
    _setLoading(true);
    _limparErro();

    try {
      final resultado = await _repository.buscarPorCondicaoSaude(condicao);
      return resultado;
    } catch (e) {
      _setErro('Erro ao buscar por condição de saúde: $e');
      return [];
    } finally {
      _setLoading(false);
    }
  }

  /// Busca anamneses de gestantes
  Future<List<AnamneseModel>> buscarGestantes() async {
    _setLoading(true);
    _limparErro();

    try {
      final resultado = await _repository.buscarGestantes();
      return resultado;
    } catch (e) {
      _setErro('Erro ao buscar gestantes: $e');
      return [];
    } finally {
      _setLoading(false);
    }
  }

  /// Busca anamneses com contraindicações
  Future<List<AnamneseModel>> buscarComContraindicacoes() async {
    _setLoading(true);
    _limparErro();

    try {
      final resultado = await _repository.buscarComContraindicacoes();
      return resultado;
    } catch (e) {
      _setErro('Erro ao buscar com contraindicações: $e');
      return [];
    } finally {
      _setLoading(false);
    }
  }

  // ============================================
  // MÉTODOS AUXILIARES
  // ============================================

  /// Busca uma anamnese pelo ID na lista local
  AnamneseModel? buscarPorIdLocal(String id) {
    try {
      return _anamneses.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Busca a anamnese mais recente de um cliente na lista local
  AnamneseModel? buscarMaisRecenteLocal(String clienteId) {
    try {
      final anamnesesCliente = _anamneses
          .where((a) => a.clienteId == clienteId)
          .toList();
      
      if (anamnesesCliente.isEmpty) return null;
      
      anamnesesCliente.sort((a, b) => b.dataAvaliacao.compareTo(a.dataAvaliacao));
      return anamnesesCliente.first;
    } catch (e) {
      return null;
    }
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

  /// Limpa o erro manualmente
  void limparErro() {
    _erro = null;
    notifyListeners();
  }

  /// Limpa as anamneses do cliente atual
  void limparAnamnesesDoCliente() {
    _anamnesesDoCliente = [];
    notifyListeners();
  }

  /// Limpa todo o estado
  void limparEstado() {
    _anamneses = [];
    _anamnesesDoCliente = [];
    _anamneseSelecionada = null;
    _isLoading = false;
    _erro = null;
    notifyListeners();
  }
}
