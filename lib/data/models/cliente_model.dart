import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo de Cliente para o app Aroma de Hortelã
class ClienteModel {
  final String? id;
  final String nome;
  final String telefone;
  final String? email;
  final String? cpf;
  final String? endereco;
  final String? dataNascimento; // formato: "yyyy-MM-dd"
  final String? observacoes;
  final bool isAtivo;
  final DateTime createdAt;
  final DateTime updatedAt;

  ClienteModel({
    this.id,
    required this.nome,
    required this.telefone,
    this.email,
    this.cpf,
    this.endereco,
    this.dataNascimento,
    this.observacoes,
    this.isAtivo = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // ============================================
  // GETTERS ÚTEIS
  // ============================================

  /// Retorna a primeira letra do nome (para avatar)
  String get inicial => nome.isNotEmpty ? nome[0].toUpperCase() : '?';

  /// Retorna as iniciais (até 2 letras)
  String get iniciais {
    if (nome.isEmpty) return '?';
    final partes = nome.trim().split(' ');
    if (partes.length == 1) {
      return partes[0][0].toUpperCase();
    }
    return '${partes[0][0]}${partes.last[0]}'.toUpperCase();
  }

  /// Retorna o primeiro nome
  String get primeiroNome => nome.split(' ').first;

  /// Retorna o telefone formatado
  String get telefoneFormatado {
    final nums = telefone.replaceAll(RegExp(r'[^\d]'), '');
    if (nums.length == 11) {
      return '(${nums.substring(0, 2)}) ${nums.substring(2, 7)}-${nums.substring(7)}';
    } else if (nums.length == 10) {
      return '(${nums.substring(0, 2)}) ${nums.substring(2, 6)}-${nums.substring(6)}';
    }
    return telefone;
  }

  /// Retorna o CPF formatado
  String? get cpfFormatado {
    if (cpf == null || cpf!.isEmpty) return null;
    final nums = cpf!.replaceAll(RegExp(r'[^\d]'), '');
    if (nums.length == 11) {
      return '${nums.substring(0, 3)}.${nums.substring(3, 6)}.${nums.substring(6, 9)}-${nums.substring(9)}';
    }
    return cpf;
  }

  /// Retorna a data de nascimento como DateTime
  DateTime? get dataNascimentoDateTime {
    if (dataNascimento == null || dataNascimento!.isEmpty) return null;
    return DateTime.tryParse(dataNascimento!);
  }

  /// Retorna a data de nascimento formatada: "15/02/1990"
  String? get dataNascimentoFormatada {
    final dt = dataNascimentoDateTime;
    if (dt == null) return null;
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  /// Retorna a idade em anos
  int? get idade {
    final dt = dataNascimentoDateTime;
    if (dt == null) return null;
    final agora = DateTime.now();
    int anos = agora.year - dt.year;
    if (agora.month < dt.month || (agora.month == dt.month && agora.day < dt.day)) {
      anos--;
    }
    return anos;
  }

  /// Alias para createdAt
  DateTime get dataCadastro => createdAt;

  /// Verifica se tem email
  bool get temEmail => email != null && email!.trim().isNotEmpty;

  /// Verifica se tem endereço
  bool get temEndereco => endereco != null && endereco!.trim().isNotEmpty;

  /// Verifica se tem CPF
  bool get temCpf => cpf != null && cpf!.trim().isNotEmpty;

  // ============================================
  // CONVERSÃO PARA/DO FIRESTORE
  // ============================================

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'telefone': telefone,
      'email': email,
      'cpf': cpf,
      'endereco': endereco,
      'dataNascimento': dataNascimento,
      'observacoes': observacoes,
      'isAtivo': isAtivo,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    };
  }

  factory ClienteModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ClienteModel(
      id: doc.id,
      nome: data['nome'] ?? '',
      telefone: data['telefone'] ?? '',
      email: data['email'],
      cpf: data['cpf'],
      endereco: data['endereco'],
      dataNascimento: data['dataNascimento'],
      observacoes: data['observacoes'],
      isAtivo: data['isAtivo'] ?? true,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  factory ClienteModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return ClienteModel(
      id: id ?? map['id'],
      nome: map['nome'] ?? '',
      telefone: map['telefone'] ?? '',
      email: map['email'],
      cpf: map['cpf'],
      endereco: map['endereco'],
      dataNascimento: map['dataNascimento'],
      observacoes: map['observacoes'],
      isAtivo: map['isAtivo'] ?? true,
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

  ClienteModel copyWith({
    String? id,
    String? nome,
    String? telefone,
    String? email,
    String? cpf,
    String? endereco,
    String? dataNascimento,
    String? observacoes,
    bool? isAtivo,
    bool? ativo, // Alias para isAtivo
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ClienteModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      telefone: telefone ?? this.telefone,
      email: email ?? this.email,
      cpf: cpf ?? this.cpf,
      endereco: endereco ?? this.endereco,
      dataNascimento: dataNascimento ?? this.dataNascimento,
      observacoes: observacoes ?? this.observacoes,
      isAtivo: ativo ?? isAtivo ?? this.isAtivo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // ============================================
  // MODELO VAZIO
  // ============================================

  factory ClienteModel.empty() {
    return ClienteModel(
      nome: '',
      telefone: '',
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ClienteModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ClienteModel(id: $id, nome: $nome, telefone: $telefone, isAtivo: $isAtivo)';
  }
}
