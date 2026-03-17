/// Validadores de campos para o app Aroma de Hortelã
/// Validação de nome, telefone, email, CPF, data, etc.
class Validators {
  Validators._();

  // ============================================
  // VALIDAÇÃO DE CAMPOS OBRIGATÓRIOS
  // ============================================

  /// Valida se o campo não está vazio
  static String? obrigatorio(String? valor, [String? nomeCampo]) {
    if (valor == null || valor.trim().isEmpty) {
      return nomeCampo != null 
          ? '$nomeCampo é obrigatório' 
          : 'Campo obrigatório';
    }
    return null;
  }

  /// Valida se a lista não está vazia
  static String? listaObrigatoria(List? lista, [String? nomeCampo]) {
    if (lista == null || lista.isEmpty) {
      return nomeCampo != null 
          ? 'Selecione pelo menos um(a) $nomeCampo' 
          : 'Selecione pelo menos uma opção';
    }
    return null;
  }

  // ============================================
  // VALIDAÇÃO DE NOME
  // ============================================

  /// Valida nome completo (mínimo 2 palavras)
  static String? nomeCompleto(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Nome é obrigatório';
    }

    final partes = valor.trim().split(' ');
    if (partes.length < 2) {
      return 'Digite o nome completo';
    }

    // Verifica se cada parte tem pelo menos 2 caracteres
    for (var parte in partes) {
      if (parte.length < 2) {
        return 'Nome inválido';
      }
    }

    // Verifica se contém apenas letras e espaços
    if (!RegExp(r'^[a-zA-ZÀ-ÿ\s]+$').hasMatch(valor)) {
      return 'Nome deve conter apenas letras';
    }

