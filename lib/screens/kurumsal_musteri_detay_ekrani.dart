import 'package:crm/models/kurumsal_musteri_model.dart';
import 'package:crm/services/kurumsal_musteri_servisi.dart';
import 'package:flutter/material.dart';
import 'package:crm/generated/l10n/app_localizations.dart';

class KurumsalMusteriDetayEkrani extends StatefulWidget {
  final String kurumsalMusteriId;
  const KurumsalMusteriDetayEkrani({super.key, required this.kurumsalMusteriId});

  @override
  State<KurumsalMusteriDetayEkrani> createState() => _KurumsalMusteriDetayEkraniState();
}

class _KurumsalMusteriDetayEkraniState extends State<KurumsalMusteriDetayEkrani> {
  final KurumsalMusteriServisi _servis = KurumsalMusteriServisi();
  bool _loading = true;
  KurumsalMusteriModel? _musteri;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final musteri = await _servis.getKurumsalMusteriById(widget.kurumsalMusteriId);
      if (mounted) {
        setState(() {
          _musteri = musteri;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  Future<void> _softDelete() async {
    if (_musteri == null) return;
    await _servis.softDeleteKurumsalMusteri(_musteri!.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Müşteri çöp kutusuna taşındı'), backgroundColor: Colors.orange),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_musteri?.sirketAdi ?? AppLocalizations.of(context)!.customersTitle),
        actions: [
          IconButton(
            tooltip: 'Yenile',
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          ),
          IconButton(
            tooltip: 'Sil (Soft Delete)',
            icon: const Icon(Icons.delete_outline),
            onPressed: _softDelete,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(height: 8),
            Text('${AppLocalizations.of(context)!.help}: $_error'),
            const SizedBox(height: 12),
            FilledButton(onPressed: _load, child: Text(AppLocalizations.of(context)!.retry)),
          ],
        ),
      );
    }
    if (_musteri == null) {
      return Center(child: Text(AppLocalizations.of(context)!.customerNotFound));
    }

    final m = _musteri!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  child: Text(m.sirketAdi.isNotEmpty ? m.sirketAdi[0].toUpperCase() : '?'),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(m.sirketAdi, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(m.email ?? AppLocalizations.of(context)!.emailNotAvailable, style: TextStyle(color: Colors.grey[600])),
                      if ((m.telefon ?? '').isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(m.telefon!, style: TextStyle(color: Colors.grey[700])),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.email_outlined, size: 18),
                      label: const Text('E-posta'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.phone_outlined, size: 18),
                      label: const Text('Ara'),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionHeader(icon: Icons.info_outline, title: AppLocalizations.of(context)!.companyInfo, color: Colors.blue),
                const SizedBox(height: 12),
                _kv(AppLocalizations.of(context)!.taxNumber, m.vergiNo ?? '-'),
                _kv(AppLocalizations.of(context)!.address, m.adres ?? '-'),
                _kv('Web', '-'),
                _kv(AppLocalizations.of(context)!.notes, m.notlar ?? '-'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 140, child: Text(k, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500))),
          Expanded(child: Text(v)),
        ],
      ),
    );
  }

  Widget _sectionHeader({required IconData icon, required String title, required Color color}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}
