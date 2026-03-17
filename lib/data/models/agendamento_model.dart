import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo de Agendamento para o app Aroma de Hortelã
/// Representa uma sessão agendada com um cliente
class AgendamentoModel {
  final String? id;
  final String clienteId;
  final String clienteNome; // Desnormalizado para facilitar listagens
  final DateTime dataHora;
  final String tipoMassagem;
  final String duracao;
  final double? valor;
  final String status; // Agendado, Confirmado, Em andamento, Concluído, Cancelado, Não compareceu
  final String? observacoes;
  final DateTime createdAt;
  final DateTime updatedAt;

  AgendamentoModel({
    this.id,
    required this.clienteId,
    required this.clienteNome,
    required this.dataHora,
    required this.tipoMassagem,
    required this.duracao,
    this.valor,
    this.status = 'Agendado',
    this.observacoes,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // ============================================
  // GETTERS ÚTEIS
  // ============================================

  /// Retorna apenas a data (sem hora)
  DateTime get data => DateTime(dataHora.year, dataHora.month, dataHora.day);

  /// Retorna a hora formatada: "14:30"
  String get horaFormatada {
    final hora = dataHora.hour.toString().padLeft(2, '0');
    final minuto = dataHora.minute.toString().padLeft(2, '0');
    return '$hora:$minuto';
  }

  /// Retorna a duração em minutos
  int get duracaoEmMinutos {
    switch (duracao) {
      case '30 minutos':
        return 30;
      case '45 minutos':
        return 45;
      case '1 hora':
        return 60;
      case '1 hora e 30 minutos':
        return 90;
      case '2 horas':
        return 120;
      default:
        return 60;
    }
  }

  /// Retorna o horário de término previsto
  DateTime get horarioTermino => dataHora.add(Duration(minutes: duracaoEmMinutos));

  /// Retorna o horário de término formatado: "15:30"
  String get horarioTerminoFormatado {
    final termino = horarioTermino;
    final hora = termino.hour.toString().padLeft(2, '0');
    final minuto = termino.minute.toString().padLeft(2, '0');
    return '$hora:$minuto';
  }

  /// Verifica se o agendamento é hoje
  bool get isHoje {
    final hoje = DateTime.now();
    return dataHora.year == hoje.year &&
        dataHora.month == hoje.month &&
        dataHora.day == hoje.day;
  }

  /// Verifica se o agendamento já passou
  bool get isPassado => dataHora.isBefore(DateTime.now());

  /// Verifica se o agendamento é futuro
  bool get isFuturo => dataHora.isAfter(DateTime.now());

  /// Verifica se está agendado (não concluído/cancelado)
  bool get isPendente => 
      status == 'Agendado' || status == 'Confirmado';

  /// Verifica se foi concluído
  bool get isConcluido => status == 'Concluído';

  /// Verifica se foi cancelado
  bool get isCancelado => status == 'Cancelado';

  /// Verifica se o cliente não compareceu
  bool get isNaoCompareceu => status == 'Não compareceu';

  /// Retorna a cor do status (para uso na UI)
  /// Retorna o nome da cor, não a cor em si (para manter o model puro)
  String get statusCor {
    switch (status) {
      case 'Agendado':
        return 'warning';
      case 'Confirmado':
        return 'info';
      case 'Em andamento':
        return 'primary';
      case 'Concluído':
        return 'success';
      case 'Cancelado':
        return 'error';
      case 'Não compareceu':
        return 'grey';
      default:
        return 'grey';
    }
  }

  /// Retorna a data formatada: "15/02/2026"
  String get dataFormatada {
    final dia = dataHora.day.toString().padLeft(2, '0');
    final mes = dataHora.month.toString().padLeft(2, '0');
    final ano = dataHora.year;
    return '$dia/$mes/$ano';
  }

  /// Alias para tipoMassagem (compatibilidade)
  String get procedimento => tipoMassagem;


  // ============================================
  // CONVERSÃO PARA/DO FIRESTORE
  // ============================================

  /// Converte o modelo para Map (para salvar no Firestore)
  Map<String, dynamic> toMap() {
    return {
      'clienteId': clienteId,
      'clienteNome': clienteNome,
      'dataHora': Timestamp.fromDate(dataHora),
      'tipoMassagem': tipoMassagem,
      'duracao': duracao,
      'valor': valor,
      'status': status,
      'observacoes': observacoes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    };
  }

  /// Cria um modelo a partir de um DocumentSnapshot do Firestore
  factory AgendamentoModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return AgendamentoModel(
      id: doc.id,
      clienteId: data['clienteId'] ?? '',
      clienteNome: data['clienteNome'] ?? '',
      dataHora: data['dataHora'] != null 
          ? (data['dataHora'] as Timestamp).toDate() 
          : DateTime.now(),
      tipoMassagem: data['tipoMassagem'] ?? '',
      duracao: data['duracao'] ?? '1 hora',
      valor: data['valor']?.toDouble(),
      status: data['status'] ?? 'Agendado',
      observacoes: data['observacoes'],
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : DateTime.now(),
    );
  }

  /// Cria um modelo a partir de um Map genérico
  factory AgendamentoModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return AgendamentoModel(
      id: id ?? map['id'],
      clienteId: map['clienteId'] ?? '',
      clienteNome: map['clienteNome'] ?? '',
      dataHora: map['dataHora'] != null
          ? (map['dataHora'] is Timestamp
              ? (map['dataHora'] as Timestamp).toDate()
              : DateTime.parse(map['dataHora']))
          : DateTime.now(),
      tipoMassagem: map['tipoMassagem'] ?? '',
      duracao: map['duracao'] ?? '1 hora',
      valor: map['valor']?.toDouble(),
      status: map['status'] ?? 'Agendado',
      observacoes: map['observacoes'],
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] is Timestamp
              ? (map['createdAt'] as Timestamp).toDate()
              : DateTime.parse(map['createdAt']))
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] is Timestamp
              ? (map['updatedAt'] as Timestamp).toDate()
              : DateTime.parse(map['updatedAt']))
          : DateTime.now(),
    );
  }

  // ============================================
  // CÓPIA COM MODIFICAÇÕES
  // ============================================

  /// Cria uma cópia do modelo com os campos especificados alterados
  AgendamentoModel copyWith({
    String? id,
    String? clienteId,
    String? clienteNome,
    DateTime? dataHora,
    String? tipoMassagem,
    String? duracao,
    double? valor,
    String? status,
    String? observacoes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AgendamentoModel(
      id: id ?? this.id,
      clienteId: clienteId ?? this.clienteId,
      clienteNome: clienteNome ?? this.clienteNome,
      dataHora: dataHora ?? this.dataHora,
      tipoMassagem: tipoMassagem ?? this.tipoMassagem,
      duracao: duracao ?? this.duracao,
      valor: valor ?? this.valor,
      status: status ?? this.status,
      observacoes: observacoes ?? this.observacoes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // ============================================
  // MODELO VAZIO
  // ============================================

  /// Retorna um modelo vazio para inicialização
  factory AgendamentoModel.empty({String? clienteId, String? clienteNome}) {
    return AgendamentoModel(
      clienteId: clienteId ?? '',
      clienteNome: clienteNome ?? '',
      dataHora: DateTime.now().add(const Duration(hours: 1)),
      tipoMassagem: '',
      duracao: '1 hora',
    );
  }

  // ============================================
  // MÉTODOS DE NEGÓCIO
  // ============================================

  /// Verifica se há conflito de horário com outro agendamento
  bool conflitaCom(AgendamentoModel outro) {
    // Não conflita consigo mesmo
    if (id != null && id == outro.id) return false;
    
    // Não verifica agendamentos cancelados
    if (isCancelado || outro.isCancelado) return false;
    
    // Verifica sobreposição de horários
    final inicioA = dataHora;
    final fimA = horarioTermino;
    final inicioB = outro.dataHora;
    final fimB = outro.horarioTermino;
    
    // Há conflito se um começa antes do outro terminar
    return inicioA.isBefore(fimB) && fimA.isAfter(inicioB);
  }

  // ============================================
  // COMPARAÇÃO E IGUALDADE
  // ============================================

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AgendamentoModel &&
        other.id == id &&
        other.clienteId == clienteId &&
        other.dataHora == dataHora &&
        other.tipoMassagem == tipoMassagem;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        clienteId.hashCode ^
        dataHora.hashCode ^
        tipoMassagem.hashCode;
  }

  // ============================================
  // REPRESENTAÇÃO EM STRING
  // ============================================

  @override
  String toString() {
    return 'AgendamentoModel(id: $id, clienteNome: $clienteNome, dataHora: $dataHora, tipoMassagem: $tipoMassagem, status: $status)';
  }
}
