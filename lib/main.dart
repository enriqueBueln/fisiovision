// main.dart
import 'package:fisiovision/config/router.dart';
import 'package:fisiovision/config/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
Future<void> main() async {
  // Asegurarse de que los widgets estén inicializados
  WidgetsFlutterBinding.ensureInitialized();


  // Inicializar datos de localización para formateo de fechas
  await initializeDateFormatting('es', null);
  // Cargar variables de entorno desde el archivo .env
  await dotenv.load(fileName: ".env");

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    
    return MaterialApp.router(
      routerConfig: appRouter,
      title: 'Fisioterapia App',
      debugShowCheckedModeBanner: false,
      theme: theme,
    );
  }
}
