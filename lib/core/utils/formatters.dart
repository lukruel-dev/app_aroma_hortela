import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Utilitários de formatação para o app Aroma de Hortelã
/// Formatação de datas, telefones, moedas, nomes, etc.
class Formatters {
  Formatters._();

  /// Inicializa as configurações de localização para pt_BR
  static Future<void> initialize() async {
    await initializeDateFormatting('pt_BR', null);
  }

  // ============================================
  // FORMATAÇÃO DE DATA
  // ============================================

  /// Formata data completa: "segunda-feira, 16 de fevereiro"
  static String dataCompleta(DateTime data) {
    final formatter = DateFormat("EEEE, d 'de' MMMM", 'pt_BR');
    return formatter.format(data);
  }

  /// Formata data com ano: "16 de fevereiro de 2026"
  static String dataCompletaComAno(DateTime data) {
    final formatter = DateFormat("d 'de' MMMM 'de' yyyy", 'pt_BR');
    return formatter.format(data);
  }

  /// Formata data curta: "16/02/2026"
  static String dataCurta(DateTime data) {
    final formatter = DateFormat('dd/MM/yyyy', 'pt_BR');
    return formatter.format(data);
  }

  /// Formata data abreviada: "16 fev"
  static String dataAbreviada(DateTime data) {
    final formatter = DateFormat("d MMM", 'pt_BR');
    return formatter.format(data);
  }

  /// Formata intervalo de datas: "15 de fevereiro - 21 de fevereiro"
  static String intervaloData(DateTime inicio, DateTime fim) {
    final formatterDia = DateFormat("d 'de' MMMM", 'pt_BR');
    return '${formatterDia.format(inicio)} - ${formatterDia.format(fim)}';
  }

  /// Retorna o dia da semana: "DOMINGO", "SEGUNDA", etc.
  static String diaSemana(DateTime data) {
    final formatter = DateFormat('EEEE', 'pt_BR');
    return formatter.format(data).toUpperCase();
  }

  /// Retorna o dia da semana abreviado: "DOM", "SEG", etc.
  static String diaSemanaAbreviado(DateTime data) {
    final formatter = DateFormat('E', 'pt_BR');
    String dia = formatter.format(data).toUpperCase();
    // Remove ponto final se houver
    if (dia.endsWith('.')) {
      dia = dia.substring(0, dia.length - 1);
    }
    return dia;
  }

  /// Retorna apenas o dia do mês: "16"
  static String diaMes(DateTime data) {
    return data.day.toString();
  }

  /// Retorna mês e ano: "Fevereiro 2026"
  static String mesAno(DateTime data) {
    final formatter = DateFormat('MMMM yyyy', 'pt_BR');
    String resultado = formatter.format(data);
    // Capitaliza a primeira letra
    return resultado[0].toUpperCase() + resultado.substring(1);
  }

  /// Retorna apenas o ano: "2026"
  static String ano(DateTime data) {
    return data.year.toString();
  }

  // ============================================
  // FORMATAÇÃO DE HORA
  // ============================================

  /// Formata hora: "14:30"
  static String hora(DateTime data) {
    final formatter = DateFormat('HH:mm', 'pt_BR');
    return formatter.format(data);
  }

  /// Formata hora com segundos: "14:30:45"
  static String horaCompleta(DateTime data) {
    final formatter = DateFormat('HH:mm:ss', 'pt_BR');
    return formatter.format(data);
  }

  /// Formata data e hora: "16/02/2026 às 14:30"
  static String dataHora(DateTime data) {
    final formatterData = DateFormat('dd/MM/yyyy', 'pt_BR');
    final formatterHora = DateFormat('HH:mm', 'pt_BR');
    return '${formatterData.format(data)} às ${formatterHora.format(data)}';
  }

  // ============================================
  // FORMATAÇÃO DE TELEFONE
  // ============================================

