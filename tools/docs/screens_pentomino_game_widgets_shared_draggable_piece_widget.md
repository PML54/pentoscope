# screens/pentomino_game/widgets/shared/draggable_piece_widget.dart

**Module:** screens

## Fonctions

### DraggablePieceWidget

Widget pour gérer proprement le double-tap sans propagation

Gère deux modes :
- Pièce non sélectionnée : LongPressDraggable (long press pour drag)
- Pièce sélectionnée : Draggable normal (drag immédiat)

Interactions :
- Tap simple : sélectionner la pièce
- Double-tap : faire pivoter (si déjà sélectionnée)
- Long press : commencer le drag (si non sélectionnée)
- Drag immédiat : si déjà sélectionnée


```dart
const DraggablePieceWidget({
```

### createState

```dart
State<DraggablePieceWidget> createState() => _DraggablePieceWidgetState();
```

### dispose

```dart
void dispose() {
```

### build

```dart
Widget build(BuildContext context) {
```

