import 'package:crm/services/kurumsal_musteri_servisi.dart';
import 'package:flutter/material.dart';

class KurumsalMusteriEkle extends StatefulWidget {
  const KurumsalMusteriEkle({super.key});

  @override
  State<KurumsalMusteriEkle> createState() => _KurumsalMusteriEkleState();
}

class _KurumsalMusteriEkleState extends State<KurumsalMusteriEkle> {
  final _formKey = GlobalKey<FormState>();
  final _sirketAdiController = TextEditingController();
  final _vergiNoController = TextEditingController();
  final _telefonController = TextEditingController();
  final _emailController = TextEditingController();
  final _adresController = TextEditingController();
  final _notlarController = TextEditingController();
  
  final _kurumsalMusteriServisi = KurumsalMusteriServisi();
  bool _isSaving = false;

  @override
  void dispose() {
    _sirketAdiController.dispose();
    _vergiNoController.dispose();
    _telefonController.dispose();
    _emailController.dispose();
    _adresController.dispose();
    _notlarController.dispose();
    super.dispose();
  }

  Future<void> _kaydet() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      
      final musteriData = {
        'sirketAdi': _sirketAdiController.text.trim(),
        'vergiNo': _vergiNoController.text.trim(),
        'telefon': _telefonController.text.trim(),
        'email': _emailController.text.trim(),
        'adres': _adresController.text.trim(),
        'notlar': _notlarController.text.trim(),
        'isDeleted': false,
      };

      try {
        await _kurumsalMusteriServisi.addKurumsalMusteri(musteriData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Kurumsal müşteri başarıyla eklendi!'), backgroundColor: Colors.green),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          print("KURUMSAL MÜŞTERİ EKLEME HATASI: $e"); // Hata ayıklama için eklendi
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isSaving = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yeni Kurumsal Müşteri Ekle')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _sirketAdiController,
                decoration: const InputDecoration(labelText: 'Şirket Adı'),
                validator: (value) => (value == null || value.isEmpty) ? 'Şirket adı zorunludur' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _vergiNoController,
                decoration: const InputDecoration(labelText: 'Vergi Numarası'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'E-posta'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _telefonController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Telefon'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _adresController,
                decoration: const InputDecoration(labelText: 'Adres'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notlarController,
                decoration: const InputDecoration(labelText: 'Notlar'),
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Müşteriyi Kaydet'),
                onPressed: _isSaving ? null : _kaydet,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 