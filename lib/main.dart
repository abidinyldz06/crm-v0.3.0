import 'package:crm/screens/login_screen.dart';
import 'package:crm/services/auth_service.dart';
import 'package:crm/services/theme_service.dart';
import 'package:crm/services/localization_service.dart';
import 'package:crm/services/fcm_service.dart';
import 'package:crm/theme_v2.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:crm/screens/dashboard_v2.dart';
import 'package:crm/screens/musteri_detay.dart';
import 'package:crm/screens/basvuru_detay.dart';
import 'package:crm/screens/musteri_ekle.dart';
import 'package:crm/services/musteri_servisi.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'package:crm/generated/l10n/app_localizations.dart';
import 'package:crm/routes/route_generator.dart';
import 'package:crm/routes/route_names.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Web platformunda Firebase Messaging desteği sınırlı
  if (!kIsWeb) {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }
  
  // Theme, Localization ve FCM service'lerini initialize et
  await ThemeService().init();
  await LocalizationService().init();
  
  // FCM sadece web olmayan platformlarda initialize et
  if (!kIsWeb) {
    await FCMService().initialize();
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeService()),
        ChangeNotifierProvider(create: (context) => LocalizationService()),
        ChangeNotifierProvider(create: (context) => FCMService()),
      ],
      child: Consumer2<ThemeService, LocalizationService>(
        builder: (context, themeService, localizationService, child) {
          return MaterialApp(
            title: 'Vize Danışmanlık CRM',
            debugShowCheckedModeBanner: false,
            theme: AppThemeV2.lightTheme,
            darkTheme: AppThemeV2.darkTheme,
            themeMode: themeService.themeMode,
            locale: localizationService.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('tr', 'TR'),
              Locale('en', 'US'),
            ],
            home: const AuthWrapper(),
            onGenerateRoute: RouteGenerator.onGenerateRoute,
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().user,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData) {
          return const DashboardV2(); // Eski Dashboard yerine V2 kullanılıyor
        }
        return const LoginScreen();
      },
    );
  }
}
