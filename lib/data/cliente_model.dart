import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo de Cliente para o app Aroma de Hortelã
/// Representa um cliente do sistema com todos os seus dados
class ClienteModel {
  final String? id;
  final String nome;
  final String telefone;
  final String? email;
  final DateTime? dataNascimento;
  final String? endereco;
  final String? observacoes;
  final String status; // 'Ativo' ou 'Inativo'
  final DateTime createdAt;
  final DateTime updatedAt;

  ClienteModel({
    this.id,
    required this.nome,
    required this.telefone,
    this.email,
    this.dataNascimento,
    this.endereco,
    this.observacoes,
    this.status = 'Ativo',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // ============================================
  // GETTERS ÚTEIS
  // ============================================

  /// Retorna as iniciais do nome
  String get iniciais {
    if (nome.isEmpty) return '';
    final partes = nome.trim().split(' ');
    if (partes.length == 1) {
      return partes[0][0].toUpperCase();
    }
    return '${partes.first[0]}${partes.last[0]}'.toUpperCase();
  }

  /// Retorna o primeiro nome
  String get primeiroNome {
    if (nome.isEmpty) return '';
    return nome.split(' ').first;
  }

  /// Retorna a idade calculada
  int? get idade {
    if (dataNascimento == null) return null;
    final hoje = DateTime.now();
    int anos = hoje.year - dataNascimento!.year;
    if (hoje.month < dataNascimento!.month ||
        (hoje.month == dataNascimento!.month && hoje.day < dataNascimento!.day)) {
      anos--;
    }
    return anos;
  }

  /// Verifica se o cliente está ativo
  bool get isAtivo => status == 'Ativo';

  // ============================================
  // CONVERSÃO PARA/DO FIRESTORE
  // ============================================

  /// Converte o modelo para Map (para salvar no Firestore)
  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'telefone': telefone,
      'email': email,
      'dataNascimento': dataNascimento != null 
          ? Timestamp.fromDate(dataNascimento!) 
          : null,
      'endereco': endereco,
      'observacoes': observacoes,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    };
  }

  /// Cria um modelo a partir de um DocumentSnapshot do Firestore
  factory ClienteModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return ClienteModel(
      id: doc.id,
      nome: data['nome'] ?? '',
      telefone: data['telefone'] ?? '',
      email: data['email'],
      dataNascimento: data['dataNascimento'] != null 
          ? (data['dataNascimento'] as Timestamp).toDate() 
          : null,
      endereco: data['endereco'],
      observacoes: data['observacoes'],
      status: data['status'] ?? 'Ativo',
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : DateTime.now(),
    );
  }

  /// Cria um modelo a partir de um Map genérico
  factory ClienteModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return ClienteModel(
      id: id ?? map['id'],
      nome: map['nome'] ?? '',
      telefone: map['telefone'] ?? '',
      email: map['email'],
      dataNascimento: map['dataNascimento'] != null
          ? (map['dataNascimento'] is Timestamp
              ? (map['dataNascimento'] as Timestamp).toDate()
              : DateTime.parse(map['dataNascimento']))
          : null,
      endereco: map['endereco'],
      observacoes: map['observacoes'],
      status: map['status'] ?? 'Ativo',
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
  ClienteModel copyWith({
    String? id,
    String? nome,
    String? telefone,
    String? email,
    DateTime? dataNascimento,
    String? endereco,
    String? observacoes,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ClienteModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      telefone: telefone ?? this.telefone,
      email: email ?? this.email,
      dataNascimento: dataNascimento ?? this.dataNascimento,
      endereco: endereco ?? this.endereco,
      observacoes: observacoes ?? this.observacoes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // ============================================
  // MODELO VAZIO
  // ============================================

  /// Retorna um modelo vazio para inicialização
  factory ClienteModel.empty() {
    return ClienteModel(
      nome: '',
      telefone: '',
    );
  }

  // ============================================
  // COMPARAÇÃO E IGUALDADE
  // ============================================

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ClienteModel &&
        other.id == id &&
        other.nome == nome &&
        other.telefone == telefone &&
        other.email == email &&
        other.dataNascimento == dataNascimento &&
        other.endereco == endereco &&
        other.status == status;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        nome.hashCode ^
        telefone.hashCode ^
        email.hashCode ^
        dataNascimento.hashCode ^
        endereco.hashCode ^
        status.hashCode;
  }

  // ============================================
  // REPRESENTAÇÃO EM STRING
  // ============================================

  @override
  String toString() {
    return 'ClienteModel(id: $id, nome: $nome, telefone: $telefone, status: $status)';
  }
}
