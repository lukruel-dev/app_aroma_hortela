import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Estilos de texto do app Aroma de Hortelã
/// Utiliza Google Fonts (Poppins para títulos, Inter para corpo)
class AppTextStyles {
  AppTextStyles._();

  // ============================================
  // FONTES BASE
  // ============================================
  
  /// Fonte para títulos e destaques
  static String get _headingFont => GoogleFonts.poppins().fontFamily!;
  
  /// Fonte para corpo de texto
  static String get _bodyFont => GoogleFonts.inter().fontFamily!;

  // ============================================
  // TÍTULOS (HEADINGS)
  // ============================================
  
  /// Título extra grande - Nome do app, telas principais
  static TextStyle heading1({Color? color, bool isDark = false}) {
    return TextStyle(
      fontFamily: _headingFont,
      fontSize: 32,
      fontWeight: FontWeight.w700,
      color: color ?? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
      height: 1.2,
    );
  }
  
  /// Título grande - Títulos de página (Dashboard, Clientes, etc)
  static TextStyle heading2({Color? color, bool isDark = false}) {
    return TextStyle(
      fontFamily: _headingFont,
      fontSize: 28,
      fontWeight: FontWeight.w600,
      color: color ?? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
      height: 1.3,
    );
  }
  
  /// Título médio - Títulos de seção
  static TextStyle heading3({Color? color, bool isDark = false}) {
    return TextStyle(
      fontFamily: _headingFont,
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: color ?? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
      height: 1.3,
    );
  }
  
  /// Título pequeno - Subtítulos, cards
  static TextStyle heading4({Color? color, bool isDark = false}) {
    return TextStyle(
      fontFamily: _headingFont,
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: color ?? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
      height: 1.4,
    );
  }

  // ============================================
  // TÍTULOS DE SEÇÃO (COM COR LARANJA)
  // ============================================
  
  /// Título de seção em cards (Áreas de Dor, Histórico, etc)
  static TextStyle sectionTitle({Color? color}) {
    return TextStyle(
      fontFamily: _headingFont,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: color ?? AppColors.primary,
      height: 1.4,
    );
  }

  // ============================================
  // CORPO DE TEXTO (BODY)
  // ============================================
  
  /// Texto grande - Descrições importantes
  static TextStyle bodyLarge({Color? color, bool isDark = false}) {
    return TextStyle(
      fontFamily: _bodyFont,
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: color ?? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
      height: 1.5,
    );
  }
  
  /// Texto médio - Corpo principal
  static TextStyle bodyMedium({Color? color, bool isDark = false}) {
    return TextStyle(
      fontFamily: _bodyFont,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: color ?? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
      height: 1.5,
    );
  }
  
