# duel/screens/duel_waiting_screen.dart

**Module:** duel

## Fonctions

### DuelWaitingScreen

```dart
const DuelWaitingScreen({super.key});
```

### build

```dart
Widget build(BuildContext context, WidgetRef ref) {
```

### Scaffold

```dart
return Scaffold( appBar: AppBar( title: const Text('En attente...'), leading: IconButton( icon: const Icon(Icons.arrow_back), onPressed: () {
```

### SizedBox

```dart
const SizedBox( height: 100, width: 100, child: CircularProgressIndicator( strokeWidth: 6, ), ), const SizedBox(height: 32),  // Titre const Text( 'Partagez ce code', style: TextStyle( fontSize: 20, color: Colors.grey, ), ), const SizedBox(height: 16),  // Code de la room (grand et visible) Container( padding: const EdgeInsets.symmetric( horizontal: 32, vertical: 20, ), decoration: BoxDecoration( color: Colors.blue.shade50, borderRadius: BorderRadius.circular(16), border: Border.all( color: Colors.blue.shade200, width: 2, ), ), child: Text( roomCode, style: TextStyle( fontSize: 48, fontWeight: FontWeight.bold, letterSpacing: 12, color: Colors.blue.shade800, ), ), ), const SizedBox(height: 24),  // Boutons Copier / Partager Row( mainAxisAlignment: MainAxisAlignment.center, children: [ // Bouton Copier ElevatedButton.icon( onPressed: () {
```

### SizedBox

```dart
const SizedBox(height: 32),  // Titre const Text( 'Partagez ce code', style: TextStyle( fontSize: 20, color: Colors.grey, ), ), const SizedBox(height: 16),  // Code de la room (grand et visible) Container( padding: const EdgeInsets.symmetric( horizontal: 32, vertical: 20, ), decoration: BoxDecoration( color: Colors.blue.shade50, borderRadius: BorderRadius.circular(16), border: Border.all( color: Colors.blue.shade200, width: 2, ), ), child: Text( roomCode, style: TextStyle( fontSize: 48, fontWeight: FontWeight.bold, letterSpacing: 12, color: Colors.blue.shade800, ), ), ), const SizedBox(height: 24),  // Boutons Copier / Partager Row( mainAxisAlignment: MainAxisAlignment.center, children: [ // Bouton Copier ElevatedButton.icon( onPressed: () {
```

### Text

```dart
const Text( 'Partagez ce code', style: TextStyle( fontSize: 20, color: Colors.grey, ), ), const SizedBox(height: 16),  // Code de la room (grand et visible) Container( padding: const EdgeInsets.symmetric( horizontal: 32, vertical: 20, ), decoration: BoxDecoration( color: Colors.blue.shade50, borderRadius: BorderRadius.circular(16), border: Border.all( color: Colors.blue.shade200, width: 2, ), ), child: Text( roomCode, style: TextStyle( fontSize: 48, fontWeight: FontWeight.bold, letterSpacing: 12, color: Colors.blue.shade800, ), ), ), const SizedBox(height: 24),  // Boutons Copier / Partager Row( mainAxisAlignment: MainAxisAlignment.center, children: [ // Bouton Copier ElevatedButton.icon( onPressed: () {
```

### SizedBox

```dart
const SizedBox(height: 16),  // Code de la room (grand et visible) Container( padding: const EdgeInsets.symmetric( horizontal: 32, vertical: 20, ), decoration: BoxDecoration( color: Colors.blue.shade50, borderRadius: BorderRadius.circular(16), border: Border.all( color: Colors.blue.shade200, width: 2, ), ), child: Text( roomCode, style: TextStyle( fontSize: 48, fontWeight: FontWeight.bold, letterSpacing: 12, color: Colors.blue.shade800, ), ), ), const SizedBox(height: 24),  // Boutons Copier / Partager Row( mainAxisAlignment: MainAxisAlignment.center, children: [ // Bouton Copier ElevatedButton.icon( onPressed: () {
```

### SizedBox

```dart
const SizedBox(height: 24),  // Boutons Copier / Partager Row( mainAxisAlignment: MainAxisAlignment.center, children: [ // Bouton Copier ElevatedButton.icon( onPressed: () {
```

### SizedBox

```dart
const SizedBox(width: 16),  // Bouton Partager ElevatedButton.icon( onPressed: () {
```

### SizedBox

```dart
const SizedBox(height: 48),  // Message d'attente Row( mainAxisAlignment: MainAxisAlignment.center, children: [ SizedBox( height: 20, width: 20, child: CircularProgressIndicator( strokeWidth: 2, color: Colors.grey.shade400, ), ), const SizedBox(width: 12), Text( 'En attente d\'un adversaire...', style: TextStyle( fontSize: 16, color: Colors.grey.shade600, ), ), ], ),  // Afficher l'adversaire s'il est connecté if (duelState.opponent != null) ...[ const SizedBox(height: 24), Container( padding: const EdgeInsets.all(16), decoration: BoxDecoration( color: Colors.green.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green.shade200), ), child: Row( mainAxisSize: MainAxisSize.min, children: [ const Icon(Icons.check_circle, color: Colors.green), const SizedBox(width: 8), Text( '${duelState.opponent!.name} a rejoint !',
```

### SizedBox

```dart
const SizedBox(width: 12), Text( 'En attente d\'un adversaire...', style: TextStyle( fontSize: 16, color: Colors.grey.shade600, ), ), ], ),  // Afficher l'adversaire s'il est connecté if (duelState.opponent != null) ...[ const SizedBox(height: 24), Container( padding: const EdgeInsets.all(16), decoration: BoxDecoration( color: Colors.green.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green.shade200), ), child: Row( mainAxisSize: MainAxisSize.min, children: [ const Icon(Icons.check_circle, color: Colors.green), const SizedBox(width: 8), Text( '${duelState.opponent!.name} a rejoint !',
```

### SizedBox

```dart
const SizedBox(height: 24), Container( padding: const EdgeInsets.all(16), decoration: BoxDecoration( color: Colors.green.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green.shade200), ), child: Row( mainAxisSize: MainAxisSize.min, children: [ const Icon(Icons.check_circle, color: Colors.green), const SizedBox(width: 8), Text( '${duelState.opponent!.name} a rejoint !',
```

### Icon

```dart
const Icon(Icons.check_circle, color: Colors.green), const SizedBox(width: 8), Text( '${duelState.opponent!.name} a rejoint !',
```

### SizedBox

```dart
const SizedBox(width: 8), Text( '${duelState.opponent!.name} a rejoint !',
```

### SizedBox

```dart
const SizedBox(height: 16), const Text( 'La partie va commencer...', style: TextStyle( color: Colors.green, fontSize: 14, ), ), ],  const Spacer(),  // Bouton Annuler TextButton( onPressed: () {
```

### Text

```dart
const Text( 'La partie va commencer...', style: TextStyle( color: Colors.green, fontSize: 14, ), ), ],  const Spacer(),  // Bouton Annuler TextButton( onPressed: () {
```

### Spacer

```dart
const Spacer(),  // Bouton Annuler TextButton( onPressed: () {
```

