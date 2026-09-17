import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';
import 'screens/root_screen.dart';

void main() {
  runApp(const DinamikDiyetApp());
}

class DinamikDiyetApp extends StatelessWidget {
  const DinamikDiyetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: Consumer<AppState>(
        builder: (context, appState, _) {
          return MaterialApp(
            title: 'Dinamik Diyet Planlayıcı',
            debugShowCheckedModeBanner: false,
            themeMode: appState.themeMode,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            home: const RootScreen(),
          );
        },
      ),
    );
  }
}
