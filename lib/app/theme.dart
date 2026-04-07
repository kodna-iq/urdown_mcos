import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// AppColors  — single source of truth for the entire design system
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//
// Extracted from kodna.org CSS:
//   --accent:#00e5ff   --accent2:#7c3aed
//   --bg:#07090d       --surface:#0e1117   --card:#12151c
//   --border:#1a1f2e   --text:#e8eaf0      --muted:#6b7280

class AppColors {
  AppColors._();

  // ── Brand ─────────────────────────────────────────────────────────────
  static const brand       = Color(0xFF00E5FF); // cyan accent
  static const brandSecond = Color(0xFF7C3AED); // purple accent
  static const brandLight  = Color(0xFF33ECFF);
  static const brandDark   = Color(0xFF00B8CC);

  // ── Semantic ──────────────────────────────────────────────────────────
  static const success = Color(0xFF4ADE80); // green
  static const error   = Color(0xFFEF4444); // red
  static const warning = Color(0xFFFB923C); // orange
  static const info    = Color(0xFF7C3AED); // purple

  // ── Dark-theme surfaces ───────────────────────────────────────────────
  static const darkBg      = Color(0xFF07090D); // page background
  static const darkSurface = Color(0xFF0E1117); // navbar / appbar
  static const darkCard    = Color(0xFF12151C); // cards
  static const darkBorder  = Color(0xFF1A1F2E); // dividers / borders

  // ── Dark-theme text ───────────────────────────────────────────────────
  static const darkText          = Color(0xFFE8EAF0); // primary
  static const darkTextSecondary = Color(0xFF6B7280); // muted
  static const darkTextMuted     = Color(0xFF363B4A); // very muted

  // ── Light-theme surfaces ──────────────────────────────────────────────
  static const lightBg     = Color(0xFFF0F4FA);
  static const lightCard   = Color(0xFFFFFFFF);
  static const lightBorder = Color(0xFFDDE3EE);

