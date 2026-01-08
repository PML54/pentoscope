# tutorial/parser/yaml_parser.dart

**Module:** tutorial

## Fonctions

### parse

Parser de scripts YAML
Parse un fichier YAML en TutorialScript


```dart
static TutorialScript parse(String yamlContent) {
```

### FormatException

```dart
throw FormatException('Le script doit contenir au moins une step');
```

### validate

Valide un script YAML sans le parser complètement


```dart
static bool validate(String yamlContent) {
```

### ClearMessageCommand

Parse une commande depuis un Map


```dart
return ClearMessageCommand();
```

### EnterTutorialModeCommand

```dart
return EnterTutorialModeCommand();
```

### CancelTutorialCommand

```dart
return CancelTutorialCommand();
```

### ResetGameCommand

```dart
return ResetGameCommand();
```

### ClearSliderHighlightCommand

```dart
return ClearSliderHighlightCommand();
```

### ResetSliderPositionCommand

```dart
return ResetSliderPositionCommand();
```

### CancelSelectionCommand

```dart
return CancelSelectionCommand();
```

### ClearHighlightsCommand

```dart
return ClearHighlightsCommand();
```

### FormatException

```dart
throw FormatException('Commande inconnue: $commandName');
```

