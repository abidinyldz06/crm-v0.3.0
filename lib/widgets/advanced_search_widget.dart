import 'package:flutter/material.dart';
import '../services/advanced_search_service.dart';
import '../models/basvuru_model.dart';

class AdvancedSearchWidget extends StatefulWidget {
  final Function(List<dynamic>)? onResults;
  final SearchType searchType;

  const AdvancedSearchWidget({
    super.key,
    this.onResults,
    this.searchType = SearchType.all,
  });

  @override
  State<AdvancedSearchWidget> createState() => _AdvancedSearchWidgetState();
}

class _AdvancedSearchWidgetState extends State<AdvancedSearchWidget> {
  final AdvancedSearchService _searchService = AdvancedSearchService();
  final _formKey = GlobalKey<FormState>();

  // Müşteri arama parametreleri
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();

  // Başvuru arama parametreleri
  final TextEditingController _applicationTypeController = TextEditingController();
  String? _selectedConsultant;
  List<BasvuruDurumu> _selectedStatuses = [];

  // Genel parametreler
  DateTime? _startDate;
  DateTime? _endDate;
  bool _includeDeleted = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Gelişmiş Arama',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),

              // Arama türüne göre alanlar
              if (widget.searchType == SearchType.customers || widget.searchType == SearchType.all)
                _buildCustomerSearchFields(),

              if (widget.searchType == SearchType.applications || widget.searchType == SearchType.all)
                _buildApplicationSearchFields(),

              const SizedBox(height: 16),
              _buildCommonFields(),

