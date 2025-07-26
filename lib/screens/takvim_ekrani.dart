import 'package:crm/models/musteri_model.dart';
import 'package:crm/models/randevu_model.dart';
import 'package:crm/services/musteri_servisi.dart';
import 'package:crm/services/randevu_servisi.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class TakvimEkrani extends StatefulWidget {
  const TakvimEkrani({super.key});

  @override
  State<TakvimEkrani> createState() => _TakvimEkraniState();
}

class _TakvimEkraniState extends State<TakvimEkrani> {
  final RandevuServisi _randevuServisi = RandevuServisi();
  late final ValueNotifier<List<RandevuModel>> _selectedEvents;
  
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<RandevuModel>> _events = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
    _loadFirestoreEvents();
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  void _loadFirestoreEvents() {
    _randevuServisi.getRandevular(_focusedDay).listen((snapshot) {
      final Map<DateTime, List<RandevuModel>> events = {};
      for (var doc in snapshot) {
        final day = DateTime.utc(doc.tarih.year, doc.tarih.month, doc.tarih.day);
        if (events[day] == null) {
          events[day] = [];
        }
        events[day]!.add(doc);
      }
      setState(() {
        _events = events;
      });
      _selectedEvents.value = _getEventsForDay(_selectedDay!);
    });
  }

  List<RandevuModel> _getEventsForDay(DateTime day) {
    return _events[DateTime.utc(day.year, day.month, day.day)] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Takvim'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TableCalendar<RandevuModel>(
              locale: 'tr_TR',
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              calendarFormat: _calendarFormat,
              eventLoader: _getEventsForDay,
              onDaySelected: _onDaySelected,
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                }
              },
              onPageChanged: (focusedDay) {
                setState(() {
                  _focusedDay = focusedDay;
                });
                _loadFirestoreEvents();
              },
              // STYLING BAŞLANGICI
              headerStyle: const HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
                titleTextStyle: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  shape: BoxShape.circle,
                ),
                outsideDaysVisible: false,
              ),
              // STYLING BİTİŞİ
              calendarBuilders: CalendarBuilders(
                 defaultBuilder: (context, day, focusedDay) {
                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.5), width: 0.5),
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: const TextStyle(),
                      ),
                    ),
                  );
                },
                todayBuilder: (context, day, focusedDay) {
                   return Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                      shape: BoxShape.circle,
                       border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.5), width: 0.5),
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                },
                selectedBuilder: (context, day, focusedDay) {
                  return Container(
                    decoration: BoxDecoration(
                       color: Theme.of(context).colorScheme.primary,
                       shape: BoxShape.circle,
                        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.5), width: 0.5),
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                },
                markerBuilder: (context, date, events) {
                  if (events.isNotEmpty) {
                    return Positioned(
                      right: 1,
                      bottom: 1,
                      child: _buildEventsMarker(date, events),
                    );
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: ValueListenableBuilder<List<RandevuModel>>(
                valueListenable: _selectedEvents,
                builder: (context, value, _) {
                  if (value.isEmpty) {
                    return const Center(child: Text('Seçili gün için randevu bulunmuyor.'));
                  }
                  return ListView.builder(
                    itemCount: value.length,
                    itemBuilder: (context, index) {
                      final event = value[index];
                      return Card(
                        child: ListTile(
                          title: Text(event.baslik),
                          subtitle: Text(event.not ?? ''),
                          trailing: Text(DateFormat.Hm().format(event.tarih)),
                          onTap: () => _showMusteriDetayDialog(event.musteriId),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMusteriDetayDialog(String musteriId) {
    final MusteriServisi musteriServisi = MusteriServisi();
    showDialog(
      context: context,
      builder: (context) {
        return FutureBuilder<MusteriModel?>(
          future: musteriServisi.getMusteriById(musteriId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const AlertDialog(
                title: Text('Müşteri Bilgileri'),
                content: Center(child: CircularProgressIndicator()),
              );
            }
            if (!snapshot.hasData || snapshot.data == null) {
              return const AlertDialog(
                title: Text('Hata'),
                content: Text('Müşteri bilgileri bulunamadı.'),
              );
            }

            final musteri = snapshot.data!;
            return AlertDialog(
              title: Text(musteri.adSoyad),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    _buildInfoRow(Icons.email, 'E-posta', musteri.email),
                    _buildInfoRow(Icons.phone, 'Telefon', musteri.telefon),
                    _buildInfoRow(Icons.flag, 'Başvuru Ülkesi', musteri.basvuruUlkesi),
                    _buildInfoRow(Icons.location_on, 'Adres', musteri.adres),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Kapat'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(value),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsMarker(DateTime date, List events) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).primaryColor,
      ),
      width: 16.0,
      height: 16.0,
      child: Center(
        child: Text(
          '${events.length}',
          style: const TextStyle().copyWith(
            color: Colors.white,
            fontSize: 12.0,
          ),
        ),
      ),
    );
  }
} 