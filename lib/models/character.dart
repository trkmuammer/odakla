class Character {
  final String id;
  final String name;
  final String emoji;
  final String description;
  final int pointsCost;
  final bool isDefault;

  Character({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.pointsCost,
    required this.isDefault,
  });

  factory Character.fromJson(Map<String, dynamic> json) => Character(
    id: json['id'] as String,
    name: json['name'] as String,
    emoji: json['emoji'] as String,
    description: json['description'] as String,
    pointsCost: json['pointsCost'] as int,
    isDefault: json['isDefault'] as bool,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'emoji': emoji,
    'description': description,
    'pointsCost': pointsCost,
    'isDefault': isDefault,
  };
}
