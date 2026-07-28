import 'package:flutter/material.dart';
import 'package:poty_ia_app/ui/core/themes/app_spacing.dart';
import 'package:poty_ia_app/ui/core/themes/cores.dart';

abstract final class AppTheme {
  static ThemeData get main {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.primaryDark,
      secondary: AppColors.secondary,
      tertiary: AppColors.accent,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      error: AppColors.error,
      onError: Colors.white,
      errorContainer: AppColors.errorContainer,
      outline: AppColors.border,
      outlineVariant: AppColors.borderSoft,
    );

    final baseTheme = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: Brightness.light,
    );

    return baseTheme.copyWith(
      scaffoldBackgroundColor: AppColors.background,

      visualDensity: VisualDensity.standard,

      textTheme: _buildTextTheme(baseTheme.textTheme),

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleSpacing: 24,
        toolbarHeight: 68,
        iconTheme: IconThemeData(
          color: AppColors.textSecondary,
          size: 22,
        ),
      ),

      cardTheme: CardThemeData(
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shadowColor: AppColors.shadow,
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppSpacing.radiusLarge,
          ),
          side: const BorderSide(
            color: AppColors.borderSoft,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        isDense: false,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        hintStyle: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 14,
        ),
        labelStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        floatingLabelStyle: const TextStyle(
          color: AppColors.primary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        prefixIconColor: AppColors.textMuted,
        suffixIconColor: AppColors.textMuted,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppSpacing.radiusMedium,
          ),
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppSpacing.radiusMedium,
          ),
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppSpacing.radiusMedium,
          ),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.8,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppSpacing.radiusMedium,
          ),
          borderSide: const BorderSide(
            color: AppColors.error,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppSpacing.radiusMedium,
          ),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 1.8,
          ),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(
            Size(0, 50),
          ),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(
              horizontal: 22,
              vertical: 14,
            ),
          ),
          backgroundColor: WidgetStateProperty.resolveWith(
                (states) {
              if (states.contains(WidgetState.disabled)) {
                return AppColors.primary.withValues(alpha: 0.45);
              }

              if (states.contains(WidgetState.hovered)) {
                return AppColors.primaryDark;
              }

              return AppColors.primary;
            },
          ),
          foregroundColor: const WidgetStatePropertyAll(
            Colors.white,
          ),
          overlayColor: WidgetStatePropertyAll(
            Colors.white.withValues(alpha: 0.10),
          ),
          elevation: const WidgetStatePropertyAll(0),
          textStyle: const WidgetStatePropertyAll(
            TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                AppSpacing.radiusMedium,
              ),
            ),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(
            Size(0, 48),
          ),
          foregroundColor: const WidgetStatePropertyAll(
            AppColors.primary,
          ),
          side: const WidgetStatePropertyAll(
            BorderSide(
              color: AppColors.border,
            ),
          ),
          textStyle: const WidgetStatePropertyAll(
            TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                AppSpacing.radiusMedium,
              ),
            ),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: const WidgetStatePropertyAll(
            AppColors.primary,
          ),
          textStyle: const WidgetStatePropertyAll(
            TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                AppSpacing.radiusSmall,
              ),
            ),
          ),
        ),
      ),

      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          foregroundColor: const WidgetStatePropertyAll(
            AppColors.textSecondary,
          ),
          backgroundColor: WidgetStateProperty.resolveWith(
                (states) {
              if (states.contains(WidgetState.hovered)) {
                return AppColors.surfaceMuted;
              }

              return Colors.transparent;
            },
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                AppSpacing.radiusSmall,
              ),
            ),
          ),
        ),
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
              (states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primary;
            }

            return Colors.transparent;
          },
        ),
        checkColor: const WidgetStatePropertyAll(
          Colors.white,
        ),
        side: const BorderSide(
          color: AppColors.border,
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: const WidgetStatePropertyAll(
          Colors.white,
        ),
        trackColor: WidgetStateProperty.resolveWith(
              (states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primary;
            }

            return AppColors.border;
          },
        ),
      ),

      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: const WidgetStatePropertyAll(
            AppColors.surface,
          ),
          elevation: const WidgetStatePropertyAll(4),
          shadowColor: const WidgetStatePropertyAll(
            AppColors.shadow,
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                AppSpacing.radiusMedium,
              ),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              AppSpacing.radiusMedium,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shadowColor: AppColors.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppSpacing.radiusExtraLarge,
          ),
        ),
        titleTextStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
          height: 1.5,
        ),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppSpacing.radiusMedium,
          ),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.borderSoft,
        thickness: 1,
        space: 1,
      ),

      chipTheme: baseTheme.chipTheme.copyWith(
        backgroundColor: AppColors.surfaceMuted,
        selectedColor: AppColors.primaryLight,
        side: const BorderSide(
          color: AppColors.borderSoft,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
        labelStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),

      dataTableTheme: DataTableThemeData(
        headingRowColor: const WidgetStatePropertyAll(
          AppColors.surfaceMuted,
        ),
        dataRowColor: WidgetStateProperty.resolveWith(
              (states) {
            if (states.contains(WidgetState.hovered)) {
              return AppColors.primaryLight;
            }

            return AppColors.surface;
          },
        ),
        headingTextStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
        dataTextStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
        ),
        dividerThickness: 1,
        horizontalMargin: 20,
        columnSpacing: 28,
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primaryLight,
        elevation: 0,
        height: 72,
        iconTheme: WidgetStateProperty.resolveWith(
              (states) {
            return IconThemeData(
              color: states.contains(WidgetState.selected)
                  ? AppColors.primary
                  : AppColors.textMuted,
            );
          },
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
              (states) {
            return TextStyle(
              color: states.contains(WidgetState.selected)
                  ? AppColors.primary
                  : AppColors.textMuted,
              fontSize: 12,
              fontWeight: states.contains(WidgetState.selected)
                  ? FontWeight.w700
                  : FontWeight.w500,
            );
          },
        ),
      ),

      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primaryLight,
        selectedIconTheme: const IconThemeData(
          color: AppColors.primary,
        ),
        unselectedIconTheme: const IconThemeData(
          color: AppColors.textMuted,
        ),
        selectedLabelTextStyle: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelTextStyle: const TextStyle(
          color: AppColors.textMuted,
          fontWeight: FontWeight.w500,
        ),
      ),


      floatingActionButtonTheme:
      const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        focusElevation: 3,
        hoverElevation: 4,
      ),

      progressIndicatorTheme:
      const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.primaryLight,
        circularTrackColor: AppColors.primaryLight,
      ),

      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.textPrimary,
          borderRadius: BorderRadius.circular(
            AppSpacing.radiusSmall,
          ),
        ),
        textStyle: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
    );
  }

  static TextTheme _buildTextTheme(TextTheme base) {
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.5,
      ),
      headlineLarge: base.headlineLarge?.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      titleLarge: base.titleLarge?.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: base.titleMedium?.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        color: AppColors.textSecondary,
        height: 1.5,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        color: AppColors.textSecondary,
        height: 1.5,
      ),
      bodySmall: base.bodySmall?.copyWith(
        color: AppColors.textMuted,
        height: 1.4,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }
}