import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo de Anamnese para o app Aroma de Hortelã
/// Representa a ficha de avaliação completa do cliente
class AnamneseModel {
  final String? id;
  final String clienteId;
  final String clienteNome; // Desnormalizado para facilitar listagens
  final DateTime dataAvaliacao;
  
  // ============================================
  // QUEIXA PRINCIPAL
  // ============================================
  final String queixaPrincipal;
  final List<String> areasDor; // Lista de áreas com dor/desconforto
  
  // ============================================
  // HISTÓRICO DE SAÚDE
  // ============================================
  final String? historicoMedico;
  final List<String> condicoesSaude; // Hipertensão, Diabetes, etc.
  final String? cirurgias;
  final String? medicamentosEmUso;
  final String? alergias;
  
  // ============================================
  // ESTILO DE VIDA
  // ============================================
  final String nivelEstresse; // Baixo, Moderado, Alto, Muito alto
  final String qualidadeSono; // Excelente, Boa, Regular, Ruim, Muito ruim
  final String atividadeFisica; // Sedentário, Leve, Moderado, Intenso
  final String consumoAgua; // Menos de 1L, 1-2L, 2-3L, Mais de 3L
  
  // ============================================
  // OBJETIVOS E PREFERÊNCIAS
  // ============================================
  final List<String> objetivos; // Alívio de dores, Relaxamento, etc.
  final String? preferenciaPressao; // Leve, Moderada, Firme
  final List<String>? areasEvitar; // Áreas que não devem ser massageadas
  
  // ============================================
  // CONTRAINDICAÇÕES E OBSERVAÇÕES
  // ============================================
  final String? contraindicacoes;
  final String? observacoesGerais;
  
  // ============================================
  // METADADOS
  // ============================================
  final DateTime createdAt;
  final DateTime updatedAt;

