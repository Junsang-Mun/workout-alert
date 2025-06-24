// main.dart
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
      themeMode: ThemeMode.system,
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
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
        _workoutData.putIfAbsent(key, () => []).add(result);
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

  @override
  Widget build(BuildContext context) {
    final logs = _workoutData[_selectedDay];

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
                border: Border.all(color: Colors.teal),
              ),
            ),
            calendarBuilders: CalendarBuilders(
              todayBuilder: (context, day, _) => Center(
                child: Text(
                  '${day.day}',
                  style: const TextStyle(
                    color: Colors.teal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              defaultBuilder: (context, day, _) {
                final logs = _workoutData[dateOnly(day)];
                String symbol = '';
                if (logs != null) {
                  symbol = logs.isEmpty ? '✖️' : '✔️';
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
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: _selectedDay == null
                      ? const Center(child: Text('날짜를 선택해 운동 기록을 확인하세요.'))
                      : logs == null
                      ? const Center(child: Text('이 날은 아직 운동을 안 하셨어요 😅'))
                      : logs.isEmpty
                      ? Row(
                          children: [
                            const Icon(
                              Icons.self_improvement,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 12),
                            const Expanded(child: Text('이 날은 운동 안 하기로 했어요 🙃')),
                            IconButton(
                              icon: const Icon(
                                Icons.refresh,
                                color: Colors.teal,
                              ),
                              onPressed: () {
                                setState(() {
                                  _workoutData.remove(_selectedDay!);
                                });
                              },
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.fitness_center,
                                  color: Colors.teal,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  '${_selectedDay!.year}-${_selectedDay!.month.toString().padLeft(2, '0')}-${_selectedDay!.day.toString().padLeft(2, '0')} 운동 기록',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Expanded(
                              child: ListView.builder(
                                itemCount: logs.length,
                                itemBuilder: (context, index) {
                                  final log = logs[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.check_circle,
                                          color: Colors.teal,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          log.type,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text('${log.minutes}분'),
                                        const Spacer(),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.redAccent,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              logs.removeAt(index);
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
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
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  onPressed: _handleNoPressed,
                  child: const Text('운동 안 할래요'),
                ),
                ElevatedButton(
                  onPressed: _handleYesPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  child: const Text('운동 했어요'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
