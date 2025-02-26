import 'package:flutter/material.dart';
import 'package:travellista/home_screen_page.dart';
import 'package:travellista/util/theme_manager.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:travellista/providers/journal_entry_provider.dart';
import 'package:travellista/providers/profile_provider.dart';
import 'package:travellista/firebase_options.dart';

import 'entry_creation_form.dart';
import 'map_view_page.dart';
import 'profile_page.dart';

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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => JournalEntryProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ],
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
            routes:{
              "/home": (context) => const HomeScreenPage(),
              "/add": (context) => const EntryCreationForm(),
              "/map": (context) => const MapViewPage(),
              "/profile": (context) => const ProfilePage()
            },
            initialRoute:"/home",
          );
        },
      ),
    );
  }
}
