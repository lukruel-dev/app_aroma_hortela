/// Constantes do app Aroma de Hortelã
/// Listas de opções para formulários, configurações gerais, etc.
class AppConstants {
  AppConstants._();

  // ============================================
  // INFORMAÇÕES DO APP
  // ============================================
  
  static const String appName = 'Aroma de Hortelã';
  static const String appSubtitle = 'Massagem & Aromaterapia';
  static const String appVersion = '1.0.0';

  // ============================================
  // TIPOS DE MASSAGEM
  // ============================================
  
  static const List<String> tiposMassagem = [
    'Massagem Relaxante',
    'Massagem Terapêutica',    
    'Drenagem Linfática',
    'Reflexologia',
    'Massagem Humanizada',    
  ];

  // ============================================
  // DURAÇÃO DAS SESSÕES
  // ============================================
  
  static const List<String> duracoesSessao = [
    '30 minutos',
    '45 minutos',
    '1 hora',
    '1 hora e 30 minutos',
    '2 horas',
  ];
  
  static const Map<String, int> duracaoEmMinutos = {
    '30 minutos': 30,
    '45 minutos': 45,
    '1 hora': 60,
    '1 hora e 30 minutos': 90,
    '2 horas': 120,
  };

  // ============================================
  // HORÁRIOS DISPONÍVEIS
  // ============================================
  
  static const List<String> horariosDisponiveis = [
    '08:00',
    '09:00',
    '10:00',
    '11:00',
    '12:00',
    '13:00',
    '14:00',
    '15:00',
    '16:00',
    '17:00',
    '18:00',
    '19:00',
    '20:00',
  ];

  // ============================================
  // ÁREAS DE DOR OU DESCONFORTO
  // ============================================
  
  static const List<String> areasDor = [
    'Cabeça',
    'Pescoço',
    'Ombros',
    'Braços',
    'Mãos',
    'Coluna cervical',
    'Coluna torácica',
    'Coluna lombar',
    'Quadril',
    'Pernas',
    'Joelhos',
    'Pés',
  ];

  // ============================================
  // HISTÓRICO DE SAÚDE
  // ============================================
  
  static const List<String> condicoesSaude = [
    'Hipertensão',
    'Diabetes',
    'Problema cardíaco',
    'Gestante',
    'Varizes',
    'Problemas de pele',
  ];

  // ============================================
  // OBJETIVOS COM A MASSOTERAPIA
  // ============================================
  
  static const List<String> objetivosMassoterapia = [
    'Alívio de dores',
    'Relaxamento',
    'Redução do estresse',
    'Melhora da circulação',
    'Tratamento de tensões',
    'Reabilitação',
    'Bem-estar geral',
    'Melhora do sono',
  ];

  // ============================================
  // NÍVEIS DE ESTRESSE
  // ============================================
  
  static const List<String> niveisEstresse = [
    'Baixo',
    'Moderado',
    'Alto',
    'Muito alto',
  ];

  // ============================================
  // QUALIDADE DO SONO
  // ============================================
  
  static const List<String> qualidadesSono = [
    'Excelente',
    'Boa',
    'Regular',
    'Ruim',
    'Muito ruim',
  ];

  // ============================================
  // ATIVIDADE FÍSICA
  // ============================================
  
  static const List<String> niveisAtividadeFisica = [
    'Sedentário',
    'Leve (1-2x por semana)',
    'Moderado (3-4x por semana)',
    'Intenso (5+ vezes por semana)',
  ];

  // ============================================
  // CONSUMO DE ÁGUA
  // ============================================
  
  static const List<String> consumoAgua = [
    'Menos de 1 litro',
    '1 a 2 litros',
    '2 a 3 litros',
    'Mais de 3 litros',
  ];

  // ============================================
  // STATUS DO CLIENTE
  // ============================================
  
  static const List<String> statusCliente = [
    'Ativo',
    'Inativo',
  ];

  // ============================================
  // STATUS DO AGENDAMENTO
  // ============================================
  
  static const List<String> statusAgendamento = [
    'Agendado',
    'Confirmado',
    'Em andamento',
    'Concluído',
    'Cancelado',
    'Não compareceu',
  ];

  // ============================================
  // DIAS DA SEMANA
  // ============================================
  
  static const List<String> diasSemana = [
    'Domingo',
    'Segunda',
    'Terça',
    'Quarta',
    'Quinta',
    'Sexta',
    'Sábado',
  ];
  
  static const List<String> diasSemanaAbrev = [
    'DOM',
    'SEG',
    'TER',
    'QUA',
    'QUI',
    'SEX',
    'SÁB',
  ];

  // ============================================
  // MESES
  // ============================================
  
  static const List<String> meses = [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro',
  ];

  // ============================================
  // CONFIGURAÇÕES DE UI
  // ============================================
  
  /// Padding padrão das telas
  static const double screenPadding = 20.0;
  
  /// Espaçamento entre elementos
  static const double spacingXS = 4.0;
  static const double spacingSM = 8.0;
  static const double spacingMD = 16.0;
  static const double spacingLG = 24.0;
  static const double spacingXL = 32.0;
  
  /// Border radius
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 20.0;
  
  /// Tamanho do avatar
  static const double avatarSizeSM = 40.0;
  static const double avatarSizeMD = 50.0;
  static const double avatarSizeLG = 64.0;

  // ============================================
  // ROTAS DO APP
  // ============================================
  
  static const String routeDashboard = '/dashboard';
  static const String routeClientes = '/clientes';
  static const String routeClienteForm = '/cliente-form';
  static const String routeAnamnese = '/anamnese';
  static const String routeAnamneseForm = '/anamnese-form';
  static const String routeAgendamentos = '/agendamentos';
  static const String routeAgendamentoForm = '/agendamento-form';

  // ============================================
  // COLEÇÕES DO FIREBASE
  // ============================================
  
  static const String collectionClientes = 'clientes';
  static const String collectionAnamneses = 'anamneses';
  static const String collectionAgendamentos = 'agendamentos';

  // ============================================
  // MENSAGENS
  // ============================================
  
  static const String msgSalvoSucesso = 'Salvo com sucesso!';
  static const String msgErroSalvar = 'Erro ao salvar. Tente novamente.';
  static const String msgExcluidoSucesso = 'Excluído com sucesso!';
  static const String msgErroExcluir = 'Erro ao excluir. Tente novamente.';
  static const String msgCamposObrigatorios = 'Preencha todos os campos obrigatórios.';
  static const String msgNenhumRegistro = 'Nenhum registro encontrado.';
  static const String msgConfirmarExclusao = 'Tem certeza que deseja excluir?';
  static const String msgAcaoIrreversivel = 'Esta ação não pode ser desfeita.';

  // ============================================
  // PLACEHOLDERS
  // ============================================
  
  static const String placeholderNome = 'Digite o nome completo';
  static const String placeholderTelefone = '(00) 00000-0000';
  static const String placeholderEmail = 'email@exemplo.com';
  static const String placeholderEndereco = 'Rua, número, bairro, cidade';
  static const String placeholderObservacoes = 'Observações gerais...';
  static const String placeholderBusca = 'Buscar por nome, telefone ou email...';
  static const String placeholderQueixaPrincipal = 'Descreva o motivo principal da consulta...';
  static const String placeholderHistoricoMedico = 'Doenças anteriores, tratamentos...';
  static const String placeholderCirurgias = 'Liste cirurgias anteriores...';
  static const String placeholderMedicamentos = 'Liste os medicamentos...';
  static const String placeholderAlergias = 'Liste alergias conhecidas...';
  static const String placeholderContraindicacoes = 'Liste contraindicações observadas...';
}
