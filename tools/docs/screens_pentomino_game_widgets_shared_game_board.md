# screens/pentomino_game/widgets/shared/game_board.dart

**Module:** screens

## Fonctions

### GameBoard

Plateau de jeu 6×10

Gère :
- Affichage grille avec pièces
- Drag & drop des pièces
- Preview en temps réel avec SNAP intelligent
- Sélection et déplacement
- Rotation portrait/paysage


```dart
const GameBoard({
```

### build

```dart
Widget build(BuildContext context, WidgetRef ref) {
```

### LayoutBuilder

```dart
return LayoutBuilder( builder: (context, constraints) {
```

### Center

```dart
return Center( child: Container( width: cellSize * visualCols, height: cellSize * visualRows, decoration: BoxDecoration( gradient: LinearGradient( begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [ Colors.grey.shade50, Colors.grey.shade100, ], ), boxShadow: [ BoxShadow( color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 4), ), ], borderRadius: BorderRadius.circular(16), ), child: ClipRRect( borderRadius: BorderRadius.circular(16), child: DragTarget<Pento>( onWillAcceptWithDetails: (details) => true, onMove: (details) {
```

