import 'package:flutter/material.dart';
import '../services/advanced_search_service.dart';
import '../widgets/loading_widgets.dart';
import '../screens/musteri_detay.dart';
import '../screens/basvuru_detay.dart';
import '../services/musteri_servisi.dart';

class GlobalSearchScreen extends StatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  State<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final AdvancedSearchService _searchService = AdvancedSearchService();
  final MusteriServisi _musteriServisi = MusteriServisi();
  
  List<SearchResult> _searchResults = [];
  List<String> _searchSuggestions = [];
  List<String> _searchHistory = [];
  List<String> _popularSearches = [];
  bool _isLoading = false;
  bool _showFilters = false;
  SearchType _selectedType = SearchType.all;
  
  // Filtre değişkenleri
  DateTime? _startDate;
  DateTime? _endDate;
  List<String> _selectedStatuses = [];
  String? _selectedCountry;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final history = await _searchService.getSearchHistory(null);
    final popular = await _searchService.getPopularSearches(null);
    
    if (mounted) {
      setState(() {
        _searchHistory = history;
        _popularSearches = popular;
      });
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final filter = SearchFilter(
        startDate: _startDate,
        endDate: _endDate,
        statuses: _selectedStatuses.isNotEmpty ? _selectedStatuses : null,
        countries: _selectedCountry != null ? [_selectedCountry!] : null,
      );

      final results = await _searchService.globalSearch(
        query: query,
        type: _selectedType,
        filter: filter,
        limit: 50,
      );

      // Arama geçmişine kaydet
      await _searchService.saveSearchHistory(query, _selectedType);

      if (mounted) {
        setState(() {
          _searchResults = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Arama hatası: $e')),
        );
      }
    }
  }

  Future<void> _getSuggestions(String query) async {
    if (query.length < 2) {
      setState(() {
        _searchSuggestions = [];
      });
      return;
    }

    final suggestions = await _searchService.getSearchSuggestions(query, _selectedType);
    if (mounted) {
      setState(() {
        _searchSuggestions = suggestions;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Global Arama'),
        actions: [
          IconButton(
            icon: Icon(_showFilters ? Icons.filter_list : Icons.filter_list_outlined),
            onPressed: () => setState(() => _showFilters = !_showFilters),
          ),
        ],
      ),
      body: Column(
        children: [
          // Arama çubuğu
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Müşteri, başvuru veya kullanıcı ara...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchResults = [];
                                _searchSuggestions = [];
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  onChanged: (value) {
                    _getSuggestions(value);
                    if (value.isEmpty) {
                      setState(() {
                        _searchResults = [];
                      });
                    }
                  },
                  onSubmitted: _performSearch,
                ),
                const SizedBox(height: 8),
                // Arama türü seçimi
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: SearchType.values.map((type) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(_getSearchTypeLabel(type)),
                          selected: _selectedType == type,
                          onSelected: (selected) {
                            setState(() {
                              _selectedType = type;
                            });
                            if (_searchController.text.isNotEmpty) {
                              _performSearch(_searchController.text);
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Filtreler
          if (_showFilters) _buildFilters(),

          // Arama önerileri
          if (_searchSuggestions.isNotEmpty && _searchController.text.isNotEmpty)
            _buildSuggestions(),

          // Sonuçlar veya başlangıç ekranı
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _searchResults.isNotEmpty
                    ? _buildSearchResults()
                    : _buildInitialScreen(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Filtreler', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          
          // Tarih filtreleri
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  icon: const Icon(Icons.date_range),
                  label: Text(_startDate != null 
                      ? 'Başlangıç: ${_formatDate(_startDate!)}'
                      : 'Başlangıç Tarihi'),
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _startDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() => _startDate = date);
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextButton.icon(
                  icon: const Icon(Icons.date_range),
                  label: Text(_endDate != null 
                      ? 'Bitiş: ${_formatDate(_endDate!)}'
                      : 'Bitiş Tarihi'),
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _endDate ?? DateTime.now(),
                      firstDate: _startDate ?? DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() => _endDate = date);
                    }
                  },
                ),
              ),
            ],
          ),

          // Durum filtreleri
          if (_selectedType == SearchType.all || _selectedType == SearchType.applications)
            Wrap(
              spacing: 8,
              children: ['Yeni', 'İşlemde', 'Tamamlandı', 'İptal'].map((status) {
                return FilterChip(
                  label: Text(status),
                  selected: _selectedStatuses.contains(status.toLowerCase()),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedStatuses.add(status.toLowerCase());
                      } else {
                        _selectedStatuses.remove(status.toLowerCase());
                      }
                    });
                  },
                );
              }).toList(),
            ),

          // Filtreleri temizle
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _startDate = null;
                    _endDate = null;
                    _selectedStatuses.clear();
                    _selectedCountry = null;
                  });
                },
                child: const Text('Filtreleri Temizle'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions() {
    return Container(
      height: 200,
      child: ListView.builder(
        itemCount: _searchSuggestions.length,
        itemBuilder: (context, index) {
          final suggestion = _searchSuggestions[index];
          return ListTile(
            leading: const Icon(Icons.search),
            title: Text(suggestion),
            onTap: () {
              _searchController.text = suggestion;
              _performSearch(suggestion);
            },
          );
        },
      ),
    );
  }

  Widget _buildInitialScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Arama geçmişi
          if (_searchHistory.isNotEmpty) ...[
            const Text(
              'Son Aramalar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _searchHistory.map((query) {
                return ActionChip(
                  label: Text(query),
                  onPressed: () {
                    _searchController.text = query;
                    _performSearch(query);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],

          // Popüler aramalar
          if (_popularSearches.isNotEmpty) ...[
            const Text(
              'Popüler Aramalar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _popularSearches.map((query) {
                return ActionChip(
                  label: Text(query),
                  onPressed: () {
                    _searchController.text = query;
                    _performSearch(query);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],

          // Arama ipuçları
          const Text(
            'Arama İpuçları',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• Müşteri adı, email veya telefon ile arayabilirsiniz'),
                  Text('• Başvuru türü veya ID ile arayabilirsiniz'),
                  Text('• Filtreleri kullanarak sonuçları daraltabilirsiniz'),
                  Text('• Arama türünü seçerek daha hızlı sonuç alabilirsiniz'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final result = _searchResults[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getTypeColor(result.type),
              child: Icon(
                _getTypeIcon(result.type),
                color: Colors.white,
              ),
            ),
            title: Text(result.title),
            subtitle: Text(result.subtitle),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _getTypeLabel(result.type),
                  style: TextStyle(
                    fontSize: 12,
                    color: _getTypeColor(result.type),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (result.createdAt != null)
                  Text(
                    _formatDate(result.createdAt!),
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
              ],
            ),
            onTap: () => _navigateToDetail(result),
          ),
        );
      },
    );
  }

  void _navigateToDetail(SearchResult result) async {
    switch (result.type) {
      case 'customer':
        try {
          final musteri = await _musteriServisi.musteriGetir(result.id);
          if (musteri != null && mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MusteriDetay(musteriId: musteri.id),
              ),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Müşteri detayı açılamadı: $e')),
          );
        }
        break;
      case 'application':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BasvuruDetay(basvuruId: result.id),
          ),
        );
        break;
      case 'user':
        // Kullanıcı detay sayfası henüz yok
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kullanıcı detay sayfası henüz mevcut değil')),
        );
        break;
    }
  }

  String _getSearchTypeLabel(SearchType type) {
    switch (type) {
      case SearchType.all:
        return 'Tümü';
      case SearchType.customers:
        return 'Müşteriler';
      case SearchType.applications:
        return 'Başvurular';
      case SearchType.users:
        return 'Kullanıcılar';
    }
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'customer':
        return 'Müşteri';
      case 'application':
        return 'Başvuru';
      case 'user':
        return 'Kullanıcı';
      default:
        return 'Bilinmeyen';
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'customer':
        return Colors.blue;
      case 'application':
        return Colors.green;
      case 'user':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'customer':
        return Icons.person;
      case 'application':
        return Icons.assignment;
      case 'user':
        return Icons.admin_panel_settings;
      default:
        return Icons.help;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}