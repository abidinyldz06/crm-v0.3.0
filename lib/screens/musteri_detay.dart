import 'package:flutter/material.dart';
import 'package:crm/models/musteri_model.dart';
import 'package:crm/services/musteri_servisi.dart';
import 'package:crm/screens/musteri_guncelle.dart';
import 'package:crm/screens/basvuru_ekle.dart';

class MusteriDetay extends StatefulWidget {
  final String musteriId;
  
  const MusteriDetay({super.key, required this.musteriId});

  @override
  State<MusteriDetay> createState() => _MusteriDetayState();
}

class _MusteriDetayState extends State<MusteriDetay> {
  final MusteriServisi _musteriServisi = MusteriServisi();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Müşteri Detayları'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final musteri = await _musteriServisi.getMusteriById(widget.musteriId);
              if (musteri != null && mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MusteriGuncelle(musteri: musteri),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<MusteriModel?>(
        stream: _musteriServisi.getMusteriByIdStream(widget.musteriId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Hata: ${snapshot.error}'),
            );
          }

          final musteri = snapshot.data;
          if (musteri == null) {
            return const Center(
              child: Text('Müşteri bulunamadı'),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kişisel Bilgiler',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow('Ad Soyad', musteri.adSoyad),
                      _buildInfoRow('E-posta', musteri.email),
                      _buildInfoRow('Telefon', musteri.telefon),
                      if (musteri.tcNo != null) _buildInfoRow('TC Kimlik No', musteri.tcNo!),
                      if (musteri.pasaportNo != null) _buildInfoRow('Pasaport No', musteri.pasaportNo!),
                      if (musteri.dogumTarihi != null) 
                        _buildInfoRow('Doğum Tarihi', '${musteri.dogumTarihi!.day}/${musteri.dogumTarihi!.month}/${musteri.dogumTarihi!.year}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'İletişim Bilgileri',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow('Adres', musteri.adres),
                      _buildInfoRow('Başvuru Ülkesi', musteri.basvuruUlkesi),
                      if (musteri.notlar != null) _buildInfoRow('Notlar', musteri.notlar!),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.assignment_add),
                      label: const Text('Yeni Başvuru'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BasvuruEkle(musteri: musteri),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.edit),
                      label: const Text('Düzenle'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MusteriGuncelle(musteri: musteri),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value.isEmpty ? 'Belirtilmemiş' : value),
          ),
        ],
      ),
    );
  }
}