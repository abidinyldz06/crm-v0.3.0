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
  final Map<String, Color> _customerColorMap = {};
  final List<Color> _palette = const [
    Color(0xFF5B8DEF),
    Color(0xFF6DD3C1),
    Color(0xFFFFC857),
    Color(0xFFFF6B6B),
    Color(0xFFA78BFA),
    Color(0xFF34D399),
    Color(0xFFF472B6),
    Color(0xFF60A5FA),
  ];

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
        events.putIfAbsent(day, () => []);
        events[day]!.add(doc);

        // Müşteri renk eşlemesi
        if (!_customerColorMap.containsKey(doc.musteriId)) {
          final idx = (_customerColorMap.length) % _palette.length;
          _customerColorMap[doc.musteriId] = _palette[idx];
        }
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

  void _goToPreviousPage() {
    // Bir önceki aya/haftaya geç
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
      _selectedDay = DateTime(_focusedDay.year, _focusedDay.month, 1);
    });
    _loadFirestoreEvents();
  }

  void _goToNextPage() {
    // Bir sonraki aya/haftaya geç
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
      _selectedDay = DateTime(_focusedDay.year, _focusedDay.month, 1);
    });
    _loadFirestoreEvents();
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
            // Modern başlık + format butonları
            _buildCalendarHeader(context),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.5)),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              child: TableCalendar<RandevuModel>(
                locale: 'tr_TR',
                firstDay: DateTime.utc(2000, 1, 1),
                lastDay: DateTime.utc(2100, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                calendarFormat: _calendarFormat,
                startingDayOfWeek: StartingDayOfWeek.monday,
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
                // Geçmiş/gelecek aya geçişi garanti etmek için odak ve seçimi yeni sayfaya sabitle
                setState(() {
                  _focusedDay = focusedDay;
                  _selectedDay = DateTime(focusedDay.year, focusedDay.month, 1);
                });
                _loadFirestoreEvents();
              },
                // STYLING BAŞLANGICI
                headerVisible: false,
                daysOfWeekVisible: true,
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  outsideDaysVisible: true, // önceki/sonraki ay günlerini de göster
                  cellMargin: const EdgeInsets.all(3),
                  cellPadding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                  // Haftanın gün isimleri stilini belirgin yap
                  tablePadding: const EdgeInsets.only(top: 4),
                  // Not: table_calendar 3.2.0 sürümünde cellDecoration parametresi yok.
                  // Hücre kenarlıklarını _buildDayCell içinde BoxDecoration ile verdik.
                  // Burada ek bir stil gerekmiyor.
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekendStyle: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.9),
                  ),
                  weekdayStyle: TextStyle(
                    fontWeight: FontWeight.w900, // daha kalın
                    letterSpacing: 0.2,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.95),
                  ),
                ),
                // STYLING BİTİŞİ
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, day, events) {
                    // Varsayılan siyah noktayı tamamen KALDIR
                    return const SizedBox.shrink();
                  },
                  dowBuilder: (context, day) {
                    // Haftanın gün başlıkları: daha okunaklı kısaltmalar
                    final text = DateFormat.E('tr_TR').format(day); // Pzt, Sal, ...
                    return Center(
                      child: Text(
                        text.toUpperCase(), // okunurluğu artır
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.9),
                            ),
                      ),
                    );
                  },
                  defaultBuilder: (context, day, focusedDay) {
                    return _buildDayCell(context, day, _getEventsForDay(day), isToday: false, isSelected: false);
                  },
                  todayBuilder: (context, day, focusedDay) {
                    return _buildDayCell(context, day, _getEventsForDay(day), isToday: true, isSelected: false);
                  },
                  selectedBuilder: (context, day, focusedDay) {
                    return _buildDayCell(context, day, _getEventsForDay(day), isToday: false, isSelected: true);
                  },
                ),
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

  // Modern başlık
  Widget _buildCalendarHeader(BuildContext context) {
    final monthText = DateFormat.yMMMM('tr_TR').format(_focusedDay);
    return Row(
      children: [
        // Sol ok: görünür ve tıklanabilir büyük buton
        IconButton.filledTonal(
          tooltip: 'Önceki',
          iconSize: 28,
          style: ButtonStyle(
            shape: WidgetStateProperty.all(const CircleBorder()),
            padding: WidgetStateProperty.all(const EdgeInsets.all(6)),
          ),
          icon: const Icon(Icons.chevron_left),
          onPressed: _goToPreviousPage,
        ),
        const SizedBox(width: 8),
        // Başlık
        Text(
          monthText,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(width: 8),
        // Sağ ok: görünür ve tıklanabilir büyük buton
        IconButton.filledTonal(
          tooltip: 'Sonraki',
          iconSize: 28,
          style: ButtonStyle(
            shape: WidgetStateProperty.all(const CircleBorder()),
            padding: WidgetStateProperty.all(const EdgeInsets.all(6)),
          ),
          icon: const Icon(Icons.chevron_right),
          onPressed: _goToNextPage,
        ),
        const Spacer(),
        SegmentedButton<CalendarFormat>(
          segments: const [
            ButtonSegment(value: CalendarFormat.month, label: Text('Ay')),
            ButtonSegment(value: CalendarFormat.twoWeeks, label: Text('2 Hafta')),
            ButtonSegment(value: CalendarFormat.week, label: Text('Hafta')),
          ],
          selected: <CalendarFormat>{_calendarFormat},
          onSelectionChanged: (v) {
            final f = v.first;
            setState(() => _calendarFormat = f);
          },
        ),
        const SizedBox(width: 12),
        FilledButton.tonal(
          onPressed: () {
            setState(() {
              _focusedDay = DateTime.now();
              _selectedDay = _focusedDay;
            });
          },
          child: const Text('Bugün'),
        ),
      ],
    );
  }

  // Modern gün hücresi: sol üstte gün numarası, altında müşteri isimleri chip’leri
  Widget _buildDayCell(BuildContext context, DateTime day, List<RandevuModel> events, {required bool isToday, required bool isSelected}) {
    final isOutsideMonth = day.month != _focusedDay.month;
    final borderColor = Theme.of(context).dividerColor.withValues(alpha: 0.4);

    final bgColor = isSelected
        ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.12)
        : isToday
            ? Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.25)
            : Colors.transparent;

    // Her hücre için sabit, güvenli bir yükseklik: overflow'u tamamen engelle
    // Ekran genişliğine göre hücre yüksekliğini biraz küçült (overflow'u azalt)
    final gridWidth = MediaQuery.of(context).size.width - 32; // padding hariç yaklaşık
    final approxCell = (gridWidth / 7) * 0.58; // daha kompakt, overflow riskini azalt
    final cellHeight = approxCell.clamp(36.0, 44.0);
    return InkWell(
      onTap: () => _onDaySelected(day, day),
      child: SizedBox(
        height: cellHeight,
        child: Container(
          margin: const EdgeInsets.all(2),
          padding: const EdgeInsets.fromLTRB(6, 4, 6, 4), // alt boşluğu azalt
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.7), width: 1.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Üst satır: gün rozeti + sayaç
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${day.day}',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (events.isNotEmpty)
                    Expanded(
                      child: Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: 26, // biraz küçült
                          height: 26,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.20),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.18),
                                blurRadius: 6,
                                offset: const Offset(0, 1.5),
                              ),
                            ],
                            border: Border.all(
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            '${events.length}',
                            style: TextStyle(
                              fontSize: 13.5, // 14 -> 13.5
                              height: 1.0,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              // Alt kısım boş bırakıldı: hücrede yalnız sayaç olacak
              // (TableCalendar varsayılan event noktasını tamamen kapatmak için)
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerChips(BuildContext context, List<RandevuModel> events, {int maxItems = 3, bool maxWidth = false}) {
    // Aynı gün içinde farklı müşterilerin isimlerini göster
    final names = <String>[];
    for (final e in events) {
      // RandevuModel'inde musteriAdi alanı yoksa, müşteri adını async çekmek yerine
      // kutucuk üzerinde kısa etiket için başlığı kullanıyoruz.
      final display = e.baslik;
      if (display.trim().isNotEmpty) {
        names.add(display.trim());
      }
    }
    // İlk 3’ünü göster
    final toShow = names.take(maxItems).toList();
    final overflow = names.length - toShow.length;

    final chips = <Widget>[
      for (final label in toShow)
        _chip(label, color: _colorForLabel(label)),
      if (overflow > 0)
        _chip('+$overflow', color: Theme.of(context).colorScheme.tertiary),
    ];

    if (maxWidth) {
      // Tek satıra sığdırmak için yatay kaydırma + kısıtlama
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        child: Row(children: [
          for (final c in chips) Padding(padding: const EdgeInsets.only(right: 4), child: c),
        ]),
      );
    }

    return Wrap(
      spacing: 4,
      runSpacing: -6,
      children: chips,
    );
  }

  Color _colorForLabel(String label) {
    // müşteriId tabanlı renk varsa kullan; yoksa label hash’inden üret
    // Burada label yerine deterministik ama basit bir seçim:
    final idx = (label.hashCode.abs()) % _palette.length;
    return _palette[idx];
  }

  Widget _chip(String text, {required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 0.7),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 9,
          color: color,
          fontWeight: FontWeight.w600,
          height: 1.0,
        ),
      ),
    );
  }
}
