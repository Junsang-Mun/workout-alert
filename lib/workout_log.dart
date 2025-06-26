class WorkoutLog {
  final String type;
  final int minutes;

  WorkoutLog({required this.type, required this.minutes});

  // For SQLite
  Map<String, dynamic> toMap() => {'type': type, 'minutes': minutes};

  factory WorkoutLog.fromMap(Map<String, dynamic> map) =>
      WorkoutLog(type: map['type'] as String, minutes: map['minutes'] as int);
}