    return null;
  }

  /// Valida nome simples (apenas não vazio)
  static String? nome(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Nome é obrigatório';
    }

    if (valor.trim().length < 2) {
      return 'Nome deve ter pelo menos 2 caracteres';
    }

    return null;
  }

  // ============================================
  // VALIDAÇÃO DE TELEFONE
  // ============================================

  /// Valida telefone brasileiro (10 ou 11 dígitos)
  static String? telefone(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Telefone é obrigatório';
    }

    // Remove formatação
    final apenasNumeros = valor.replaceAll(RegExp(r'[^\d]'), '');

    if (apenasNumeros.length < 10 || apenasNumeros.length > 11) {
      return 'Telefone inválido';
    }

    // Valida DDD (11 a 99)
    final ddd = int.tryParse(apenasNumeros.substring(0, 2));
    if (ddd == null || ddd < 11 || ddd > 99) {
      return 'DDD inválido';
    }

    return null;
  }

  /// Valida telefone opcional (se preenchido, deve ser válido)
  static String? telefoneOpcional(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return null; // Campo opcional, vazio é válido
    }
    return telefone(valor);
  }

  // ============================================
  // VALIDAÇÃO DE EMAIL
  // ============================================

  /// Valida email
  static String? email(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Email é obrigatório';
    }

    // Regex para validação de email
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(valor.trim())) {
      return 'Email inválido';
    }

    return null;
  }

  /// Valida email opcional
  static String? emailOpcional(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return null;
    }
    return email(valor);
  }

  // ============================================
  // VALIDAÇÃO DE CPF
  // ============================================

  /// Valida CPF brasileiro
  static String? cpf(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'CPF é obrigatório';
    }

    // Remove formatação
    final apenasNumeros = valor.replaceAll(RegExp(r'[^\d]'), '');

    if (apenasNumeros.length != 11) {
      return 'CPF deve ter 11 dígitos';
    }

    // Verifica se todos os dígitos são iguais
    if (RegExp(r'^(\d)\1*$').hasMatch(apenasNumeros)) {
      return 'CPF inválido';
    }

    // Validação dos dígitos verificadores
    if (!_validarDigitosCPF(apenasNumeros)) {
      return 'CPF inválido';
    }

    return null;
  }

  /// Valida CPF opcional
  static String? cpfOpcional(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return null;
    }
    return cpf(valor);
  }

  /// Algoritmo de validação dos dígitos do CPF
  static bool _validarDigitosCPF(String cpf) {
    // Calcula primeiro dígito verificador
    int soma = 0;
    for (int i = 0; i < 9; i++) {
      soma += int.parse(cpf[i]) * (10 - i);
    }
    int primeiroDigito = (soma * 10) % 11;
    if (primeiroDigito == 10) primeiroDigito = 0;

    if (primeiroDigito != int.parse(cpf[9])) {
      return false;
    }

    // Calcula segundo dígito verificador
    soma = 0;
    for (int i = 0; i < 10; i++) {
      soma += int.parse(cpf[i]) * (11 - i);
    }
    int segundoDigito = (soma * 10) % 11;
    if (segundoDigito == 10) segundoDigito = 0;

    return segundoDigito == int.parse(cpf[10]);
  }

  // ============================================
  // VALIDAÇÃO DE DATA
  // ============================================

  /// Valida data de nascimento (não pode ser futura, idade máxima 120 anos)
  static String? dataNascimento(DateTime? valor) {
    if (valor == null) {
      return 'Data de nascimento é obrigatória';
    }

    final hoje = DateTime.now();

    if (valor.isAfter(hoje)) {
      return 'Data não pode ser futura';
    }

    final idade = hoje.year - valor.year;
    if (idade > 120) {
      return 'Data inválida';
    }

    if (idade < 0) {
      return 'Data inválida';
    }

    return null;
  }

  /// Valida data de nascimento opcional
  static String? dataNascimentoOpcional(DateTime? valor) {
    if (valor == null) {
      return null;
    }
    return dataNascimento(valor);
  }

  /// Valida data de agendamento (não pode ser passada)
  static String? dataAgendamento(DateTime? valor) {
    if (valor == null) {
      return 'Data é obrigatória';
    }

    final hoje = DateTime.now();
    final apenasHoje = DateTime(hoje.year, hoje.month, hoje.day);
    final apenasValor = DateTime(valor.year, valor.month, valor.day);

    if (apenasValor.isBefore(apenasHoje)) {
      return 'Data não pode ser no passado';
    }

    return null;
  }

  // ============================================
  // VALIDAÇÃO DE VALORES NUMÉRICOS
  // ============================================

  /// Valida valor monetário
  static String? valor(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Valor é obrigatório';
    }

    // Remove formatação de moeda
    final limpo = valor
        .replaceAll('R\$', '')
        .replaceAll(' ', '')
        .replaceAll('.', '')
        .replaceAll(',', '.');

    final numero = double.tryParse(limpo);

    if (numero == null) {
      return 'Valor inválido';
    }

    if (numero < 0) {
      return 'Valor não pode ser negativo';
    }

    return null;
  }

  /// Valida valor monetário opcional
  static String? valorOpcional(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return null;
    }
    return Validators.valor(valor);
  }

  /// Valida número inteiro positivo
  static String? numeroPositivo(String? valor, [String? nomeCampo]) {
    if (valor == null || valor.trim().isEmpty) {
      return nomeCampo != null 
          ? '$nomeCampo é obrigatório' 
          : 'Campo obrigatório';
    }

    final numero = int.tryParse(valor);

    if (numero == null) {
      return 'Digite um número válido';
    }

    if (numero <= 0) {
      return 'O valor deve ser maior que zero';
    }

    return null;
  }

  // ============================================
  // VALIDAÇÃO DE SELEÇÃO
  // ============================================

  /// Valida se uma opção foi selecionada (dropdown)
  static String? selecaoObrigatoria(String? valor, [String? nomeCampo]) {
    if (valor == null || valor.trim().isEmpty) {
      return nomeCampo != null 
          ? 'Selecione um(a) $nomeCampo' 
          : 'Selecione uma opção';
    }
    return null;
  }

  // ============================================
  // VALIDAÇÃO DE TEXTO
  // ============================================

  /// Valida tamanho mínimo do texto
  static String? tamanhoMinimo(String? valor, int minimo, [String? nomeCampo]) {
    if (valor == null || valor.trim().isEmpty) {
      return nomeCampo != null 
          ? '$nomeCampo é obrigatório' 
          : 'Campo obrigatório';
    }

    if (valor.trim().length < minimo) {
      return nomeCampo != null
          ? '$nomeCampo deve ter pelo menos $minimo caracteres'
          : 'Deve ter pelo menos $minimo caracteres';
    }

    return null;
  }

  /// Valida tamanho máximo do texto
  static String? tamanhoMaximo(String? valor, int maximo, [String? nomeCampo]) {
    if (valor == null || valor.trim().isEmpty) {
      return null; // Se vazio, não valida máximo
    }

    if (valor.trim().length > maximo) {
      return nomeCampo != null
          ? '$nomeCampo deve ter no máximo $maximo caracteres'
          : 'Deve ter no máximo $maximo caracteres';
    }

    return null;
  }

  // ============================================
  // VALIDAÇÃO DE ENDEREÇO
  // ============================================

  /// Valida endereço (mínimo 10 caracteres)
  static String? endereco(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Endereço é obrigatório';
    }

    if (valor.trim().length < 10) {
      return 'Digite um endereço mais completo';
    }

    return null;
  }

  /// Valida endereço opcional
  static String? enderecoOpcional(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return null;
    }
    return endereco(valor);
  }

  // ============================================
  // VALIDAÇÃO DE HORÁRIO
  // ============================================

  /// Valida horário no formato HH:mm
  static String? horario(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Horário é obrigatório';
    }

    final regex = RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9]$');
    if (!regex.hasMatch(valor)) {
      return 'Horário inválido';
    }

    return null;
  }

  // ============================================
  // COMBINADORES
  // ============================================

  /// Combina múltiplos validadores
  static String? combinar(String? valor, List<String? Function(String?)> validadores) {
    for (final validador in validadores) {
      final erro = validador(valor);
      if (erro != null) {
        return erro;
      }
    }
    return null;
  }
}
