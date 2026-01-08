# duel/screens/duel_home_screen.dart

**Module:** duel

## Fonctions

### DuelHomeScreen

```dart
const DuelHomeScreen({super.key});
```

### build

```dart
Widget build(BuildContext context, WidgetRef ref) {
```

### Scaffold

```dart
return Scaffold( appBar: AppBar( title: const Text('Mode Duel'), centerTitle: true, ), body: Container( decoration: BoxDecoration( gradient: LinearGradient( begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [ Colors.blue.shade50, Colors.white, ], ), ), child: SafeArea( child: Padding( padding: const EdgeInsets.all(24.0), child: Column( mainAxisAlignment: MainAxisAlignment.center, children: [ // Icône const Icon( Icons.sports_esports, size: 100, color: Colors.blue, ), const SizedBox(height: 24),  // Titre const Text( 'Défiez un ami !', style: TextStyle( fontSize: 28, fontWeight: FontWeight.bold, ), ), const SizedBox(height: 12),  // Description Text( 'Placez plus de pièces que votre adversaire\nsur le même plateau en temps réel !', textAlign: TextAlign.center, style: TextStyle( fontSize: 16, color: Colors.grey.shade600, ), ), const SizedBox(height: 48),  // Bouton Créer une partie SizedBox( width: double.infinity, height: 56, child: ElevatedButton.icon( onPressed: () {
```

### Icon

```dart
const Icon( Icons.sports_esports, size: 100, color: Colors.blue, ), const SizedBox(height: 24),  // Titre const Text( 'Défiez un ami !', style: TextStyle( fontSize: 28, fontWeight: FontWeight.bold, ), ), const SizedBox(height: 12),  // Description Text( 'Placez plus de pièces que votre adversaire\nsur le même plateau en temps réel !', textAlign: TextAlign.center, style: TextStyle( fontSize: 16, color: Colors.grey.shade600, ), ), const SizedBox(height: 48),  // Bouton Créer une partie SizedBox( width: double.infinity, height: 56, child: ElevatedButton.icon( onPressed: () {
```

### SizedBox

```dart
const SizedBox(height: 24),  // Titre const Text( 'Défiez un ami !', style: TextStyle( fontSize: 28, fontWeight: FontWeight.bold, ), ), const SizedBox(height: 12),  // Description Text( 'Placez plus de pièces que votre adversaire\nsur le même plateau en temps réel !', textAlign: TextAlign.center, style: TextStyle( fontSize: 16, color: Colors.grey.shade600, ), ), const SizedBox(height: 48),  // Bouton Créer une partie SizedBox( width: double.infinity, height: 56, child: ElevatedButton.icon( onPressed: () {
```

### Text

```dart
const Text( 'Défiez un ami !', style: TextStyle( fontSize: 28, fontWeight: FontWeight.bold, ), ), const SizedBox(height: 12),  // Description Text( 'Placez plus de pièces que votre adversaire\nsur le même plateau en temps réel !', textAlign: TextAlign.center, style: TextStyle( fontSize: 16, color: Colors.grey.shade600, ), ), const SizedBox(height: 48),  // Bouton Créer une partie SizedBox( width: double.infinity, height: 56, child: ElevatedButton.icon( onPressed: () {
```

### SizedBox

```dart
const SizedBox(height: 12),  // Description Text( 'Placez plus de pièces que votre adversaire\nsur le même plateau en temps réel !', textAlign: TextAlign.center, style: TextStyle( fontSize: 16, color: Colors.grey.shade600, ), ), const SizedBox(height: 48),  // Bouton Créer une partie SizedBox( width: double.infinity, height: 56, child: ElevatedButton.icon( onPressed: () {
```

### SizedBox

```dart
const SizedBox(height: 48),  // Bouton Créer une partie SizedBox( width: double.infinity, height: 56, child: ElevatedButton.icon( onPressed: () {
```

### SizedBox

```dart
const SizedBox(height: 16),  // Bouton Rejoindre une partie SizedBox( width: double.infinity, height: 56, child: OutlinedButton.icon( onPressed: () {
```

### Spacer

```dart
const Spacer(),  // Règles rapides Container( padding: const EdgeInsets.all(16), decoration: BoxDecoration( color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12), ), child: Column( children: [ const Text( '📋 Règles rapides', style: TextStyle( fontWeight: FontWeight.bold, fontSize: 16, ), ), const SizedBox(height: 8), Text( '• Même puzzle pour les 2 joueurs\n' '• Tournez les pièces pour trouver la bonne orientation\n' '• Premier à placer une pièce la gagne\n' '• Le plus de pièces placées gagne !', style: TextStyle( color: Colors.grey.shade700, height: 1.5, ), ), ], ), ), ], ), ), ), ), );
```

### Text

```dart
const Text( '📋 Règles rapides', style: TextStyle( fontWeight: FontWeight.bold, fontSize: 16, ), ), const SizedBox(height: 8), Text( '• Même puzzle pour les 2 joueurs\n' '• Tournez les pièces pour trouver la bonne orientation\n' '• Premier à placer une pièce la gagne\n' '• Le plus de pièces placées gagne !', style: TextStyle( color: Colors.grey.shade700, height: 1.5, ), ), ], ), ), ], ), ), ), ), );
```

### SizedBox

```dart
const SizedBox(height: 8), Text( '• Même puzzle pour les 2 joueurs\n' '• Tournez les pièces pour trouver la bonne orientation\n' '• Premier à placer une pièce la gagne\n' '• Le plus de pièces placées gagne !', style: TextStyle( color: Colors.grey.shade700, height: 1.5, ), ), ], ), ), ], ), ), ), ), );
```

