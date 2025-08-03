import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageServisi {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<Map<String, String>?> dosyaYukle({
    required File dosya,
    required String dosyaAdi,
    required String musteriId,
    required String basvuruId,
  }) async {
    try {
      final ref = _storage.ref('basvuru_dosyalari/$musteriId/$basvuruId/$dosyaAdi');
      final uploadTask = ref.putFile(dosya);
      final snapshot = await uploadTask.whenComplete(() => {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return {'name': dosyaAdi, 'url': downloadUrl};
    } catch (e) {
      print("Dosya yükleme hatası: $e");
      return null;
    }
  }

  // Dosya silme fonksiyonu
  Future<bool> dosyaSil({
    required String dosyaUrl,
    required String musteriId,
    required String basvuruId,
    required String dosyaAdi,
  }) async {
    try {
      // URL'den dosya referansını al
      final ref = _storage.refFromURL(dosyaUrl);
      await ref.delete();
      return true;
    } catch (e) {
      print("Dosya silme hatası: $e");
      // Alternatif yol: Path ile silmeyi dene
      try {
        final ref = _storage.ref('basvuru_dosyalari/$musteriId/$basvuruId/$dosyaAdi');
        await ref.delete();
        return true;
      } catch (e2) {
        print("Alternatif dosya silme hatası: $e2");
        return false;
      }
    }
  }

  // Birden fazla dosyayı sil
  Future<List<bool>> cokluDosyaSil({
    required List<Map<String, String>> dosyalar,
    required String musteriId,
    required String basvuruId,
  }) async {
    List<bool> sonuclar = [];
    
    for (var dosya in dosyalar) {
      final sonuc = await dosyaSil(
        dosyaUrl: dosya['url'] ?? '',
        musteriId: musteriId,
        basvuruId: basvuruId,
        dosyaAdi: dosya['name'] ?? '',
      );
      sonuclar.add(sonuc);
    }
    
    return sonuclar;
  }

  // Başvuruya ait tüm dosyaları sil
  Future<bool> basvuruDosyalariniSil({
    required String musteriId,
    required String basvuruId,
  }) async {
    try {
      final ref = _storage.ref('basvuru_dosyalari/$musteriId/$basvuruId');
      final listResult = await ref.listAll();
      
      // Tüm dosyaları sil
      for (var item in listResult.items) {
        await item.delete();
      }
      
      return true;
    } catch (e) {
      print("Başvuru dosyaları silme hatası: $e");
      return false;
    }
  }

  // Müşteriye ait tüm dosyaları sil
  Future<bool> musteriDosyalariniSil({required String musteriId}) async {
    try {
      final ref = _storage.ref('basvuru_dosyalari/$musteriId');
      final listResult = await ref.listAll();
      
      // Tüm alt klasörleri ve dosyaları sil
      for (var prefix in listResult.prefixes) {
        final subListResult = await prefix.listAll();
        for (var item in subListResult.items) {
          await item.delete();
        }
      }
      
      // Ana klasördeki dosyaları sil
      for (var item in listResult.items) {
        await item.delete();
      }
      
      return true;
    } catch (e) {
      print("Müşteri dosyaları silme hatası: $e");
      return false;
    }
  }

  // Dosya boyutunu kontrol et
  Future<int?> dosyaBoyutuGetir(String dosyaUrl) async {
    try {
      final ref = _storage.refFromURL(dosyaUrl);
      final metadata = await ref.getMetadata();
      return metadata.size;
    } catch (e) {
      print("Dosya boyutu alma hatası: $e");
      return null;
    }
  }

  // Dosya metadata'sını getir
  Future<FullMetadata?> dosyaMetadataGetir(String dosyaUrl) async {
    try {
      final ref = _storage.refFromURL(dosyaUrl);
      return await ref.getMetadata();
    } catch (e) {
      print("Dosya metadata alma hatası: $e");
      return null;
    }
  }
}
