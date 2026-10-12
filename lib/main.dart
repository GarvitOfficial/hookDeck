import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'theme/theme_provider.dart';
import 'services/storage_service.dart';
import 'screens/profiles_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  final themeProvider = ThemeProvider();
  final storageService = StorageService();

  runApp(HookDeckApp(
    themeProvider: themeProvider,
    storageService: storageService,
  ));
}

class HookDeckApp extends StatelessWidget {
  final ThemeProvider themeProvider;
  final StorageService storageService;

  const HookDeckApp({
    super.key,
    required this.themeProvider,
    required this.storageService,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([themeProvider, storageService]),
      builder: (context, _) {
        return MaterialApp(
          title: 'HookDeck',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          home: MainNavigationHolder(
            storageService: storageService,
            themeProvider: themeProvider,
          ),
        );
      },
    );
  }
}