              const SizedBox(height: 16),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerSearchFields() {
    return ExpansionTile(
      title: const Text('Müşteri Arama'),
      initiallyExpanded: widget.searchType == SearchType.customers,
      children: [
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Ad/Soyad',
            hintText: 'Müşteri adı veya soyadı',
            prefixIcon: Icon(Icons.person),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'E-posta',
            hintText: 'ornek@email.com',
            prefixIcon: Icon(Icons.email),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _phoneController,
          decoration: const InputDecoration(
            labelText: 'Telefon',
            hintText: '05xxxxxxxxx',
            prefixIcon: Icon(Icons.phone),
          ),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _countryController,
          decoration: const InputDecoration(
            labelText: 'Ülke',
            hintText: 'Başvuru yapılacak ülke',
            prefixIcon: Icon(Icons.flag),
          ),
        ),
      ],
    );
  }

  Widget _buildApplicationSearchFields() {
    return ExpansionTile(
      title: const Text('Başvuru Arama'),
      initiallyExpanded: widget.searchType == SearchType.applications,
      children: [
        const SizedBox(height: 8),
        TextFormField(
          controller: _applicationTypeController,
          decoration: const InputDecoration(
            labelText: 'Başvuru Türü',
            hintText: 'Vize, Oturum İzni vb.',
            prefixIcon: Icon(Icons.assignment),
          ),
        ),
        const SizedBox(height: 8),
        
        // Başvuru durumu seçimi
        const Text('Başvuru Durumu:', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: BasvuruDurumu.values.map((durum) {
            return FilterChip(
              label: Text(durum.displayName),
              selected: _selectedStatuses.contains(durum),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedStatuses.add(durum);
                  } else {
                    _selectedStatuses.remove(durum);
                  }
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 8),

        // Danışman seçimi (gelecekte implement edilecek)
        DropdownButtonFormField<String>(
          value: _selectedConsultant,
          decoration: const InputDecoration(
            labelText: 'Atanan Danışman',
            prefixIcon: Icon(Icons.person_outline),
          ),
          items: const [
            DropdownMenuItem(value: null, child: Text('Tüm Danışmanlar')),
            // Gerçek danışman listesi buraya eklenecek
          ],
          onChanged: (value) {
            setState(() {
              _selectedConsultant = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildCommonFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Genel Filtreler:', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        
        // Tarih aralığı
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _startDate ?? DateTime.now().subtract(const Duration(days: 30)),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() => _startDate = date);
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Başlangıç Tarihi',
                    prefixIcon: Icon(Icons.date_range),
                  ),
                  child: Text(
                    _startDate != null 
                        ? _formatDate(_startDate!)
                        : 'Tarih seçin',
                    style: TextStyle(
                      color: _startDate != null ? null : Colors.grey[600],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: InkWell(
                onTap: () async {
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
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Bitiş Tarihi',
                    prefixIcon: Icon(Icons.date_range),
                  ),
                  child: Text(
                    _endDate != null 
                        ? _formatDate(_endDate!)
                        : 'Tarih seçin',
                    style: TextStyle(
                      color: _endDate != null ? null : Colors.grey[600],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Silinmiş kayıtları dahil et
        CheckboxListTile(
          title: const Text('Silinmiş kayıtları dahil et'),
          value: _includeDeleted,
          onChanged: (value) {
            setState(() {
              _includeDeleted = value ?? false;
            });
          },
          controlAffinity: ListTileControlAffinity.leading,
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _performSearch,
            icon: _isLoading 
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.search),
            label: Text(_isLoading ? 'Aranıyor...' : 'Ara'),
          ),
        ),
        const SizedBox(width: 16),
        OutlinedButton.icon(
          onPressed: _clearForm,
          icon: const Icon(Icons.clear),
          label: const Text('Temizle'),
        ),
      ],
    );
  }

  Future<void> _performSearch() async {
    setState(() => _isLoading = true);

    try {
      List<dynamic> results = [];

      if (widget.searchType == SearchType.customers || widget.searchType == SearchType.all) {
        final customerResults = await _searchService.advancedCustomerSearch(
          name: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : null,
          email: _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : null,
          phone: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
          country: _countryController.text.trim().isNotEmpty ? _countryController.text.trim() : null,
          startDate: _startDate,
          endDate: _endDate,
          includeDeleted: _includeDeleted,
        );
        results.addAll(customerResults);
      }

      if (widget.searchType == SearchType.applications || widget.searchType == SearchType.all) {
        final applicationResults = await _searchService.advancedApplicationSearch(
          applicationType: _applicationTypeController.text.trim().isNotEmpty 
              ? _applicationTypeController.text.trim() 
              : null,
          statuses: _selectedStatuses.isNotEmpty ? _selectedStatuses : null,
          consultantId: _selectedConsultant,
          startDate: _startDate,
          endDate: _endDate,
          includeDeleted: _includeDeleted,
        );
        results.addAll(applicationResults);
      }

      widget.onResults?.call(results);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${results.length} sonuç bulundu'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Arama hatası: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _clearForm() {
    setState(() {
      _nameController.clear();
      _emailController.clear();
      _phoneController.clear();
      _countryController.clear();
      _applicationTypeController.clear();
      _selectedConsultant = null;
      _selectedStatuses.clear();
      _startDate = null;
      _endDate = null;
      _includeDeleted = false;
    });
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _countryController.dispose();
    _applicationTypeController.dispose();
    super.dispose();
  }
}

// Hızlı arama widget'ı
class QuickSearchWidget extends StatefulWidget {
  final Function(String)? onSearch;
  final String? hintText;

  const QuickSearchWidget({
    super.key,
    this.onSearch,
    this.hintText,
  });

  @override
  State<QuickSearchWidget> createState() => _QuickSearchWidgetState();
}

class _QuickSearchWidgetState extends State<QuickSearchWidget> {
  final TextEditingController _controller = TextEditingController();
  final AdvancedSearchService _searchService = AdvancedSearchService();
  List<String> _suggestions = [];
  bool _showSuggestions = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: widget.hintText ?? 'Hızlı arama...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _controller.clear();
                      setState(() {
                        _suggestions = [];
                        _showSuggestions = false;
                      });
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          onChanged: _onSearchChanged,
          onSubmitted: (value) {
            widget.onSearch?.call(value);
            setState(() => _showSuggestions = false);
          },
        ),
        if (_showSuggestions && _suggestions.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  dense: true,
                  leading: const Icon(Icons.search, size: 16),
                  title: Text(_suggestions[index]),
                  onTap: () {
                    _controller.text = _suggestions[index];
                    widget.onSearch?.call(_suggestions[index]);
                    setState(() => _showSuggestions = false);
                  },
                );
              },
            ),
          ),
      ],
    );
  }

  Future<void> _onSearchChanged(String value) async {
    if (value.length < 2) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
      return;
    }

    final suggestions = await _searchService.getSearchSuggestions(value, SearchType.all);
    if (mounted) {
      setState(() {
        _suggestions = suggestions;
        _showSuggestions = suggestions.isNotEmpty;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
