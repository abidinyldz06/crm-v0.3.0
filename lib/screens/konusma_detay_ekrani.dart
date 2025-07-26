import 'package:crm/models/konusma_model.dart';
import 'package:crm/models/mesaj_model.dart';
import 'package:crm/services/mesajlasma_servisi.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class KonusmaDetayEkrani extends StatefulWidget {
  final KonusmaModel konusma;
  // TODO: Konuşma başlığı için katılımcı isimleri de buraya paslanabilir.
  const KonusmaDetayEkrani({super.key, required this.konusma});

  @override
  State<KonusmaDetayEkrani> createState() => _KonusmaDetayEkraniState();
}

class _KonusmaDetayEkraniState extends State<KonusmaDetayEkrani> {
  final MesajlasmaServisi _mesajlasmaServisi = MesajlasmaServisi();
  final TextEditingController _mesajController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final String? _currentUserUid = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _mesajlasmaServisi.konusmayiOkunduIsaretle(widget.konusma.id);
  }

  void _mesajGonder() {
    _mesajlasmaServisi.mesajGonder(widget.konusma.id, _mesajController.text);
    _mesajController.clear();
    // Scroll'u en aşağı kaydır
     _scrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Konuşma Detayı"), // Başlık daha sonra dinamikleşecek
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<MesajModel>>(
              stream: _mesajlasmaServisi.getMesajlar(widget.konusma.id),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final mesajlar = snapshot.data!;
                return ListView.builder(
                  controller: _scrollController,
                  reverse: true, // Mesajları aşağıdan yukarıya sıralar
                  itemCount: mesajlar.length,
                  itemBuilder: (context, index) {
                    final mesaj = mesajlar[index];
                    final isCurrentUser = mesaj.gonderenId == _currentUserUid;
                    return _MesajBalonu(mesaj: mesaj, isCurrentUser: isCurrentUser);
                  },
                );
              },
            ),
          ),
          _buildMesajGondermeAlani(),
        ],
      ),
    );
  }

  Widget _buildMesajGondermeAlani() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: const [BoxShadow(blurRadius: 2, color: Colors.black12)],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _mesajController,
              decoration: const InputDecoration.collapsed(hintText: 'Mesajınızı yazın...'),
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _mesajController.text.trim().isEmpty ? null : _mesajGonder,
            color: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }
}

class _MesajBalonu extends StatelessWidget {
  final MesajModel mesaj;
  final bool isCurrentUser;

  const _MesajBalonu({required this.mesaj, required this.isCurrentUser});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isCurrentUser ? Theme.of(context).primaryColor : Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          mesaj.metin,
          style: TextStyle(color: isCurrentUser ? Colors.white : Colors.black),
        ),
      ),
    );
  }
} 