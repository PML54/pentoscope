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

Formate le temps en secondes (max 999s) - compact pour l'UI


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
return Scaffold( backgroundColor: Colors.white, // AppBar uniquement en mode portrait appBar: isLandscape ? null : PreferredSize( preferredSize: const Size.fromHeight(56.0), child: AppBar( toolbarHeight: UISizes.appBarHeight, backgroundColor: Colors.white, automaticallyImplyLeading: false,  // ✨ Pas de flèche retour automatique  // ✨ Croix rouge + Chrono à gauche (masqués si pièce sélectionnée) leading: isInTransformMode ? null  // Pas de leading en mode transformation : Row( mainAxisSize: MainAxisSize.min, children: [ // Croix rouge pour quitter IconButton( icon: const Icon(Icons.close), color: Colors.red, iconSize: UISizes.appBarIconSize, onPressed: () {
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

### LayoutBuilder

Layout paysage : plateau à gauche, actions + slider vertical à droite


```dart
return LayoutBuilder( builder: (context, constraints) {
```

### Row

```dart
return Row( children: [ // Plateau de jeu (10×6 visuel) Expanded( child: GameBoard(isLandscape: true), ),  // Colonne de droite : actions + slider Row( children: [ // Slider d'actions verticales (même logique que l'AppBar) Container( width: actionColumnWidth, decoration: BoxDecoration( color: Colors.white, boxShadow: [ BoxShadow( color: Colors.black.withOpacity(0.05), blurRadius: 2, offset: const Offset(-1, 0), ), ], ), child: const ActionSlider(isLandscape: true), ),  // Slider de pièces vertical AVEC DragTarget _buildSliderWithDragTarget(ref: ref, isLandscape: true, width: sliderWidth), ], ), ], );
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
return AnimatedContainer( duration: const Duration(milliseconds: 150), curve: Curves.easeOut, height: isLandscape ? null : 170, width: isLandscape ? (width ?? 140) : null, decoration: BoxDecoration( color: isHovering ? Colors.red.shade50 : Colors.grey.shade100, border: isHovering ? Border.all(color: Colors.red.shade400, width: 3) : null, boxShadow: [ BoxShadow( color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: isLandscape ? const Offset(-2, 0) : const Offset(0, -2), ), ], ), child: Stack( children: [ // Le slider PieceSlider(isLandscape: isLandscape),  // Overlay de suppression au survol if (isHovering) Positioned.fill( child: IgnorePointer( child: Container( color: Colors.red.withOpacity(0.1), child: Center( child: TweenAnimationBuilder<double>( tween: Tween(begin: 0.8, end: 1.0), duration: const Duration(milliseconds: 200), curve: Curves.elasticOut, builder: (context, scale, child) {
```

