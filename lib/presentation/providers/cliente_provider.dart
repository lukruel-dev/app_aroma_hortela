import 'package:flutter/foundation.dart';
import '../../data/models/cliente_model.dart';
import '../../data/repositories/cliente_repository.dart';

/// Provider para gerenciamento de estado dos Clientes
class ClienteProvider extends ChangeNotifier {
  final ClienteRepository _repository;

  // ============================================
  // ESTADO
  // ============================================
  
  List<ClienteModel> _clientes = [];
  List<ClienteModel> _clientesFiltrados = [];
  ClienteModel? _clienteSelecionado;
  bool _isLoading = false;
  bool _isBuscando = false;
  String? _erro;
  String _filtroStatus = 'Todos';
  String _termoBusca = '';

  // ============================================
  // GETTERS
  // ============================================

  List<ClienteModel> get clientes {
    var lista = List<ClienteModel>.from(_clientes);
    
    if (_filtroStatus == 'Ativo') {
      lista = lista.where((c) => c.isAtivo).toList();
    } else if (_filtroStatus == 'Inativo') {
      lista = lista.where((c) => !c.isAtivo).toList();
    }
    
    if (_termoBusca.isNotEmpty) {
      lista = lista.where((c) => 
        c.nome.toLowerCase().contains(_termoBusca.toLowerCase())
      ).toList();
    }
    
    return lista;
  }

  List<ClienteModel> get todosClientes => List.unmodifiable(_clientes);
  List<ClienteModel> get clientesFiltrados => List.unmodifiable(_clientesFiltrados);
  List<ClienteModel> get clientesAtivos => _clientes.where((c) => c.isAtivo).toList();
  ClienteModel? get clienteSelecionado => _clienteSelecionado;
  bool get isLoading => _isLoading;
  bool get isBuscando => _isBuscando;
  String? get erro => _erro;
  String get filtroStatus => _filtroStatus;
  String get termoBusca => _termoBusca;
  int get totalClientes => _clientes.length;
  int get totalClientesAtivos => _clientes.where((c) => c.isAtivo).length;
  int get totalClientesInativos => _clientes.where((c) => !c.isAtivo).length;

  // ============================================
  // CONSTRUTOR
  // ============================================

  ClienteProvider({ClienteRepository? repository})
      : _repository = repository ?? ClienteRepository();

  // ============================================
  // MÉTODOS DE CARREGAMENTO
  // ============================================

