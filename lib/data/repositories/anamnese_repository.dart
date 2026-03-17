import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/anamnese_model.dart';
import '../../core/constants/app_constants.dart';

/// Repositório de Anamneses
/// Gerencia todas as operações de CRUD no Firestore
class AnamneseRepository {
  final FirebaseFirestore _firestore;
  
  /// Referência para a coleção de anamneses
  late final CollectionReference<Map<String, dynamic>> _collection;

  AnamneseRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance {
    _collection = _firestore.collection(AppConstants.collectionAnamneses);
  }

  // ============================================
  // CREATE - Criar
  // ============================================

  /// Adiciona uma nova anamnese
  /// Retorna o ID da anamnese criada
  Future<String> criar(AnamneseModel anamnese) async {
    try {
      final docRef = await _collection.add(anamnese.toMap());
      return docRef.id;
    } catch (e) {
      throw AnamneseRepositoryException('Erro ao criar anamnese: $e');
    }
  }

  // ============================================
  // READ - Ler
  // ============================================

  /// Busca uma anamnese pelo ID
  Future<AnamneseModel?> buscarPorId(String id) async {
    try {
      final doc = await _collection.doc(id).get();
      
      if (!doc.exists) return null;
      
      return AnamneseModel.fromFirestore(doc);
    } catch (e) {
      throw AnamneseRepositoryException('Erro ao buscar anamnese: $e');
    }
  }

  /// Lista todas as anamneses
  Future<List<AnamneseModel>> listarTodas() async {
    try {
      final snapshot = await _collection
          .orderBy('dataAvaliacao', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => AnamneseModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw AnamneseRepositoryException('Erro ao listar anamneses: $e');
    }
  }

  /// Lista todas as anamneses de um cliente específico
  Future<List<AnamneseModel>> listarPorCliente(String clienteId) async {
    try {
      final snapshot = await _collection
          .where('clienteId', isEqualTo: clienteId)
          .orderBy('dataAvaliacao', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => AnamneseModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw AnamneseRepositoryException('Erro ao listar anamneses do cliente: $e');
    }
  }

  /// Busca a anamnese mais recente de um cliente
  Future<AnamneseModel?> buscarMaisRecentePorCliente(String clienteId) async {
    try {
      final snapshot = await _collection
          .where('clienteId', isEqualTo: clienteId)
          .orderBy('dataAvaliacao', descending: true)
          .limit(1)
          .get();
      
      if (snapshot.docs.isEmpty) return null;
      
      return AnamneseModel.fromFirestore(snapshot.docs.first);
    } catch (e) {
      throw AnamneseRepositoryException('Erro ao buscar anamnese mais recente: $e');
    }
  }

  /// Stream de todas as anamneses (tempo real)
  Stream<List<AnamneseModel>> streamAnamneses() {
    return _collection
        .orderBy('dataAvaliacao', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AnamneseModel.fromFirestore(doc))
            .toList());
  }

  /// Stream das anamneses de um cliente (tempo real)
  Stream<List<AnamneseModel>> streamAnamnesesPorCliente(String clienteId) {
    return _collection
        .where('clienteId', isEqualTo: clienteId)
        .orderBy('dataAvaliacao', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AnamneseModel.fromFirestore(doc))
            .toList());
  }

  /// Stream de uma anamnese específica (tempo real)
  Stream<AnamneseModel?> streamAnamnese(String id) {
    return _collection
        .doc(id)
        .snapshots()
        .map((doc) => doc.exists ? AnamneseModel.fromFirestore(doc) : null);
  }

  // ============================================
  // UPDATE - Atualizar
  // ============================================

  /// Atualiza uma anamnese existente
  Future<void> atualizar(AnamneseModel anamnese) async {
    if (anamnese.id == null) {
      throw AnamneseRepositoryException('ID da anamnese é obrigatório para atualização');
    }
    
    try {
      await _collection.doc(anamnese.id).update(anamnese.toMap());
    } catch (e) {
      throw AnamneseRepositoryException('Erro ao atualizar anamnese: $e');
    }
  }

  /// Atualiza o nome do cliente em todas as anamneses
  /// (usado quando o nome do cliente é alterado)
  Future<void> atualizarNomeCliente(String clienteId, String novoNome) async {
    try {
      final snapshot = await _collection
          .where('clienteId', isEqualTo: clienteId)
          .get();
      
      final batch = _firestore.batch();
      
      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {
          'clienteNome': novoNome,
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        });
      }
      
