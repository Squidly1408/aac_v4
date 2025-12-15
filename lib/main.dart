import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'state/app_controller.dart';
import 'services/storage_service.dart';
import 'screens/home_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  final storage = StorageService();
  await storage.init();

  final controller = AppController(storageService: storage);
  await controller.load();

  runApp(
    ChangeNotifierProvider.value(
      value: controller,
      child: const AacBestApp(),
    ),
  );
}

class AacBestApp extends StatelessWidget {
  const AacBestApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF00C2FF),
      brightness: Brightness.dark,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AAC Best',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: colorScheme.surface,
        textTheme: Theme.of(context).textTheme.apply(
              fontFamily: 'Roboto',
            ),
        visualDensity: VisualDensity.standard,
      ),
      home: const HomeShell(),
    );
  }
}
