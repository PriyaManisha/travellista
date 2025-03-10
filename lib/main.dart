import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:travellista/util/theme_manager.dart';
import 'package:travellista/providers/journal_entry_provider.dart';
import 'package:travellista/providers/profile_provider.dart';
import 'package:travellista/firebase_options.dart';
import 'package:travellista/router/app_router.dart';

Future<void> main() async {
  // Initialize Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, 
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => JournalEntryProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ],
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: ThemeManager.themeNotifier,
        builder: (_, ThemeMode currentTheme, __) {
          return MaterialApp.router(
            title: 'Travellista',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
              textTheme: const TextTheme(
                titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                titleSmall: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                bodyLarge: TextStyle(fontSize: 16),
                bodyMedium: TextStyle(fontSize: 14),
                bodySmall: TextStyle(fontSize: 12),
                labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
            darkTheme: ThemeData.dark(),
            themeMode: currentTheme,
            routerConfig: appRouter,
          );
        },
      ),
    );
  }
}
