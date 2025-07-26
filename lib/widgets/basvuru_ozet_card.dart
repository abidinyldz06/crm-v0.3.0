import 'package:crm/models/basvuru_model.dart';
import 'package:crm/screens/basvuru_detay.dart';
import 'package:crm/services/kullanici_servisi.dart';
import 'package:crm/services/musteri_servisi.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BasvuruOzetCard extends StatefulWidget {
  final BasvuruModel basvuru;

  const BasvuruOzetCard({super.key, required this.basvuru});

  @override
  State<BasvuruOzetCard> createState() => _BasvuruOzetCardState();
}

class _BasvuruOzetCardState extends State<BasvuruOzetCard> {
  final MusteriServisi _musteriServisi = MusteriServisi();
  final KullaniciServisi _kullaniciServisi = KullaniciServisi();

  String _musteriAdi = 'Yükleniyor...';
  String _danismanAdi = 'Atanmamış';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final musteri = await _musteriServisi.getMusteriById(widget.basvuru.musteriId);
    if (mounted && musteri != null) {
      setState(() {
        _musteriAdi = musteri.adSoyad;
      });
    }

    if (widget.basvuru.atananDanismanId != null && widget.basvuru.atananDanismanId!.isNotEmpty) {
      final danisman = await _kullaniciServisi.getUserById(widget.basvuru.atananDanismanId!);
      if (mounted && danisman != null) {
        setState(() {
          _danismanAdi = danisman.displayName ?? 'İsimsiz Danışman';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      // Global CardTheme'den stil alacak
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => BasvuruDetay(basvuruId: widget.basvuru.id),
          ));
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: colorScheme.primaryContainer,
                child: Text(
                  _musteriAdi.isNotEmpty ? _musteriAdi[0] : '?',
                  style: TextStyle(color: colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_musteriAdi, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Başvuru: ${widget.basvuru.basvuruTuru}', style: textTheme.bodyMedium),
                    Text('Danışman: $_danismanAdi', style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                DateFormat('dd/MM/yy').format(widget.basvuru.olusturulmaTarihi.toDate()),
                style: textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 