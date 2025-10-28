class StepLog {
  StepLog({
    this.id,
    required this.date,
    required this.steps,
    required this.goal,
  });

  final int? id;
  final DateTime date;
  final int steps;
  final int goal;

  StepLog copyWith({
    int? id,
    DateTime? date,
    int? steps,
    int? goal,
  }) {
    return StepLog(
      id: id ?? this.id,
      date: date ?? this.date,
      steps: steps ?? this.steps,
      goal: goal ?? this.goal,
    );
  }

  factory StepLog.fromMap(Map<String, dynamic> map) {
    return StepLog(
      id: map['id'] as int?,
      date: DateTime.parse(map['date'] as String),
      steps: map['steps'] as int,
      goal: map['goal'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'steps': steps,
      'goal': goal,
    };
  }
}
