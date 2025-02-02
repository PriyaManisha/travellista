import 'package:flutter/material.dart';
import 'package:travellista/home_screen_page.dart';
import 'package:travellista/util/theme_manager.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:travellista/providers/journal_entry_provider.dart';
import 'package:travellista/firebase_options.dart';

void main() async {
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
    return ChangeNotifierProvider(
      create: (_) => JournalEntryProvider(),
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: ThemeManager.themeNotifier,
        builder: (_, ThemeMode currentTheme, __) {
          return MaterialApp(
            title: 'Travellista',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
            ),
            darkTheme: ThemeData.dark(),
            themeMode: currentTheme,
            home: const HomeScreenPage(),
          );
        },
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:travellista/models/journal_entry.dart';
// import 'package:travellista/home_screen_page.dart';
// import 'package:travellista/util/theme_manager.dart';
//
//
// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
// @override
// Widget build(BuildContext context) {
//   return ValueListenableBuilder<ThemeMode>(
//     valueListenable: ThemeManager.themeNotifier,
//     builder: (_, ThemeMode currentTheme, __) {
//       return MaterialApp(
//         title: 'Travellista',
//         theme: ThemeData(
//           colorScheme: ColorScheme.fromSeed(
//             seedColor: Colors.deepPurple,
//           ),
//           useMaterial3: true,
//         ),
//         darkTheme: ThemeData.dark(),
//         themeMode: currentTheme,
//         home: const HomeScreenPage(),
//       );
//     },
//   );
// }
// }
