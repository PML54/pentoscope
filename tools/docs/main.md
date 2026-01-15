# main.dart

**Module:** main.dart

## Fonctions

### main

```dart
void main() async {
```

### PentapolApp

```dart
const PentapolApp({super.key});
```

### createState

```dart
ConsumerState<PentapolApp> createState() => _PentapolAppState();
```

### initState

```dart
void initState() {
```

### build

```dart
Widget build(BuildContext context) {
```

### MaterialApp

```dart
return MaterialApp( title: 'Pentapol', theme: ThemeData( useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue), ), home: _isInitialized ? const PentoscopeGameScreen() : _buildLoadingScreen(),  routes: {
```

