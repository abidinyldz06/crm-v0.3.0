import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:crm/models/dokuman_sablonu_model.dart';

class DokumanSablonuServisi {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> createSablon(DokumanSablonuModel sablon) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Kullanıcı girişi yapılmamış');
    
    await _db.collection('dokuman_sablonlari').add({
      ...sablon.toMap(),
      'olusturanId': user.uid,
      'olusturulmaTarihi': Timestamp.now(),
    });
  }

  Stream<List<DokumanSablonuModel>> getSablonlar() {
    return _db.collection('dokuman_sablonlari')
        .orderBy('olusturulmaTarihi', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DokumanSablonuModel.fromFirestore(doc))
            .toList());
  }

  Stream<List<DokumanSablonuModel>> getSablonlarByTur(SablonTuru tur) {
    return _db.collection('dokuman_sablonlari')
        .where('tur', isEqualTo: tur.name)
        .orderBy('ad')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DokumanSablonuModel.fromFirestore(doc))
            .toList());
  }

  Future<DokumanSablonuModel?> getSablonById(String id) async {
    final doc = await _db.collection('dokuman_sablonlari').doc(id).get();
    if (doc.exists) {
      return DokumanSablonuModel.fromFirestore(doc);
    }
    return null;
  }

  String dokumanOlustur(DokumanSablonuModel sablon, Map<String, String> veriler) {
    String dokuman = sablon.icerik;
    
    // Değişkenleri değerlerle değiştir
    veriler.forEach((key, value) {
      dokuman = dokuman.replaceAll('{{$key}}', value);
    });
    
    // Tarih değişkenini otomatik ekle
    final now = DateTime.now();
    dokuman = dokuman.replaceAll('{{tarih}}', '${now.day}/${now.month}/${now.year}');
    
    return dokuman;
  }

  Future<void> varsayilanSablonlariOlustur() async {
    // Varsayılan teklif şablonu
    final teklifSablonu = DokumanSablonuModel(
      id: '',
      ad: 'Standart Teklif Şablonu',
      tur: SablonTuru.teklif,
      icerik: '''
TEKLİF FORMU

Tarih: {{tarih}}

Sayın {{musteriAdi}},

{{basvuruTuru}} başvurunuz için teklifimiz aşağıdaki gibidir:

Hizmet Detayları:
{{hizmetDetaylari}}

Toplam Tutar: {{toplamTutar}} {{paraBirimi}}

Geçerlilik Tarihi: {{gecerlilikTarihi}}

Saygılarımızla,
{{danismanAdi}}
''',
      degiskenler: {
        'musteriAdi': 'Müşteri Adı',
        'basvuruTuru': 'Başvuru Türü',
        'hizmetDetaylari': 'Hizmet Detayları',
        'toplamTutar': 'Toplam Tutar',
        'paraBirimi': 'Para Birimi',
        'gecerlilikTarihi': 'Geçerlilik Tarihi',
        'danismanAdi': 'Danışman Adı',
      },
      olusturulmaTarihi: Timestamp.now(),
      olusturanId: _auth.currentUser?.uid ?? '',
    );

    // Varsayılan sözleşme şablonu
    final sozlesmeSablonu = DokumanSablonuModel(
      id: '',
      ad: 'Standart Hizmet Sözleşmesi',
      tur: SablonTuru.sozlesme,
      icerik: '''
HİZMET SÖZLEŞMESİ

Tarih: {{tarih}}

TARAFLAR:
Hizmet Veren: {{sirketAdi}}
Hizmet Alan: {{musteriAdi}}

KONU: {{basvuruTuru}} Danışmanlık Hizmeti

MADDE 1 - HİZMET KAPSAMI
{{hizmetKapsami}}

MADDE 2 - ÜCRET VE ÖDEME KOŞULLARI
Toplam Ücret: {{toplamTutar}} {{paraBirimi}}
Ödeme Şekli: {{odemeSekli}}

MADDE 3 - SÜRE
Başlangıç: {{baslangicTarihi}}
Bitiş: {{bitisTarihi}}

İşbu sözleşme iki nüsha olarak düzenlenmiş ve taraflarca imzalanmıştır.

HİZMET VEREN                    HİZMET ALAN
{{danismanAdi}}                 {{musteriAdi}}
''',
      degiskenler: {
        'sirketAdi': 'Şirket Adı',
        'musteriAdi': 'Müşteri Adı',
        'basvuruTuru': 'Başvuru Türü',
        'hizmetKapsami': 'Hizmet Kapsamı',
        'toplamTutar': 'Toplam Tutar',
        'paraBirimi': 'Para Birimi',
        'odemeSekli': 'Ödeme Şekli',
        'baslangicTarihi': 'Başlangıç Tarihi',
        'bitisTarihi': 'Bitiş Tarihi',
        'danismanAdi': 'Danışman Adı',
      },
      olusturulmaTarihi: Timestamp.now(),
      olusturanId: _auth.currentUser?.uid ?? '',
    );

    // Şablonları kaydet
    await createSablon(teklifSablonu);
    await createSablon(sozlesmeSablonu);
  }
} 