  Future<void> carregarClientes() async {
    _isLoading = true;
    _erro = null;

    try {
      _clientes = await _repository.listarTodos();
      _clientesFiltrados = List.from(_clientes);
    } catch (e) {
      _erro = 'Erro ao carregar clientes: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> recarregar() async {
    await carregarClientes();
  }

  Future<ClienteModel?> carregarCliente(String id) async {
    _isLoading = true;
    _erro = null;

    try {
      final cliente = await _repository.buscarPorId(id);
      if (cliente != null) {
        _clienteSelecionado = cliente;
      }
      return cliente;
    } catch (e) {
      _erro = 'Erro ao carregar cliente: $e';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================
  // MÉTODOS DE BUSCA
  // ============================================

  void buscarClientes(String termo) {
    _isBuscando = true;
    _termoBusca = termo;
    
    if (termo.isEmpty) {
      _clientesFiltrados = List.from(_clientes);
    } else {
      _clientesFiltrados = _clientes.where((c) {
        final nomeLower = c.nome.toLowerCase();
        final termoLower = termo.toLowerCase();
        final telefone = c.telefone.replaceAll(RegExp(r'[^\d]'), '');
        
        return nomeLower.contains(termoLower) || 
               telefone.contains(termo.replaceAll(RegExp(r'[^\d]'), ''));
      }).toList();
    }
    
    notifyListeners();
  }

  void limparBusca() {
    _isBuscando = false;
    _termoBusca = '';
    _clientesFiltrados = List.from(_clientes);
    notifyListeners();
  }

  // ============================================
  // MÉTODOS DE CRUD
  // ============================================

  Future<String?> criarCliente(ClienteModel cliente) async {
    _isLoading = true;
    _erro = null;

    try {
      final telefoneExiste = await _repository.telefoneJaExiste(cliente.telefone);
      if (telefoneExiste) {
        _erro = 'Já existe um cliente com este telefone';
        _isLoading = false;
        notifyListeners();
        return null;
      }

      if (cliente.email != null && cliente.email!.isNotEmpty) {
        final emailExiste = await _repository.emailJaExiste(cliente.email!);
        if (emailExiste) {
          _erro = 'Já existe um cliente com este email';
          _isLoading = false;
          notifyListeners();
          return null;
        }
      }

      final id = await _repository.criar(cliente);
      
      final novoCliente = cliente.copyWith(id: id);
      _clientes.add(novoCliente);
      _clientesFiltrados = List.from(_clientes);
      _ordenarClientes();
      
      _isLoading = false;
      notifyListeners();
      return id;
    } catch (e) {
      _erro = 'Erro ao criar cliente: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> atualizarCliente(ClienteModel cliente) async {
    if (cliente.id == null) {
      _erro = 'ID do cliente é obrigatório';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _erro = null;

    try {
      final telefoneExiste = await _repository.telefoneJaExiste(
        cliente.telefone, 
        excluirId: cliente.id,
      );
      if (telefoneExiste) {
        _erro = 'Já existe outro cliente com este telefone';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (cliente.email != null && cliente.email!.isNotEmpty) {
        final emailExiste = await _repository.emailJaExiste(
          cliente.email!, 
          excluirId: cliente.id,
        );
        if (emailExiste) {
          _erro = 'Já existe outro cliente com este email';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      }

      await _repository.atualizar(cliente);
      
      final index = _clientes.indexWhere((c) => c.id == cliente.id);
      if (index != -1) {
        _clientes[index] = cliente;
        _clientesFiltrados = List.from(_clientes);
        _ordenarClientes();
      }
      
      if (_clienteSelecionado?.id == cliente.id) {
        _clienteSelecionado = cliente;
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _erro = 'Erro ao atualizar cliente: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> excluirCliente(String id, {bool excluirDadosRelacionados = false}) async {
    _isLoading = true;
    _erro = null;

    try {
      if (excluirDadosRelacionados) {
        await _repository.excluirComDadosRelacionados(id);
      } else {
        await _repository.excluir(id);
      }
      
      _clientes.removeWhere((c) => c.id == id);
      _clientesFiltrados.removeWhere((c) => c.id == id);
      
      if (_clienteSelecionado?.id == id) {
        _clienteSelecionado = null;
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _erro = 'Erro ao excluir cliente: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> ativarCliente(String id) async {
    _isLoading = true;
    _erro = null;

    try {
      await _repository.ativar(id);
      
      final index = _clientes.indexWhere((c) => c.id == id);
      if (index != -1) {
        _clientes[index] = _clientes[index].copyWith(isAtivo: true);
      }
      
      final indexFiltrado = _clientesFiltrados.indexWhere((c) => c.id == id);
      if (indexFiltrado != -1) {
        _clientesFiltrados[indexFiltrado] = _clientesFiltrados[indexFiltrado].copyWith(isAtivo: true);
      }
      
      if (_clienteSelecionado?.id == id) {
        _clienteSelecionado = _clienteSelecionado!.copyWith(isAtivo: true);
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _erro = 'Erro ao ativar cliente: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> inativarCliente(String id) async {
    _isLoading = true;
    _erro = null;

    try {
      await _repository.inativar(id);
      
      final index = _clientes.indexWhere((c) => c.id == id);
      if (index != -1) {
        _clientes[index] = _clientes[index].copyWith(isAtivo: false);
      }
      
      final indexFiltrado = _clientesFiltrados.indexWhere((c) => c.id == id);
      if (indexFiltrado != -1) {
        _clientesFiltrados[indexFiltrado] = _clientesFiltrados[indexFiltrado].copyWith(isAtivo: false);
      }
      
      if (_clienteSelecionado?.id == id) {
        _clienteSelecionado = _clienteSelecionado!.copyWith(isAtivo: false);
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _erro = 'Erro ao inativar cliente: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ============================================
  // MÉTODOS DE FILTRO
  // ============================================

  void setFiltroStatus(String status) {
    _filtroStatus = status;
    notifyListeners();
  }

  void setTermoBusca(String termo) {
    _termoBusca = termo;
    notifyListeners();
  }

  void limparFiltros() {
    _filtroStatus = 'Todos';
    _termoBusca = '';
    _clientesFiltrados = List.from(_clientes);
    notifyListeners();
  }

  // ============================================
  // MÉTODOS DE SELEÇÃO
  // ============================================

  void selecionarCliente(ClienteModel? cliente) {
    _clienteSelecionado = cliente;
    notifyListeners();
  }

  void limparSelecao() {
    _clienteSelecionado = null;
    notifyListeners();
  }

  // ============================================
  // MÉTODOS AUXILIARES
  // ============================================

  ClienteModel? buscarPorIdLocal(String id) {
    try {
      return _clientes.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  void _ordenarClientes() {
    _clientes.sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
    _clientesFiltrados.sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
  }

  void limparErro() {
    _erro = null;
    notifyListeners();
  }

  void limparEstado() {
    _clientes = [];
    _clientesFiltrados = [];
    _clienteSelecionado = null;
    _isLoading = false;
    _isBuscando = false;
    _erro = null;
    _filtroStatus = 'Todos';
    _termoBusca = '';
    notifyListeners();
  }
}
