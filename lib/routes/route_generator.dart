import 'package:crm/routes/route_names.dart';
import 'package:crm/screens/basvuru_detay.dart';
import 'package:crm/screens/musteri_detay.dart';
import 'package:crm/screens/musteri_ekle.dart';
import 'package:crm/screens/kurumsal_musteri_detay_ekrani.dart';
import 'package:crm/services/musteri_servisi.dart';
import 'package:flutter/material.dart';

class RouteGenerator {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.musteriDetay:
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
      case RouteNames.basvuruDetay:
        final basvuruId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (context) => BasvuruDetay(basvuruId: basvuruId),
        );
      case RouteNames.musteriEkle:
        return MaterialPageRoute(
          builder: (context) => const MusteriEkle(),
        );
      case RouteNames.kurumsalMusteriDetay:
        final kurumsalId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (context) => KurumsalMusteriDetayEkrani(kurumsalMusteriId: kurumsalId),
        );
      default:
        return null;
    }
  }
}
