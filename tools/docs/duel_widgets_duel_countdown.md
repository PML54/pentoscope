# duel/widgets/duel_countdown.dart

**Module:** duel

## Fonctions

### DuelCountdown

```dart
const DuelCountdown({super.key, required this.value});
```

### build

```dart
Widget build(BuildContext context) {
```

### Container

```dart
return Container( color: Colors.black54, child: Center( child: TweenAnimationBuilder<double>( tween: Tween(begin: 0.5, end: 1.0), duration: const Duration(milliseconds: 300), key: ValueKey(value), builder: (context, scale, child) {
```

