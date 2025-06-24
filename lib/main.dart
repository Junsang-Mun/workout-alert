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
      title: 'Workout Tracker',
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

  final Map<DateTime, WorkoutLog?> _workoutData = {}; // null = No 운동

  DateTime dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  DateTime get _today => dateOnly(DateTime.now());

  void _handleDaySelected(DateTime selectedDay, DateTime focusedDay) {
    final selected = dateOnly(selectedDay);
    if (selected.isAfter(_today)) return;

    setState(() {
      _selectedDay = selected;
      _focusedDay = focusedDay;
    });

    final log = _workoutData[selected];
    if (!_workoutData.containsKey(selected)) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('운동 기록 없음'),
          content: const Text('이 날은 운동 기록이 없습니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('닫기'),
            ),
          ],
        ),
      );
    } else if (log == null) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('운동하지 않음'),
          content: const Text('이 날은 운동을 하지 않았습니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('확인'),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('운동 기록'),
          content: Text('${log.type}을(를) ${log.minutes}분 했어요.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('확인'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _handleYesPressed() async {
    if (_selectedDay == null) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const WorkoutInputPage()),
    );

    if (result != null && result is WorkoutLog) {
      setState(() {
        _workoutData[dateOnly(_selectedDay!)] = result;
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
                _workoutData[dateOnly(_selectedDay!)] = null;
              });
              Navigator.pop(context);
            },
            child: const Text('정말 안 할래요'),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayWorkoutSummary() {
    final todayLog = _workoutData[_today];

    if (!_workoutData.containsKey(_today)) {
      return const Text(
        '오늘은 아직 운동을 안 하셨어요 😅',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      );
    }

    if (todayLog == null) {
      return const Text(
        '오늘은 운동 안 하기로 했어요 🙃',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      );
    }

    return Text(
      '오늘은 ${todayLog.type}을(를) ${todayLog.minutes}분 했어요 💪',
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
                final log = _workoutData[dateOnly(day)];
                String symbol = '';
                if (log != null) {
                  symbol = log.type.isNotEmpty ? '✔️' : '✖️';
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

          // 👇 오늘 운동 기록 표시 영역
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: _buildTodayWorkoutSummary(),
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
