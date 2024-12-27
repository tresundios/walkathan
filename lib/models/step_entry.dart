// lib/models/step_entry.dart

class StepEntry {
  final String userId;
  final DateTime date;
  final int steps;

  StepEntry({
    required this.userId,
    required this.date,
    required this.steps,
  });

  factory StepEntry.fromMap(Map<String, dynamic> map) {
    return StepEntry(
      userId: map['userId'],
      date: DateTime.parse(map['date']),
      steps: map['steps'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'date': date.toIso8601String(),
      'steps': steps,
    };
  }
}