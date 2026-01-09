// lib/tutorial/models/tutorial_script.dart
// Définition d'un script de tutoriel complet

import 'package:pentapol/tutorial/models/scratch_command.dart';

/// Script de tutoriel complet
class TutorialScript {
  /// Identifiant unique du script
  final String id;

  /// Nom affiché
  final String name;

  /// Description
  final String description;

  /// Niveau de difficulté
  final TutorialDifficulty difficulty;

  /// Durée estimée en secondes
  final int estimatedDuration;

  /// Variables globales initiales
  final Map<String, dynamic> variables;

  /// Liste des commandes à exécuter
  final List<ScratchCommand> steps;

  /// Tags pour le filtrage
  final List<String> tags;

  const TutorialScript({
    required this.id,
    required this.name,
    required this.description,
    this.difficulty = TutorialDifficulty.beginner,
    this.estimatedDuration = 60,
    this.variables = const {},
    required this.steps,
    this.tags = const [],
  });

  /// Crée un script depuis un Map (YAML parsé)
  factory TutorialScript.fromMap(Map<String, dynamic> map) {
    return TutorialScript(
      id: map['id'] as String? ?? map['name'] as String? ?? 'unknown',
      name: map['name'] as String,
      description: map['description'] as String? ?? '',
      difficulty: _parseDifficulty(map['difficulty'] as String?),
      estimatedDuration: map['estimatedDuration'] as int? ?? 60,
      variables: map['variables'] as Map<String, dynamic>? ?? {},
      steps: [], // Sera rempli par le parser
      tags: (map['tags'] as List?)?.cast<String>() ?? [],
    );
  }

  static TutorialDifficulty _parseDifficulty(String? diff) {
    switch (diff?.toLowerCase()) {
      case 'beginner':
        return TutorialDifficulty.beginner;
      case 'intermediate':
        return TutorialDifficulty.intermediate;
      case 'advanced':
        return TutorialDifficulty.advanced;
      default:
        return TutorialDifficulty.beginner;
    }
  }

  /// Copie avec modifications
  TutorialScript copyWith({
    String? id,
    String? name,
    String? description,
    TutorialDifficulty? difficulty,
    int? estimatedDuration,
    Map<String, dynamic>? variables,
    List<ScratchCommand>? steps,
    List<String>? tags,
  }) {
    return TutorialScript(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      difficulty: difficulty ?? this.difficulty,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      variables: variables ?? this.variables,
      steps: steps ?? this.steps,
      tags: tags ?? this.tags,
    );
  }
}

/// Niveau de difficulté d'un tutoriel
enum TutorialDifficulty { beginner, intermediate, advanced }

/// Extension pour affichage
extension TutorialDifficultyExtension on TutorialDifficulty {
  String get label {
    switch (this) {
      case TutorialDifficulty.beginner:
        return 'Débutant';
      case TutorialDifficulty.intermediate:
        return 'Intermédiaire';
      case TutorialDifficulty.advanced:
        return 'Avancé';
    }
  }
}
