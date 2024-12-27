// lib/models/event.dart

class Event {
  final String id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final Map<String, bool> participants;

  Event({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.participants,
  });

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'],
      name: map['name'],
      startDate: DateTime.parse(map['startDate']),
      endDate: DateTime.parse(map['endDate']),
      participants: Map<String, bool>.from(map['participants']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'participants': participants,
    };
  }
}