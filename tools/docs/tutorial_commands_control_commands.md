# tutorial/commands/control_commands.dart

**Module:** tutorial

## Fonctions

### WaitCommand

Commande WAIT - Attend un certain temps


```dart
const WaitCommand({this.durationMs = 1000});
```

### execute

```dart
Future<void> execute(TutorialContext context) async {
```

### WaitCommand

```dart
return WaitCommand(durationMs: durationMs);
```

### RepeatCommand

Commande REPEAT - Répète un bloc de commandes


```dart
const RepeatCommand({required this.count, required this.commands});
```

### execute

```dart
Future<void> execute(TutorialContext context) async {
```

### RepeatCommand

```dart
return RepeatCommand( count: count, commands: [], // Sera rempli par le parser );
```

