import 'package:crm/models/basvuru_model.dart';
import 'package:crm/models/kullanici_model.dart';
import 'package:crm/services/auth_service.dart';
import 'package:crm/services/basvuru_servisi.dart';
import 'package:crm/widgets/basvuru_list_tile.dart';
import 'package:flutter/material.dart';

class BasvuruListesi extends StatefulWidget {
  const BasvuruListesi({super.key});

  @override
  State<BasvuruListesi> createState() => _BasvuruListesiState();
}

class _BasvuruListesiState extends State<BasvuruListesi> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _filterStatus = 'Tümü';
  final BasvuruServisi _basvuruServisi = BasvuruServisi();
  final AuthService _authService = AuthService();
  
  Stream<List<BasvuruModel>>? _basvurularStream;
  KullaniciModel? _currentUser;

  @override
  void initState() {
    super.initState();
    // Arama dinleyicisini ekle
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
    _initializeUserAndStream();
  }

  Future<void> _initializeUserAndStream() async {
    try {
      final user = await _authService.currentUserData();
      if (mounted) {
        setState(() {
          _currentUser = user;
          _basvurularStream = _getStreamBasedOnRole(user);
        });
      }
    } catch (e) {
      print('Kullanıcı bilgisi alınırken hata: $e');
      if (mounted) {
        setState(() {
          _basvurularStream = _basvuruServisi.getTumBasvurularStream();
        });
      }
    }
  }

  Stream<List<BasvuruModel>> _getStreamBasedOnRole(KullaniciModel? user) {
    if (user == null) {
      return _basvuruServisi.getTumBasvurularStream();
    }
    
    // Admin tüm başvuruları görebilir
    if (user.isAdmin) {
      return _basvuruServisi.getTumBasvurularStream();
    }
    
    // Danışman sadece kendine atanan başvuruları görebilir
    return _basvuruServisi.getDanismaninBasvurulariStream(user.uid);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentUser?.isAdmin == true ? 'Tüm Başvurular' : 'Başvurularım'),
        actions: [
          DropdownButton<String>(
            value: _filterStatus,
            items: ['Tümü', 'Yeni', 'İşlemde', 'Tamamlandı', 'İptal'].map((status) => DropdownMenuItem(value: status, child: Text(status))).toList(),
            onChanged: (value) => setState(() => _filterStatus = value ?? 'Tümü'),
          ),
          SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Başvuru Ara',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: _basvurularStream == null 
              ? const Center(child: CircularProgressIndicator())
              : StreamBuilder<List<BasvuruModel>>(
                stream: _basvurularStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) return Center(child: Text('Hata: ${snapshot.error}'));
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

                final basvurular = snapshot.data!;
                final filtered = basvurular.where((b) {
                  bool matchesFilter = _filterStatus == 'Tümü' || b.durum.displayName == _filterStatus;
                  bool matchesSearch = b.musteriId.toLowerCase().contains(_searchQuery) ||
                    b.id.toLowerCase().contains(_searchQuery);
                  return matchesFilter && matchesSearch;
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.folder_off, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          _currentUser?.isAdmin == true 
                            ? 'Henüz başvuru bulunmuyor.'
                            : 'Size atanmış başvuru bulunmuyor.',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final b = filtered[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getStatusColor(b.durum),
                          child: Icon(
                            _getStatusIcon(b.durum),
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        title: Text(b.basvuruTuru),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Müşteri ID: ${b.musteriId}'),
                            Text('Durum: ${b.durum.displayName}'),
                            if (_currentUser?.isAdmin == true && b.atananDanismanId != null)
                              Text('Danışman: ${b.atananDanismanId}', 
                                style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                          ],
                        ),
                        trailing: Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () => Navigator.pushNamed(context, '/basvuru_detay', arguments: b.id),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(BasvuruDurumu durum) {
    switch (durum) {
      case BasvuruDurumu.yeni:
        return Colors.blue;
      case BasvuruDurumu.islemde:
        return Colors.orange;
      case BasvuruDurumu.tamamlandi:
        return Colors.green;
      case BasvuruDurumu.iptal:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(BasvuruDurumu durum) {
    switch (durum) {
      case BasvuruDurumu.yeni:
        return Icons.new_releases;
      case BasvuruDurumu.islemde:
        return Icons.hourglass_empty;
      case BasvuruDurumu.tamamlandi:
        return Icons.check_circle;
      case BasvuruDurumu.iptal:
        return Icons.cancel;
    }
  }
} 