  /// Formata telefone: "(11) 99123-4567"
  static String telefone(String numero) {
    // Remove tudo que não é número
    final apenasNumeros = numero.replaceAll(RegExp(r'[^\d]'), '');

    if (apenasNumeros.length == 11) {
      // Celular: (00) 00000-0000
      return '(${apenasNumeros.substring(0, 2)}) ${apenasNumeros.substring(2, 7)}-${apenasNumeros.substring(7)}';
    } else if (apenasNumeros.length == 10) {
      // Fixo: (00) 0000-0000
      return '(${apenasNumeros.substring(0, 2)}) ${apenasNumeros.substring(2, 6)}-${apenasNumeros.substring(6)}';
    }

    return numero; // Retorna original se não conseguir formatar
  }

  /// Remove formatação do telefone, retornando apenas números
  static String telefoneLimpo(String telefone) {
    return telefone.replaceAll(RegExp(r'[^\d]'), '');
  }

  // ============================================
  // FORMATAÇÃO DE MOEDA
  // ============================================

  /// Formata valor em reais: "R$ 150,00"
  static String moeda(double valor) {
    final formatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );
    return formatter.format(valor);
  }

  /// Formata valor sem símbolo: "150,00"
  static String moedaSemSimbolo(double valor) {
    final formatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: '',
      decimalDigits: 2,
    );
    return formatter.format(valor).trim();
  }

  /// Converte string de moeda para double
  static double moedaParaDouble(String valor) {
    // Remove R$, espaços e troca vírgula por ponto
    String limpo = valor
        .replaceAll('R\$', '')
        .replaceAll(' ', '')
        .replaceAll('.', '')
        .replaceAll(',', '.');
    return double.tryParse(limpo) ?? 0.0;
  }

  // ============================================
  // FORMATAÇÃO DE NOMES
  // ============================================

  /// Capitaliza primeira letra de cada palavra: "maria silva" -> "Maria Silva"
  static String capitalizarNome(String nome) {
    if (nome.isEmpty) return nome;

    return nome.split(' ').map((palavra) {
      if (palavra.isEmpty) return palavra;
      // Não capitaliza preposições curtas
      if (['de', 'da', 'do', 'das', 'dos', 'e'].contains(palavra.toLowerCase())) {
        return palavra.toLowerCase();
      }
      return palavra[0].toUpperCase() + palavra.substring(1).toLowerCase();
    }).join(' ');
  }

  /// Retorna as iniciais do nome: "Maria Silva" -> "MS"
  static String iniciais(String nome) {
    if (nome.isEmpty) return '';

    final partes = nome.trim().split(' ');
    if (partes.length == 1) {
      return partes[0][0].toUpperCase();
    }

    // Pega primeira e última inicial
    return '${partes.first[0]}${partes.last[0]}'.toUpperCase();
  }

  /// Retorna apenas a primeira inicial: "Maria" -> "M"
  static String primeiraInicial(String nome) {
    if (nome.isEmpty) return '';
    return nome[0].toUpperCase();
  }

  /// Retorna primeiro nome: "Maria Silva Santos" -> "Maria"
  static String primeiroNome(String nomeCompleto) {
    if (nomeCompleto.isEmpty) return '';
    return nomeCompleto.split(' ').first;
  }

  /// Abrevia nome do meio: "Maria Silva Santos" -> "Maria S. Santos"
  static String nomeAbreviado(String nomeCompleto) {
    if (nomeCompleto.isEmpty) return '';

    final partes = nomeCompleto.split(' ');
    if (partes.length <= 2) return nomeCompleto;

    final primeiro = partes.first;
    final ultimo = partes.last;
    final meio = partes.sublist(1, partes.length - 1).map((p) => '${p[0]}.').join(' ');

    return '$primeiro $meio $ultimo';
  }

  // ============================================
  // FORMATAÇÃO DE CPF
  // ============================================

  /// Formata CPF: "12345678901" -> "123.456.789-01"
  static String cpf(String cpf) {
    final apenasNumeros = cpf.replaceAll(RegExp(r'[^\d]'), '');

    if (apenasNumeros.length == 11) {
      return '${apenasNumeros.substring(0, 3)}.${apenasNumeros.substring(3, 6)}.${apenasNumeros.substring(6, 9)}-${apenasNumeros.substring(9)}';
    }

    return cpf;
  }

  /// Remove formatação do CPF
  static String cpfLimpo(String cpf) {
    return cpf.replaceAll(RegExp(r'[^\d]'), '');
  }

  // ============================================
  // FORMATAÇÃO DE IDADE
  // ============================================

  /// Calcula e formata idade: "35 anos"
  static String idade(DateTime dataNascimento) {
    final hoje = DateTime.now();
    int anos = hoje.year - dataNascimento.year;

    if (hoje.month < dataNascimento.month ||
        (hoje.month == dataNascimento.month && hoje.day < dataNascimento.day)) {
      anos--;
    }

    return '$anos ${anos == 1 ? 'ano' : 'anos'}';
  }

  /// Retorna apenas o número da idade
  static int idadeNumero(DateTime dataNascimento) {
    final hoje = DateTime.now();
    int anos = hoje.year - dataNascimento.year;

    if (hoje.month < dataNascimento.month ||
        (hoje.month == dataNascimento.month && hoje.day < dataNascimento.day)) {
      anos--;
    }

    return anos;
  }

  // ============================================
  // FORMATAÇÃO DE NÚMEROS
  // ============================================

  /// Formata número com separador de milhar: "1.234"
  static String numero(int valor) {
    final formatter = NumberFormat('#,###', 'pt_BR');
    return formatter.format(valor);
  }

  /// Formata número decimal: "1.234,56"
  static String numeroDecimal(double valor, {int casasDecimais = 2}) {
    final formatter = NumberFormat.decimalPatternDigits(
      locale: 'pt_BR',
      decimalDigits: casasDecimais,
    );
    return formatter.format(valor);
  }

  // ============================================
  // FORMATAÇÃO DE TEMPO RELATIVO
  // ============================================

  /// Retorna tempo relativo: "há 5 minutos", "há 2 horas", "ontem", etc.
  static String tempoRelativo(DateTime data) {
    final agora = DateTime.now();
    final diferenca = agora.difference(data);

    if (diferenca.inSeconds < 60) {
      return 'agora';
    } else if (diferenca.inMinutes < 60) {
      final minutos = diferenca.inMinutes;
      return 'há $minutos ${minutos == 1 ? 'minuto' : 'minutos'}';
    } else if (diferenca.inHours < 24) {
      final horas = diferenca.inHours;
      return 'há $horas ${horas == 1 ? 'hora' : 'horas'}';
    } else if (diferenca.inDays == 1) {
      return 'ontem';
    } else if (diferenca.inDays < 7) {
      final dias = diferenca.inDays;
      return 'há $dias dias';
    } else if (diferenca.inDays < 30) {
      final semanas = (diferenca.inDays / 7).floor();
      return 'há $semanas ${semanas == 1 ? 'semana' : 'semanas'}';
    } else if (diferenca.inDays < 365) {
      final meses = (diferenca.inDays / 30).floor();
      return 'há $meses ${meses == 1 ? 'mês' : 'meses'}';
    } else {
      final anos = (diferenca.inDays / 365).floor();
      return 'há $anos ${anos == 1 ? 'ano' : 'anos'}';
    }
  }

  // ============================================
  // PLURALIZAÇÃO
  // ============================================

  /// Retorna singular ou plural: pluralizar(1, "cliente", "clientes") -> "1 cliente"
  static String pluralizar(int quantidade, String singular, String plural) {
    return '$quantidade ${quantidade == 1 ? singular : plural}';
  }
}
