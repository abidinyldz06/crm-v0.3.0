import 'package:crm/models/musteri_model.dart';
import 'package:crm/services/randevu_servisi.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RandevuEkleEkrani extends StatefulWidget {
  final MusteriModel musteri;

  const RandevuEkleEkrani({super.key, required this.musteri});

  @override
  State<RandevuEkleEkrani> createState() => _RandevuEkleEkraniState();
}

class _RandevuEkleEkraniState extends State<RandevuEkleEkrani> {
  final _formKey = GlobalKey<FormState>();
  final _baslikController = TextEditingController();
  final _notController = TextEditingController();
  DateTime? _secilenTarih;
  TimeOfDay? _secilenZaman;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _secilenTarih = DateTime.now();
    _secilenZaman = TimeOfDay.fromDateTime(DateTime.now());
  }

  Future<void> _tarihSec(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _secilenTarih ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _secilenTarih) {
      setState(() {
        _secilenTarih = picked;
      });
    }
  }

  Future<void> _zamanSec(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _secilenZaman ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _secilenZaman) {
      setState(() {
        _secilenZaman = picked;
      });
    }
  }

  Future<void> _randevuKaydet() async {
    if (_formKey.currentState!.validate() && _secilenTarih != null && _secilenZaman != null) {
      setState(() => _isSaving = true);
      
      final randevuZamani = DateTime(
        _secilenTarih!.year,
        _secilenTarih!.month,
        _secilenTarih!.day,
        _secilenZaman!.hour,
        _secilenZaman!.minute,
      );

      final randevuData = {
        'musteriId': widget.musteri.id,
        'baslik': _baslikController.text.trim(),
        'not': _notController.text.trim(),
        'tarih': randevuZamani,
      };

      try {
        await RandevuServisi().addRandevu(randevuData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Randevu başarıyla eklendi!'), backgroundColor: Colors.green),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Randevu eklenirken hata oluştu: $e'), backgroundColor: Colors.red),
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
      appBar: AppBar(title: Text('${widget.musteri.adSoyad} için Yeni Randevu')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _baslikController,
                decoration: const InputDecoration(labelText: 'Randevu Başlığı'),
                validator: (value) => (value == null || value.isEmpty) ? 'Başlık zorunludur' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notController,
                decoration: const InputDecoration(labelText: 'Notlar'),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Tarih: ${DateFormat.yMd('tr_TR').format(_secilenTarih!)}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: const Text('Değiştir'),
                    onPressed: () => _tarihSec(context),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Zaman: ${_secilenZaman!.format(context)}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.access_time),
                    label: const Text('Değiştir'),
                    onPressed: () => _zamanSec(context),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Randevuyu Kaydet'),
                onPressed: _isSaving ? null : _randevuKaydet,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 