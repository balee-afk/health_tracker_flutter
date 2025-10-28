import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'controllers/app_state.dart';
import 'data/local_database.dart';
import 'screens/home_shell.dart';
import 'screens/login_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID');
  final appState = AppState(LocalDatabase.instance);
  await appState.ensureInitialized();
  runApp(HeartTrackerApp(appState: appState));
}

class HeartTrackerApp extends StatelessWidget {
  const HeartTrackerApp({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppState>.value(
      value: appState,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'HealthTrack',
        theme: buildAppTheme(),
        home: const _RootRouter(),
      ),
    );
  }
}

class _RootRouter extends StatelessWidget {
  const _RootRouter();

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        if (state.isAuthenticated) {
          return const HomeShell();
        }
        return const LoginScreen();
      },
    );
  }
}
