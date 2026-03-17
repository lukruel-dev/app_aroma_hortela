import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/agendamento_model.dart';
import '../../core/constants/app_constants.dart';

/// Repositório de Agendamentos
/// Gerencia todas as operações de CRUD no Firestore
class AgendamentoRepository {
  final FirebaseFirestore _firestore;
  
  /// Referência para a coleção de agendamentos
  late final CollectionReference<Map<String, dynamic>> _collection;

  AgendamentoRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance {
    _collection = _firestore.collection(AppConstants.collectionAgendamentos);
  }

  // ============================================
  // CREATE - Criar
  // ============================================

  /// Adiciona um novo agendamento
  /// Retorna o ID do agendamento criado
  Future<String> criar(AgendamentoModel agendamento) async {
    try {
      final docRef = await _collection.add(agendamento.toMap());
      return docRef.id;
    } catch (e) {
      throw AgendamentoRepositoryException('Erro ao criar agendamento: $e');
    }
  }

  // ============================================
  // READ - Ler
  // ============================================

  /// Busca um agendamento pelo ID
  Future<AgendamentoModel?> buscarPorId(String id) async {
    try {
      final doc = await _collection.doc(id).get();
      
      if (!doc.exists) return null;
      
      return AgendamentoModel.fromFirestore(doc);
    } catch (e) {
      throw AgendamentoRepositoryException('Erro ao buscar agendamento: $e');
    }
  }

