import "package:flutter/material.dart";

class AppTheme
{
    static ThemeData light()
    {
        final scheme = ColorScheme.fromSeed(seedColor: Colors.deepPurple);

        final base = ThemeData(
            useMaterial3: true,
            colorScheme: scheme,
            brightness: Brightness.light,
            visualDensity: VisualDensity.adaptivePlatformDensity,
        );

        return base.copyWith(
            scaffoldBackgroundColor: scheme.surface,

            appBarTheme: AppBarTheme(
                backgroundColor: scheme.surface,
                foregroundColor: scheme.onSurface,
                elevation: 0,
                centerTitle: false,
                titleTextStyle: base.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: scheme.onSurface,
                ),
            ),

            cardTheme: CardThemeData(
                elevation: 1.2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                margin: EdgeInsets.zero,
            ),

            dividerTheme: DividerThemeData(
                color: scheme.outlineVariant.withOpacity(0.6),
                thickness: 1,
                space: 1,
            ),

            listTileTheme: ListTileThemeData(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                iconColor: scheme.onSurfaceVariant,
                textColor: scheme.onSurface,
            ),

            navigationBarTheme: NavigationBarThemeData(
                height: 68,
                backgroundColor: scheme.surface,
                indicatorColor: scheme.primaryContainer,
                labelTextStyle: MaterialStateProperty.all(
                    base.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w800) ?? const TextStyle(),
                ),
            ),

            navigationRailTheme: NavigationRailThemeData(
                backgroundColor: scheme.surface,
                indicatorColor: scheme.primaryContainer,
                selectedIconTheme: IconThemeData(color: scheme.onPrimaryContainer),
                unselectedIconTheme: IconThemeData(color: scheme.onSurfaceVariant),
                selectedLabelTextStyle: base.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: scheme.onSurface,
                ),
                unselectedLabelTextStyle: base.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurfaceVariant,
                ),
                minWidth: 84,
                groupAlignment: -0.85,
            ),

            chipTheme: base.chipTheme.copyWith(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                side: BorderSide(color: scheme.outlineVariant),
                labelStyle: base.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
            ),

            inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: scheme.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: scheme.outlineVariant),
                ),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: scheme.primary, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),

            snackBarTheme: SnackBarThemeData(
                behavior: SnackBarBehavior.floating,
                backgroundColor: scheme.inverseSurface,
                contentTextStyle: base.textTheme.bodyMedium?.copyWith(
                    color: scheme.onInverseSurface,
                    fontWeight: FontWeight.w600,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),

            scrollbarTheme: ScrollbarThemeData(
                radius: const Radius.circular(999),
                thickness: MaterialStateProperty.resolveWith<double?>((states)
                {
                    if (states.contains(MaterialState.hovered) || states.contains(MaterialState.dragged))
                    {
                        return 10;
                    }
                    return 8;
                }),
                thumbVisibility: MaterialStateProperty.resolveWith<bool?>((states)
                {
                    if (states.contains(MaterialState.hovered) || states.contains(MaterialState.dragged))
                    {
                        return true;
                    }
                    return null;
                }),
            ),
        );
    }

    static ThemeData dark()
    {
        final scheme = ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.dark,
        );

        final base = ThemeData(
            useMaterial3: true,
            colorScheme: scheme,
            brightness: Brightness.dark,
            visualDensity: VisualDensity.adaptivePlatformDensity,
        );

        return base.copyWith(
            scaffoldBackgroundColor: scheme.surface,

            appBarTheme: AppBarTheme(
                backgroundColor: scheme.surface,
                foregroundColor: scheme.onSurface,
                elevation: 0,
                centerTitle: false,
                titleTextStyle: base.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: scheme.onSurface,
                ),
            ),

            cardTheme: CardThemeData(
                elevation: 1.2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                margin: EdgeInsets.zero,
            ),

            navigationBarTheme: NavigationBarThemeData(
                height: 68,
                backgroundColor: scheme.surface,
                indicatorColor: scheme.primaryContainer,
                labelTextStyle: MaterialStateProperty.all(
                    base.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w800) ?? const TextStyle(),
                ),
            ),

            navigationRailTheme: NavigationRailThemeData(
                backgroundColor: scheme.surface,
                indicatorColor: scheme.primaryContainer,
                selectedIconTheme: IconThemeData(color: scheme.onPrimaryContainer),
                unselectedIconTheme: IconThemeData(color: scheme.onSurfaceVariant),
                minWidth: 84,
                groupAlignment: -0.85,
            ),

            inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: scheme.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: scheme.outlineVariant),
                ),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: scheme.primary, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),

            scrollbarTheme: const ScrollbarThemeData(
                radius: Radius.circular(999),
            ),
        );
    }
}
