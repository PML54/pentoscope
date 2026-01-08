# pentoscope/screens/pentoscope_menu_screen.dart

**Module:** pentoscope

## Fonctions

### PentoscopeMenuScreen

```dart
const PentoscopeMenuScreen({super.key});
```

### createState

```dart
ConsumerState<PentoscopeMenuScreen> createState() => _PentoscopeMenuScreenState();
```

### build

```dart
Widget build(BuildContext context) {
```

### Scaffold

```dart
return Scaffold( appBar: AppBar( title: const Text('Pentoscope'), centerTitle: true, ), body: SafeArea( child: SingleChildScrollView(  // ← Rendre scrollable child: Padding( padding: const EdgeInsets.all(24.0), child: Column( crossAxisAlignment: CrossAxisAlignment.stretch, children: [ const Text( 'Mini-Puzzles Pentominos', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center, ), const SizedBox(height: 8),   // Sélection de la taille const Text( 'Taille du plateau', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600), ), const SizedBox(height: 12), _buildSizeSelector(),    /* // Sélection de la difficulté const Text( 'Difficulté', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600), ), const SizedBox(height: 12), _buildDifficultySelector(), */   // ✅ NOUVEAU: Toggle "Afficher la solution" Container( padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), decoration: BoxDecoration( color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blue.shade200, width: 1), ), child: Row( children: [ Icon(Icons.lightbulb, color: Colors.blue.shade700), const SizedBox(width: 12), Expanded( child: Column( crossAxisAlignment: CrossAxisAlignment.start, children: [ const Text( 'Training', style: TextStyle( fontSize: 14, fontWeight: FontWeight.w600, ), ), Text( 'Afficher la solution optimale', style: TextStyle( fontSize: 12, color: Colors.grey[600], ), ), ], ), ), Switch( value: _showSolution, onChanged: (value) {
```

### Text

```dart
const Text( 'Mini-Puzzles Pentominos', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center, ), const SizedBox(height: 8),   // Sélection de la taille const Text( 'Taille du plateau', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600), ), const SizedBox(height: 12), _buildSizeSelector(),    /* // Sélection de la difficulté const Text( 'Difficulté', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600), ), const SizedBox(height: 12), _buildDifficultySelector(), */   // ✅ NOUVEAU: Toggle "Afficher la solution" Container( padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), decoration: BoxDecoration( color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blue.shade200, width: 1), ), child: Row( children: [ Icon(Icons.lightbulb, color: Colors.blue.shade700), const SizedBox(width: 12), Expanded( child: Column( crossAxisAlignment: CrossAxisAlignment.start, children: [ const Text( 'Training', style: TextStyle( fontSize: 14, fontWeight: FontWeight.w600, ), ), Text( 'Afficher la solution optimale', style: TextStyle( fontSize: 12, color: Colors.grey[600], ), ), ], ), ), Switch( value: _showSolution, onChanged: (value) {
```

### SizedBox

```dart
const SizedBox(height: 8),   // Sélection de la taille const Text( 'Taille du plateau', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600), ), const SizedBox(height: 12), _buildSizeSelector(),    /* // Sélection de la difficulté const Text( 'Difficulté', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600), ), const SizedBox(height: 12), _buildDifficultySelector(), */   // ✅ NOUVEAU: Toggle "Afficher la solution" Container( padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), decoration: BoxDecoration( color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blue.shade200, width: 1), ), child: Row( children: [ Icon(Icons.lightbulb, color: Colors.blue.shade700), const SizedBox(width: 12), Expanded( child: Column( crossAxisAlignment: CrossAxisAlignment.start, children: [ const Text( 'Training', style: TextStyle( fontSize: 14, fontWeight: FontWeight.w600, ), ), Text( 'Afficher la solution optimale', style: TextStyle( fontSize: 12, color: Colors.grey[600], ), ), ], ), ), Switch( value: _showSolution, onChanged: (value) {
```

### Text

```dart
const Text( 'Taille du plateau', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600), ), const SizedBox(height: 12), _buildSizeSelector(),    /* // Sélection de la difficulté const Text( 'Difficulté', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600), ), const SizedBox(height: 12), _buildDifficultySelector(), */   // ✅ NOUVEAU: Toggle "Afficher la solution" Container( padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), decoration: BoxDecoration( color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blue.shade200, width: 1), ), child: Row( children: [ Icon(Icons.lightbulb, color: Colors.blue.shade700), const SizedBox(width: 12), Expanded( child: Column( crossAxisAlignment: CrossAxisAlignment.start, children: [ const Text( 'Training', style: TextStyle( fontSize: 14, fontWeight: FontWeight.w600, ), ), Text( 'Afficher la solution optimale', style: TextStyle( fontSize: 12, color: Colors.grey[600], ), ), ], ), ), Switch( value: _showSolution, onChanged: (value) {
```

### SizedBox

