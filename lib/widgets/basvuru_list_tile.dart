import 'package:crm/models/basvuru_model.dart';
import 'package:crm/models/kullanici_model.dart';
import 'package:crm/models/musteri_model.dart';
import 'package:crm/screens/basvuru_detay.dart';
import 'package:crm/services/kullanici_servisi.dart';
import 'package:crm/services/musteri_servisi.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BasvuruListTile extends StatefulWidget {
  final BasvuruModel basvuru;

  const BasvuruListTile({super.key, required this.basvuru});

  @override
  State<BasvuruListTile> createState() => _BasvuruListTileState();
}

class _BasvuruListTileState extends State<BasvuruListTile> {
  MusteriModel? _musteri;
  KullaniciModel? _danisman;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final musteriServisi = MusteriServisi();
    final kullaniciServisi = KullaniciServisi();
    
    final musteri = await musteriServisi.getMusteriById(widget.basvuru.musteriId);
    
    KullaniciModel? danisman;
    if (widget.basvuru.atananDanismanId != null && widget.basvuru.atananDanismanId!.isNotEmpty) {
      danisman = await kullaniciServisi.getUserById(widget.basvuru.atananDanismanId!);
    }

    if (mounted) {
      setState(() {
        _musteri = musteri;
        _danisman = danisman;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_musteri == null) {
      return const Card(
        child: ListTile(
          title: Text('Yükleniyor...'),
        ),
      );
    }

    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Text(_musteri!.ad.isNotEmpty ? _musteri!.ad[0] : '?'),
        ),
        title: Text(_musteri!.adSoyad, style: textTheme.titleMedium),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.basvuru.basvuruTuru),
            if (_danisman != null)
              Text('Danışman: ${_danisman!.displayName ?? '...'}', style: textTheme.bodySmall),
          ],
        ),
        trailing: _buildStatusChip(widget.basvuru.durum, context),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => BasvuruDetay(basvuruId: widget.basvuru.id),
          ));
        },
      ),
    );
  }

  Widget _buildStatusChip(BasvuruDurumu durum, BuildContext context) {
    Color chipColor;
    IconData chipIcon;

    switch (durum) {
      case BasvuruDurumu.yeni:
        chipColor = Colors.blue;
        chipIcon = Icons.new_releases;
        break;
      case BasvuruDurumu.islemde:
        chipColor = Colors.orange;
        chipIcon = Icons.hourglass_top;
        break;
      case BasvuruDurumu.tamamlandi:
        chipColor = Colors.green;
        chipIcon = Icons.check_circle;
        break;
      case BasvuruDurumu.iptal:
        chipColor = Colors.red;
        chipIcon = Icons.cancel;
        break;
    }

    return Chip(
      avatar: Icon(chipIcon, color: Colors.white, size: 16),
      label: Text(
        durum.displayName,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      backgroundColor: chipColor,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
    );
  }
} 