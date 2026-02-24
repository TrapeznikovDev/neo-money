import 'package:flutter/material.dart';
import 'package:neomoney/cloacka/core/presentation/state/ui_state.dart';
import 'package:provider/provider.dart';

import 'app/app.dart';
import 'app/di.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();

  runApp(
    ChangeNotifierProvider<AppState>(
      create: (_) => getIt<AppState>(),
      child: const App(),
    ),
  );
}