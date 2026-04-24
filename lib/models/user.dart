class User {
  final String id;
  final int points;
  final int totalFocusMinutes;
  final int dayStreak;
  final int sessionsCompleted;
  final String equippedCharacter;
  final List<String> unlockedCharacters;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.points,
    required this.totalFocusMinutes,
    required this.dayStreak,
    required this.sessionsCompleted,
    required this.equippedCharacter,
    required this.unlockedCharacters,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] as String,
    points: json['points'] as int,
    totalFocusMinutes: json['totalFocusMinutes'] as int,
    dayStreak: json['dayStreak'] as int,
    sessionsCompleted: json['sessionsCompleted'] as int,
    equippedCharacter: json['equippedCharacter'] as String,
    unlockedCharacters: List<String>.from(json['unlockedCharacters'] as List),
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'points': points,
    'totalFocusMinutes': totalFocusMinutes,
    'dayStreak': dayStreak,
    'sessionsCompleted': sessionsCompleted,
    'equippedCharacter': equippedCharacter,
    'unlockedCharacters': unlockedCharacters,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  User copyWith({
    String? id,
    int? points,
    int? totalFocusMinutes,
    int? dayStreak,
    int? sessionsCompleted,
    String? equippedCharacter,
    List<String>? unlockedCharacters,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => User(
    id: id ?? this.id,
    points: points ?? this.points,
    totalFocusMinutes: totalFocusMinutes ?? this.totalFocusMinutes,
    dayStreak: dayStreak ?? this.dayStreak,
    sessionsCompleted: sessionsCompleted ?? this.sessionsCompleted,
    equippedCharacter: equippedCharacter ?? this.equippedCharacter,
    unlockedCharacters: unlockedCharacters ?? this.unlockedCharacters,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
