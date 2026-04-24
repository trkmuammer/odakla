class FocusSession {
  final String id;
  final String userId;
  final int durationMinutes;
  final DateTime startTime;
  final DateTime? endTime;
  final bool completed;
  final int pointsEarned;
  final DateTime createdAt;
  final DateTime updatedAt;

  FocusSession({
    required this.id,
    required this.userId,
    required this.durationMinutes,
    required this.startTime,
    this.endTime,
    required this.completed,
    required this.pointsEarned,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FocusSession.fromJson(Map<String, dynamic> json) => FocusSession(
    id: json['id'] as String,
    userId: json['userId'] as String,
    durationMinutes: json['durationMinutes'] as int,
    startTime: DateTime.parse(json['startTime'] as String),
    endTime: json['endTime'] != null ? DateTime.parse(json['endTime'] as String) : null,
    completed: json['completed'] as bool,
    pointsEarned: json['pointsEarned'] as int,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'durationMinutes': durationMinutes,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime?.toIso8601String(),
    'completed': completed,
    'pointsEarned': pointsEarned,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  FocusSession copyWith({
    String? id,
    String? userId,
    int? durationMinutes,
    DateTime? startTime,
    DateTime? endTime,
    bool? completed,
    int? pointsEarned,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => FocusSession(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    durationMinutes: durationMinutes ?? this.durationMinutes,
    startTime: startTime ?? this.startTime,
    endTime: endTime ?? this.endTime,
    completed: completed ?? this.completed,
    pointsEarned: pointsEarned ?? this.pointsEarned,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