      await batch.commit();
    } catch (e) {
      throw AnamneseRepositoryException('Erro ao atualizar nome do cliente nas anamneses: $e');
    }
  }

  // ============================================
  // DELETE - Excluir
  // ============================================

  /// Exclui uma anamnese permanentemente
  Future<void> excluir(String id) async {
    try {
      await _collection.doc(id).delete();
    } catch (e) {
      throw AnamneseRepositoryException('Erro ao excluir anamnese: $e');
    }
  }

  /// Exclui todas as anamneses de um cliente
  Future<void> excluirPorCliente(String clienteId) async {
    try {
      final snapshot = await _collection
          .where('clienteId', isEqualTo: clienteId)
          .get();
      
      final batch = _firestore.batch();
      
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
    } catch (e) {
      throw AnamneseRepositoryException('Erro ao excluir anamneses do cliente: $e');
    }
  }

  // ============================================
  // ESTATÍSTICAS
  // ============================================

  /// Retorna o total de anamneses
  Future<int> contarTotal() async {
    try {
      final snapshot = await _collection.count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      throw AnamneseRepositoryException('Erro ao contar anamneses: $e');
    }
  }

  /// Retorna o total de anamneses de um cliente
  Future<int> contarPorCliente(String clienteId) async {
    try {
      final snapshot = await _collection
          .where('clienteId', isEqualTo: clienteId)
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      throw AnamneseRepositoryException('Erro ao contar anamneses do cliente: $e');
    }
  }

  /// Verifica se um cliente possui anamnese
  Future<bool> clientePossuiAnamnese(String clienteId) async {
    try {
      final count = await contarPorCliente(clienteId);
      return count > 0;
    } catch (e) {
      throw AnamneseRepositoryException('Erro ao verificar anamnese do cliente: $e');
    }
  }

  /// Retorna anamneses criadas em um período
  Future<List<AnamneseModel>> anamnesesNoPeriodo(
    DateTime inicio, 
    DateTime fim,
  ) async {
    try {
      final snapshot = await _collection
          .where('dataAvaliacao', isGreaterThanOrEqualTo: Timestamp.fromDate(inicio))
          .where('dataAvaliacao', isLessThanOrEqualTo: Timestamp.fromDate(fim))
          .orderBy('dataAvaliacao', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => AnamneseModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw AnamneseRepositoryException('Erro ao buscar anamneses por período: $e');
    }
  }

  // ============================================
  // CONSULTAS ESPECIAIS
  // ============================================

  /// Busca anamneses por condição de saúde
  Future<List<AnamneseModel>> buscarPorCondicaoSaude(String condicao) async {
    try {
      final snapshot = await _collection
          .where('condicoesSaude', arrayContains: condicao)
          .orderBy('dataAvaliacao', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => AnamneseModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw AnamneseRepositoryException('Erro ao buscar por condição de saúde: $e');
    }
  }

  /// Busca anamneses de gestantes
  Future<List<AnamneseModel>> buscarGestantes() async {
    return buscarPorCondicaoSaude('Gestante');
  }

  /// Busca anamneses por nível de estresse
  Future<List<AnamneseModel>> buscarPorNivelEstresse(String nivel) async {
    try {
      final snapshot = await _collection
          .where('nivelEstresse', isEqualTo: nivel)
          .orderBy('dataAvaliacao', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => AnamneseModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw AnamneseRepositoryException('Erro ao buscar por nível de estresse: $e');
    }
  }

  /// Busca anamneses que possuem contraindicações
  Future<List<AnamneseModel>> buscarComContraindicacoes() async {
    try {
      final snapshot = await _collection
          .where('contraindicacoes', isNull: false)
          .orderBy('dataAvaliacao', descending: true)
          .get();
      
      // Filtra no cliente para garantir que não está vazio
      return snapshot.docs
          .map((doc) => AnamneseModel.fromFirestore(doc))
          .where((anamnese) => anamnese.temContraindicacoes)
          .toList();
    } catch (e) {
      throw AnamneseRepositoryException('Erro ao buscar com contraindicações: $e');
    }
  }
}

/// Exceção customizada para erros do repositório
class AnamneseRepositoryException implements Exception {
  final String message;
  
  AnamneseRepositoryException(this.message);
  
  @override
  String toString() => message;
}
