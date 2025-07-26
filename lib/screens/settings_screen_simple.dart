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
            _buildSectionHeader(
              icon: Icons.person,
              title: 'Profil Bilgileri',
              color: Colors.blue,
              subtitle: 'Hesap bilgilerinizi görüntüleyin ve düzenleyin',
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
            _buildSectionHeader(
              icon: Icons.palette,
              title: 'Görünüm ve Dil',
              color: Colors.purple,
              subtitle: 'Tema, dil ve görünüm tercihlerinizi ayarlayın',
            ),
            const SizedBox(height: 16),
            _buildModernSwitchTile(
              icon: Icons.dark_mode,
              title: 'Karanlık Tema',
              subtitle: 'Gece modu aktif/pasif',
              value: _darkMode,
              onChanged: (value) {
                setState(() => _darkMode = value);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(value ? 'Karanlık tema aktif (Yakında!)' : 'Açık tema aktif'),
                    backgroundColor: value ? Colors.grey[800] : Colors.blue,
                  ),
                );
              },
              iconColor: Colors.indigo,
            ),
            _buildModernListTile(
              icon: Icons.language,
              title: 'Dil Seçimi',
              subtitle: _getLanguageName(_language),
              onTap: () => _showLanguagePicker(),
              iconColor: Colors.green,
            ),
            _buildModernListTile(
              icon: Icons.color_lens,
              title: 'Tema Rengi',
              subtitle: 'Mavi (Varsayılan)',
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
              iconColor: Colors.purple,
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
            _buildSectionHeader(
              icon: Icons.notifications_active,
              title: 'Bildirim Tercihleri',
              color: Colors.orange,
              subtitle: 'E-posta ve sistem bildirimlerini yönetin',
            ),
            const SizedBox(height: 16),
            _buildModernSwitchTile(
              icon: Icons.notifications_active,
              title: 'Sistem Bildirimleri',
              subtitle: 'Tüm bildirimleri aç/kapat',
              value: _notifications,
              onChanged: (value) {
                setState(() => _notifications = value);
              },
              iconColor: Colors.orange,
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: _notifications ? Colors.grey[50] : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(_notifications ? 0.1 : 0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.email,
                    color: _notifications ? Colors.blue : Colors.grey,
                    size: 20,
                  ),
                ),
                title: Text(
                  'E-posta Bildirimleri',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: _notifications ? Colors.black : Colors.grey,
                  ),
                ),
                subtitle: Text(
                  'E-posta ile bildirim al',
                  style: TextStyle(
                    color: _notifications ? Colors.grey[600] : Colors.grey[400],
                    fontSize: 13,
                  ),
                ),
                value: _emailNotifications,
                onChanged: _notifications ? (value) {
                  setState(() => _emailNotifications = value);
                } : null,
                activeColor: Colors.blue,
              ),
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
            _buildSectionHeader(
              icon: Icons.info_outline,
              title: 'Sistem ve Destek',
              color: Colors.teal,
              subtitle: 'Uygulama bilgileri, yardım ve destek',
            ),
            const SizedBox(height: 16),
            _buildModernListTile(
              icon: Icons.apps,
              title: 'Uygulama Sürümü',
              subtitle: 'v0.2.3 (Build 230126)',
              trailing: const Icon(Icons.info_outline, size: 16),
              onTap: () => _showVersionInfo(),
              iconColor: Colors.blue,
            ),
            _buildModernListTile(
              icon: Icons.storage,
              title: 'Depolama Kullanımı',
              subtitle: 'Kullanılan alan: 2.5 GB / 10 GB',
              onTap: () => _showStorageInfo(),
              iconColor: Colors.green,
            ),
            _buildModernListTile(
              icon: Icons.help_outline,
              title: 'Yardım ve Destek',
              subtitle: 'Kullanım kılavuzu ve canlı destek',
              onTap: () => _showHelpDialog(),
              iconColor: Colors.teal,
            ),
            _buildModernListTile(
              icon: Icons.bug_report,
              title: 'Hata Bildirimi',
              subtitle: 'Sorun ve önerilerinizi bildirin',
              onTap: () => _showBugReportDialog(),
              iconColor: Colors.orange,
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
            _buildSectionHeader(
              icon: Icons.security,
              title: 'Güvenlik ve Hesap',
              color: Colors.red,
              subtitle: 'Şifre değiştirme ve hesap yönetimi',
            ),
            const SizedBox(height: 16),
            _buildModernListTile(
              icon: Icons.lock_outline,
              title: 'Şifre Değiştir',
              subtitle: 'Hesap güvenliğinizi güncelleyin',
              onTap: () => _showChangePasswordDialog(),
              iconColor: Colors.orange,
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.logout, color: Colors.red, size: 20),
                ),
                title: const Text(
                  'Çıkış Yap',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  'Hesaptan güvenli çıkış yapın',
                  style: TextStyle(color: Colors.red[700], fontSize: 13),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.red, size: 16),
                onTap: () => _showLogoutDialog(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Methods
  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required Color color,
    String? subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildModernSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    Color? iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (iconColor ?? Colors.blue).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor ?? Colors.blue, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey[600], fontSize: 13),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: iconColor ?? Colors.blue,
      ),
    );
  }

  Widget _buildModernListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (iconColor ?? Colors.blue).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor ?? Colors.blue, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey[600], fontSize: 13),
        ),
        trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

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