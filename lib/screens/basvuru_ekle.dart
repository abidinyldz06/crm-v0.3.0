import 'package:crm/models/musteri_model.dart';
import 'package:crm/services/basvuru_servisi.dart';
import 'package:flutter/material.dart';

class BasvuruEkle extends StatefulWidget {
  final MusteriModel musteri;
  const BasvuruEkle({super.key, required this.musteri});

  @override
  State<BasvuruEkle> createState() => _BasvuruEkleState();
}

class _BasvuruEkleState extends State<BasvuruEkle> {
  final _formKey = GlobalKey<FormState>();
  final _basvuruTuruController = TextEditingController();
  final _basvuruServisi = BasvuruServisi();
  bool _isSaving = false;

  @override
  void dispose() {
    _basvuruTuruController.dispose();
    super.dispose();
  }

  Future<void> _kaydet() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      try {
        await _basvuruServisi.createBasvuru(
          musteriId: widget.musteri.id,
          basvuruTuru: _basvuruTuruController.text.trim(),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Başvuru başarıyla oluşturuldu!'), backgroundColor: Colors.green),
          );
          Navigator.of(context).pop(); // Go back to the previous screen
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
      appBar: AppBar(
        title: Text('${widget.musteri.ad} için Yeni Başvuru'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _basvuruTuruController,
                decoration: const InputDecoration(
                  labelText: 'Başvuru Türü (Örn: Turistik Vize)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Başvuru türü zorunludur.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSaving ? null : _kaydet,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Başvuruyu Kaydet', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 