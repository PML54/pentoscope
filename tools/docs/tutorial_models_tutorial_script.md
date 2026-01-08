# tutorial/models/tutorial_script.dart

**Module:** tutorial

## Fonctions

### TutorialScript

Script de tutoriel complet
Identifiant unique du script
Nom affiché
Description
Niveau de difficulté
Durée estimée en secondes
Variables globales initiales
Liste des commandes à exécuter
Tags pour le filtrage


```dart
const TutorialScript({
```

### TutorialScript

Crée un script depuis un Map (YAML parsé)


```dart
return TutorialScript( id: map['id'] as String? ?? map['name'] as String? ?? 'unknown', name: map['name'] as String, description: map['description'] as String? ?? '', difficulty: _parseDifficulty(map['difficulty'] as String?), estimatedDuration: map['estimatedDuration'] as int? ?? 60, variables: map['variables'] as Map<String, dynamic>? ?? {},
```

### copyWith

Copie avec modifications


```dart
TutorialScript copyWith({
```

### TutorialScript

```dart
return TutorialScript( id: id ?? this.id, name: name ?? this.name, description: description ?? this.description, difficulty: difficulty ?? this.difficulty, estimatedDuration: estimatedDuration ?? this.estimatedDuration, variables: variables ?? this.variables, steps: steps ?? this.steps, tags: tags ?? this.tags, );
```

