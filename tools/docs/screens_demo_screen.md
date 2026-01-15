# screens/demo_screen.dart

**Module:** screens

## Fonctions

### DemoScreen

```dart
const DemoScreen({super.key});
```

### createState

```dart
ConsumerState<DemoScreen> createState() => _DemoScreenState();
```

### initState

```dart
void initState() {
```

### dispose

```dart
void dispose() {
```

### AnimatedPieceWidget

Anime le placement d'une pièce depuis le slider vers le plateau


```dart
return AnimatedPieceWidget( piece: piece, startPosition: startPosition, endPosition: endPosition, duration: const Duration(milliseconds: 2000), onComplete: () {
```

### build

```dart
Widget build(BuildContext context) {
```

### Scaffold

```dart
return Scaffold( appBar: AppBar( title: const Text('Démonstration automatique'), actions: [ if (_isPlaying) IconButton( icon: const Icon(Icons.stop), onPressed: _stopDemo, tooltip: 'Arrêter la démo', ) else IconButton( icon: const Icon(Icons.play_arrow), onPressed: _startDemo, tooltip: 'Relancer la démo', ), ], ), body: Column( children: [ // Zone de message Container( width: double.infinity, padding: const EdgeInsets.all(16), color: colorScheme.primaryContainer.withOpacity(0.3), child: Text( _currentMessage, style: theme.textTheme.titleMedium?.copyWith( color: colorScheme.onPrimaryContainer, fontWeight: FontWeight.w500, ), textAlign: TextAlign.center, ), ),  // Indicateur de progression LinearProgressIndicator( value: _step / _demoSteps.length, backgroundColor: colorScheme.surfaceVariant, valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary), ),  // Jeu Pentominos (avec overlay pour la démo) Expanded( child: Stack( children: [ const PentominoGameScreen(),  /*                // Overlay semi-transparent pendant la démo if (_isPlaying) Container( color: Colors.black.withOpacity(0.1), child: const Center( child: Card( child: Padding( padding: EdgeInsets.all(16), child: Text( 'Démonstration en cours...\nRegardez les actions automatiques', textAlign: TextAlign.center, ), ), ), ), ),*/  // Bouton pour arrêter/recommencer en bas Positioned( bottom: 16, right: 16, child: FloatingActionButton( onPressed: _isPlaying ? _stopDemo : _startDemo, child: Icon(_isPlaying ? Icons.stop : Icons.play_arrow), ), ), ], ), ), ], ), );
```

### PentominoGameScreen

```dart
const PentominoGameScreen(),  /*                // Overlay semi-transparent pendant la démo if (_isPlaying) Container( color: Colors.black.withOpacity(0.1), child: const Center( child: Card( child: Padding( padding: EdgeInsets.all(16), child: Text( 'Démonstration en cours...\nRegardez les actions automatiques', textAlign: TextAlign.center, ), ), ), ), ),*/  // Bouton pour arrêter/recommencer en bas Positioned( bottom: 16, right: 16, child: FloatingActionButton( onPressed: _isPlaying ? _stopDemo : _startDemo, child: Icon(_isPlaying ? Icons.stop : Icons.play_arrow), ), ), ], ), ), ], ), );
```

### DemoStep

Étape de démonstration


```dart
const DemoStep({
```

### AnimatedPieceWidget

Actions possibles dans la démo
Widget pour animer une pièce se déplaçant du slider vers le plateau


```dart
const AnimatedPieceWidget({
```

### createState

```dart
State<AnimatedPieceWidget> createState() => _AnimatedPieceWidgetState();
```

### initState

```dart
void initState() {
```

### dispose

```dart
void dispose() {
```

### build

```dart
Widget build(BuildContext context) {
```

### AnimatedBuilder

```dart
return AnimatedBuilder( animation: _positionAnimation, builder: (context, child) {
```

### Positioned

```dart
return Positioned( left: _positionAnimation.value.dx, top: _positionAnimation.value.dy, child: Transform.scale( scale: _scaleAnimation.value, child: Opacity( opacity: 0.9, child: PentominoPieceWidget( piece: widget.piece, cellSize: 24, // Taille adaptée pour l'animation positionIndex: 0, // Position par défaut ), ), ), );
```

### PentominoPieceWidget

Widget pour afficher une pièce pentomino


```dart
const PentominoPieceWidget({
```

### build

```dart
Widget build(BuildContext context) {
```

### SizedBox

```dart
return SizedBox( width: width, height: height, child: Stack( children: position.map((cellNum) {
```

### Positioned

```dart
return Positioned( left: adjustedX, top: adjustedY, child: Container( width: cellSize - 1, // Petit espacement height: cellSize - 1, decoration: BoxDecoration( color: Colors.blue.shade600, border: Border.all( color: Colors.white, width: 1, ), borderRadius: BorderRadius.circular(2), ), ), );
```

