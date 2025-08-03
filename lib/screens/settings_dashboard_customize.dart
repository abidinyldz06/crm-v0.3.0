import 'package:crm/services/dashboard_settings_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SettingsDashboardCustomize extends StatefulWidget {
  const SettingsDashboardCustomize({super.key});

  @override
  State<SettingsDashboardCustomize> createState() => _SettingsDashboardCustomizeState();
}

class _SettingsDashboardCustomizeState extends State<SettingsDashboardCustomize> {
  final _service = DashboardSettingsService();

  // Tüm yönetilebilir bölümler ve kullanıcıya gösterilecek başlıkları
  static const Map<String, String> _sectionTitles = {
    'kpi': 'KPI Kartları',
    'statusPie': 'Başvuru Durumu Dağılımı',
    'recentApplications': 'Son Başvurular',
    'reminders': 'Hatırlatıcılar',
    'quickAccess': 'Hızlı Erişim',
  };

  DashboardSettings? _settings;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Canlı izleme: kullanıcı tercihleri anlık güncellensin
    _service.watchSettings().listen((value) {
      if (!mounted) return;
      setState(() {
        _settings = _sanitize(value);
        _loading = false;
        _error = null;
      });
    }, onError: (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Ayarlar yüklenemedi: $e';
        _loading = false;
      });
    });
  }

  DashboardSettings _sanitize(DashboardSettings s) {
    final allKeys = _sectionTitles.keys.toList();
    // Enabled içinde var olmayan key olmasın
    final enabled = s.enabledSections.where((e) => allKeys.contains(e)).toList();
    // Order sadece bilinen keylerden oluşsun
    var order = s.order.where((e) => allKeys.contains(e)).toList();
    // Order içinde olmayan ama enabled olanlar sona eklensin
    for (final k in enabled) {
      if (!order.contains(k)) order.add(k);
    }
    // Varsayılan: hiçbiri yoksa hepsini etkinleştir
    if (enabled.isEmpty) {
      return DashboardSettings(enabledSections: allKeys, order: allKeys);
    }
    return DashboardSettings(enabledSections: enabled, order: order);
  }

  Future<void> _toggleSection(String key, bool value) async {
    if (_settings == null) return;
    final enabled = [..._settings!.enabledSections];
    if (value) {
      if (!enabled.contains(key)) enabled.add(key);
    } else {
      enabled.remove(key);
    }
    final updated = _settings!.copyWith(enabledSections: enabled);
    setState(() => _settings = updated);
    await _service.saveSettings(updated);
  }

  Future<void> _reorder(int oldIndex, int newIndex) async {
    if (_settings == null) return;
    final order = [..._settings!.order];
    if (newIndex > oldIndex) newIndex -= 1;
    final item = order.removeAt(oldIndex);
    order.insert(newIndex, item);
    final updated = _settings!.copyWith(order: order);
    setState(() => _settings = updated);
    await _service.saveSettings(updated);
  }

  Future<void> _resetDefaults() async {
    final defaults = const DashboardSettings(
      enabledSections: ['kpi', 'statusPie', 'recentApplications', 'reminders', 'quickAccess'],
      order: ['kpi', 'statusPie', 'recentApplications', 'reminders', 'quickAccess'],
    );
    setState(() {
      _settings = defaults;
    });
    await _service.saveSettings(defaults);
  }

  bool get _canEdit => FirebaseAuth.instance.currentUser != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Özelleştir'),
        actions: [
          IconButton(
            tooltip: 'Varsayılanlara dön',
            icon: const Icon(Icons.restore),
            onPressed: _canEdit ? _resetDefaults : null,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
                  ),
                )
              : _buildContent(theme),
    );
  }

  Widget _buildContent(ThemeData theme) {
    final settings = _settings!;
    final enabledSet = settings.enabledSections.toSet();

    return LayoutBuilder(
      builder: (context, constraints) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hangi bölümler görünsün?',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ..._sectionTitles.entries.map((e) {
                      return SwitchListTile(
                        title: Text(e.value),
                        value: enabledSet.contains(e.key),
                        onChanged: _canEdit
                            ? (val) {
                                _toggleSection(e.key, val);
                              }
                            : null,
                      );
                    }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Sıralama (sürükle-bırak)',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ReorderableListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      onReorder: _canEdit ? _reorder : (a, b) {},
                      itemCount: settings.order.length,
                      itemBuilder: (context, index) {
                        final key = settings.order[index];
                        final title = _sectionTitles[key] ?? key;
                        final visible = enabledSet.contains(key);
                        return ListTile(
                          key: ValueKey(key),
                          leading: const Icon(Icons.drag_handle),
                          title: Text(title),
                          trailing: visible
                              ? Chip(
                                  label: const Text('Görünür'),
                                  backgroundColor: Colors.green.withOpacity(0.1),
                                  labelStyle: const TextStyle(color: Colors.green),
                                )
                              : Chip(
                                  label: const Text('Gizli'),
                                  backgroundColor: Colors.grey.withOpacity(0.15),
                                  labelStyle: const TextStyle(color: Colors.grey),
                                ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _canEdit
                  ? () async {
                      // Şu an tüm değişiklikler anlık kaydediliyor; burada sadece bilgi veriyoruz
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Dashboard tercihleri kaydedildi'), backgroundColor: Colors.green),
                      );
                    }
                  : null,
              icon: const Icon(Icons.save),
              label: const Text('Kaydet'),
            ),
          ],
        );
      },
    );
  }
}
