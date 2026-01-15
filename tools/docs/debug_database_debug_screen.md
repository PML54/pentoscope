# debug/database_debug_screen.dart

**Module:** debug

## Fonctions

### DatabaseDebugScreen

Widget debug simple pour vérifier les données sauvegardées


```dart
const DatabaseDebugScreen({Key? key}) : super(key: key);
```

### createState

```dart
State<DatabaseDebugScreen> createState() => _DatabaseDebugScreenState();
```

### build

```dart
Widget build(BuildContext context) {
```

### Scaffold

```dart
return Scaffold( appBar: AppBar( title: const Text('🐛 Database Debug'), backgroundColor: Colors.red[700], ), body: SingleChildScrollView( padding: const EdgeInsets.all(16), child: Column( crossAxisAlignment: CrossAxisAlignment.start, spacing: 20, children: [ // ========== STATS GLOBALES ========== _buildSection( title: '📊 STATS GLOBALES', child: FutureBuilder( future: database.getGlobalStats(), builder: (context, snapshot) {
```

### Text

```dart
return Text('Erreur: ${snapshot.error}');
```

### Column

```dart
return Column( crossAxisAlignment: CrossAxisAlignment.start, spacing: 8, children: [ _statRow('Sessions totales:', '${stats['totalSessions'] ?? 0}'),
```

### Text

```dart
return Text('Erreur: ${snapshot.error}');
```

### Column

```dart
return Column( spacing: 8, children: [ Text('${sessions.length} session(s) trouvée(s)'),
```

### Container

```dart
return Container( decoration: BoxDecoration( border: Border.all(color: Colors.blue), borderRadius: BorderRadius.circular(6), color: Colors.blue[50], ), padding: const EdgeInsets.all(8), child: Column( crossAxisAlignment: CrossAxisAlignment.start, spacing: 4, children: [ Text( '🎮 Session #${session.id}',
```

### Column

```dart
return Column( crossAxisAlignment: CrossAxisAlignment.start, children: [ Text( title, style: const TextStyle( fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue, ), ), const SizedBox(height: 12), Container( decoration: BoxDecoration( border: Border.all(color: Colors.blue), borderRadius: BorderRadius.circular(8), color: Colors.blue[50], ), padding: const EdgeInsets.all(12), child: child, ), ], );
```

### SizedBox

```dart
const SizedBox(height: 12), Container( decoration: BoxDecoration( border: Border.all(color: Colors.blue), borderRadius: BorderRadius.circular(8), color: Colors.blue[50], ), padding: const EdgeInsets.all(12), child: child, ), ], );
```

### Row

```dart
return Row( mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [ Text( label, style: const TextStyle(fontWeight: FontWeight.bold), ), Text( value, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold), ), ], );
```

### Row

```dart
return Row( mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [ Text(label, style: const TextStyle(fontSize: 12)), Text( value, style: const TextStyle(fontSize: 12, color: Colors.green), ), ], );
```

### SnackBar

```dart
const SnackBar( content: Text('✅ Toutes les données supprimées!'), backgroundColor: Colors.orange, ), );
```

