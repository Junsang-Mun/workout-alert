// lib/main.dart
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'workout_input_page.dart';
import 'workout_log.dart';

void main() {
  runApp(const WorkoutTrackerApp());
}

class WorkoutTrackerApp extends StatelessWidget {
  const WorkoutTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '듀오는 언어 말고도 운동을 원해요',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const WorkoutHomePage(),
    );
  }
}

class WorkoutHomePage extends StatefulWidget {
  const WorkoutHomePage({super.key});

  @override
  State<WorkoutHomePage> createState() => _WorkoutHomePageState();
}

class _WorkoutHomePageState extends State<WorkoutHomePage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Change to store a list of WorkoutLog per day
  final Map<DateTime, List<WorkoutLog>> _workoutData = {};

  DateTime dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  DateTime get _today => dateOnly(DateTime.now());

  void _handleDaySelected(DateTime selectedDay, DateTime focusedDay) {
    final selected = dateOnly(selectedDay);
    if (selected.isAfter(_today)) return;

    setState(() {
      _selectedDay = selected;
      _focusedDay = focusedDay;
    });
  }

  Future<void> _handleYesPressed() async {
    if (_selectedDay == null) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const WorkoutInputPage()),
    );

    if (result != null && result is WorkoutLog) {
      setState(() {
        final key = dateOnly(_selectedDay!);
        if (_workoutData.containsKey(key)) {
          _workoutData[key]!.add(result);
        } else {
          _workoutData[key] = [result];
        }
      });
    }
  }

  void _handleNoPressed() {
    if (_selectedDay == null) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('정말 운동 안 하실 건가요?'),
        content: const Text('운동 안 하면 복근은 다음 생으로 넘어갑니다 😅'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('생각해볼게요'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                // Mark as "no workout" by setting an empty list
                _workoutData[dateOnly(_selectedDay!)] = [];
              });
              Navigator.pop(context);
            },
            child: const Text('정말 안 할래요'),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedDayWorkoutSummary() {
    if (_selectedDay == null) {
      return Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
          child: Row(
            children: const [
              Icon(Icons.info_outline, color: Colors.teal, size: 28),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  '날짜를 선택해 운동 기록을 확인하세요.',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final logs = _workoutData[_selectedDay!];

    if (!_workoutData.containsKey(_selectedDay!)) {
      return Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
          child: Row(
            children: const [
              Icon(Icons.sentiment_dissatisfied, color: Colors.orange, size: 28),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  '이 날은 아직 운동을 안 하셨어요 😅',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (logs == null || logs.isEmpty) {
      return Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
          child: Row(
            children: [
              const Icon(Icons.self_improvement, color: Colors.grey, size: 28),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  '이 날은 운동 안 하기로 했어요 🙃',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.teal, size: 24),
                tooltip: '운동 기록 입력으로 되돌리기',
                onPressed: () {
                  setState(() {
                    _workoutData.remove(_selectedDay!);
                  });
                },
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.fitness_center, color: Colors.teal, size: 28),
                const SizedBox(width: 12),
                Text(
                  '${_selectedDay!.year}-${_selectedDay!.month.toString().padLeft(2, '0')}-${_selectedDay!.day.toString().padLeft(2, '0')} 운동 기록',
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ...logs.asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.teal, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '${entry.value.type} ',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '${entry.value.minutes}분',
                      style: const TextStyle(fontSize: 15, color: Colors.black87),
                    ),
                    // Stick delete icon to the right
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                      tooltip: '삭제',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        setState(() {
                          logs.removeAt(entry.key);
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Align(
              alignment: Alignment.centerRight,
              child: Text('💪', style: TextStyle(fontSize: 22)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('듀오는 언어 말고도 운동을 원해요'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          TableCalendar(
            calendarFormat: CalendarFormat.month,
            availableCalendarFormats: const {CalendarFormat.month: 'Month'},
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => dateOnly(day) == _selectedDay,
            onDaySelected: _handleDaySelected,
            enabledDayPredicate: (day) => !dateOnly(day).isAfter(_today),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.teal,
                  style: BorderStyle.solid,
                  width: 1,
                ),
              ),
            ),
            calendarBuilders: CalendarBuilders(
              todayBuilder: (context, day, _) {
                return Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.teal,
                      style: BorderStyle.solid,
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${day.day}',
                      style: const TextStyle(
                        color: Colors.teal,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
              defaultBuilder: (context, day, _) {
                final logs = _workoutData[dateOnly(day)];
                String symbol = '';
                if (logs != null) {
                  if (logs.isNotEmpty) {
                    symbol = '✔️';
                  } else {
                    symbol = '✖️';
                  }
                }

                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${day.day}'),
                      if (symbol.isNotEmpty)
                        Text(symbol, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                );
              },
            ),
          ),

          // 👇 선택한 날짜 운동 기록 표시 영역
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: _buildSelectedDayWorkoutSummary(),
          ),

          const Spacer(),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 20,
                    ),
                  ),
                  onPressed: _handleNoPressed,
                  child: const Text('No', style: TextStyle(fontSize: 16)),
                ),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 20,
                    ),
                  ),
                  onPressed: _handleYesPressed,
                  child: const Text(
                    'Yes',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
