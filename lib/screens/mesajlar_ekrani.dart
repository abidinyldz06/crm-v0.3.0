import 'package:crm/models/konusma_model.dart';
import 'package:crm/models/kullanici_model.dart';
import 'package:crm/screens/konusma_detay_ekrani.dart';
import 'package:crm/services/kullanici_servisi.dart';
import 'package:crm/services/mesajlasma_servisi.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MesajlarEkrani extends StatelessWidget {
  const MesajlarEkrani({super.key});

  @override
  Widget build(BuildContext context) {
    final MesajlasmaServisi mesajlasmaServisi = MesajlasmaServisi();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mesajlar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment_outlined),
            onPressed: () => _showYeniKonusmaDialog(context),
            tooltip: 'Yeni Konuşma Başlat',
          ),
        ],
      ),
      body: StreamBuilder<List<KonusmaModel>>(
        stream: mesajlasmaServisi.getKonusmalarim(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Henüz bir konuşmanız yok.'));
          }
          final konusmalar = snapshot.data!;
          return ListView.builder(
            itemCount: konusmalar.length,
            itemBuilder: (context, index) {
              return _KonusmaKarti(konusma: konusmalar[index]);
            },
          );
        },
      ),
    );
  }

  void _showYeniKonusmaDialog(BuildContext context) {
    final KullaniciServisi kullaniciServisi = KullaniciServisi();
    final MesajlasmaServisi mesajlasmaServisi = MesajlasmaServisi();
    List<KullaniciModel> secilenKullanicilar = [];
    final ilkMesajController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Yeni Konuşma Başlat'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Konuşmaya dahil edilecek danışmanları seçin:'),
                    const SizedBox(height: 8),
                    FutureBuilder<List<KullaniciModel>>(
                      future: kullaniciServisi.getConsultants(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.data!.isEmpty) {
                          return const Text('Sistemde başka danışman bulunmuyor.');
                        }
                        // Kendimiz dışındaki danışmanları filtrele
                        final danismanlar = snapshot.data!
                            .where((user) => user.uid != FirebaseAuth.instance.currentUser?.uid)
                            .toList();

                        if (danismanlar.isEmpty) {
                           return const Text('Sistemde başka danışman bulunmuyor.');
                        }

                        return Wrap(
                          spacing: 8.0,
                          children: danismanlar.map((danisman) {
                            final isSelected = secilenKullanicilar.contains(danisman);
                            return FilterChip(
                              label: Text(danisman.displayName ?? 'İsimsiz'),
                              selected: isSelected,
                              onSelected: (bool selected) {
                                setDialogState(() {
                                  if (selected) {
                                    secilenKullanicilar.add(danisman);
                                  } else {
                                    secilenKullanicilar.remove(danisman);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        );
                      },
                    ),
                    const Divider(height: 24),
                    TextField(
                      controller: ilkMesajController,
                      decoration: const InputDecoration(labelText: 'İlk Mesajınız'),
                    ),
                  ],
                ),
              ),
              actions: [
                 TextButton(
                  child: const Text('İptal'),
                  onPressed: () => Navigator.of(dialogContext).pop(),
                ),
                FilledButton(
                  child: const Text('Başlat'),
                  onPressed: (secilenKullanicilar.isEmpty || ilkMesajController.text.isEmpty)
                      ? null
                      : () async {
                          final uyeIdleri = secilenKullanicilar.map((e) => e.uid).toList();
                          await mesajlasmaServisi.yeniKonusmaBaslat(uyeIdleri, ilkMesajController.text);
                          if(context.mounted) Navigator.of(dialogContext).pop();
                        },
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _KonusmaKarti extends StatelessWidget {
  final KonusmaModel konusma;
  const _KonusmaKarti({required this.konusma});

  @override
  Widget build(BuildContext context) {
    final currentUserUid = FirebaseAuth.instance.currentUser?.uid;
    // Mevcut kullanıcı dışındaki üyelerin ID'lerini al
    final digerUyeIdleri = konusma.uyeler.where((uid) => uid != currentUserUid).toList();
    final okunmamisSayisi = konusma.okunmamisSayilari[currentUserUid] ?? 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.people)),
        title: _DigerUyeIsimleri(uyeIdleri: digerUyeIdleri),
        subtitle: Text(
          konusma.sonMesaj,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(DateFormat.Hm().format(konusma.sonMesajTarihi.toDate())),
            if (okunmamisSayisi > 0) ...[
              const SizedBox(height: 4),
              Badge(
                label: Text(okunmamisSayisi.toString()),
              ),
            ]
          ],
        ),
        onTap: () {
          // TODO: Konuşma detay ekranına yönlendirme yapılacak (M-2B)
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => KonusmaDetayEkrani(konusma: konusma),
          ));
        },
      ),
    );
  }
}

// Konuşmadaki diğer üyelerin isimlerini getiren widget
class _DigerUyeIsimleri extends StatelessWidget {
  final List<String> uyeIdleri;
  const _DigerUyeIsimleri({required this.uyeIdleri});

  @override
  Widget build(BuildContext context) {
    final kullaniciServisi = KullaniciServisi();
    return FutureBuilder<List<KullaniciModel?>>(
      future: Future.wait(uyeIdleri.map((uid) => kullaniciServisi.getUserById(uid)).toList()),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Text('Yükleniyor...');
        }
        final katilimcilar = snapshot.data!.where((user) => user != null).map((user) => user!.displayName ?? 'Bilinmeyen').join(', ');
        return Text(
          katilimcilar.isEmpty ? 'Bilinmeyen Katılımcı' : katilimcilar,
          style: const TextStyle(fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
      },
    );
  }
} 