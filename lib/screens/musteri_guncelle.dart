import 'package:crm/models/kurumsal_musteri_model.dart';
import 'package:crm/models/musteri_model.dart';
import 'package:crm/services/kurumsal_musteri_servisi.dart';
import 'package:crm/services/musteri_servisi.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MusteriGuncelle extends StatefulWidget {
  final MusteriModel musteri;
  const MusteriGuncelle({super.key, required this.musteri});

  @override
  State<MusteriGuncelle> createState() => _MusteriGuncelleState();
}

class _MusteriGuncelleState extends State<MusteriGuncelle> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _adController;
  late TextEditingController _soyadController;
  late TextEditingController _ulkeController;
  late TextEditingController _telefonController;
  late TextEditingController _emailController;
  late TextEditingController _adresController;
  late TextEditingController _notlarController;
  late TextEditingController _tcNoController;
  late TextEditingController _pasaportNoController;
  late TextEditingController _dogumTarihiController;

  final _musteriServisi = MusteriServisi();
  final _kurumsalMusteriServisi = KurumsalMusteriServisi();
  bool _isSaving = false;
  String? _seciliKurumsalMusteriId;
  List<KurumsalMusteriModel> _kurumsalMusteriler = [];
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _adController = TextEditingController(text: widget.musteri.ad);
    _soyadController = TextEditingController(text: widget.musteri.soyad);
    _ulkeController = TextEditingController(text: widget.musteri.basvuruUlkesi);
    _telefonController = TextEditingController(text: widget.musteri.telefon);
    _emailController = TextEditingController(text: widget.musteri.email);
    _adresController = TextEditingController(text: widget.musteri.adres);
    _notlarController = TextEditingController(text: widget.musteri.notlar ?? '');
    _tcNoController = TextEditingController(text: widget.musteri.tcNo ?? '');
    _pasaportNoController = TextEditingController(text: widget.musteri.pasaportNo ?? '');
    _selectedDate = widget.musteri.dogumTarihi;
    _dogumTarihiController = TextEditingController(
      text: _selectedDate != null 
        ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}' 
        : ''
    );
    _seciliKurumsalMusteriId = widget.musteri.kurumsalMusteriId;
    _loadKurumsalMusteriler();
  }

  Future<void> _loadKurumsalMusteriler() async {
    final musteriler = await _kurumsalMusteriServisi.getKurumsalMusterilerStream().first;
    if (mounted) {
      setState(() {
        _kurumsalMusteriler = musteriler;
      });
    }
  }

  @override
  void dispose() {
    _adController.dispose();
    _soyadController.dispose();
    _ulkeController.dispose();
    _telefonController.dispose();
    _emailController.dispose();
    _adresController.dispose();
    _notlarController.dispose();
    _tcNoController.dispose();
    _pasaportNoController.dispose();
    _dogumTarihiController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dogumTarihiController.text = '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  Future<void> _guncelle() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);

      final musteriData = {
        'ad': _adController.text.trim(),
        'soyad': _soyadController.text.trim(),
        'basvuruUlkesi': _ulkeController.text.trim(),
        'telefon': _telefonController.text.trim(),
        'email': _emailController.text.trim(),
        'adres': _adresController.text.trim(),
        'notlar': _notlarController.text.trim().isEmpty ? null : _notlarController.text.trim(),
        'kurumsalMusteriId': _seciliKurumsalMusteriId,
        'tcNo': _tcNoController.text.trim().isEmpty ? null : _tcNoController.text.trim(),
        'pasaportNo': _pasaportNoController.text.trim().isEmpty ? null : _pasaportNoController.text.trim(),
        'dogumTarihi': _selectedDate != null ? Timestamp.fromDate(_selectedDate!) : null,
        'guncellemeTarihi': Timestamp.fromDate(DateTime.now()),
      };

      try {
        await _musteriServisi.updateMusteri(widget.musteri.id, musteriData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Müşteri başarıyla güncellendi!'), backgroundColor: Colors.green),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
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
      appBar: AppBar(title: const Text('Müşteri Bilgilerini Güncelle')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _adController,
                decoration: const InputDecoration(labelText: 'Ad'),
                validator: (value) => (value == null || value.isEmpty) ? 'Ad alanı zorunludur' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _soyadController,
                decoration: const InputDecoration(labelText: 'Soyad'),
                validator: (value) => (value == null || value.isEmpty) ? 'Soyad alanı zorunludur' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _seciliKurumsalMusteriId,
                hint: const Text('Bağlı Olduğu Kurumu Seçin (Opsiyonel)'),
                isExpanded: true,
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Kurumdan Ayır', style: TextStyle(fontStyle: FontStyle.italic)),
                  ),
                  ..._kurumsalMusteriler.map((KurumsalMusteriModel musteri) {
                    return DropdownMenuItem<String>(
                      value: musteri.id,
                      child: Text(musteri.sirketAdi),
                    );
                  }),
                ],
                onChanged: (String? newValue) {
                  setState(() {
                    _seciliKurumsalMusteriId = newValue;
                  });
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ulkeController,
                decoration: const InputDecoration(labelText: 'Başvuru Yapılacak Ülke'),
                 validator: (value) => (value == null || value.isEmpty) ? 'Ülke alanı zorunludur' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'E-posta'),
                validator: (value) => (value == null || value.isEmpty) ? 'E-posta alanı zorunludur' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _telefonController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Telefon'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _tcNoController,
                      decoration: const InputDecoration(labelText: 'TC Kimlik No'),
                      keyboardType: TextInputType.number,
                      maxLength: 11,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _pasaportNoController,
                      decoration: const InputDecoration(labelText: 'Pasaport No'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dogumTarihiController,
                decoration: InputDecoration(
                  labelText: 'Doğum Tarihi',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: _selectDate,
                  ),
                ),
                readOnly: true,
                onTap: _selectDate,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _adresController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Adres'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notlarController,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Notlar'),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.save_as_outlined),
                onPressed: _isSaving ? null : _guncelle,
                label: _isSaving
                    ? const CircularProgressIndicator(strokeWidth: 2)
                    : const Text('Bilgileri Güncelle'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 