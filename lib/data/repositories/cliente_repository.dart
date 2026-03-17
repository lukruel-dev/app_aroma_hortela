import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cliente_model.dart';
import '../../core/constants/app_constants.dart';

/// Repositório de Clientes
/// Gerencia todas as operações de CRUD no Firestore
class ClienteRepository {
  final FirebaseFirestore _firestore;
  
  /// Referência para a coleção de clientes
  late final CollectionReference<Map<String, dynamic>> _collection;

  ClienteRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance {
    _collection = _firestore.collection(AppConstants.collectionClientes);
  }

  // ============================================
  // CREATE - Criar
  // ============================================

  /// Adiciona um novo cliente
  /// Retorna o ID do cliente criado
  Future<String> criar(ClienteModel cliente) async {
    try {
      final docRef = await _collection.add(cliente.toMap());
      return docRef.id;
    } catch (e) {
      throw ClienteRepositoryException('Erro ao criar cliente: $e');
    }
  }

  // ============================================
  // READ - Ler
  // ============================================

  /// Busca um cliente pelo ID
  Future<ClienteModel?> buscarPorId(String id) async {
    try {
      final doc = await _collection.doc(id).get();
      
      if (!doc.exists) return null;
      
      return ClienteModel.fromFirestore(doc);
    } catch (e) {
      throw ClienteRepositoryException('Erro ao buscar cliente: $e');
    }
  }

