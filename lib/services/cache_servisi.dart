import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheServisi {
  static const Duration _defaultCacheDuration = Duration(hours: 1);
  
  // Veriyi cache'e kaydet
  static Future<void> saveToCache({
    required String key,
    required dynamic data,
    Duration? duration,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheData = {
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'duration': (duration ?? _defaultCacheDuration).inMilliseconds,
    };
    await prefs.setString(key, jsonEncode(cacheData));
  }

  // Cache'den veri oku
  static Future<dynamic> getFromCache(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheString = prefs.getString(key);
    
    if (cacheString == null) return null;
    
    try {
      final cacheData = jsonDecode(cacheString);
      final timestamp = cacheData['timestamp'] as int;
      final duration = cacheData['duration'] as int;
      final now = DateTime.now().millisecondsSinceEpoch;
      
      // Cache süresi dolmuşsa null döndür
      if (now - timestamp > duration) {
        await prefs.remove(key);
        return null;
      }
      
      return cacheData['data'];
    } catch (e) {
      print('Cache okuma hatası: $e');
      return null;
    }
  }

  // Cache'i temizle
  static Future<void> clearCache(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  // Tüm cache'i temizle
  static Future<void> clearAllCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Müşteri listesi için özel cache fonksiyonları
  static Future<void> saveMusteriListToCache(List<Map<String, dynamic>> musteriler) async {
    await saveToCache(
      key: 'musteri_list_cache',
      data: musteriler,
      duration: Duration(minutes: 30),
    );
  }

  static Future<List<Map<String, dynamic>>?> getMusteriListFromCache() async {
    final data = await getFromCache('musteri_list_cache');
    if (data != null) {
      return List<Map<String, dynamic>>.from(data);
    }
    return null;
  }

  // Başvuru listesi için özel cache fonksiyonları
  static Future<void> saveBasvuruListToCache(List<Map<String, dynamic>> basvurular) async {
    await saveToCache(
      key: 'basvuru_list_cache',
      data: basvurular,
      duration: Duration(minutes: 15),
    );
  }

  static Future<List<Map<String, dynamic>>?> getBasvuruListFromCache() async {
    final data = await getFromCache('basvuru_list_cache');
    if (data != null) {
      return List<Map<String, dynamic>>.from(data);
    }
    return null;
  }
} 