```dart
const SizedBox(height: 12), _buildSizeSelector(),    /* // Sélection de la difficulté const Text( 'Difficulté', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600), ), const SizedBox(height: 12), _buildDifficultySelector(), */   // ✅ NOUVEAU: Toggle "Afficher la solution" Container( padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), decoration: BoxDecoration( color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blue.shade200, width: 1), ), child: Row( children: [ Icon(Icons.lightbulb, color: Colors.blue.shade700), const SizedBox(width: 12), Expanded( child: Column( crossAxisAlignment: CrossAxisAlignment.start, children: [ const Text( 'Training', style: TextStyle( fontSize: 14, fontWeight: FontWeight.w600, ), ), Text( 'Afficher la solution optimale', style: TextStyle( fontSize: 12, color: Colors.grey[600], ), ), ], ), ), Switch( value: _showSolution, onChanged: (value) {
```

### Text

```dart
const Text( 'Difficulté', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600), ), const SizedBox(height: 12), _buildDifficultySelector(), */   // ✅ NOUVEAU: Toggle "Afficher la solution" Container( padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), decoration: BoxDecoration( color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blue.shade200, width: 1), ), child: Row( children: [ Icon(Icons.lightbulb, color: Colors.blue.shade700), const SizedBox(width: 12), Expanded( child: Column( crossAxisAlignment: CrossAxisAlignment.start, children: [ const Text( 'Training', style: TextStyle( fontSize: 14, fontWeight: FontWeight.w600, ), ), Text( 'Afficher la solution optimale', style: TextStyle( fontSize: 12, color: Colors.grey[600], ), ), ], ), ), Switch( value: _showSolution, onChanged: (value) {
```

### SizedBox

```dart
const SizedBox(height: 12), _buildDifficultySelector(), */   // ✅ NOUVEAU: Toggle "Afficher la solution" Container( padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), decoration: BoxDecoration( color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blue.shade200, width: 1), ), child: Row( children: [ Icon(Icons.lightbulb, color: Colors.blue.shade700), const SizedBox(width: 12), Expanded( child: Column( crossAxisAlignment: CrossAxisAlignment.start, children: [ const Text( 'Training', style: TextStyle( fontSize: 14, fontWeight: FontWeight.w600, ), ), Text( 'Afficher la solution optimale', style: TextStyle( fontSize: 12, color: Colors.grey[600], ), ), ], ), ), Switch( value: _showSolution, onChanged: (value) {
```

### SizedBox

```dart
const SizedBox(width: 12), Expanded( child: Column( crossAxisAlignment: CrossAxisAlignment.start, children: [ const Text( 'Training', style: TextStyle( fontSize: 14, fontWeight: FontWeight.w600, ), ), Text( 'Afficher la solution optimale', style: TextStyle( fontSize: 12, color: Colors.grey[600], ), ), ], ), ), Switch( value: _showSolution, onChanged: (value) {
```

### Text

```dart
const Text( 'Training', style: TextStyle( fontSize: 14, fontWeight: FontWeight.w600, ), ), Text( 'Afficher la solution optimale', style: TextStyle( fontSize: 12, color: Colors.grey[600], ), ), ], ), ), Switch( value: _showSolution, onChanged: (value) {
```

### SizedBox

```dart
const SizedBox(height: 24),  // Bouton Jouer ElevatedButton( onPressed: _startGame, style: ElevatedButton.styleFrom( padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(12), ), ), child: const Text( 'Jouer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), ), ), const SizedBox(height: 16), ], ), ), ), ), );
```

### SizedBox

```dart
const SizedBox(height: 16), ], ), ), ), ), );
```

### Row

```dart
return Row( children: PentoscopeSize.values.map((size) {
```

### Expanded

```dart
return Expanded( child: GestureDetector( onTap: () => setState(() => _selectedSize = size), child: Container( margin: const EdgeInsets.symmetric(horizontal: 4), padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8), decoration: BoxDecoration( color: isSelected ? Theme.of(context).primaryColor : Colors.grey[200], borderRadius: BorderRadius.circular(12), border: Border.all( color: isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!, width: 2, ), ), child: Column( children: [ Text( size.label, style: TextStyle( fontSize: 18, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.black87, ), ), const SizedBox(height: 4), Text( '${size.numPieces} pièces',
```

### SizedBox

```dart
const SizedBox(height: 4), Text( '${size.numPieces} pièces',
```

### Row

```dart
return Row( children: [ _buildDifficultyButton( PentoscopeDifficulty.easy, 'Facile', Icons.sentiment_satisfied, Colors.green, ), const SizedBox(width: 8), _buildDifficultyButton( PentoscopeDifficulty.random, 'Aléatoire', Icons.shuffle, Colors.blue, ),  ], );
```

### SizedBox

```dart
const SizedBox(width: 8), _buildDifficultyButton( PentoscopeDifficulty.random, 'Aléatoire', Icons.shuffle, Colors.blue, ),  ], );
```

### Expanded

```dart
return Expanded( child: GestureDetector( onTap: () => setState(() => _selectedDifficulty = difficulty), child: Container( padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration( color: isSelected ? color.withOpacity(0.15) : Colors.grey[100], borderRadius: BorderRadius.circular(12), border: Border.all( color: isSelected ? color : Colors.grey[300]!, width: 2, ), ), child: Column( children: [ Icon(icon, color: isSelected ? color : Colors.grey[500], size: 28), const SizedBox(height: 4), Text( label, style: TextStyle( fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? color : Colors.grey[600], ), ), ], ), ), ), );
```

### SizedBox

```dart
const SizedBox(height: 4), Text( label, style: TextStyle( fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? color : Colors.grey[600], ), ), ], ), ), ), );
```

