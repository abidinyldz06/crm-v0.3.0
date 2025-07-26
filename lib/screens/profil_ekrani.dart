import 'package:crm/models/kullanici_model.dart';
import 'package:crm/services/auth_service.dart';
import 'package:crm/services/kullanici_servisi.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilEkrani extends StatefulWidget {
  const ProfilEkrani({super.key});

  @override
  State<ProfilEkrani> createState() => _ProfilEkraniState();
}

class _ProfilEkraniState extends State<ProfilEkrani> {
  final _formKey = GlobalKey<FormState>();
  final _adController = TextEditingController();
  final _kullaniciServisi = KullaniciServisi();
  final _auth = FirebaseAuth.instance;
  
  bool _isLoading = true;
  bool _isSaving = false;
  KullaniciModel? _mevcutKullanici;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    final user = await _kullaniciServisi.mevcutKullaniciBilgileri();
    if (user != null && mounted) {
      setState(() {
        _mevcutKullanici = user;
        _adController.text = user.displayName ?? '';
        _isLoading = false;
      });
    } else if (mounted) {
       setState(() => _isLoading = false);
    }
  }

  Future<void> _guncelle() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      
      final displayName = _adController.text.trim();
      final currentUser = _auth.currentUser;

      if (currentUser == null) return;

      try {
        // Firebase Auth profilini güncelle (görünen isim)
        await currentUser.updateDisplayName(displayName);

        // Firestore'daki kullanıcı belgesini güncelle
        await _kullaniciServisi.updateUserData(currentUser.uid, {'displayName': displayName});

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profil başarıyla güncellendi!'), backgroundColor: Colors.green),
          );
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
      appBar: AppBar(title: const Text('Profilim')),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Email: ${_mevcutKullanici?.email ?? '...'}', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _adController,
                        decoration: const InputDecoration(labelText: 'Görünecek İsim'),
                        validator: (value) => (value == null || value.isEmpty) ? 'İsim alanı zorunludur' : null,
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.save),
                        label: const Text('Bilgileri Kaydet'),
                        onPressed: _isSaving ? null : _guncelle,
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
    );
  }
} 