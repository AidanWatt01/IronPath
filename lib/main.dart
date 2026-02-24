import "dart:async";
import "dart:ui";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "ui/home_shell.dart";
import "ui/theme/app_theme.dart";

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint("FlutterError: ${details.exceptionAsString()}");
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint("PlatformError: $error");
    debugPrint("$stack");
    return true;
  };

  runZonedGuarded(
    () {
      runApp(const ProviderScope(child: CaliSkillTreeApp()));
    },
    (error, stack) {
      debugPrint("ZoneError: $error");
      debugPrint("$stack");
    },
  );
}

class CaliSkillTreeApp extends StatelessWidget {
  const CaliSkillTreeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Cali Skill Tree",
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: const HomeShell(),
    );
  }
}
