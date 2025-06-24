// workout_input_page.dart
import 'package:flutter/material.dart';
import 'workout_log.dart';

class WorkoutInputPage extends StatefulWidget {
  const WorkoutInputPage({super.key});

  @override
  State<WorkoutInputPage> createState() => _WorkoutInputPageState();
}

class _WorkoutInputPageState extends State<WorkoutInputPage> {
  String? _selectedType;
  int? _selectedMinutes;

  final List<_WorkoutOption> workoutOptions = [
    _WorkoutOption('사이클링', Icons.directions_bike),
    _WorkoutOption('러닝', Icons.directions_run),
    _WorkoutOption('하이킹', Icons.hiking),
    _WorkoutOption('기타', Icons.accessibility_new),
  ];

  final List<int> predefinedMinutes = [10, 30, 60];

  void _submit() {
    if (_selectedType == null || _selectedMinutes == null) return;

    Navigator.pop(
      context,
      WorkoutLog(type: _selectedType!, minutes: _selectedMinutes!),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('운동 기록')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('어떤 종류의 운동을 하셨나요?', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: workoutOptions.map((option) {
                final isSelected = _selectedType == option.label;
                return GestureDetector(
                  onTap: () => setState(() => _selectedType = option.label),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.teal.shade100
                              : Colors.grey.shade200,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Icon(
                          option.icon,
                          size: 32,
                          color: isSelected ? Colors.teal : Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        option.label,
                        style: TextStyle(
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            const Text('얼마나 운동하셨나요?', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ...predefinedMinutes.map((min) {
                  final isSelected = _selectedMinutes == min;
                  return ChoiceChip(
                    label: Text('${min == 60 ? '1시간' : '$min분'}'),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedMinutes = min),
                    selectedColor: Colors.teal,
                  );
                }),
                ChoiceChip(
                  label: const Text('기타'),
                  selected: !predefinedMinutes.contains(_selectedMinutes ?? -1),
                  onSelected: (_) async {
                    final controller = TextEditingController();
                    final result = await showDialog<int>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('운동 시간 입력'),
                        content: TextField(
                          controller: controller,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: '운동 시간 (분)',
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('취소'),
                          ),
                          TextButton(
                            onPressed: () {
                              final min = int.tryParse(controller.text);
                              Navigator.pop(context, min);
                            },
                            child: const Text('확인'),
                          ),
                        ],
                      ),
                    );
                    if (result != null && result > 0) {
                      setState(() => _selectedMinutes = result);
                    }
                  },
                ),
              ],
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: (_selectedType != null && _selectedMinutes != null)
                    ? _submit
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 14,
                  ),
                ),
                child: const Text(
                  '저장',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkoutOption {
  final String label;
  final IconData icon;

  const _WorkoutOption(this.label, this.icon);
}
