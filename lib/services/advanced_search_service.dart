import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/musteri_model.dart';
import '../models/basvuru_model.dart';
import '../models/kullanici_model.dart';

enum SearchType {
  all,
  customers,
  applications,
  users,
}

class SearchFilter {
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String>? statuses;
  final List<String>? countries;
  final String? assignedConsultant;
  final bool? isDeleted;

  SearchFilter({
    this.startDate,
    this.endDate,
    this.statuses,
    this.countries,
    this.assignedConsultant,
    this.isDeleted,
  });
}

class SearchResult {
  final String id;
  final String title;
  final String subtitle;
  final String type;
  final Map<String, dynamic> data;
  final DateTime? createdAt;

  SearchResult({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.data,
    this.createdAt,
  });
}

class AdvancedSearchService {
  static final AdvancedSearchService _instance = AdvancedSearchService._internal();
  factory AdvancedSearchService() => _instance;
  AdvancedSearchService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Global arama
  Future<List<SearchResult>> globalSearch({
    required String query,
    SearchType type = SearchType.all,
    SearchFilter? filter,
    int limit = 20,
  }) async {
    if (query.trim().isEmpty) return [];

    final results = <SearchResult>[];
    final lowerQuery = query.toLowerCase();

    try {
      // Müşteri araması
      if (type == SearchType.all || type == SearchType.customers) {
        final customerResults = await _searchCustomers(lowerQuery, filter, limit);
        results.addAll(customerResults);
      }

      // Başvuru araması
      if (type == SearchType.all || type == SearchType.applications) {
        final applicationResults = await _searchApplications(lowerQuery, filter, limit);
        results.addAll(applicationResults);
      }

      // Kullanıcı araması (sadece admin için)
      final currentUser = await _getCurrentUser();
      if (currentUser?.isAdmin == true && (type == SearchType.all || type == SearchType.users)) {
        final userResults = await _searchUsers(lowerQuery, limit);
        results.addAll(userResults);
      }

      // Sonuçları relevansa göre sırala
      results.sort((a, b) => _calculateRelevance(b, lowerQuery).compareTo(_calculateRelevance(a, lowerQuery)));

      return results.take(limit).toList();
    } catch (e) {
      print('Global arama hatası: $e');
      return [];
    }
  }

  // Müşteri araması
  Future<List<SearchResult>> _searchCustomers(String query, SearchFilter? filter, int limit) async {
    final results = <SearchResult>[];

    try {
      // Ad/soyad araması
      final nameQuery = await _firestore
          .collection('customers')
          .where('isDeleted', isEqualTo: filter?.isDeleted ?? false)
          .limit(limit)
          .get();

      for (var doc in nameQuery.docs) {
        final customer = MusteriModel.fromFirestore(doc);
        final fullName = customer.adSoyad.toLowerCase();
        final email = customer.email.toLowerCase();
        final phone = customer.telefon.toLowerCase();

        if (fullName.contains(query) || 
            email.contains(query) || 
            phone.contains(query) ||
            customer.basvuruUlkesi.toLowerCase().contains(query)) {
          
          // Filtre kontrolü
          if (_matchesCustomerFilter(customer, filter)) {
            results.add(SearchResult(
              id: customer.id,
              title: customer.adSoyad,
              subtitle: '${customer.email} • ${customer.basvuruUlkesi}',
              type: 'customer',
              data: customer.toMap(),
              createdAt: customer.olusturulmaTarihi.toDate(),
            ));
          }
        }
      }
    } catch (e) {
      print('Müşteri arama hatası: $e');
    }

    return results;
  }

  // Başvuru araması
  Future<List<SearchResult>> _searchApplications(String query, SearchFilter? filter, int limit) async {
    final results = <SearchResult>[];

    try {
      final applicationQuery = await _firestore
          .collection('applications')
          .where('isDeleted', isEqualTo: filter?.isDeleted ?? false)
          .limit(limit)
          .get();

      for (var doc in applicationQuery.docs) {
        final application = BasvuruModel.fromFirestore(doc);
        final applicationType = application.basvuruTuru.toLowerCase();
        final applicationId = application.id.toLowerCase();

        if (applicationType.contains(query) || 
            applicationId.contains(query) ||
            application.durum.displayName.toLowerCase().contains(query)) {
          
          // Filtre kontrolü
          if (_matchesApplicationFilter(application, filter)) {
            // Müşteri bilgisini al
            String customerName = 'Bilinmeyen Müşteri';
            try {
              final customerDoc = await _firestore.collection('customers').doc(application.musteriId).get();
              if (customerDoc.exists) {
                final customer = MusteriModel.fromFirestore(customerDoc);
                customerName = customer.adSoyad;
              }
            } catch (e) {
              print('Müşteri bilgisi alma hatası: $e');
            }

            results.add(SearchResult(
              id: application.id,
              title: application.basvuruTuru,
              subtitle: '$customerName • ${application.durum.displayName}',
              type: 'application',
              data: application.toMap(),
              createdAt: application.olusturulmaTarihi.toDate(),
            ));
          }
        }
      }
    } catch (e) {
      print('Başvuru arama hatası: $e');
    }

    return results;
  }

