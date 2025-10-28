class SleepLog {
  SleepLog({
    this.id,
    required this.date,
    required this.durationMinutes,
    required this.quality,
    this.sleepStart,
    this.sleepEnd,
    this.notes,
  });

  final int? id;
  final DateTime date;
  final int durationMinutes;
  final String quality;
  final DateTime? sleepStart;
  final DateTime? sleepEnd;
  final String? notes;

  SleepLog copyWith({
    int? id,
    DateTime? date,
    int? durationMinutes,
    String? quality,
    DateTime? sleepStart,
    DateTime? sleepEnd,
    String? notes,
  }) {
    return SleepLog(
      id: id ?? this.id,
      date: date ?? this.date,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      quality: quality ?? this.quality,
      sleepStart: sleepStart ?? this.sleepStart,
      sleepEnd: sleepEnd ?? this.sleepEnd,
      notes: notes ?? this.notes,
    );
  }

  factory SleepLog.fromMap(Map<String, dynamic> map) {
    return SleepLog(
      id: map['id'] as int?,
      date: DateTime.parse(map['date'] as String),
      durationMinutes: map['duration_minutes'] as int,
      quality: map['quality'] as String,
      sleepStart: map['sleep_start'] != null
          ? DateTime.tryParse(map['sleep_start'] as String)
          : null,
      sleepEnd: map['sleep_end'] != null
          ? DateTime.tryParse(map['sleep_end'] as String)
          : null,
      notes: map['notes'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'duration_minutes': durationMinutes,
      'quality': quality,
      'sleep_start': sleepStart?.toIso8601String(),
      'sleep_end': sleepEnd?.toIso8601String(),
      'notes': notes,
    };
  }
}
