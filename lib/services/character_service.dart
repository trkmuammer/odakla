import 'package:focuszen/models/character.dart';

class CharacterService {
  static List<Character> getAllCharacters() => [
    Character(
      id: 'focus_spirit',
      name: 'Focus Spirit',
      emoji: '🔮',
      description: 'Your default companion',
      pointsCost: 0,
      isDefault: true,
    ),
    Character(
      id: 'zen_monk',
      name: 'Zen Monk',
      emoji: '🧘',
      description: 'Master of stillness',
      pointsCost: 100,
      isDefault: false,
    ),
    Character(
      id: 'cosmic_owl',
      name: 'Cosmic Owl',
      emoji: '🦉',
      description: 'Wise night guardian',
      pointsCost: 250,
      isDefault: false,
    ),
    Character(
      id: 'flame_fox',
      name: 'Flame Fox',
      emoji: '🦊',
      description: 'Burning with focus',
      pointsCost: 500,
      isDefault: false,
    ),
    Character(
      id: 'time_dragon',
      name: 'Time Dragon',
      emoji: '🐉',
      description: 'Controls the flow of time',
      pointsCost: 750,
      isDefault: false,
    ),
    Character(
      id: 'crystal_cat',
      name: 'Crystal Cat',
      emoji: '🐱',
      description: 'Reflects pure concentration',
      pointsCost: 1000,
      isDefault: false,
    ),
  ];

  static Character? getCharacterById(String id) {
    try {
      return getAllCharacters().firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }
}
