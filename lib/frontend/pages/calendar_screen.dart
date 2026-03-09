import 'package:flutter/material.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  int _viewIndex = 0; // 0=Month, 1=Week, 2=Day
  int _filterIndex = 1; // 0=Classes, 1=Assignments, 2=Exams

  // Demo selected date highlight (Sep 5)
  final int _selectedDay = 5;

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

              _todayHeader(),
              const SizedBox(height: 12),

              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: const [
                    _ScheduleCard(
                      time: "09:00",
                      ampm: "AM",
                      dotColor: _C.tealDot,
                      title: "Advanced Psych Statistics",
                      subtitle1: "Hall B-12",
                      subtitle2: "1h 30m",
                      rightTop: "SEP 5, TUE",
                    ),
                    SizedBox(height: 12),
                    _ScheduleCard(
                      time: "11:59",
                      ampm: "PM",
                      dotColor: _C.yellowDot,
                      title: "Submit Term Paper",
                      subtitle1: "Canvas Submission",
                      badge: "URGENT",
                    ),
                    SizedBox(height: 12),
                    _ScheduleCard(
                      time: "02:30",
                      ampm: "PM",
                      dotColor: _C.tealDot,
                      title: "Organic Chemistry Lab",
                      subtitle1: "Canceled by Professor",
                      isCancelled: true,
                    ),
                  ],
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
        onTap: () => setState(() => _viewIndex = index),
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
      // Assignments pill in screenshot looks olive
      bg = selected ? _C.olive : Colors.transparent;
      border = _C.oliveBorder;
    } else {
      bg = selected ? _C.pillSelected : Colors.transparent;
      border = _C.pillBorder;
    }

    return GestureDetector(
      onTap: () => setState(() => _filterIndex = index),
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
          style: TextStyle(
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
        _circleIcon(Icons.chevron_left_rounded),
        const Text(
          "September 2023",
          style: TextStyle(
            color: _C.textDim,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        _circleIcon(Icons.chevron_right_rounded),
      ],
    );
  }

  Widget _circleIcon(IconData icon) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _C.stroke),
      ),
      child: Icon(icon, color: _C.textDim),
    );
  }

  Widget _calendarGrid() {
    // Simple month layout demo (not real date calculation, just matches UI look)
    const weekDays = ["S", "M", "T", "W", "T", "F", "S"];

    // leading blanks + days (roughly like screenshot)
    final cells = <String?>[
      null,
      null,
      null,
      "1",
      "2",
      "3",
      "4",
      "5",
      "6",
      "7",
      "8",
      "9",
      "10",
      "11",
      "12",
      null,
      null,
      null,
      null,
      null,
      null,
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
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
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cells.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 10,
              crossAxisSpacing: 6,
              childAspectRatio: 1.0,
            ),
            itemBuilder: (_, i) {
              final value = cells[i];
              if (value == null) return const SizedBox.shrink();

              final day = int.tryParse(value) ?? 0;
              final selected = day == _selectedDay;

              return Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: selected ? _C.accent : Colors.transparent,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: selected ? Colors.transparent : Colors.transparent,
                    ),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: _C.accent.withOpacity(0.25),
                              blurRadius: 18,
                              spreadRadius: 1,
                            ),
                          ]
                        : [],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    value,
                    style: TextStyle(
                      color: selected ? _C.bg : _C.text,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _todayHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        Text(
          "Today's Schedule",
          style: TextStyle(
            color: _C.text,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          "SEP 5, TUE",
          style: TextStyle(
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
        onPressed: () {
          // TODO: open add-event bottomsheet
        },
        backgroundColor: _C.accent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add_rounded, color: _C.bg, size: 28),
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final String time;
  final String ampm;
  final Color dotColor;
  final String title;
  final String subtitle1;
  final String? subtitle2;
  final String? badge;
  final bool isCancelled;
  final String? rightTop;

  const _ScheduleCard({
    required this.time,
    required this.ampm,
    required this.dotColor,
    required this.title,
    required this.subtitle1,
    this.subtitle2,
    this.badge,
    this.isCancelled = false,
    this.rightTop,
  });

  @override
  Widget build(BuildContext context) {
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
          // Time column
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

          // Divider line
          Container(
            width: 1,
            height: 62,
            margin: const EdgeInsets.only(top: 4, right: 12),
            color: _C.stroke,
          ),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (rightTop != null)
                  Align(
                    alignment: Alignment.topRight,
                    child: Text(
                      rightTop!,
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
                        title,
                        style: TextStyle(
                          color: isCancelled ? _C.textDim : _C.text,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          decoration: isCancelled
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                _metaRow(
                  Icons.location_on_outlined,
                  subtitle1,
                  dim: isCancelled,
                ),

                if (subtitle2 != null) ...[
                  const SizedBox(height: 6),
                  _metaRow(
                    Icons.access_time_rounded,
                    subtitle2!,
                    dim: isCancelled,
                  ),
                ],

                if (badge != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _C.badgeBg,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      badge!,
                      style: const TextStyle(
                        color: _C.badgeText,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.6,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metaRow(IconData icon, String text, {bool dim = false}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: dim ? _C.textDim : _C.textDim),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: dim ? _C.textDim : _C.textDim,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _C {
  // Background & surfaces
  static const bg = Color(0xFF0E1B1A);
  static const card = Color(0xFF132524);
  static const stroke = Color(0xFF1F3B39);

  // Text
  static const text = Color(0xFFEAF6F4);
  static const textDim = Color(0xFF9AB7B3);

  // Accents
  static const accent = Color(0xFF2ED1B2);
  static const iconBg = Color(0xFF0F2A26);

  // Segmented
  static const segmentBg = Color(0xFF163432);
  static const segmentSelected = Color(0xFF0F2A26);

  // Pills
  static const pillBorder = Color(0xFF2ED1B2);
  static const pillSelected = Color(0xFF0F2A26);

  // Olive assignments pill
  static const olive = Color(0xFF535A1F);
  static const oliveBorder = Color(0xFFB8C05A);

  // Dots
  static const tealDot = Color(0xFF2ED1B2);
  static const yellowDot = Color(0xFFF2C94C);

  // Badge
  static const badgeBg = Color(0xFF3B3B10);
  static const badgeText = Color(0xFFE9E27A);
}