  /// Lista todos os agendamentos
  Future<List<AgendamentoModel>> listarTodos() async {
    try {
      final snapshot = await _collection
          .orderBy('dataHora', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => AgendamentoModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw AgendamentoRepositoryException('Erro ao listar agendamentos: $e');
    }
  }

  /// Lista agendamentos de um cliente específico
  Future<List<AgendamentoModel>> listarPorCliente(String clienteId) async {
    try {
      final snapshot = await _collection
          .where('clienteId', isEqualTo: clienteId)
          .orderBy('dataHora', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => AgendamentoModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw AgendamentoRepositoryException('Erro ao listar agendamentos do cliente: $e');
    }
  }

  /// Lista agendamentos de uma data específica
  Future<List<AgendamentoModel>> listarPorData(DateTime data) async {
    try {
      final inicioDia = DateTime(data.year, data.month, data.day);
      final fimDia = DateTime(data.year, data.month, data.day, 23, 59, 59);
      
      final snapshot = await _collection
          .where('dataHora', isGreaterThanOrEqualTo: Timestamp.fromDate(inicioDia))
          .where('dataHora', isLessThanOrEqualTo: Timestamp.fromDate(fimDia))
          .orderBy('dataHora')
          .get();
      
      return snapshot.docs
          .map((doc) => AgendamentoModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw AgendamentoRepositoryException('Erro ao listar agendamentos por data: $e');
    }
  }

  /// Lista agendamentos de hoje
  Future<List<AgendamentoModel>> listarHoje() async {
    return listarPorData(DateTime.now());
  }

  /// Lista agendamentos de uma semana específica
  Future<List<AgendamentoModel>> listarPorSemana(DateTime dataReferencia) async {
    try {
      // Encontra o início da semana (domingo)
      final diaSemana = dataReferencia.weekday;
      final inicioSemana = dataReferencia.subtract(Duration(days: diaSemana % 7));
      final inicioSemanaZerado = DateTime(inicioSemana.year, inicioSemana.month, inicioSemana.day);
      final fimSemana = inicioSemanaZerado.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
      
      final snapshot = await _collection
          .where('dataHora', isGreaterThanOrEqualTo: Timestamp.fromDate(inicioSemanaZerado))
          .where('dataHora', isLessThanOrEqualTo: Timestamp.fromDate(fimSemana))
          .orderBy('dataHora')
          .get();
      
      return snapshot.docs
          .map((doc) => AgendamentoModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw AgendamentoRepositoryException('Erro ao listar agendamentos da semana: $e');
    }
  }

  /// Lista agendamentos de um mês específico
  Future<List<AgendamentoModel>> listarPorMes(int ano, int mes) async {
    try {
      final inicioMes = DateTime(ano, mes, 1);
      final fimMes = DateTime(ano, mes + 1, 0, 23, 59, 59);
      
      final snapshot = await _collection
          .where('dataHora', isGreaterThanOrEqualTo: Timestamp.fromDate(inicioMes))
          .where('dataHora', isLessThanOrEqualTo: Timestamp.fromDate(fimMes))
          .orderBy('dataHora')
          .get();
      
      return snapshot.docs
          .map((doc) => AgendamentoModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw AgendamentoRepositoryException('Erro ao listar agendamentos do mês: $e');
    }
  }

  /// Lista próximos agendamentos (a partir de agora)
  Future<List<AgendamentoModel>> listarProximos({int limite = 10}) async {
    try {
      final agora = DateTime.now();
      
      final snapshot = await _collection
          .where('dataHora', isGreaterThanOrEqualTo: Timestamp.fromDate(agora))
          .where('status', whereIn: ['Agendado', 'Confirmado'])
          .orderBy('dataHora')
          .limit(limite)
          .get();
      
      return snapshot.docs
          .map((doc) => AgendamentoModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw AgendamentoRepositoryException('Erro ao listar próximos agendamentos: $e');
    }
  }

  /// Lista agendamentos por status
  Future<List<AgendamentoModel>> listarPorStatus(String status) async {
    try {
      final snapshot = await _collection
          .where('status', isEqualTo: status)
          .orderBy('dataHora', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => AgendamentoModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw AgendamentoRepositoryException('Erro ao listar agendamentos por status: $e');
    }
  }

  // ============================================
  // STREAMS (Tempo Real)
  // ============================================

  /// Stream de todos os agendamentos (tempo real)
  Stream<List<AgendamentoModel>> streamAgendamentos() {
    return _collection
        .orderBy('dataHora', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AgendamentoModel.fromFirestore(doc))
            .toList());
  }

  /// Stream dos agendamentos de um cliente (tempo real)
  Stream<List<AgendamentoModel>> streamAgendamentosPorCliente(String clienteId) {
    return _collection
        .where('clienteId', isEqualTo: clienteId)
        .orderBy('dataHora', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AgendamentoModel.fromFirestore(doc))
            .toList());
  }

  /// Stream dos agendamentos de uma data específica (tempo real)
  Stream<List<AgendamentoModel>> streamAgendamentosPorData(DateTime data) {
    final inicioDia = DateTime(data.year, data.month, data.day);
    final fimDia = DateTime(data.year, data.month, data.day, 23, 59, 59);
    
    return _collection
        .where('dataHora', isGreaterThanOrEqualTo: Timestamp.fromDate(inicioDia))
        .where('dataHora', isLessThanOrEqualTo: Timestamp.fromDate(fimDia))
        .orderBy('dataHora')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AgendamentoModel.fromFirestore(doc))
            .toList());
  }

  /// Stream dos agendamentos de hoje (tempo real)
  Stream<List<AgendamentoModel>> streamAgendamentosHoje() {
    return streamAgendamentosPorData(DateTime.now());
  }

  /// Stream de um agendamento específico (tempo real)
  Stream<AgendamentoModel?> streamAgendamento(String id) {
    return _collection
        .doc(id)
        .snapshots()
        .map((doc) => doc.exists ? AgendamentoModel.fromFirestore(doc) : null);
  }

  // ============================================
  // UPDATE - Atualizar
  // ============================================

  /// Atualiza um agendamento existente
  Future<void> atualizar(AgendamentoModel agendamento) async {
    if (agendamento.id == null) {
      throw AgendamentoRepositoryException('ID do agendamento é obrigatório para atualização');
    }
    
    try {
      await _collection.doc(agendamento.id).update(agendamento.toMap());
    } catch (e) {
      throw AgendamentoRepositoryException('Erro ao atualizar agendamento: $e');
    }
  }

  /// Atualiza apenas o status do agendamento
  Future<void> atualizarStatus(String id, String status) async {
    try {
      await _collection.doc(id).update({
        'status': status,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw AgendamentoRepositoryException('Erro ao atualizar status: $e');
    }
  }

  /// Confirma um agendamento
  Future<void> confirmar(String id) async {
    await atualizarStatus(id, 'Confirmado');
  }

  /// Inicia um agendamento (em andamento)
  Future<void> iniciar(String id) async {
    await atualizarStatus(id, 'Em andamento');
  }

  /// Conclui um agendamento
  Future<void> concluir(String id) async {
    await atualizarStatus(id, 'Concluído');
  }

  /// Cancela um agendamento
  Future<void> cancelar(String id) async {
    await atualizarStatus(id, 'Cancelado');
  }

  /// Marca como não compareceu
  Future<void> marcarNaoCompareceu(String id) async {
    await atualizarStatus(id, 'Não compareceu');
  }

  /// Atualiza o nome do cliente em todos os agendamentos
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
      throw AgendamentoRepositoryException('Erro ao atualizar nome do cliente: $e');
    }
  }

  // ============================================
  // DELETE - Excluir
  // ============================================

  /// Exclui um agendamento permanentemente
  Future<void> excluir(String id) async {
    try {
      await _collection.doc(id).delete();
    } catch (e) {
      throw AgendamentoRepositoryException('Erro ao excluir agendamento: $e');
    }
  }

  /// Exclui todos os agendamentos de um cliente
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
      throw AgendamentoRepositoryException('Erro ao excluir agendamentos do cliente: $e');
    }
  }

  // ============================================
  // ESTATÍSTICAS
  // ============================================

  /// Retorna o total de agendamentos
  Future<int> contarTotal() async {
    try {
      final snapshot = await _collection.count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      throw AgendamentoRepositoryException('Erro ao contar agendamentos: $e');
    }
  }

  /// Retorna o total de agendamentos de um cliente
  Future<int> contarPorCliente(String clienteId) async {
    try {
      final snapshot = await _collection
          .where('clienteId', isEqualTo: clienteId)
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      throw AgendamentoRepositoryException('Erro ao contar agendamentos do cliente: $e');
    }
  }

  /// Retorna o total de agendamentos por status
  Future<int> contarPorStatus(String status) async {
    try {
      final snapshot = await _collection
          .where('status', isEqualTo: status)
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      throw AgendamentoRepositoryException('Erro ao contar por status: $e');
    }
  }

  /// Retorna o total de agendamentos de hoje
  Future<int> contarHoje() async {
    try {
      final hoje = DateTime.now();
      final inicioDia = DateTime(hoje.year, hoje.month, hoje.day);
      final fimDia = DateTime(hoje.year, hoje.month, hoje.day, 23, 59, 59);
      
      final snapshot = await _collection
          .where('dataHora', isGreaterThanOrEqualTo: Timestamp.fromDate(inicioDia))
          .where('dataHora', isLessThanOrEqualTo: Timestamp.fromDate(fimDia))
          .count()
          .get();
      
      return snapshot.count ?? 0;
    } catch (e) {
      throw AgendamentoRepositoryException('Erro ao contar agendamentos de hoje: $e');
    }
  }

  /// Retorna estatísticas do mês
  Future<Map<String, int>> estatisticasMes(int ano, int mes) async {
    try {
      final agendamentos = await listarPorMes(ano, mes);
      
      return {
        'total': agendamentos.length,
        'agendados': agendamentos.where((a) => a.status == 'Agendado').length,
        'confirmados': agendamentos.where((a) => a.status == 'Confirmado').length,
        'concluidos': agendamentos.where((a) => a.status == 'Concluído').length,
        'cancelados': agendamentos.where((a) => a.status == 'Cancelado').length,
        'naoCompareceram': agendamentos.where((a) => a.status == 'Não compareceu').length,
      };
    } catch (e) {
      throw AgendamentoRepositoryException('Erro ao calcular estatísticas: $e');
    }
  }

  // ============================================
  // VALIDAÇÕES
  // ============================================

  /// Verifica se há conflito de horário
  Future<bool> verificarConflito(AgendamentoModel agendamento) async {
    try {
      final agendamentosDoDia = await listarPorData(agendamento.dataHora);
      
      for (var existente in agendamentosDoDia) {
        if (agendamento.conflitaCom(existente)) {
          return true;
        }
      }
      
      return false;
    } catch (e) {
      throw AgendamentoRepositoryException('Erro ao verificar conflito: $e');
    }
  }

  /// Retorna os horários disponíveis para uma data
  Future<List<String>> horariosDisponiveis(DateTime data) async {
    try {
      final agendamentosDoDia = await listarPorData(data);
      
      // Lista de todos os horários possíveis (8h às 20h, de 30 em 30 min)
      final todosHorarios = <String>[];
      for (int hora = 8; hora < 20; hora++) {
        todosHorarios.add('${hora.toString().padLeft(2, '0')}:00');
        todosHorarios.add('${hora.toString().padLeft(2, '0')}:30');
      }
      
      // Remove horários já ocupados
      final horariosOcupados = agendamentosDoDia
          .where((a) => !a.isCancelado)
          .map((a) => a.horaFormatada)
          .toSet();
      
      return todosHorarios
          .where((h) => !horariosOcupados.contains(h))
          .toList();
    } catch (e) {
      throw AgendamentoRepositoryException('Erro ao buscar horários disponíveis: $e');
    }
  }
}

/// Exceção customizada para erros do repositório
class AgendamentoRepositoryException implements Exception {
  final String message;
  
  AgendamentoRepositoryException(this.message);
  
  @override
  String toString() => message;
}
