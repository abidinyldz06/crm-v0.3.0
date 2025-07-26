import 'package:crm/models/kurumsal_musteri_model.dart';
import 'package:crm/models/musteri_model.dart';
// import 'package:crm/screens/kurumsal_musteri_detay_ekrani.dart'; // Geçici olarak devre dışı
import 'package:crm/screens/musteri_detay.dart';
import 'package:crm/services/kurumsal_musteri_servisi.dart';
import 'package:crm/services/musteri_servisi.dart';
import 'package:crm/widgets/loading_states.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class MusteriListesi extends StatefulWidget {
  const MusteriListesi({super.key});

  @override
  State<MusteriListesi> createState() => _MusteriListesiState();
}

class _MusteriListesiState extends State<MusteriListesi> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _filterType = 'Tümü';
  final MusteriServisi _musteriServisi = MusteriServisi();
  final KurumsalMusteriServisi _kurumsalServisi = KurumsalMusteriServisi();
  
  final int _itemsPerPage = 20;
  int _currentPage = 0;
  List<dynamic> _allItems = [];
  List<dynamic> _displayedItems = [];
  bool _isLoading = false;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
        _currentPage = 0;
        _filterAndPaginate();
      });
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  void _loadMore() {
    if (!_isLoading && _hasMore) {
      setState(() {
        _currentPage++;
        _filterAndPaginate();
      });
    }
  }

  void _filterAndPaginate() {
    final filtered = _allItems.where((m) {
      bool matchesFilter = _filterType == 'Tümü' ||
        (_filterType == 'Bireysel' && m is MusteriModel) ||
        (_filterType == 'Kurumsal' && m is KurumsalMusteriModel);

      bool matchesSearch = false;
      if (m is MusteriModel) {
        matchesSearch = m.ad.toLowerCase().contains(_searchQuery) ||
          m.soyad.toLowerCase().contains(_searchQuery);
      } else if (m is KurumsalMusteriModel) {
        matchesSearch = m.sirketAdi.toLowerCase().contains(_searchQuery);
      }

      return matchesFilter && matchesSearch;
    }).toList();

    final startIndex = _currentPage * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;
    
    setState(() {
      if (_currentPage == 0) {
        _displayedItems = filtered.take(endIndex).toList();
      } else {
        _displayedItems.addAll(filtered.skip(startIndex).take(_itemsPerPage).toList());
      }
      _hasMore = endIndex < filtered.length;
    });
  }

  Future<void> _loadData({bool showLoading = true}) async {
    if (showLoading) setState(() => {}); // Eğer loading göstereceksen
    // Burada veri yükleme işlemleri, ama zaten stream kullanıyoruz, gerek olmayabilir
  }

  Stream<List<dynamic>> getCombinedMusteriler() {
    return Rx.zip2(
      _musteriServisi.getMusterilerStream(),
      _kurumsalServisi.getKurumsalMusterilerStream(),
      (bireysel, kurumsal) => [...bireysel, ...kurumsal],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Müşteriler'),
        actions: [
          DropdownButton<String>(
            value: _filterType,
            items: ['Tümü', 'Bireysel', 'Kurumsal'].map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
            onChanged: (value) => setState(() => _filterType = value ?? 'Tümü'),
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
                labelText: 'Müşteri Ara',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<dynamic>>(
              stream: getCombinedMusteriler(),
              builder: (context, snapshot) {
                // Error state with retry
                if (snapshot.hasError) {
                  return LoadingStates.errorState(
                    message: 'Müşteri verileri yüklenirken bir hata oluştu.\n${snapshot.error}',
                    onRetry: () => setState(() {}),
                  );
                }
                
                // Loading state with skeleton
                if (!snapshot.hasData) {
                  return LoadingStates.skeletonList(
                    itemCount: 8,
                    showAvatar: true,
                    showSubtitle: true,
                  );
                }

                // Empty state
                if (snapshot.data!.isEmpty) {
                  return LoadingStates.emptyState(
                    message: 'Henüz müşteri bulunmuyor.\nİlk müşterinizi eklemek için + butonuna tıklayın.',
                    icon: Icons.people_outline,
                    actionText: 'Müşteri Ekle',
                    onAction: () {
                      // Müşteri ekleme sayfasına yönlendir
                      Navigator.pushNamed(context, '/musteri_ekle');
                    },
                  );
                }

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    setState(() {
                      _allItems = snapshot.data!;
                      if (_displayedItems.isEmpty && _currentPage == 0) {
                        _filterAndPaginate();
                      }
                    });
                  }
                });

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: _displayedItems.length + (_hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _displayedItems.length) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    
                    final m = _displayedItems[index];
                    if (m is MusteriModel) {
                      return ListTile(
                        title: Text(m.adSoyad),
                        subtitle: Text(m.email),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _musteriServisi.softDeleteMusteri(m.id),
                        ),
                        onTap: () => Navigator.pushNamed(context, '/musteri_detay', arguments: m.id),
                      );
                    } else if (m is KurumsalMusteriModel) {
                      return ListTile(
                        title: Text(m.sirketAdi),
                        subtitle: Text(m.email ?? ''),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _kurumsalServisi.softDeleteKurumsalMusteri(m.id),
                        ),
                        onTap: () => Navigator.pushNamed(context, '/kurumsal_musteri_detay', arguments: m.id),
                      );
                    }
                    return SizedBox.shrink();
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => Navigator.pushNamed(context, '/musteri_ekle').then((_) => _loadData(showLoading: false)),
      ),
    );
  }
}

// Bireysel Müşteriler İçin Alt Widget
class _BireyselMusteriListesi extends StatefulWidget {
  const _BireyselMusteriListesi();

  @override
  State<_BireyselMusteriListesi> createState() => __BireyselMusteriListesiState();
}

class __BireyselMusteriListesiState extends State<_BireyselMusteriListesi> {
  final MusteriServisi _musteriServisi = MusteriServisi();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Bireysel Müşteri Adına Göre Ara',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => _searchController.clear(),
                    )
                  : null,
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<MusteriModel>>(
            stream: _musteriServisi.searchMusteri(_searchQuery),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('Bireysel müşteri bulunamadı.'));
              }
              final musteriler = snapshot.data!;
              return ListView.builder(
                itemCount: musteriler.length,
                itemBuilder: (context, index) {
                  final musteri = musteriler[index];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(musteri.ad.isNotEmpty ? musteri.ad[0] : '?'),
                      ),
                      title: Text(musteri.adSoyad, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(musteri.email),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => MusteriDetay(musteriId: musteri.id),
                      )),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// Kurumsal Müşteriler İçin Alt Widget
class _KurumsalMusteriListesi extends StatelessWidget {
  const _KurumsalMusteriListesi();

  @override
  Widget build(BuildContext context) {
    final KurumsalMusteriServisi kurumsalServisi = KurumsalMusteriServisi();
    // TODO: Kurumsal müşteri arama çubuğu eklenecek.
    return StreamBuilder<List<KurumsalMusteriModel>>(
      stream: kurumsalServisi.getKurumsalMusterilerStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Kurumsal müşteri bulunamadı.'));
        }
        final sirketler = snapshot.data!;
        return ListView.builder(
          itemCount: sirketler.length,
          itemBuilder: (context, index) {
            final sirket = sirketler[index];
            return Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.business)),
                title: Text(sirket.sirketAdi, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(sirket.email ?? 'E-posta yok'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const Center(child: Text('Kurumsal müşteri detayı yakında...')),
                  ));
                },
              ),
            );
          },
        );
      },
    );
  }
} 