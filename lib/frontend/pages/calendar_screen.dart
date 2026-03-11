import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../backend/models/calendar_schedule.dart';
import '../../backend/services/calendar_service.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final CalendarService _service = CalendarService();

  int _viewIndex = 0; // 0=Month, 1=Week, 2=Day
  int _filterIndex = 1; // 0=Classes, 1=Assignments, 2=Exams

  DateTime _currentMonth = DateTime.now();
  DateTime _selectedDate = DateTime.now();

  List<CalendarSchedule> _visibleSchedules = [];
  List<CalendarSchedule> _monthSchedules = [];

  @override
  void initState() {
    super.initState();
    _refreshSchedules();
    _service.checkExpiredAndNotify();
  }

  Future<void> _refreshSchedules() async {
    List<CalendarSchedule> items;
    List<CalendarSchedule> monthItems = await _service.getSchedulesForMonth(
      _currentMonth,
    );

    if (_viewIndex == 0) {
      items = await _service.getSchedulesForMonth(_currentMonth);
    } else if (_viewIndex == 1) {
      items = await _service.getSchedulesForWeek(_selectedDate);
    } else {
      items = await _service.getSchedulesForDay(_selectedDate);
    }

    items = _applyTypeFilter(items);

    setState(() {
      _visibleSchedules = items;
      _monthSchedules = monthItems;
    });
  }

  List<CalendarSchedule> _applyTypeFilter(List<CalendarSchedule> items) {
    final type = _selectedTypeName();
    return items.where((e) => e.type.toLowerCase() == type).toList();
  }

  String _selectedTypeName() {
    if (_filterIndex == 0) return 'class';
    if (_filterIndex == 1) return 'assignment';
    return 'exam';
  }

  Future<void> _toggleCompleted(CalendarSchedule item) async {
    await _service.toggleCompleted(item.id);
    await _refreshSchedules();
  }

  Future<void> _openAddDialog() async {
    final titleController = TextEditingController();
    final placeController = TextEditingController();
    final durationController = TextEditingController();

    String selectedType = 'assignment';
    DateTime chosenDate = _selectedDate;
    TimeOfDay chosenTime = TimeOfDay.now();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: _C.card,
          title: const Text('Add Schedule', style: TextStyle(color: _C.text)),
          content: StatefulBuilder(
            builder: (context, setInnerState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _dialogField(titleController, 'Title'),
                    const SizedBox(height: 10),
                    _dialogField(placeController, 'Place'),
                    const SizedBox(height: 10),
                    _dialogField(durationController, 'Duration'),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: selectedType,
                      dropdownColor: _C.card,
                      style: const TextStyle(color: _C.text),
                      decoration: _dialogDecoration('Type'),
                      items: const [
                        DropdownMenuItem(value: 'class', child: Text('Class')),
                        DropdownMenuItem(
                          value: 'assignment',
                          child: Text('Assignment'),
                        ),
                        DropdownMenuItem(value: 'exam', child: Text('Exam')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setInnerState(() => selectedType = value);
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Date: ${DateFormat('yyyy-MM-dd').format(chosenDate)}',
                        style: const TextStyle(color: _C.text),
                      ),
                      trailing: const Icon(
                        Icons.calendar_today,
                        color: _C.accent,
                      ),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: chosenDate,
                          firstDate: DateTime(2024),
                          lastDate: DateTime(2035),
                        );
                        if (picked != null) {
                          setInnerState(() => chosenDate = picked);
                        }
                      },
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Time: ${chosenTime.format(context)}',
                        style: const TextStyle(color: _C.text),
                      ),
                      trailing: const Icon(Icons.access_time, color: _C.accent),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: chosenTime,
                        );
                        if (picked != null) {
                          setInnerState(() => chosenTime = picked);
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: Navigator.of(context).pop,
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final dateTime = DateTime(
                  chosenDate.year,
                  chosenDate.month,
                  chosenDate.day,
                  chosenTime.hour,
                  chosenTime.minute,
                );

                final item = CalendarSchedule(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: titleController.text.trim(),
                  type: selectedType,
                  startDateTime: dateTime,
                  deadline: dateTime,
                  place: placeController.text.trim(),
                  durationText: durationController.text.trim().isEmpty
                      ? null
                      : durationController.text.trim(),
                  badge: '',
                  isCompleted: false,
                  isManuallyCreated: true,
                );

                await _service.addManualSchedule(item);
                if (mounted) Navigator.pop(context);
                await _refreshSchedules();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  InputDecoration _dialogDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: _C.textDim),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: _C.stroke),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: _C.accent),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _dialogField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: _C.text),
      decoration: _dialogDecoration(label),
    );
  }

  void _goToPrevMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    });
    _refreshSchedules();
  }

  void _goToNextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    });
    _refreshSchedules();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _topBar(context),
              const SizedBox(height: 14),
              _segmentedView(),
              const SizedBox(height: 16),
              _filtersRow(),
              const SizedBox(height: 18),
              _monthHeader(),
              const SizedBox(height: 12),
              _calendarGrid(),
              const SizedBox(height: 18),
              _sectionHeader(),
              const SizedBox(height: 12),
              Expanded(
                child: _visibleSchedules.isEmpty
                    ? const Center(
                        child: Text(
                          'No schedules found',
                          style: TextStyle(color: _C.textDim),
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: _visibleSchedules.length,
                        itemBuilder: (context, index) {
                          final item = _visibleSchedules[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _ScheduleCard(
                              schedule: item,
                              onComplete: () => _toggleCompleted(item),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _fab(),
    );
  }

  Widget _topBar(BuildContext context) {
    return Row(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => Navigator.pop(context),
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: _C.text,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: _C.iconBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.calendar_month_rounded,
            color: _C.accent,
            size: 20,
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          "Calendar",
          style: TextStyle(
            color: _C.text,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _segmentedView() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: _C.segmentBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.stroke),
      ),
      child: Row(
        children: [
          _segmentItem("Month", 0),
          _segmentItem("Week", 1),
          _segmentItem("Day", 2),
        ],
      ),
    );
  }

  Widget _segmentItem(String label, int index) {
    final bool selected = _viewIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () async {
          setState(() => _viewIndex = index);
          await _refreshSchedules();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? _C.segmentSelected : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? _C.text : _C.textDim,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _filtersRow() {
    return Row(
      children: [
        Expanded(child: _pill("CLASSES", 0)),
        const SizedBox(width: 10),
        Expanded(child: _pill("ASSIGNMENTS", 1)),
        const SizedBox(width: 10),
        Expanded(child: _pill("EXAMS", 2)),
      ],
    );
  }

  Widget _pill(String text, int index) {
    final bool selected = _filterIndex == index;

    Color bg;
    Color border;
    if (index == 1) {
      bg = selected ? _C.olive : Colors.transparent;
      border = _C.oliveBorder;
    } else {
      bg = selected ? _C.pillSelected : Colors.transparent;
      border = _C.pillBorder;
    }

    return GestureDetector(
      onTap: () async {
        setState(() => _filterIndex = index);
        await _refreshSchedules();
      },
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: border, width: 1.2),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: const TextStyle(
            color: _C.text,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _monthHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _circleIcon(Icons.chevron_left_rounded, _goToPrevMonth),
        Text(
          DateFormat('MMMM yyyy').format(_currentMonth),
          style: const TextStyle(
            color: _C.textDim,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        _circleIcon(Icons.chevron_right_rounded, _goToNextMonth),
      ],
    );
  }

  Widget _circleIcon(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: _C.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _C.stroke),
        ),
        child: Icon(icon, color: _C.textDim),
      ),
    );
  }

  Widget _calendarGrid() {
    final firstDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month,
      1,
    );
    final daysInMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month + 1,
      0,
    ).day;
    final leadingEmpty = firstDayOfMonth.weekday % 7;

    final cells = <Widget>[];

    for (int i = 0; i < leadingEmpty; i++) {
      cells.add(const SizedBox.shrink());
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, day);
      final isSelected =
          date.year == _selectedDate.year &&
          date.month == _selectedDate.month &&
          date.day == _selectedDate.day;

      final hasSchedule = _monthSchedules.any(
        (e) =>
            e.startDateTime.year == date.year &&
            e.startDateTime.month == date.month &&
            e.startDateTime.day == date.day,
      );

      cells.add(
        GestureDetector(
          onTap: () async {
            setState(() => _selectedDate = date);
            await _refreshSchedules();
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? _C.accent : Colors.transparent,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  '$day',
                  style: TextStyle(
                    color: isSelected ? _C.bg : _C.text,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (hasSchedule)
                  const Positioned(
                    bottom: 4,
                    child: CircleAvatar(
                      radius: 2.5,
                      backgroundColor: _C.yellowDot,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    const weekDays = ["S", "M", "T", "W", "T", "F", "S"];

    return Column(
      children: [
        Row(
          children: weekDays
              .map(
                (d) => Expanded(
                  child: Center(
                    child: Text(
                      d,
                      style: const TextStyle(
                        color: _C.textDim,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          crossAxisCount: 7,
          mainAxisSpacing: 10,
          crossAxisSpacing: 6,
          childAspectRatio: 1,
          physics: const NeverScrollableScrollPhysics(),
          children: cells,
        ),
      ],
    );
  }

  Widget _sectionHeader() {
    String title = 'Selected Schedules';
    if (_viewIndex == 0) title = 'Monthly Schedules';
    if (_viewIndex == 1) title = 'Weekly Schedules';
    if (_viewIndex == 2) title = 'Daily Schedules';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: _C.text,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          DateFormat('MMM d, yyyy').format(_selectedDate),
          style: const TextStyle(
            color: _C.textDim,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
        ),
      ],
    );
  }

  Widget _fab() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _C.accent.withOpacity(0.35),
            blurRadius: 20,
            spreadRadius: 1,
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: _openAddDialog,
        backgroundColor: _C.accent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add_rounded, color: _C.bg, size: 28),
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final CalendarSchedule schedule;
  final VoidCallback onComplete;

  const _ScheduleCard({required this.schedule, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    final time = DateFormat('hh:mm').format(schedule.startDateTime);
    final ampm = DateFormat('a').format(schedule.startDateTime);

    final isExpired = schedule.isExpired;
    final isCancelled = schedule.badge.toUpperCase() == 'CANCELLED';

    Color dotColor = _C.tealDot;
    if (schedule.type == 'assignment') dotColor = _C.yellowDot;
    if (schedule.type == 'exam') dotColor = const Color(0xFFFF8A65);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _C.stroke),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 62,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    color: isCancelled ? _C.textDim : _C.text,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  ampm,
                  style: TextStyle(
                    color: isCancelled ? _C.textDim : _C.textDim,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 70,
            margin: const EdgeInsets.only(top: 4, right: 12),
            color: _C.stroke,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Text(
                    DateFormat(
                      'MMM d, EEE',
                    ).format(schedule.startDateTime).toUpperCase(),
                    style: const TextStyle(
                      color: _C.textDim,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: dotColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        schedule.title,
                        style: TextStyle(
                          color: isCancelled ? _C.textDim : _C.text,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          decoration: schedule.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: onComplete,
                      icon: Icon(
                        schedule.isCompleted
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: schedule.isCompleted
                            ? Colors.greenAccent
                            : _C.textDim,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _metaRow(Icons.location_on_outlined, schedule.place),
                if ((schedule.durationText ?? '').isNotEmpty) ...[
                  const SizedBox(height: 6),
                  _metaRow(Icons.access_time_rounded, schedule.durationText!),
                ],
                if (isExpired) ...[
                  const SizedBox(height: 10),
                  _badge(
                    'EXPIRED',
                    const Color(0xFF5C1F1F),
                    const Color(0xFFFF9E9E),
                  ),
                ] else if (schedule.isCompleted) ...[
                  const SizedBox(height: 10),
                  _badge(
                    'COMPLETED',
                    const Color(0xFF163D25),
                    const Color(0xFF8CFFB5),
                  ),
                ] else if (schedule.badge.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _badge(schedule.badge, _C.badgeBg, _C.badgeText),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metaRow(IconData icon, String text) {
    return Row(
      children: [
        const SizedBox(width: 0),
        Icon(icon, size: 16, color: _C.textDim),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: _C.textDim,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _badge(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.6,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _C {
  static const bg = Color(0xFF0E1B1A);
  static const card = Color(0xFF132524);
  static const stroke = Color(0xFF1F3B39);

  static const text = Color(0xFFEAF6F4);
  static const textDim = Color(0xFF9AB7B3);

  static const accent = Color(0xFF2ED1B2);
  static const iconBg = Color(0xFF0F2A26);

  static const segmentBg = Color(0xFF163432);
  static const segmentSelected = Color(0xFF0F2A26);

  static const pillBorder = Color(0xFF2ED1B2);
  static const pillSelected = Color(0xFF0F2A26);

  static const olive = Color(0xFF535A1F);
  static const oliveBorder = Color(0xFFB8C05A);

  static const tealDot = Color(0xFF2ED1B2);
  static const yellowDot = Color(0xFFF2C94C);

  static const badgeBg = Color(0xFF3B3B10);
  static const badgeText = Color(0xFFE9E27A);
}