  /// Texto pequeno - Detalhes, secundário
  static TextStyle bodySmall({Color? color, bool isDark = false}) {
    return TextStyle(
      fontFamily: _bodyFont,
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: color ?? (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
      height: 1.5,
    );
  }

  // ============================================
  // LABELS E CAMPOS
  // ============================================
  
  /// Label de campo de formulário
  static TextStyle label({Color? color, bool isDark = false}) {
    return TextStyle(
      fontFamily: _bodyFont,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: color ?? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
      height: 1.4,
    );
  }
  
  /// Label com asterisco (campo obrigatório)
  static TextStyle labelRequired({Color? color, bool isDark = false}) {
    return TextStyle(
      fontFamily: _bodyFont,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: color ?? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
      height: 1.4,
    );
  }
  
  /// Texto de input/placeholder
  static TextStyle input({Color? color, bool isDark = false}) {
    return TextStyle(
      fontFamily: _bodyFont,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: color ?? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
      height: 1.5,
    );
  }
  
  /// Placeholder/Hint
  static TextStyle hint({Color? color, bool isDark = false}) {
    return TextStyle(
      fontFamily: _bodyFont,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: color ?? (isDark ? AppColors.darkTextHint : AppColors.lightTextHint),
      height: 1.5,
    );
  }

  // ============================================
  // BOTÕES
  // ============================================
  
  /// Texto de botão grande
  static TextStyle buttonLarge({Color? color}) {
    return TextStyle(
      fontFamily: _headingFont,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: color ?? AppColors.white,
      height: 1.2,
    );
  }
  
  /// Texto de botão médio
  static TextStyle buttonMedium({Color? color}) {
    return TextStyle(
      fontFamily: _headingFont,
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: color ?? AppColors.white,
      height: 1.2,
    );
  }
  
  /// Texto de botão pequeno
  static TextStyle buttonSmall({Color? color}) {
    return TextStyle(
      fontFamily: _headingFont,
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: color ?? AppColors.white,
      height: 1.2,
    );
  }

  // ============================================
  // CARDS DO DASHBOARD
  // ============================================
  
  /// Título do stat card (Clientes Ativos, etc)
  static TextStyle statCardTitle({Color? color}) {
    return TextStyle(
      fontFamily: _bodyFont,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: color ?? AppColors.white.withOpacity(0.9),
      height: 1.4,
    );
  }
  
  /// Número grande do stat card
  static TextStyle statCardNumber({Color? color}) {
    return TextStyle(
      fontFamily: _headingFont,
      fontSize: 40,
      fontWeight: FontWeight.w700,
      color: color ?? AppColors.white,
      height: 1.1,
    );
  }
  
  /// Subtítulo do stat card
  static TextStyle statCardSubtitle({Color? color}) {
    return TextStyle(
      fontFamily: _bodyFont,
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: color ?? AppColors.white.withOpacity(0.8),
      height: 1.4,
    );
  }

  // ============================================
  // NAVEGAÇÃO E MENU
  // ============================================
  
  /// Item de menu/drawer
  static TextStyle menuItem({Color? color, bool isActive = false, bool isDark = false}) {
    return TextStyle(
      fontFamily: _bodyFont,
      fontSize: 15,
      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
      color: color ?? (isActive 
        ? AppColors.primary 
        : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
      height: 1.4,
    );
  }
  
  /// Nome do app na AppBar
  static TextStyle appBarTitle({Color? color, bool isDark = false}) {
    return TextStyle(
      fontFamily: _headingFont,
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: color ?? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
      height: 1.3,
    );
  }

  // ============================================
  // BADGES E STATUS
  // ============================================
  
  /// Badge de status (Ativo, Inativo)
  static TextStyle badge({Color? color}) {
    return TextStyle(
      fontFamily: _bodyFont,
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: color ?? AppColors.success,
      height: 1.2,
    );
  }

  // ============================================
  // LINKS E AÇÕES
  // ============================================
  
  /// Link/texto clicável
  static TextStyle link({Color? color}) {
    return TextStyle(
      fontFamily: _bodyFont,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: color ?? AppColors.primary,
      height: 1.4,
    );
  }
  
  /// "Ver todos" e similares
  static TextStyle viewAll({Color? color}) {
    return TextStyle(
      fontFamily: _bodyFont,
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: color ?? AppColors.primary,
      height: 1.4,
    );
  }

  // ============================================
  // CALENDÁRIO
  // ============================================
  
  /// Dia da semana no calendário
  static TextStyle calendarWeekday({Color? color}) {
    return TextStyle(
      fontFamily: _headingFont,
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: color ?? AppColors.primary,
      height: 1.3,
      letterSpacing: 0.5,
    );
  }
  
  /// Número do dia no calendário
  static TextStyle calendarDay({Color? color, bool isDark = false}) {
    return TextStyle(
      fontFamily: _headingFont,
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: color ?? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
      height: 1.2,
    );
  }

  // ============================================
  // DATA E HORA
  // ============================================
  
  /// Data (segunda-feira, 16 de fevereiro)
  static TextStyle date({Color? color, bool isDark = false}) {
    return TextStyle(
      fontFamily: _bodyFont,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: color ?? (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
      height: 1.4,
    );
  }

  // ============================================
  // ERROS E VALIDAÇÃO
  // ============================================
  
  /// Mensagem de erro em campos
  static TextStyle error({Color? color}) {
    return TextStyle(
      fontFamily: _bodyFont,
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: color ?? AppColors.error,
      height: 1.4,
    );
  }

  // ============================================
  // CHECKBOX E RADIO
  // ============================================
  
  /// Texto do checkbox/radio
  static TextStyle checkboxLabel({Color? color, bool isDark = false}) {
    return TextStyle(
      fontFamily: _bodyFont,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: color ?? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
      height: 1.4,
    );
  }

  // ============================================
  // AVATAR
  // ============================================
  
  /// Inicial no avatar
  static TextStyle avatarInitial({Color? color, double? fontSize}) {
    return TextStyle(
      fontFamily: _headingFont,
      fontSize: fontSize ?? 18,
      fontWeight: FontWeight.w600,
      color: color ?? AppColors.white,
      height: 1.0,
    );
  }
}
