# screens/pentomino_game/widgets/shared/piece_renderer.dart

**Module:** screens

## Fonctions

### PieceRenderer

Widget qui affiche une pièce de pentomino

Utilisé dans :
- Le slider de pièces
- Le feedback de drag
- Partout où on doit afficher une pièce


```dart
const PieceRenderer({
```

### build

```dart
Widget build(BuildContext context) {
```

### Container

```dart
return Container( width: width * cellSize + 8, height: height * cellSize + 8, decoration: BoxDecoration( boxShadow: isDragging ? [ BoxShadow( color: GameColors.draggingShadowColor, blurRadius: 10, offset: const Offset(0, 5), ), ] : null, ), child: Stack( children: [ // Les 5 carrés de la pièce for (final coord in coords) Positioned( left: (coord['x']! - minX) * cellSize + 4, top: (coord['y']! - minY) * cellSize + 4, child: Container( width: cellSize, height: cellSize, decoration: BoxDecoration( color: getPieceColor(piece.id), border: Border.all(color: GameColors.pieceInnerBorderColor, width: 1.5), borderRadius: BorderRadius.circular(3), boxShadow: [ BoxShadow( color: GameColors.shadowColorDark, blurRadius: 2, offset: const Offset(1, 1), ), ], ), // Numéro de la pièce sur le premier carré child: coord == coords.first ? Center( child: Text( piece.id.toString(), style: const TextStyle( color: GameColors.pieceTextColor, fontSize: 12, fontWeight: FontWeight.bold, shadows: [ Shadow( color: Colors.black54, blurRadius: 2, ), ], ), ), ) : null, ), ), ], ), );
```

