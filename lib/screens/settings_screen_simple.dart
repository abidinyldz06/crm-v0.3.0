import 'package:crm/models/kullanici_model.dart';
import 'package:crm/services/auth_service.dart';
import 'package:crm/services/kullanici_servisi.dart';
import 'package:crm/screens/profil_ekrani.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _kullaniciServisi = KullaniciServisi();
  final _authService = AuthService();
  
  bool _isLoading = true;
  bool _darkMode = false;
  bool _notifications = true;
  bool _emailNotifications = true;
  String _language = 'tr';
  
  KullaniciModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    
    try {
      final user = await _authService.currentUserData();
      if (user != null && mounted) {
        setState(() {
          _currentUser = user;
          // Varsayılan ayarlar
          _darkMode = false;
          _notifications = true;
          _emailNotifications = true;
          _language = 'tr';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ayarlar yüklenirken hata: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _saveSettings() async {
    try {
      final settings = {
        'darkMode': _darkMode,
        'notifications': _notifications,
        'emailNotifications': _emailNotifications,
        'language': _language,
        'updatedAt': DateTime.now(),
      };
      
      await _kullaniciServisi.updateUserSettings(_currentUser!.uid, settings);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ayarlar kaydedildi!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ayarlar kaydedilirken hata: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSettings,
            tooltip: 'Ayarları Kaydet',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Kullanıcı Profili
          _buildProfileSection(),
          const SizedBox(height: 24),
          
          // Uygulama Ayarları
          _buildAppSettingsSection(),
          const SizedBox(height: 24),
          
          // Bildirim Ayarları
          _buildNotificationSection(),
          const SizedBox(height: 24),
          
          // Sistem Bilgileri
          _buildSystemSection(),
          const SizedBox(height: 24),
          
          // Çıkış
          _buildLogoutSection(),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Profil Bilgileri',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue,
                child: Text(
                  (_currentUser?.displayName?.isNotEmpty == true)
                      ? _currentUser!.displayName![0].toUpperCase()
                      : 'U',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(_currentUser?.displayName ?? 'Kullanıcı'),
              subtitle: Text(_currentUser?.email ?? ''),
              trailing: const Icon(Icons.edit),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ProfilEkrani()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.badge),
              title: const Text('Rol'),
              subtitle: Text(_currentUser?.role?.toUpperCase() ?? 'USER'),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getRoleColor(_currentUser?.role),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _currentUser?.role?.toUpperCase() ?? 'USER',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppSettingsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.settings, color: Colors.purple),
                const SizedBox(width: 8),
                Text(
                  'Uygulama Ayarları',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Karanlık Tema'),
              subtitle: const Text('Gece modu (Yakında aktif olacak)'),
              value: _darkMode,
              onChanged: (value) {
                setState(() => _darkMode = value);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Karanlık tema yakında eklenecek!')),
                );
              },
              secondary: const Icon(Icons.dark_mode),
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('Dil'),
              subtitle: Text(_getLanguageName(_language)),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _showLanguagePicker(),
            ),
            ListTile(
              leading: const Icon(Icons.color_lens),
              title: const Text('Tema Rengi'),
              subtitle: const Text('Mavi (Varsayılan)'),
              trailing: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tema rengi seçimi yakında eklenecek!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.notifications, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'Bildirimler',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Bildirimler'),
              subtitle: const Text('Tüm bildirimleri aç/kapat'),
              value: _notifications,
              onChanged: (value) {
                setState(() => _notifications = value);
              },
              secondary: const Icon(Icons.notifications_active),
            ),
            SwitchListTile(
              title: const Text('E-posta Bildirimleri'),
              subtitle: const Text('E-posta ile bildirim al'),
              value: _emailNotifications,
              onChanged: _notifications ? (value) {
                setState(() => _emailNotifications = value);
              } : null,
              secondary: const Icon(Icons.email),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info, color: Colors.teal),
                const SizedBox(width: 8),
                Text(
                  'Sistem Bilgileri',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.apps),
              title: const Text('Uygulama Sürümü'),
              subtitle: const Text('v0.2.3 (Build 230126)'),
              onTap: () => _showVersionInfo(),
            ),
            ListTile(
              leading: const Icon(Icons.storage),
              title: const Text('Depolama'),
              subtitle: const Text('Kullanılan alan: 2.5 GB / 10 GB'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _showStorageInfo(),
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text('Yardım ve Destek'),
              subtitle: const Text('Kullanım kılavuzu ve destek'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _showHelpDialog(),
            ),
            ListTile(
              leading: const Icon(Icons.bug_report),
              title: const Text('Hata Raporu Gönder'),
              subtitle: const Text('Sorun bildirin'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _showBugReportDialog(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.exit_to_app, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  'Hesap',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.lock, color: Colors.orange),
              title: const Text('Şifre Değiştir'),
              subtitle: const Text('Hesap şifrenizi güncelleyin'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _showChangePasswordDialog(),
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Çıkış Yap', style: TextStyle(color: Colors.red)),
              subtitle: const Text('Hesaptan çıkış yap'),
              onTap: () => _showLogoutDialog(),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Methods
  Color _getRoleColor(String? role) {
    switch (role?.toLowerCase()) {
      case 'admin':
        return Colors.red;
      case 'manager':
        return Colors.orange;
      case 'user':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'tr':
        return 'Türkçe';
      case 'en':
        return 'English';
      default:
        return 'Türkçe';
    }
  }

  // Dialog Methods
  void _showLanguagePicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dil Seç'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Türkçe'),
              value: 'tr',
              groupValue: _language,
              onChanged: (value) {
                setState(() => _language = value!);
                Navigator.of(context).pop();
              },
            ),
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
              groupValue: _language,
              onChanged: (value) {
                setState(() => _language = value!);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('English language support coming soon!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Şifre Değiştir'),
        content: const Text('Şifre değiştirme özelliği yakında eklenecek!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showStorageInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Depolama Bilgisi'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Kullanılan Alan: 2.5 GB'),
            Text('Toplam Alan: 10 GB'),
            SizedBox(height: 16),
            LinearProgressIndicator(value: 0.25),
            SizedBox(height: 16),
            Text('Detaylar:'),
            Text('• Müşteri Dosyaları: 1.2 GB'),
            Text('• Başvuru Belgeleri: 800 MB'),
            Text('• Sistem Verileri: 500 MB'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showBugReportDialog() {
    final reportController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hata Raporu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Karşılaştığınız sorunu detaylı olarak açıklayın:'),
            const SizedBox(height: 16),
            TextField(
              controller: reportController,
              decoration: const InputDecoration(
                hintText: 'Hata açıklaması...',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Hata raporu gönderildi! Teşekkürler.')),
              );
            },
            child: const Text('Gönder'),
          ),
        ],
      ),
    );
  }

  void _showVersionInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sürüm Bilgisi'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Vize Danışmanlık CRM'),
            Text('Sürüm: v0.2.3'),
            Text('Build: 230126'),
            Text('Flutter: 3.4.3'),
            SizedBox(height: 16),
            Text('Son Güncellemeler:'),
            Text('• NavigationRail overflow düzeltildi'),
            Text('• Hızlı erişim kartları eklendi'),
            Text('• Ayarlar sayfası eklendi'),
            Text('• Font optimizasyonu'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yardım ve Destek'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Destek Kanalları:'),
            SizedBox(height: 8),
            Text('📧 E-posta: support@vizedanismanlik.com'),
            Text('📞 Telefon: +90 212 XXX XX XX'),
            Text('💬 Canlı Destek: 09:00 - 18:00'),
            SizedBox(height: 16),
            Text('Hızlı Yardım:'),
            Text('• Müşteri ekleme: Ana Sayfa > + butonu'),
            Text('• Başvuru takibi: Başvurular menüsü'),
            Text('• Raporlar: Raporlar menüsü'),
            Text('• Ayarlar: Sol menüden Ayarlar'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text('Hesaptan çıkış yapmak istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _authService.signOut();
              if (mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );
  }
}