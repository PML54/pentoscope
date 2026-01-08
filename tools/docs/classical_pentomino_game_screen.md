# classical/pentomino_game_screen.dart

**Module:** classical

## Fonctions

### PentominoGameScreen

```dart
const PentominoGameScreen({super.key});
```

### createState

```dart
ConsumerState<PentominoGameScreen> createState() => _PentominoGameScreenState();
```

### build

```dart
Widget build(BuildContext context) {
```

### SizedBox

```dart
const SizedBox(height: 8), Text( 'Score: $score ⭐', style: const TextStyle( fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange, ), ), if (solutionInfo != null) ...[ const SizedBox(height: 16), const Divider(), const SizedBox(height: 8), Text( 'Solution #${solutionInfo.index + 1}',
```

### SizedBox

```dart
const SizedBox(height: 16), const Divider(), const SizedBox(height: 8), Text( 'Solution #${solutionInfo.index + 1}',
```

### Divider

```dart
const Divider(), const SizedBox(height: 8), Text( 'Solution #${solutionInfo.index + 1}',
```

### SizedBox

```dart
const SizedBox(height: 8), Text( 'Solution #${solutionInfo.index + 1}',
```

### SizedBox

```dart
const SizedBox(height: 4), Text( 'Famille ${solutionInfo.canonicalIndex + 1} • ${solutionInfo.variantName}',
```

### Scaffold

```dart
return Scaffold( backgroundColor: Colors.white, // AppBar uniquement en mode portrait appBar: isLandscape ? null : PreferredSize( preferredSize: const Size.fromHeight(56.0), child: AppBar( toolbarHeight: 56.0, backgroundColor: Colors.white,  // ✨ NOUVEAU: Chrono à gauche leading: Padding( padding: const EdgeInsets.symmetric(horizontal: 4.0), child: Column( mainAxisAlignment: MainAxisAlignment.center, children: [ Text( _formatTime(state.elapsedSeconds), style: const TextStyle( fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black, ), ), // ✨ Afficher la note seulement si puzzle complet if (state.availablePieces.isEmpty) Text( '⭐ ${notifier.calculateScore(state.elapsedSeconds)}',
```

### TutorialOverlay

```dart
const TutorialOverlay(), const TutorialControls(), ], ), );
```

### TutorialControls

```dart
const TutorialControls(), ], ), );
```

### dispose

```dart
void dispose() {
```

### initState

```dart
void initState() {
```

### didChangeDependencies

```dart
void didChangeDependencies() {
```

### Row

Layout paysage : plateau à gauche, actions + slider vertical à droite


```dart
return Row( children: [ // Plateau de jeu (10×6 visuel) Expanded( child: GameBoard(isLandscape: true), ),  // Colonne de droite : actions + slider Row( children: [ // Slider d'actions verticales (même logique que l'AppBar) Container( width: 44, decoration: BoxDecoration( color: Colors.white, boxShadow: [ BoxShadow( color: Colors.black.withOpacity(0.05), blurRadius: 2, offset: const Offset(-1, 0), ), ], ), child: const ActionSlider(isLandscape: true), ),  // Slider de pièces vertical AVEC DragTarget _buildSliderWithDragTarget(ref: ref, isLandscape: true), ], ), ], );
```

### Column

Layout portrait (classique) : plateau en haut, slider en bas


```dart
return Column( children: [ // Plateau de jeu Expanded( flex: 3, child: GameBoard(isLandscape: false), ),  // Slider de pièces horizontal AVEC DragTarget _buildSliderWithDragTarget(ref: ref, isLandscape: false), ], );
```

### AnimatedContainer

Construit le slider enveloppé dans un DragTarget
Quand on drag une pièce placée vers le slider, elle est retirée du plateau


```dart
return AnimatedContainer( duration: const Duration(milliseconds: 150), curve: Curves.easeOut, height: isLandscape ? null : 140, width: isLandscape ? 120 : null, decoration: BoxDecoration( color: isHovering ? Colors.red.shade50 : Colors.grey.shade100, border: isHovering ? Border.all(color: Colors.red.shade400, width: 3) : null, boxShadow: [ BoxShadow( color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: isLandscape ? const Offset(-2, 0) : const Offset(0, -2), ), ], ), child: Stack( children: [ // Le slider PieceSlider(isLandscape: isLandscape),  // Overlay de suppression au survol if (isHovering) Positioned.fill( child: IgnorePointer( child: Container( color: Colors.red.withOpacity(0.1), child: Center( child: TweenAnimationBuilder<double>( tween: Tween(begin: 0.8, end: 1.0), duration: const Duration(milliseconds: 200), curve: Curves.elasticOut, builder: (context, scale, child) {
```

