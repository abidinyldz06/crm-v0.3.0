import 'package:crm/screens/login_screen.dart';
import 'package:crm/services/auth_service.dart';
import 'package:crm/theme_v2.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:crm/screens/dashboard_v2.dart';
import 'package:crm/screens/musteri_detay.dart';
import 'package:crm/screens/basvuru_detay.dart';
import 'package:crm/services/musteri_servisi.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vize Danışmanlık CRM',
      debugShowCheckedModeBanner: false,
      theme: AppThemeV2.theme, // Değiştirildi
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('tr', 'TR'),
      ],
      home: const AuthWrapper(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/musteri_detay':
            final musteriId = settings.arguments as String;
            return MaterialPageRoute(
              builder: (context) => FutureBuilder(
                future: MusteriServisi().musteriGetir(musteriId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (snapshot.hasData && snapshot.data != null) {
                    return MusteriDetay(musteriId: snapshot.data!.id);
                  }
                  return const Scaffold(
                    body: Center(child: Text('Müşteri bulunamadı')),
                  );
                },
              ),
            );
          case '/basvuru_detay':
            final basvuruId = settings.arguments as String;
            return MaterialPageRoute(
              builder: (context) => BasvuruDetay(basvuruId: basvuruId),
            );
          default:
            return null;
        }
      },
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
