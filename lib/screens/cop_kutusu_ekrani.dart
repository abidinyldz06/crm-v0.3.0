import 'package:crm/models/basvuru_model.dart';
import 'package:crm/models/musteri_model.dart';
import 'package:crm/services/basvuru_servisi.dart';
import 'package:crm/services/musteri_servisi.dart';
import 'package:crm/widgets/basvuru_list_tile.dart';
import 'package:flutter/material.dart';

class CopKutusuEkrani extends StatelessWidget {
  const CopKutusuEkrani({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Çöp Kutusu'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Silinmiş Müşteriler', icon: Icon(Icons.person_remove)),
              Tab(text: 'Silinmiş Başvurular', icon: Icon(Icons.folder_delete)),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _SilinmisMusterilerListesi(),
            _SilinmisBasvurularListesi(),
          ],
        ),
      ),
    );
  }
}

// Silinmiş Müşteriler Widget'ı
class _SilinmisMusterilerListesi extends StatelessWidget {
  const _SilinmisMusterilerListesi();

  @override
  Widget build(BuildContext context) {
    final MusteriServisi musteriServisi = MusteriServisi();

    return StreamBuilder<List<MusteriModel>>(
      stream: musteriServisi.getSilinmisMusterilerStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Silinmiş müşteri bulunmuyor.'));
        }
        final musteriler = snapshot.data!;
        return ListView.builder(
          itemCount: musteriler.length,
          itemBuilder: (context, index) {
            final musteri = musteriler[index];
            return ListTile(
              title: Text(musteri.adSoyad),
              subtitle: Text(musteri.email),
              trailing: ElevatedButton.icon(
                icon: const Icon(Icons.restore),
                label: const Text('Geri Yükle'),
                onPressed: () async {
                  await musteriServisi.updateMusteri(musteri.id, {'isDeleted': false});
                  if (context.mounted) {
                     ScaffoldMessenger.of(context).showSnackBar(
                       const SnackBar(content: Text('Müşteri geri yüklendi.'), backgroundColor: Colors.green),
                     );
                  }
                },
              ),
            );
          },
        );
      },
    );
  }
}

// Silinmiş Başvurular Widget'ı
class _SilinmisBasvurularListesi extends StatelessWidget {
  const _SilinmisBasvurularListesi();

  @override
  Widget build(BuildContext context) {
    final BasvuruServisi basvuruServisi = BasvuruServisi();

    return StreamBuilder<List<BasvuruModel>>(
      stream: basvuruServisi.getSilinmisBasvurularStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Silinmiş başvuru bulunmuyor.'));
        }
        final basvurular = snapshot.data!;
        return ListView.builder(
          itemCount: basvurular.length,
          itemBuilder: (context, index) {
            final basvuru = basvurular[index];
            // BasvuruListTile'ı burada doğrudan kullanamayız çünkü farklı bir mantık gerekiyor.
            // Bu yüzden basit bir ListTile kullanıyoruz.
            return ListTile(
              leading: const Icon(Icons.folder),
              title: Text(basvuru.basvuruTuru),
              subtitle: Text('ID: ${basvuru.id}'), // Müşteri adını getirmek için ek sorgu gerekir, şimdilik ID
              trailing: ElevatedButton.icon(
                icon: const Icon(Icons.restore),
                label: const Text('Geri Yükle'),
                onPressed: () async {
                   await basvuruServisi.updateBasvuru(basvuru.id, {'isDeleted': false});
                   if (context.mounted) {
                       ScaffoldMessenger.of(context).showSnackBar(
                       const SnackBar(content: Text('Başvuru geri yüklendi.'), backgroundColor: Colors.green),
                     );
                  }
                },
              ),
            );
          },
        );
      },
    );
  }
} 