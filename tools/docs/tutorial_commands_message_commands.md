# tutorial/commands/message_commands.dart

**Module:** tutorial

## Fonctions

### ShowMessageCommand

Commande SHOW_MESSAGE - Affiche un message avec timeout optionnel


```dart
const ShowMessageCommand({
```

### execute

```dart
Future<void> execute(TutorialContext context) async {
```

### ShowMessageCommand

```dart
return ShowMessageCommand( text: params['text'] as String? ?? '', autoHideAfter: params['autoHideAfter'] as int?, );
```

### ClearMessageCommand

Commande CLEAR_MESSAGE - Efface le message


```dart
const ClearMessageCommand();
```

### execute

```dart
Future<void> execute(TutorialContext context) async {
```