  // Kullanıcı araması
  Future<List<SearchResult>> _searchUsers(String query, int limit) async {
    final results = <SearchResult>[];

    try {
      final userQuery = await _firestore
          .collection('users')
          .limit(limit)
          .get();

      for (var doc in userQuery.docs) {
        final user = KullaniciModel.fromFirestore(doc);
        final displayName = (user.displayName ?? '').toLowerCase();
        final email = (user.email ?? '').toLowerCase();

        if (displayName.contains(query) || email.contains(query)) {
          results.add(SearchResult(
            id: user.uid,
            title: user.displayName ?? 'İsimsiz Kullanıcı',
            subtitle: '${user.email} • ${user.role}',
            type: 'user',
            data: user.toMap(),
          ));
        }
      }
    } catch (e) {
      print('Kullanıcı arama hatası: $e');
    }

    return results;
  }

  // Gelişmiş müşteri araması
  Future<List<MusteriModel>> advancedCustomerSearch({
    String? name,
    String? email,
    String? phone,
    String? country,
    DateTime? startDate,
    DateTime? endDate,
    bool includeDeleted = false,
  }) async {
    try {
      Query query = _firestore.collection('customers');

      // Temel filtreler
      if (!includeDeleted) {
        query = query.where('isDeleted', isEqualTo: false);
      }

      // Tarih filtresi
      if (startDate != null) {
        query = query.where('olusturulmaTarihi', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }
      if (endDate != null) {
        query = query.where('olusturulmaTarihi', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      // Ülke filtresi
      if (country != null && country.isNotEmpty) {
        query = query.where('basvuruUlkesi', isEqualTo: country);
      }

      final snapshot = await query.limit(100).get();
      final customers = snapshot.docs.map((doc) => MusteriModel.fromFirestore(doc)).toList();

      // Client-side filtreleme (Firestore'un sınırlamaları nedeniyle)
      return customers.where((customer) {
        if (name != null && name.isNotEmpty) {
          if (!customer.adSoyad.toLowerCase().contains(name.toLowerCase())) {
            return false;
          }
        }
        if (email != null && email.isNotEmpty) {
          if (!customer.email.toLowerCase().contains(email.toLowerCase())) {
            return false;
          }
        }
        if (phone != null && phone.isNotEmpty) {
          if (!customer.telefon.contains(phone)) {
            return false;
          }
        }
        return true;
      }).toList();
    } catch (e) {
      print('Gelişmiş müşteri arama hatası: $e');
      return [];
    }
  }

  // Gelişmiş başvuru araması
  Future<List<BasvuruModel>> advancedApplicationSearch({
    String? applicationType,
    List<BasvuruDurumu>? statuses,
    String? consultantId,
    DateTime? startDate,
    DateTime? endDate,
    bool includeDeleted = false,
  }) async {
    try {
      Query query = _firestore.collection('applications');

      // Temel filtreler
      if (!includeDeleted) {
        query = query.where('isDeleted', isEqualTo: false);
      }

      // Danışman filtresi
      if (consultantId != null && consultantId.isNotEmpty) {
        query = query.where('atananDanismanId', isEqualTo: consultantId);
      }

      // Tarih filtresi
      if (startDate != null) {
        query = query.where('olusturulmaTarihi', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }
      if (endDate != null) {
        query = query.where('olusturulmaTarihi', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      final snapshot = await query.limit(100).get();
      final applications = snapshot.docs.map((doc) => BasvuruModel.fromFirestore(doc)).toList();

      // Client-side filtreleme
      return applications.where((application) {
        if (applicationType != null && applicationType.isNotEmpty) {
          if (!application.basvuruTuru.toLowerCase().contains(applicationType.toLowerCase())) {
            return false;
          }
        }
        if (statuses != null && statuses.isNotEmpty) {
          if (!statuses.contains(application.durum)) {
            return false;
          }
        }
        return true;
      }).toList();
    } catch (e) {
      print('Gelişmiş başvuru arama hatası: $e');
      return [];
    }
  }

  // Arama önerileri
  Future<List<String>> getSearchSuggestions(String query, SearchType type) async {
    if (query.length < 2) return [];

    final suggestions = <String>[];
    final lowerQuery = query.toLowerCase();

    try {
      switch (type) {
        case SearchType.customers:
          final customers = await _firestore
              .collection('customers')
              .where('isDeleted', isEqualTo: false)
              .limit(10)
              .get();

          for (var doc in customers.docs) {
            final customer = MusteriModel.fromFirestore(doc);
            if (customer.adSoyad.toLowerCase().startsWith(lowerQuery)) {
              suggestions.add(customer.adSoyad);
            }
            if (customer.email.toLowerCase().startsWith(lowerQuery)) {
              suggestions.add(customer.email);
            }
          }
          break;

        case SearchType.applications:
          final applications = await _firestore
              .collection('applications')
              .where('isDeleted', isEqualTo: false)
              .limit(10)
              .get();

          for (var doc in applications.docs) {
            final application = BasvuruModel.fromFirestore(doc);
            if (application.basvuruTuru.toLowerCase().startsWith(lowerQuery)) {
              suggestions.add(application.basvuruTuru);
            }
          }
          break;

        default:
          // Genel öneriler
          suggestions.addAll(['Müşteri', 'Başvuru', 'Tamamlandı', 'İşlemde', 'Yeni']);
      }
    } catch (e) {
      print('Arama önerileri hatası: $e');
    }

    return suggestions.where((s) => s.toLowerCase().contains(lowerQuery)).take(5).toList();
  }

  // Arama geçmişi
  Future<void> saveSearchHistory(String query, SearchType type) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore.collection('search_history').add({
        'userId': user.uid,
        'query': query,
        'type': type.name,
        'timestamp': Timestamp.now(),
      });
    } catch (e) {
      print('Arama geçmişi kaydetme hatası: $e');
    }
  }

  // Arama geçmişini getir
  Future<List<String>> getSearchHistory(SearchType? type) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      // Index gerektirmeyen basit sorgu
      Query query = _firestore
          .collection('search_history')
          .where('userId', isEqualTo: user.uid)
          .limit(20); // Daha fazla veri al, sonra sırala

      final snapshot = await query.get();
      var results = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'query': data['query'] as String,
          'timestamp': data['timestamp'] as Timestamp,
          'type': data['type'] as String?,
        };
      }).toList();

      // Type filtresi uygula
      if (type != null) {
        results = results.where((item) => item['type'] == type.name).toList();
      }

      // Timestamp'e göre sırala (client-side)
      results.sort((a, b) => (b['timestamp'] as Timestamp).compareTo(a['timestamp'] as Timestamp));

      // İlk 10'u al
      return results.take(10).map((item) => item['query'] as String).toList();
    } catch (e) {
      print('Arama geçmişi alma hatası: $e');
      return [];
    }
  }

  // Popüler aramalar
  Future<List<String>> getPopularSearches(SearchType? type) async {
    try {
      // Index gerektirmeyen basit sorgu
      Query query = _firestore
          .collection('search_history')
          .limit(200); // Daha fazla veri al

      final snapshot = await query.get();
      final searches = <String, int>{};

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final searchQuery = data['query'] as String;
        final searchType = data['type'] as String?;
        
        // Type filtresi uygula
        if (type != null && searchType != type.name) continue;
        
        searches[searchQuery] = (searches[searchQuery] ?? 0) + 1;
      }

      final sortedSearches = searches.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return sortedSearches.take(5).map((e) => e.key).toList();
    } catch (e) {
      print('Popüler aramalar hatası: $e');
      return [];
    }
  }

  // Yardımcı metodlar
  bool _matchesCustomerFilter(MusteriModel customer, SearchFilter? filter) {
    if (filter == null) return true;

    if (filter.startDate != null && customer.olusturulmaTarihi.toDate().isBefore(filter.startDate!)) {
      return false;
    }
    if (filter.endDate != null && customer.olusturulmaTarihi.toDate().isAfter(filter.endDate!)) {
      return false;
    }
    if (filter.countries != null && !filter.countries!.contains(customer.basvuruUlkesi)) {
      return false;
    }

    return true;
  }

  bool _matchesApplicationFilter(BasvuruModel application, SearchFilter? filter) {
    if (filter == null) return true;

    if (filter.startDate != null && application.olusturulmaTarihi.toDate().isBefore(filter.startDate!)) {
      return false;
    }
    if (filter.endDate != null && application.olusturulmaTarihi.toDate().isAfter(filter.endDate!)) {
      return false;
    }
    if (filter.statuses != null && !filter.statuses!.contains(application.durum.name)) {
      return false;
    }
    if (filter.assignedConsultant != null && application.atananDanismanId != filter.assignedConsultant) {
      return false;
    }

    return true;
  }

  double _calculateRelevance(SearchResult result, String query) {
    double score = 0.0;

    // Başlık eşleşmesi
    if (result.title.toLowerCase().contains(query)) {
      score += 10.0;
      if (result.title.toLowerCase().startsWith(query)) {
        score += 5.0;
      }
    }

    // Alt başlık eşleşmesi
    if (result.subtitle.toLowerCase().contains(query)) {
      score += 5.0;
    }

    // Tip bonusu
    switch (result.type) {
      case 'customer':
        score += 2.0;
        break;
      case 'application':
        score += 1.5;
        break;
      case 'user':
        score += 1.0;
        break;
    }

    // Tarih bonusu (yeni kayıtlar)
    if (result.createdAt != null) {
      final daysSinceCreation = DateTime.now().difference(result.createdAt!).inDays;
      if (daysSinceCreation < 30) {
        score += 1.0;
      }
    }

    return score;
  }

  Future<KullaniciModel?> _getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return KullaniciModel.fromFirestore(doc);
      }
    } catch (e) {
      print('Mevcut kullanıcı alma hatası: $e');
    }
    return null;
  }
}