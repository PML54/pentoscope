# screens/solutions_viewer_screen.dart

**Module:** screens

## Fonctions

### SolutionsViewerScreen

```dart
const SolutionsViewerScreen({super.key});
```

### createState

```dart
ConsumerState<SolutionsViewerScreen> createState() => _SolutionsViewerScreenState();
```

### build

```dart
Widget build(BuildContext context) {
```

### Scaffold

```dart
return Scaffold( appBar: AppBar(title: const Text('Solutions Canoniques')), body: const Center( child: Column( mainAxisAlignment: MainAxisAlignment.center, children: [ Icon(Icons.error_outline, size: 64, color: Colors.orange), SizedBox(height: 16), Text('Solutions non chargées'), SizedBox(height: 8), Text('Appelez SolutionDatabase.init() au démarrage'), ], ), ), );
```

### Scaffold

```dart
return Scaffold( appBar: AppBar( title: Text('Solution ${_currentIndex + 1}/${solutions.length}'),
```

### Container

```dart
return Container( decoration: BoxDecoration( color: color, border: Border.all(color: Colors.grey.shade400), ), child: Center( child: Text( text, style: const TextStyle( color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, ), ), ), );
```

### SizedBox

Couleur d'une pièce selon les paramètres de l'utilisateur


```dart
const SizedBox(height: 16), const Text('Format:'), const Text('  • 8 × int32 par solution'), const Text('  • 4 bits par cellule'), const Text('  • 240 bits utilisés'), ], ), actions: [ TextButton( onPressed: () => Navigator.pop(context), child: const Text('OK'), ), ], ), );
```

### Text

```dart
const Text('Format:'), const Text('  • 8 × int32 par solution'), const Text('  • 4 bits par cellule'), const Text('  • 240 bits utilisés'), ], ), actions: [ TextButton( onPressed: () => Navigator.pop(context), child: const Text('OK'), ), ], ), );
```

### Text

```dart
const Text('  • 8 × int32 par solution'), const Text('  • 4 bits par cellule'), const Text('  • 240 bits utilisés'), ], ), actions: [ TextButton( onPressed: () => Navigator.pop(context), child: const Text('OK'), ), ], ), );
```

### Text

```dart
const Text('  • 4 bits par cellule'), const Text('  • 240 bits utilisés'), ], ), actions: [ TextButton( onPressed: () => Navigator.pop(context), child: const Text('OK'), ), ], ), );
```

### Text

```dart
const Text('  • 240 bits utilisés'), ], ), actions: [ TextButton( onPressed: () => Navigator.pop(context), child: const Text('OK'), ), ], ), );
```

