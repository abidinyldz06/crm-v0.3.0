import 'package:crm/models/basvuru_model.dart';
import 'package:crm/models/kullanici_model.dart';
import 'package:crm/services/auth_service.dart';
import 'package:crm/services/basvuru_servisi.dart';
import 'package:flutter/material.dart';
import 'package:crm/generated/l10n/app_localizations.dart';

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

  final List<String> _statusOrder = const ['Tümü', 'Yeni', 'İşlemde', 'Tamamlandı', 'İptal'];
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
        title: Text(_currentUser?.isAdmin == true ? AppLocalizations.of(context)!.allApplicationsTitle : AppLocalizations.of(context)!.myApplicationsTitle),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Wrap(
              spacing: 6,
              children: _statusOrder.map((s) {
                final selected = _filterStatus == s;
                String localized;
                switch (s) {
                  case 'Yeni':
                    localized = AppLocalizations.of(context)!.statusNew;
                    break;
                  case 'İşlemde':
                    localized = AppLocalizations.of(context)!.statusInProgress;
                    break;
                  case 'Tamamlandı':
                    localized = AppLocalizations.of(context)!.statusCompleted;
                    break;
                  case 'İptal':
                    localized = AppLocalizations.of(context)!.statusCancelled;
                    break;
                  default:
                    localized = AppLocalizations.of(context)!.statusAll;
                }
                return ChoiceChip(
                  label: Text(localized),
                  selected: selected,
                  onSelected: (_) => setState(() => _filterStatus = s),
                  selectedColor: Colors.blue.shade100,
                  labelStyle: TextStyle(color: selected ? Colors.blue.shade900 : Colors.black87),
                );
              }).toList(),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.searchApplicationsHint,
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: _basvurularStream == null
                ? const Center(child: CircularProgressIndicator())
                : StreamBuilder<List<BasvuruModel>>(
                    stream: _basvurularStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('${AppLocalizations.of(context)!.help}: ${snapshot.error}'));
                      }
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final basvurular = snapshot.data!;
                      final filtered = basvurular.where((b) {
                        final matchesFilter =
                            _filterStatus == 'Tümü' || b.durum.displayName == _filterStatus;
                        final matchesSearch =
                            b.musteriId.toLowerCase().contains(_searchQuery) ||
                            b.id.toLowerCase().contains(_searchQuery);
                        return matchesFilter && matchesSearch;
                      }).toList();

                      if (filtered.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.folder_off, size: 64, color: Colors.grey),
                              const SizedBox(height: 16),
                              Text(
                                _currentUser?.isAdmin == true
                                    ? AppLocalizations.of(context)!.noApplicationsAdmin
                                    : AppLocalizations.of(context)!.noApplicationsConsultant,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final b = filtered[index];
                          return Card(
                            child: ListTile(
                              leading: _statusLeading(b.durum),
                              title: Text(b.basvuruTuru, style: const TextStyle(fontWeight: FontWeight.w600)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      const Icon(Icons.badge, size: 14, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text('${AppLocalizations.of(context)!.applicationId}: ${b.id}', style: TextStyle(color: Colors.grey[700])),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.person_outline, size: 14, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text('${AppLocalizations.of(context)!.customer}: ${b.musteriId}',
                                          style: TextStyle(color: Colors.grey[700])),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.info_outline, size: 14, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text('${AppLocalizations.of(context)!.status}: ${b.durum.displayName}',
                                          style: TextStyle(color: Colors.grey[700])),
                                    ],
                                  ),
                                  if (_currentUser?.isAdmin == true && b.atananDanismanId != null)
                                    Row(
                                      children: [
                                        const Icon(Icons.assignment_ind, size: 14, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text('${AppLocalizations.of(context)!.consultant}: ${b.atananDanismanId}',
                                            style: TextStyle(color: Colors.grey[700])),
                                      ],
                                    ),
                                ],
                              ),
                              trailing: PopupMenuButton<String>(
                                onSelected: (v) {
                                  // Gelecekte durum değişikliği/aksiyonlar buradan yönetilebilir
                                },
                                itemBuilder: (context) => const [
                                  PopupMenuItem(value: 'open', child: ListTile(leading: Icon(Icons.open_in_new), title: Text('Aç'))),
                                  PopupMenuItem(value: 'assign', child: ListTile(leading: Icon(Icons.person_add_alt), title: Text('Ata'))),
                                ],
                              ),
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

  Widget _statusLeading(BasvuruDurumu durum) {
    return CircleAvatar(
      backgroundColor: _getStatusColor(durum),
      child: Icon(_getStatusIcon(durum), color: Colors.white, size: 20),
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
