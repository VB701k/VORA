import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ✅ IMPORTANT:
// Your repo currently doesn't have TaskStore/AppTask in the screenshot.
// So I removed TaskStore import to avoid errors.
// Later, when you add TaskStore, I can re-connect "Add to my Task".

class CourseworkBreakdownScreen extends StatefulWidget {
  const CourseworkBreakdownScreen({super.key});

  @override
  State<CourseworkBreakdownScreen> createState() =>
      _CourseworkBreakdownScreenState();
}

class _CourseworkBreakdownScreenState extends State<CourseworkBreakdownScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _partsCtrl = TextEditingController(text: '1');

  int get _parts => int.tryParse(_partsCtrl.text.trim()) ?? 1;

  DateTime? _deadline;

  bool _sameDeadlineForAll = true;
  List<DateTime?> _partDeadlines = [];

  bool _enableDeadlineNotifications = true;

  List<_PlanItem> _plan = [];

  final _df = DateFormat('EEE, MMM d • h:mm a');

  static const _bg = Color(0xFF062B3A);
  static const _card = Color(0xFF083445);
  static const _stroke = Color(0xFF2C5B6A);
  static const _accent = Color(0xFF55C3FF);
  static const _white = Color(0xFFEAF6FB);
  static const _muted = Color(0xFF9CC6D4);

  @override
  void dispose() {
    _titleCtrl.dispose();
    _partsCtrl.dispose();
    super.dispose();
  }

  void _syncDeadlines() {
    final p = _parts.clamp(1, 50);
    if (_partDeadlines.length < p) {
      _partDeadlines = [
        ..._partDeadlines,
        ...List<DateTime?>.filled(p - _partDeadlines.length, null),
      ];
    } else if (_partDeadlines.length > p) {
      _partDeadlines = _partDeadlines.sublist(0, p);
    }
  }

  Future<DateTime?> _pickDateTime(DateTime? initial) async {
    final now = DateTime.now();
    final init = initial ?? now.add(const Duration(days: 7));

    final date = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 5)),
      initialDate: init.isBefore(now) ? now : init,
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: _accent),
        ),
        child: child!,
      ),
    );
    if (date == null) return null;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial ?? now),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: _accent),
        ),
        child: child!,
      ),
    );
    if (time == null) return null;

    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: _card));
  }

  bool _validateDeadlines() {
    final now = DateTime.now();

    if (_parts == 1) {
      if (_deadline == null) {
        _toast('Select the deadline');
        return false;
      }
      if (_deadline!.isBefore(now)) {
        _toast('Deadline must be in the future');
        return false;
      }
      return true;
    }

    if (_sameDeadlineForAll) {
      if (_deadline == null) {
        _toast('Select the deadline for all parts');
        return false;
      }
      if (_deadline!.isBefore(now)) {
        _toast('Deadline must be in the future');
        return false;
      }
      return true;
    } else {
      _syncDeadlines();
      for (int i = 0; i < _parts; i++) {
        final d = _partDeadlines[i];
        if (d == null) {
          _toast('Select deadline for Part ${i + 1}');
          return false;
        }
        if (d.isBefore(now)) {
          _toast('Part ${i + 1} deadline must be in the future');
          return false;
        }
      }
      return true;
    }
  }

  void _generatePlan() {
    if (!_formKey.currentState!.validate()) return;
    if (!_validateDeadlines()) return;

    final p = _parts;

    final List<DateTime> deadlines = [];
    if (p == 1) {
      deadlines.add(_deadline!);
    } else if (_sameDeadlineForAll) {
      deadlines.addAll(List.generate(p, (_) => _deadline!));
    } else {
      deadlines.addAll(_partDeadlines.take(p).map((e) => e!));
    }

    final items = <_PlanItem>[];
    for (int i = 0; i < p; i++) {
      items.add(
        _PlanItem(
          title: 'Part ${i + 1} • ${_taskName(i, p)}',
          due: deadlines[i],
          done: false,
        ),
      );
    }

    setState(() => _plan = items);
    _toast('Plan generated');
  }

  String _taskName(int i, int total) {
    if (total == 1) return 'Complete coursework';
    if (i == 0) return 'Research & Outline';
    if (i == 1) return 'Draft Introduction';
    if (i == total - 1) return 'Final Review & Submit';
    return 'Write Section ${i + 1}';
  }

  // ✅ For now: just go back (later we connect TaskStore)
  void _addToMyTask() {
    if (_plan.isEmpty) {
      _toast('Generate plan first');
      return;
    }

    _toast(
      _enableDeadlineNotifications
          ? 'Saved (notifications ON) — TaskStore later'
          : 'Saved (notifications OFF) — TaskStore later',
    );

    Navigator.pop(context);
  }

  void _regenerate() {
    if (_plan.isEmpty) {
      _toast('Generate plan first');
      return;
    }
    _generatePlan();
  }

  InputDecoration _fieldDeco(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: _muted.withOpacity(0.7)),
      filled: true,
      fillColor: _card,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _stroke),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _accent, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _syncDeadlines();

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: _white),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'CourseWork Break Down',
          style: TextStyle(color: _white, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Coursework Title',
                  style: TextStyle(color: _white, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleCtrl,
                  style: const TextStyle(color: _white),
                  decoration: _fieldDeco('eg: SDGP Coursework'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Title required' : null,
                ),
                const SizedBox(height: 14),

                const Text(
                  'Number of Parts',
                  style: TextStyle(color: _white, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _partsCtrl,
                  style: const TextStyle(color: _white),
                  keyboardType: TextInputType.number,
                  decoration: _fieldDeco('Enter parts count (1-50)'),
                  onChanged: (_) {
                    setState(() {
                      _plan = [];
                      _deadline = null;
                      _syncDeadlines();
                    });
                  },
                  validator: (v) {
                    final n = int.tryParse((v ?? '').trim());
                    if (n == null || n < 1 || n > 50) return 'Enter 1-50';
                    return null;
                  },
                ),

                const SizedBox(height: 14),

                if (_parts == 1) ...[
                  const Text(
                    'Deadline',
                    style: TextStyle(
                      color: _white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _DeadlineButton(
                    text: _deadline == null
                        ? 'Select date and time'
                        : _df.format(_deadline!),
                    onTap: () async {
                      final picked = await _pickDateTime(_deadline);
                      if (picked == null) return;
                      setState(() => _deadline = picked);
                    },
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _stroke),
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Same deadline for all parts?',
                            style: TextStyle(
                              color: _white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        _Pill(
                          text: 'Yes',
                          active: _sameDeadlineForAll,
                          onTap: () => setState(() {
                            _sameDeadlineForAll = true;
                            _plan = [];
                          }),
                        ),
                        const SizedBox(width: 8),
                        _Pill(
                          text: 'No',
                          active: !_sameDeadlineForAll,
                          onTap: () => setState(() {
                            _sameDeadlineForAll = false;
                            _plan = [];
                          }),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  if (_sameDeadlineForAll) ...[
                    _DeadlineButton(
                      text: _deadline == null
                          ? 'Select deadline for all parts'
                          : 'Deadline: ${_df.format(_deadline!)}',
                      onTap: () async {
                        final picked = await _pickDateTime(_deadline);
                        if (picked == null) return;
                        setState(() => _deadline = picked);
                      },
                    ),
                  ] else ...[
                    for (int i = 0; i < _parts; i++) ...[
                      _DeadlineButton(
                        text: _partDeadlines[i] == null
                            ? 'Select deadline for Part ${i + 1}'
                            : 'Part ${i + 1}: ${_df.format(_partDeadlines[i]!)}',
                        onTap: () async {
                          final picked = await _pickDateTime(_partDeadlines[i]);
                          if (picked == null) return;
                          setState(() => _partDeadlines[i] = picked);
                        },
                      ),
                      const SizedBox(height: 8),
                    ],
                  ],
                ],

                const SizedBox(height: 10),

                Container(
                  decoration: BoxDecoration(
                    color: _card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _stroke),
                  ),
                  child: SwitchListTile(
                    activeColor: _accent,
                    value: _enableDeadlineNotifications,
                    onChanged: (v) =>
                        setState(() => _enableDeadlineNotifications = v),
                    title: const Text(
                      'Enable deadline notifications',
                      style: TextStyle(
                        color: _white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: const Text(
                      'UI only (TaskStore later)',
                      style: TextStyle(color: _muted),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accent,
                      foregroundColor: _bg,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _generatePlan,
                    child: const Text(
                      'Break it down',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                const Divider(color: _stroke),
                const SizedBox(height: 10),

                const Text(
                  'Your Study Plan',
                  style: TextStyle(color: _white, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),

                if (_plan.isEmpty)
                  const Text('No plan yet.', style: TextStyle(color: _muted))
                else
                  Column(
                    children: [
                      for (int i = 0; i < _plan.length; i++) ...[
                        _PlanTile(
                          item: _plan[i],
                          onToggle: () {
                            setState(() {
                              _plan[i] = _plan[i].copyWith(
                                done: !_plan[i].done,
                              );
                            });
                          },
                          df: _df,
                        ),
                        const SizedBox(height: 10),
                      ],
                    ],
                  ),

                const SizedBox(height: 10),

                _BottomButton(text: 'Add to my Task', onTap: _addToMyTask),
                const SizedBox(height: 10),
                _BottomButton(
                  text: 'Regenerate Plan',
                  icon: Icons.refresh,
                  onTap: _regenerate,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DeadlineButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _DeadlineButton({required this.text, required this.onTap});

  static const _card = Color(0xFF083445);
  static const _stroke = Color(0xFF2C5B6A);
  static const _white = Color(0xFFEAF6FB);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: _card,
          side: const BorderSide(color: _stroke),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onTap,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            text,
            style: const TextStyle(color: _white, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final bool active;
  final VoidCallback onTap;

  const _Pill({required this.text, required this.active, required this.onTap});

  static const _accent = Color(0xFF55C3FF);
  static const _white = Color(0xFFEAF6FB);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: active ? _accent.withOpacity(0.25) : Colors.transparent,
          border: Border.all(color: _accent.withOpacity(active ? 0.8 : 0.35)),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: _white,
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _BottomButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback onTap;

  const _BottomButton({required this.text, required this.onTap, this.icon});

  static const _card = Color(0xFF083445);
  static const _stroke = Color(0xFF2C5B6A);
  static const _white = Color(0xFFEAF6FB);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: _card,
          side: const BorderSide(color: _stroke),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: _white, size: 18),
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: const TextStyle(
                color: _white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanItem {
  final String title;
  final DateTime due;
  final bool done;

  const _PlanItem({required this.title, required this.due, required this.done});

  _PlanItem copyWith({String? title, DateTime? due, bool? done}) {
    return _PlanItem(
      title: title ?? this.title,
      due: due ?? this.due,
      done: done ?? this.done,
    );
  }
}

class _PlanTile extends StatelessWidget {
  final _PlanItem item;
  final VoidCallback onToggle;
  final DateFormat df;

  const _PlanTile({
    required this.item,
    required this.onToggle,
    required this.df,
  });

  static const _card = Color(0xFF083445);
  static const _stroke = Color(0xFF2C5B6A);
  static const _accent = Color(0xFF55C3FF);
  static const _white = Color(0xFFEAF6FB);
  static const _muted = Color(0xFF9CC6D4);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _stroke),
      ),
      child: ListTile(
        leading: InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: item.done ? _accent : _stroke),
              color: item.done ? _accent.withOpacity(0.25) : Colors.transparent,
            ),
            child: item.done
                ? const Icon(Icons.check, size: 16, color: _accent)
                : null,
          ),
        ),
        title: Text(
          item.title,
          style: TextStyle(
            color: _white,
            fontWeight: FontWeight.w800,
            decoration: item.done ? TextDecoration.lineThrough : null,
            decorationColor: _muted,
          ),
        ),
        subtitle: Text(
          'Due: ${df.format(item.due)}',
          style: TextStyle(
            color: _muted,
            decoration: item.done ? TextDecoration.lineThrough : null,
            decorationColor: _muted,
          ),
        ),
        trailing: const Icon(Icons.more_vert, color: _muted),
      ),
    );
  }
}
