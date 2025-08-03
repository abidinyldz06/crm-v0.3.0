import 'dart:io';
import 'package:crm/models/basvuru_model.dart';
import 'package:crm/models/kullanici_model.dart';
import 'package:crm/models/musteri_model.dart';
import 'package:crm/services/basvuru_servisi.dart';
import 'package:crm/services/kullanici_servisi.dart';
import 'package:crm/services/musteri_servisi.dart';
import 'package:crm/services/storage_servisi.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class BasvuruDetay extends StatefulWidget {
  final String basvuruId;

  const BasvuruDetay({super.key, required this.basvuruId});

  @override
  State<BasvuruDetay> createState() => _BasvuruDetayState();
}

class _BasvuruDetayState extends State<BasvuruDetay> {
  final BasvuruServisi _basvuruServisi = BasvuruServisi();
  final MusteriServisi _musteriServisi = MusteriServisi();
  final KullaniciServisi _kullaniciServisi = KullaniciServisi();
  final StorageServisi _storageServisi = StorageServisi();

  BasvuruModel? _basvuru;
  MusteriModel? _musteri;
  KullaniciModel? _atananDanisman;
  List<KullaniciModel> _danismanlar = [];
  KullaniciModel? _secilenDanisman;

  bool _isLoading = true;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData({bool showLoading = true}) async {
    if (showLoading && mounted) setState(() => _isLoading = true);
    
    final basvuru = await _basvuruServisi.getBasvuruById(widget.basvuruId);
    if (basvuru == null) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Başvuru bulunamadı.'), backgroundColor: Colors.red));
      }
      return;
    }
    
    final musteri = await _musteriServisi.getMusteriById(basvuru.musteriId);
    KullaniciModel? atananDanisman;
    if (basvuru.atananDanismanId != null) {
      atananDanisman = await _kullaniciServisi.getUserById(basvuru.atananDanismanId!);
    }
    final danismanlar = await _kullaniciServisi.getConsultants();
    
    if (mounted) {
      setState(() {
        _basvuru = basvuru;
        _musteri = musteri;
        _atananDanisman = atananDanisman;
        _secilenDanisman = atananDanisman;
        _danismanlar = danismanlar;
        _isLoading = false;
      });
    }
  }

  Future<void> _dosyaSecVeYukle() async {
    if (_basvuru == null || _musteri == null) return;

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
    );

    if (result != null) {
      final dosya = File(result.files.single.path!);
      final dosyaAdi = result.files.single.name;
      final dosyaBoyutu = await dosya.length();

      if (dosyaBoyutu > 25 * 1024 * 1024) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dosya boyutu 25MB\'den büyük olamaz.'), backgroundColor: Colors.red),
        );
        return;
      }

      setState(() => _isUploading = true);

      try {
        final Map<String, String>? dosyaBilgisi = await _storageServisi.dosyaYukle(
          dosya: dosya,
          dosyaAdi: dosyaAdi,
          basvuruId: _basvuru!.id,
          musteriId: _musteri!.id,
        );

        if (dosyaBilgisi != null) {
          await _basvuruServisi.dosyaEkle(widget.basvuruId, dosyaBilgisi);
          await _loadData(showLoading: false); // Sayfayı yeniden yükle
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Dosya başarıyla yüklendi.'), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Dosya yüklenirken hata oluştu: $e'), backgroundColor: Colors.red),
        );
      } finally {
        if (mounted) setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _danismanAta() async {
    if (_secilenDanisman == null || _basvuru == null) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lütfen bir danışman seçin.')));
      return;
    }
    try {
      await _basvuruServisi.danismanAta(_basvuru!.id, _secilenDanisman!.uid);
      await _loadData(showLoading: false); // Sayfayı yeniden yükle
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Danışman başarıyla atandı!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _durumGuncelle(BasvuruDurumu yeniDurum) async {
    if (_basvuru == null) return;
    
    try {
      await _basvuruServisi.durumGuncelle(_basvuru!.id, yeniDurum);
      await _loadData(showLoading: false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Başvuru durumu "${yeniDurum.displayName}" olarak güncellendi!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLoading ? 'Yükleniyor...' : _basvuru?.basvuruTuru ?? 'Başvuru Detayı'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _basvuru == null || _musteri == null
              ? const Center(child: Text('Başvuru bilgileri yüklenemedi.'))
              : RefreshIndicator(
                  onRefresh: () => _loadData(),
                  child: ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      // Müşteri Bilgi Kartı
                      Card(
                        elevation: 0,
                        color: Theme.of(context).colorScheme.surfaceVariant.withValues(alpha: 0.5),
                        child: ListTile(
                           leading: const Icon(Icons.person_outline),
                           title: Text(_musteri!.adSoyad, style: Theme.of(context).textTheme.titleLarge),
                           subtitle: Text(_musteri!.email),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDanismanAtamaKarti(context),
                      const SizedBox(height: 16),
                      _buildDurumYonetimiKarti(context), // Durum Yönetimi Kartı Eklendi
                      const SizedBox(height: 16),
                      _buildDosyaYonetimiKarti(context),
                    ],
                  ),
                ),
    );
  }

  // YENİ WIDGET: Durum Yönetimi Kartı
  Widget _buildDurumYonetimiKarti(BuildContext context) {
    if (_basvuru == null) return const SizedBox.shrink();

    // TODO: Rol kontrolü eklenerek sadece admin'in değiştirmesi sağlanacak.
    final bool canChangeStatus = true; 

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Başvuru Durumu:', style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButton<BasvuruDurumu>(
              value: _basvuru!.durum,
              items: BasvuruDurumu.values.map((BasvuruDurumu durum) {
                return DropdownMenuItem<BasvuruDurumu>(
                  value: durum,
                  child: Text(durum.displayName),
                );
              }).toList(),
              onChanged: canChangeStatus 
                  ? (BasvuruDurumu? yeniDurum) {
                      if (yeniDurum != null) {
                        _basvuruServisi.updateBasvuruDurumu(widget.basvuruId, yeniDurum).then((_) {
                           ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Durum güncellendi!'), backgroundColor: Colors.green),
                          );
                          _loadData(showLoading: false); // Veriyi yeniden yükle
                        });
                      }
                    }
                  : null, // Değiştirme yetkisi yoksa pasif yap
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDosyaYonetimiKarti(BuildContext context) {
    final dosyalar = _basvuru?.dosyalar ?? [];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Başvuru Dosyaları', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            dosyalar.isEmpty
                ? const Center(child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: Text('Henüz yüklenmiş dosya yok.'),
                ))
                : Column(
                    children: dosyalar.map((dosya) {
                      final dosyaMap = dosya as Map<String, dynamic>;
                      final String dosyaAdi = dosyaMap['name'] ?? 'İsimsiz Dosya';
                      final String dosyaUrl = dosyaMap['url'] ?? '';

                      return ListTile(
                        leading: const Icon(Icons.insert_drive_file_outlined),
                        title: Text(dosyaAdi, overflow: TextOverflow.ellipsis),
                        trailing: const Icon(Icons.open_in_new),
                        onTap: () async {
                           if (dosyaUrl.isNotEmpty) {
                              final uri = Uri.parse(dosyaUrl);
                              if (await canLaunchUrl(uri)) {
                                 await launchUrl(uri, mode: LaunchMode.externalApplication);
                              }
                           }
                        },
                      );
                    }).toList(),
                  ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: _isUploading
                  ? const Center(child: CircularProgressIndicator())
                  : FilledButton.icon(
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Dosya Yükle'),
                      onPressed: _dosyaSecVeYukle,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDanismanAtamaKarti(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Danışman Ata', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            if (_atananDanisman != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text('Mevcut Danışman: ${_atananDanisman!.displayName}', style: const TextStyle(fontStyle: FontStyle.italic)),
              ),
            DropdownButtonFormField<KullaniciModel>(
              value: _danismanlar.any((d) => d.uid == _secilenDanisman?.uid) ? _secilenDanisman : null,
              items: _danismanlar.map((danisman) {
                return DropdownMenuItem<KullaniciModel>(
                  value: danisman,
                  child: Text(danisman.displayName ?? 'İsimsiz'),
                );
              }).toList(),
              onChanged: (KullaniciModel? newValue) {
                setState(() {
                  _secilenDanisman = newValue;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Danışman Seçin',
                border: OutlineInputBorder(),
              ),
              isExpanded: true,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_secilenDanisman != null && _secilenDanisman?.uid != _atananDanisman?.uid) ? _danismanAta : null,
                child: const Text('Danışmanı Güncelle'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
