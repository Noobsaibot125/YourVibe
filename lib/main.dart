import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'viewmodels/player_viewmodel.dart';
import 'views/main_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configuration de la barre de statut
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF1C1B1F),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Demander les permissions nécessaires
  await _requestPermissions();

  runApp(const MyApp());
}

Future<void> _requestPermissions() async {
  // Permissions pour accéder aux fichiers audio
  if (await Permission.audio.isDenied) {
    await Permission.audio.request();
  }

  // Pour Android 13+ (API 33+), utiliser les nouvelles permissions media
  if (await Permission.audio.isPermanentlyDenied) {
    await openAppSettings();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PlayerViewModel(),
      child: MaterialApp(
        title: 'FlutterVibe',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF9C27B0), // Purple 500
            onPrimary: Colors.white,
            secondary: Color(0xFFE040FB), // PurpleAccent 200
            surface: Color(0xFF120023), // Deep Dark Purple
            onSurface: Colors.white,
            surfaceContainerHighest:
                Color(0xFF2A0E3B), // Lighter Purple for cards
            outline: Color(0xFF7B1FA2),
          ),
          scaffoldBackgroundColor:
              const Color(0xFF120023), // Deep Dark Purple Background
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent, // Glassmorphism style
            elevation: 0,
            systemOverlayStyle: SystemUiOverlayStyle.light,
          ),
          fontFamily: 'Roboto',
        ),
        home: const MainNavigation(),
      ),
    );
  }
}