  AnamneseModel({
    this.id,
    required this.clienteId,
    required this.clienteNome,
    required this.dataAvaliacao,
    required this.queixaPrincipal,
    this.areasDor = const [],
    this.historicoMedico,
    this.condicoesSaude = const [],
    this.cirurgias,
    this.medicamentosEmUso,
    this.alergias,
    this.nivelEstresse = 'Moderado',
    this.qualidadeSono = 'Regular',
    this.atividadeFisica = 'Sedentário',
    this.consumoAgua = '1 a 2 litros',
    this.objetivos = const [],
    this.preferenciaPressao,
    this.areasEvitar,
    this.contraindicacoes,
    this.observacoesGerais,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // ============================================
  // GETTERS ÚTEIS
  // ============================================

  /// Verifica se tem alguma condição de saúde
  bool get temCondicoesSaude => condicoesSaude.isNotEmpty;

  /// Verifica se é gestante
  bool get isGestante => condicoesSaude.contains('Gestante');

  /// Verifica se tem contraindicações
  bool get temContraindicacoes => 
      contraindicacoes != null && contraindicacoes!.trim().isNotEmpty;

  /// Verifica se tem áreas para evitar
  bool get temAreasEvitar => 
      areasEvitar != null && areasEvitar!.isNotEmpty;

  /// Retorna um resumo das condições de saúde
  String get resumoCondicoes {
    if (condicoesSaude.isEmpty) return 'Nenhuma condição informada';
    return condicoesSaude.join(', ');
  }

  /// Retorna um resumo das áreas de dor
  String get resumoAreasDor {
    if (areasDor.isEmpty) return 'Nenhuma área informada';
    return areasDor.join(', ');
  }

  /// Retorna um resumo dos objetivos
  String get resumoObjetivos {
    if (objetivos.isEmpty) return 'Nenhum objetivo informado';
    return objetivos.join(', ');
  }

  // ============================================
  // CONVERSÃO PARA/DO FIRESTORE
  // ============================================

  /// Converte o modelo para Map (para salvar no Firestore)
  Map<String, dynamic> toMap() {
    return {
      'clienteId': clienteId,
      'clienteNome': clienteNome,
      'dataAvaliacao': Timestamp.fromDate(dataAvaliacao),
      'queixaPrincipal': queixaPrincipal,
      'areasDor': areasDor,
      'historicoMedico': historicoMedico,
      'condicoesSaude': condicoesSaude,
      'cirurgias': cirurgias,
      'medicamentosEmUso': medicamentosEmUso,
      'alergias': alergias,
      'nivelEstresse': nivelEstresse,
      'qualidadeSono': qualidadeSono,
      'atividadeFisica': atividadeFisica,
      'consumoAgua': consumoAgua,
      'objetivos': objetivos,
      'preferenciaPressao': preferenciaPressao,
      'areasEvitar': areasEvitar,
      'contraindicacoes': contraindicacoes,
      'observacoesGerais': observacoesGerais,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    };
  }

  /// Cria um modelo a partir de um DocumentSnapshot do Firestore
  factory AnamneseModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return AnamneseModel(
      id: doc.id,
      clienteId: data['clienteId'] ?? '',
      clienteNome: data['clienteNome'] ?? '',
      dataAvaliacao: data['dataAvaliacao'] != null 
          ? (data['dataAvaliacao'] as Timestamp).toDate() 
          : DateTime.now(),
      queixaPrincipal: data['queixaPrincipal'] ?? '',
      areasDor: List<String>.from(data['areasDor'] ?? []),
      historicoMedico: data['historicoMedico'],
      condicoesSaude: List<String>.from(data['condicoesSaude'] ?? []),
      cirurgias: data['cirurgias'],
      medicamentosEmUso: data['medicamentosEmUso'],
      alergias: data['alergias'],
      nivelEstresse: data['nivelEstresse'] ?? 'Moderado',
      qualidadeSono: data['qualidadeSono'] ?? 'Regular',
      atividadeFisica: data['atividadeFisica'] ?? 'Sedentário',
      consumoAgua: data['consumoAgua'] ?? '1 a 2 litros',
      objetivos: List<String>.from(data['objetivos'] ?? []),
      preferenciaPressao: data['preferenciaPressao'],
      areasEvitar: data['areasEvitar'] != null 
          ? List<String>.from(data['areasEvitar']) 
          : null,
      contraindicacoes: data['contraindicacoes'],
      observacoesGerais: data['observacoesGerais'],
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : DateTime.now(),
    );
  }

  /// Cria um modelo a partir de um Map genérico
  factory AnamneseModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return AnamneseModel(
      id: id ?? map['id'],
      clienteId: map['clienteId'] ?? '',
      clienteNome: map['clienteNome'] ?? '',
      dataAvaliacao: map['dataAvaliacao'] != null
          ? (map['dataAvaliacao'] is Timestamp
              ? (map['dataAvaliacao'] as Timestamp).toDate()
              : DateTime.parse(map['dataAvaliacao']))
          : DateTime.now(),
      queixaPrincipal: map['queixaPrincipal'] ?? '',
      areasDor: List<String>.from(map['areasDor'] ?? []),
      historicoMedico: map['historicoMedico'],
      condicoesSaude: List<String>.from(map['condicoesSaude'] ?? []),
      cirurgias: map['cirurgias'],
      medicamentosEmUso: map['medicamentosEmUso'],
      alergias: map['alergias'],
      nivelEstresse: map['nivelEstresse'] ?? 'Moderado',
      qualidadeSono: map['qualidadeSono'] ?? 'Regular',
      atividadeFisica: map['atividadeFisica'] ?? 'Sedentário',
      consumoAgua: map['consumoAgua'] ?? '1 a 2 litros',
      objetivos: List<String>.from(map['objetivos'] ?? []),
      preferenciaPressao: map['preferenciaPressao'],
      areasEvitar: map['areasEvitar'] != null 
          ? List<String>.from(map['areasEvitar']) 
          : null,
      contraindicacoes: map['contraindicacoes'],
      observacoesGerais: map['observacoesGerais'],
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
  AnamneseModel copyWith({
    String? id,
    String? clienteId,
    String? clienteNome,
    DateTime? dataAvaliacao,
    String? queixaPrincipal,
    List<String>? areasDor,
    String? historicoMedico,
    List<String>? condicoesSaude,
    String? cirurgias,
    String? medicamentosEmUso,
    String? alergias,
    String? nivelEstresse,
    String? qualidadeSono,
    String? atividadeFisica,
    String? consumoAgua,
    List<String>? objetivos,
    String? preferenciaPressao,
    List<String>? areasEvitar,
    String? contraindicacoes,
    String? observacoesGerais,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AnamneseModel(
      id: id ?? this.id,
      clienteId: clienteId ?? this.clienteId,
      clienteNome: clienteNome ?? this.clienteNome,
      dataAvaliacao: dataAvaliacao ?? this.dataAvaliacao,
      queixaPrincipal: queixaPrincipal ?? this.queixaPrincipal,
      areasDor: areasDor ?? this.areasDor,
      historicoMedico: historicoMedico ?? this.historicoMedico,
      condicoesSaude: condicoesSaude ?? this.condicoesSaude,
      cirurgias: cirurgias ?? this.cirurgias,
      medicamentosEmUso: medicamentosEmUso ?? this.medicamentosEmUso,
      alergias: alergias ?? this.alergias,
      nivelEstresse: nivelEstresse ?? this.nivelEstresse,
      qualidadeSono: qualidadeSono ?? this.qualidadeSono,
      atividadeFisica: atividadeFisica ?? this.atividadeFisica,
      consumoAgua: consumoAgua ?? this.consumoAgua,
      objetivos: objetivos ?? this.objetivos,
      preferenciaPressao: preferenciaPressao ?? this.preferenciaPressao,
      areasEvitar: areasEvitar ?? this.areasEvitar,
      contraindicacoes: contraindicacoes ?? this.contraindicacoes,
      observacoesGerais: observacoesGerais ?? this.observacoesGerais,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // ============================================
  // MODELO VAZIO
  // ============================================

  /// Retorna um modelo vazio para inicialização
  factory AnamneseModel.empty({String? clienteId, String? clienteNome}) {
    return AnamneseModel(
      clienteId: clienteId ?? '',
      clienteNome: clienteNome ?? '',
      dataAvaliacao: DateTime.now(),
      queixaPrincipal: '',
    );
  }

  // ============================================
  // COMPARAÇÃO E IGUALDADE
  // ============================================

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AnamneseModel &&
        other.id == id &&
        other.clienteId == clienteId &&
        other.dataAvaliacao == dataAvaliacao;
  }

  @override
  int get hashCode {
    return id.hashCode ^ clienteId.hashCode ^ dataAvaliacao.hashCode;
  }

  // ============================================
  // REPRESENTAÇÃO EM STRING
  // ============================================

  @override
  String toString() {
    return 'AnamneseModel(id: $id, clienteId: $clienteId, clienteNome: $clienteNome, dataAvaliacao: $dataAvaliacao)';
  }
}