  /// Lista todos os clientes
  Future<List<ClienteModel>> listarTodos() async {
    try {
      final snapshot = await _collection
          .orderBy('nome')
          .get();
      
      return snapshot.docs
          .map((doc) => ClienteModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ClienteRepositoryException('Erro ao listar clientes: $e');
    }
  }

  /// Lista clientes ativos
  Future<List<ClienteModel>> listarAtivos() async {
    try {
      final snapshot = await _collection
          .where('status', isEqualTo: 'Ativo')
          .orderBy('nome')
          .get();
      
      return snapshot.docs
          .map((doc) => ClienteModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ClienteRepositoryException('Erro ao listar clientes ativos: $e');
    }
  }

  /// Busca clientes por nome (busca parcial)
  Future<List<ClienteModel>> buscarPorNome(String termo) async {
    try {
      // Firebase não suporta busca "contains", então usamos range query
      final termoLower = termo.toLowerCase();
      final termoUpper = '$termoLower\uf8ff';
      
      final snapshot = await _collection
          .orderBy('nome')
          .startAt([termoLower])
          .endAt([termoUpper])
          .get();
      
      return snapshot.docs
          .map((doc) => ClienteModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ClienteRepositoryException('Erro ao buscar clientes: $e');
    }
  }

  /// Stream de todos os clientes (tempo real)
  Stream<List<ClienteModel>> streamClientes() {
    return _collection
        .orderBy('nome')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ClienteModel.fromFirestore(doc))
            .toList());
  }

  /// Stream de clientes ativos (tempo real)
  Stream<List<ClienteModel>> streamClientesAtivos() {
    return _collection
        .where('status', isEqualTo: 'Ativo')
        .orderBy('nome')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ClienteModel.fromFirestore(doc))
            .toList());
  }

  /// Stream de um cliente específico (tempo real)
  Stream<ClienteModel?> streamCliente(String id) {
    return _collection
        .doc(id)
        .snapshots()
        .map((doc) => doc.exists ? ClienteModel.fromFirestore(doc) : null);
  }

  // ============================================
  // UPDATE - Atualizar
  // ============================================

  /// Atualiza um cliente existente
  Future<void> atualizar(ClienteModel cliente) async {
    if (cliente.id == null) {
      throw ClienteRepositoryException('ID do cliente é obrigatório para atualização');
    }
    
    try {
      await _collection.doc(cliente.id).update(cliente.toMap());
    } catch (e) {
      throw ClienteRepositoryException('Erro ao atualizar cliente: $e');
    }
  }

  /// Atualiza apenas o status do cliente
  Future<void> atualizarStatus(String id, String status) async {
    try {
      await _collection.doc(id).update({
        'status': status,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw ClienteRepositoryException('Erro ao atualizar status: $e');
    }
  }

  /// Ativa um cliente
  Future<void> ativar(String id) async {
    await atualizarStatus(id, 'Ativo');
  }

  /// Inativa um cliente
  Future<void> inativar(String id) async {
    await atualizarStatus(id, 'Inativo');
  }

  // ============================================
  // DELETE - Excluir
  // ============================================

  /// Exclui um cliente permanentemente
  /// ⚠️ Cuidado: isso também deveria excluir anamneses e agendamentos relacionados
  Future<void> excluir(String id) async {
    try {
      await _collection.doc(id).delete();
    } catch (e) {
      throw ClienteRepositoryException('Erro ao excluir cliente: $e');
    }
  }

  /// Exclui um cliente e todos os dados relacionados (anamneses e agendamentos)
  Future<void> excluirComDadosRelacionados(String id) async {
    try {
      final batch = _firestore.batch();
      
      // Exclui o cliente
      batch.delete(_collection.doc(id));
      
      // Exclui anamneses do cliente
      final anamneses = await _firestore
          .collection(AppConstants.collectionAnamneses)
          .where('clienteId', isEqualTo: id)
          .get();
      
      for (var doc in anamneses.docs) {
        batch.delete(doc.reference);
      }
      
      // Exclui agendamentos do cliente
      final agendamentos = await _firestore
          .collection(AppConstants.collectionAgendamentos)
          .where('clienteId', isEqualTo: id)
          .get();
      
      for (var doc in agendamentos.docs) {
        batch.delete(doc.reference);
      }
      
      // Executa todas as exclusões de uma vez
      await batch.commit();
    } catch (e) {
      throw ClienteRepositoryException('Erro ao excluir cliente e dados relacionados: $e');
    }
  }

  // ============================================
  // ESTATÍSTICAS
  // ============================================

  /// Retorna o total de clientes
  Future<int> contarTotal() async {
    try {
      final snapshot = await _collection.count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      throw ClienteRepositoryException('Erro ao contar clientes: $e');
    }
  }

  /// Retorna o total de clientes ativos
  Future<int> contarAtivos() async {
    try {
      final snapshot = await _collection
          .where('status', isEqualTo: 'Ativo')
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      throw ClienteRepositoryException('Erro ao contar clientes ativos: $e');
    }
  }

  /// Retorna clientes criados em um período
  Future<List<ClienteModel>> clientesCriadosNoPeriodo(
    DateTime inicio, 
    DateTime fim,
  ) async {
    try {
      final snapshot = await _collection
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(inicio))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(fim))
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => ClienteModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ClienteRepositoryException('Erro ao buscar clientes por período: $e');
    }
  }

  // ============================================
  // VALIDAÇÕES
  // ============================================

  /// Verifica se já existe um cliente com o mesmo telefone
  Future<bool> telefoneJaExiste(String telefone, {String? excluirId}) async {
    try {
      final query = await _collection
          .where('telefone', isEqualTo: telefone)
          .limit(1)
          .get();
      
      if (query.docs.isEmpty) return false;
      
      // Se estamos editando, verificar se o telefone pertence ao próprio cliente
      if (excluirId != null && query.docs.first.id == excluirId) {
        return false;
      }
      
      return true;
    } catch (e) {
      throw ClienteRepositoryException('Erro ao verificar telefone: $e');
    }
  }

  /// Verifica se já existe um cliente com o mesmo email
  Future<bool> emailJaExiste(String email, {String? excluirId}) async {
    try {
      final query = await _collection
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      
      if (query.docs.isEmpty) return false;
      
      // Se estamos editando, verificar se o email pertence ao próprio cliente
      if (excluirId != null && query.docs.first.id == excluirId) {
        return false;
      }
      
      return true;
    } catch (e) {
      throw ClienteRepositoryException('Erro ao verificar email: $e');
    }
  }
}

/// Exceção customizada para erros do repositório
class ClienteRepositoryException implements Exception {
  final String message;
  
  ClienteRepositoryException(this.message);
  
  @override
  String toString() => message;
}