  // ── Light-theme text ──────────────────────────────────────────────────
  static const lightText          = Color(0xFF07090D);
  static const lightTextSecondary = Color(0xFF4A5568);
  static const lightTextMuted     = Color(0xFF9AA5B4);
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// AppTheme  — complete Material 3 theme covering every component
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class AppTheme {
  AppTheme._();

  static ThemeData get dark  => _build(Brightness.dark);
  static ThemeData get light => _build(Brightness.light);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    // ── Color scheme ────────────────────────────────────────────────────
    final colorScheme = ColorScheme.fromSeed(
      seedColor:  AppColors.brand,
      brightness: brightness,
      surface:    isDark ? AppColors.darkCard    : AppColors.lightCard,
      primary:    AppColors.brand,
      onPrimary:  isDark ? AppColors.darkBg      : Colors.white,
      secondary:  AppColors.brandSecond,
      onSecondary: Colors.white,
      error:      AppColors.error,
      onError:    Colors.white,
      // Material 3 surface roles
      surfaceContainerHighest:
          isDark ? AppColors.darkBorder : AppColors.lightBorder,
      outline:  isDark ? AppColors.darkBorder : AppColors.lightBorder,
    );

    return ThemeData(
      useMaterial3:          true,
      colorScheme:           colorScheme,
      brightness:            brightness,
      scaffoldBackgroundColor:
          isDark ? AppColors.darkBg : AppColors.lightBg,
      cardColor: isDark ? AppColors.darkCard : AppColors.lightCard,
      dividerColor:
          isDark ? AppColors.darkBorder : AppColors.lightBorder,

      // ── AppBar ─────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor:  isDark ? AppColors.darkSurface : AppColors.lightCard,
        foregroundColor:  isDark ? AppColors.darkText    : AppColors.lightText,
        elevation:        0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle:      false,
        titleTextStyle: TextStyle(
          color:      isDark ? AppColors.darkText : AppColors.lightText,
          fontSize:   18,
          fontWeight: FontWeight.w600,
        ),
        shape: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 0.5,
          ),
        ),
      ),

      // ── Text ──────────────────────────────────────────────────────────
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 36, fontWeight: FontWeight.w800,
          color: isDark ? AppColors.darkText : AppColors.lightText,
        ),
        headlineLarge: TextStyle(
          fontSize: 28, fontWeight: FontWeight.w700,
          color: isDark ? AppColors.darkText : AppColors.lightText,
        ),
        headlineMedium: TextStyle(
          fontSize: 22, fontWeight: FontWeight.w600,
          color: isDark ? AppColors.darkText : AppColors.lightText,
        ),
        headlineSmall: TextStyle(
          fontSize: 18, fontWeight: FontWeight.w600,
          color: isDark ? AppColors.darkText : AppColors.lightText,
        ),
        titleLarge: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w600,
          color: isDark ? AppColors.darkText : AppColors.lightText,
        ),
        titleMedium: TextStyle(
          fontSize: 15, fontWeight: FontWeight.w500,
          color: isDark ? AppColors.darkText : AppColors.lightText,
        ),
        titleSmall: TextStyle(
          fontSize: 14, fontWeight: FontWeight.w500,
          color: isDark ? AppColors.darkText : AppColors.lightText,
        ),
        bodyLarge: TextStyle(
          fontSize: 14, height: 1.5,
          color: isDark ? AppColors.darkText : AppColors.lightText,
        ),
        bodyMedium: TextStyle(
          fontSize: 13, height: 1.5,
          color: isDark
              ? AppColors.darkTextSecondary
              : AppColors.lightTextSecondary,
        ),
        bodySmall: TextStyle(
          fontSize: 12, height: 1.4,
          color: isDark
              ? AppColors.darkTextSecondary
              : AppColors.lightTextSecondary,
        ),
        labelLarge: TextStyle(
          fontSize: 14, fontWeight: FontWeight.w500,
          color: isDark ? AppColors.darkText : AppColors.lightText,
        ),
        labelMedium: TextStyle(
          fontSize: 12, fontWeight: FontWeight.w500,
          color: isDark
              ? AppColors.darkTextSecondary
              : AppColors.lightTextSecondary,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
        ),
      ),

      // ── Input decoration ───────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled:          true,
        fillColor:       isDark ? AppColors.darkCard : AppColors.lightCard,
        contentPadding:  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.brand, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        hintStyle: TextStyle(
          color:    isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
          fontSize: 13,
        ),
        iconColor:
            isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
        prefixIconColor:
            isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
        suffixIconColor:
            isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
      ),

      // ── Buttons ────────────────────────────────────────────────────────

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brand,
          foregroundColor: AppColors.darkBg,
          disabledBackgroundColor: isDark
              ? AppColors.darkBorder
              : AppColors.lightBorder,
          elevation:  0,
          shape:      RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding:    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle:  const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.brand,
          foregroundColor: AppColors.darkBg,
          disabledBackgroundColor: isDark
              ? AppColors.darkBorder
              : AppColors.lightBorder,
          shape:     RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding:   const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: isDark ? AppColors.darkText : AppColors.lightText,
          side: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
          shape:   RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle:
              const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.brand,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor:
              isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
        ),
      ),

      // ── Card ──────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color:       isDark ? AppColors.darkCard : AppColors.lightCard,
        elevation:   0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        margin: const EdgeInsets.symmetric(vertical: 6),
      ),

      // ── Dialog ────────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor:
            isDark ? AppColors.darkCard : AppColors.lightCard,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: TextStyle(
          fontSize:   17,
          fontWeight: FontWeight.w700,
          color:      isDark ? AppColors.darkText : AppColors.lightText,
        ),
        contentTextStyle: TextStyle(
          fontSize: 14,
          color:    isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
        ),
      ),

      // ── SnackBar ──────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor:
            isDark ? const Color(0xFF1E2333) : const Color(0xFF1E2333),
        contentTextStyle: const TextStyle(
          color:    AppColors.darkText,
          fontSize: 13,
        ),
        actionTextColor: AppColors.brand,
        behavior:        SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
      ),

      // ── Tooltip ───────────────────────────────────────────────────────
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color:        isDark
              ? AppColors.darkBorder.withValues(alpha: 0.95)
              : const Color(0xFF1E2333),
          borderRadius: BorderRadius.circular(6),
        ),
        textStyle: const TextStyle(
          color:    AppColors.darkText,
          fontSize: 12,
        ),
        waitDuration: const Duration(milliseconds: 500),
        padding:      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),

      // ── Switch ────────────────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return isDark ? AppColors.darkBg : Colors.white;
          }
          return isDark ? AppColors.darkTextMuted : const Color(0xFFB0BEC5);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.brand;
          return isDark ? AppColors.darkBorder : const Color(0xFFCFD8DC);
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),

      // ── NavigationRail ────────────────────────────────────────────────
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor:  isDark ? AppColors.darkSurface : AppColors.lightCard,
        selectedIconTheme:   const IconThemeData(color: AppColors.brand, size: 22),
        unselectedIconTheme: IconThemeData(
          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          size:  22,
        ),
        indicatorColor: AppColors.brand.withValues(alpha: 0.12),
        indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        selectedLabelTextStyle: const TextStyle(
          color: AppColors.brand, fontWeight: FontWeight.w600, fontSize: 12,
        ),
        unselectedLabelTextStyle: TextStyle(
          color:    isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          fontSize: 12,
        ),
      ),

      // ── NavigationBar (mobile) ────────────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor:
            isDark ? AppColors.darkSurface : AppColors.lightCard,
        indicatorColor:  AppColors.brand.withValues(alpha: 0.15),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.brand, size: 22);
          }
          return IconThemeData(
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            size:  22,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color:      AppColors.brand,
              fontSize:   11,
              fontWeight: FontWeight.w600,
            );
          }
          return TextStyle(
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            fontSize: 11,
          );
        }),
        surfaceTintColor: Colors.transparent,
        shadowColor:      Colors.transparent,
        elevation:        0,
        overlayColor:     WidgetStateProperty.all(Colors.transparent),
      ),

      // ── ProgressIndicator ─────────────────────────────────────────────
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color:                AppColors.brand,
        linearMinHeight:      4,
        linearTrackColor:
            isDark ? AppColors.darkBorder : AppColors.lightBorder,
        circularTrackColor:
            isDark ? AppColors.darkBorder : AppColors.lightBorder,
      ),

      // ── Slider ────────────────────────────────────────────────────────
      sliderTheme: SliderThemeData(
        activeTrackColor:   AppColors.brand,
        inactiveTrackColor:
            isDark ? AppColors.darkBorder : AppColors.lightBorder,
        thumbColor:         AppColors.brand,
        overlayColor:       AppColors.brand.withValues(alpha: 0.12),
        valueIndicatorColor: AppColors.brand,
        valueIndicatorTextStyle: const TextStyle(
          color: AppColors.darkBg,
          fontWeight: FontWeight.w700,
        ),
      ),

      // ── Chip ──────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor:
            isDark ? AppColors.darkCard : AppColors.lightCard,
        side: BorderSide(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        labelStyle: TextStyle(
          fontSize: 12,
          color:    isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),

      // ── ListTile ──────────────────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        iconColor:
            isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
        tileColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),

      // ── Divider ───────────────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color:     isDark ? AppColors.darkBorder : AppColors.lightBorder,
        thickness: 0.5,
        space:     1,
      ),

      // ── PopupMenu ─────────────────────────────────────────────────────
      popupMenuTheme: PopupMenuThemeData(
        color:     isDark ? AppColors.darkCard : AppColors.lightCard,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        textStyle: TextStyle(
          fontSize: 14,
          color:    isDark ? AppColors.darkText : AppColors.lightText,
        ),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ThemeMode provider
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const _key = 'theme_mode';

  @override
  ThemeMode build() {
    _loadTheme();
    return ThemeMode.dark;
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final name  = prefs.getString(_key);
    if (name != null) {
      final mode = ThemeMode.values.firstWhere(
        (t) => t.name == name,
        orElse: () => ThemeMode.dark,
      );
      state = mode;
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode.name);
  }
}

final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);
