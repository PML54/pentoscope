# tutorial/commands/tutorial_mode_commands.dart

**Module:** tutorial

## Fonctions

### EnterTutorialModeCommand

Commande ENTER_TUTORIAL_MODE - Entre en mode tutoriel


```dart
const EnterTutorialModeCommand();
```

### execute

```dart
Future<void> execute(TutorialContext context) async {
```

### ExitTutorialModeCommand

Commande EXIT_TUTORIAL_MODE - Sort du mode tutoriel


```dart
const ExitTutorialModeCommand({this.restore = true});
```

### execute

```dart
Future<void> execute(TutorialContext context) async {
```

### ExitTutorialModeCommand

```dart
return ExitTutorialModeCommand(restore: params['restore'] as bool? ?? true);
```

### CancelTutorialCommand

Commande CANCEL_TUTORIAL - Annule le tutoriel


```dart
const CancelTutorialCommand();
```

### execute

```dart
Future<void> execute(TutorialContext context) async {
```

### ResetGameCommand

Commande RESET_GAME - Réinitialise le jeu


```dart
const ResetGameCommand();
```

### execute

```dart
Future<void> execute(TutorialContext context) async {
```

