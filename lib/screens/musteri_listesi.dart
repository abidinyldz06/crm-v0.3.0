import 'package:crm/models/kurumsal_musteri_model.dart';
import 'package:crm/models/musteri_model.dart';
import 'package:crm/routes/route_names.dart';
import 'package:crm/screens/musteri_detay.dart';
import 'package:crm/services/kurumsal_musteri_servisi.dart';
import 'package:crm/services/musteri_servisi.dart';
import 'package:crm/widgets/loading_states.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:crm/generated/l10n/app_localizations.dart';

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
  final TextEditingController _kurumsalSearchController = TextEditingController();
  String _kurumsalSearchQuery = '';
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
      final isBireysel = m is MusteriModel;
      final isKurumsal = m is KurumsalMusteriModel;

      final matchesFilter = _filterType == 'Tümü' ||
          (_filterType == 'Bireysel' && isBireysel) ||
          (_filterType == 'Kurumsal' && isKurumsal);

      bool matchesSearch = false;
      if (isBireysel) {
        final mm = m as MusteriModel;
        matchesSearch = mm.ad.toLowerCase().contains(_searchQuery) ||
            mm.soyad.toLowerCase().contains(_searchQuery) ||
            mm.email.toLowerCase().contains(_searchQuery);
      } else if (isKurumsal) {
        final km = m as KurumsalMusteriModel;
        final query = (_kurumsalSearchQuery.isNotEmpty ? _kurumsalSearchQuery : _searchQuery);
        matchesSearch = km.sirketAdi.toLowerCase().contains(query) ||
            (km.email ?? '').toLowerCase().contains(query);
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
        title: Text(AppLocalizations.of(context)!.customersTitle),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SegmentedButton<String>(
              segments: <ButtonSegment<String>>[
                ButtonSegment<String>(value: 'Tümü', label: Text(AppLocalizations.of(context)!.filterAll), icon: const Icon(Icons.all_inclusive)),
                ButtonSegment<String>(value: 'Bireysel', label: Text(AppLocalizations.of(context)!.filterIndividual), icon: const Icon(Icons.person_outline)),
                ButtonSegment<String>(value: 'Kurumsal', label: Text(AppLocalizations.of(context)!.filterCorporate), icon: const Icon(Icons.business_outlined)),
              ],
              selected: <String>{_filterType},
              onSelectionChanged: (newSelection) {
                setState(() {
                  _filterType = newSelection.first;
                  _currentPage = 0;
                  _displayedItems.clear();
                  _filterAndPaginate();
                });
              },
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
                hintText: AppLocalizations.of(context)!.searchCustomersHint,
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
          if (_filterType == 'Kurumsal')
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: TextField(
                controller: _kurumsalSearchController,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.searchCorporateHint,
                  prefixIcon: const Icon(Icons.business),
                ),
                onChanged: (v) {
                  setState(() {
                    _kurumsalSearchQuery = v.toLowerCase();
                    _currentPage = 0;
                    _displayedItems.clear();
                    _filterAndPaginate();
                  });
                },
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
                    message: AppLocalizations.of(context)!.noCustomers,
                    icon: Icons.people_outline,
                    actionText: AppLocalizations.of(context)!.addCustomer,
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
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final m = _displayedItems[index];
                    if (m is MusteriModel) {
                      return _musteriCard(
                        context: context,
                        title: m.adSoyad,
                        subtitle: m.email,
                        leading: CircleAvatar(child: Text(m.ad.isNotEmpty ? m.ad[0].toUpperCase() : '?')),
                        onOpen: () => Navigator.pushNamed(context, RouteNames.musteriDetay, arguments: m.id),
                        onDelete: () => _musteriServisi.softDeleteMusteri(m.id),
                      );
                    } else if (m is KurumsalMusteriModel) {
                      return _musteriCard(
                        context: context,
                        title: m.sirketAdi,
                        subtitle: m.email ?? '',
                        leading: const CircleAvatar(child: Icon(Icons.business)),
                        onOpen: () => Navigator.pushNamed(context, RouteNames.kurumsalMusteriDetay, arguments: m.id),
                        onDelete: () => _kurumsalServisi.softDeleteKurumsalMusteri(m.id),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => Navigator.pushNamed(context, RouteNames.musteriEkle).then((_) => _loadData(showLoading: false)),
        tooltip: AppLocalizations.of(context)!.addCustomer,
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

  Widget _musteriCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required Widget leading,
    required VoidCallback onOpen,
    required VoidCallback onDelete,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: leading,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: PopupMenuButton<String>(
          tooltip: 'İşlemler',
          onSelected: (v) {
            switch (v) {
              case 'open':
                onOpen();
                break;
              case 'delete':
                onDelete();
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'open',
              child: ListTile(
                leading: const Icon(Icons.open_in_new),
                title: Text(AppLocalizations.of(context)!.open),
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: const Icon(Icons.delete_outline),
                title: Text(AppLocalizations.of(context)!.delete),
              ),
            ),
          ],
        ),
        onTap: onOpen,
      ),
    );
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
