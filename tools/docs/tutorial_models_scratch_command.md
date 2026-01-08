# tutorial/models/scratch_command.dart

**Module:** tutorial

## Fonctions

### ScratchCommand

Classe abstraite pour toutes les commandes Scratch


```dart
const ScratchCommand();
```

### execute

Exécute la commande dans le contexte donné


```dart
Future<void> execute(TutorialContext context);
```

### validate

Nom de la commande (pour debug/logs)
Validation de la commande (optionnel)


```dart
bool validate() => true;
```

### CompositeCommand

Description de la commande (pour aide/documentation)
Commande composée (bloc de commandes)


```dart
const CompositeCommand(this.commands);
```

### execute

```dart
Future<void> execute(TutorialContext context) async {
```

### ConditionalCommand

Commande conditionnelle


```dart
const ConditionalCommand({
```

### execute

```dart
Future<void> execute(TutorialContext context) async {
```

