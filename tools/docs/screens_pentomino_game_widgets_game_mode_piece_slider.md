# screens/pentomino_game/widgets/game_mode/piece_slider.dart

**Module:** screens

## Fonctions

### PieceSlider

Slider de pièces disponibles

Affiche les pièces non encore placées dans un slider infini.
- Portrait: horizontal en bas
- Paysage: vertical à droite


```dart
const PieceSlider({
```

### createState

```dart
ConsumerState<PieceSlider> createState() => _PieceSliderState();
```

### dispose

```dart
void dispose() {
```

### build

```dart
Widget build(BuildContext context) {
```

### Padding

Construit une pièce draggable


```dart
return Padding( padding: const EdgeInsets.symmetric(horizontal: 6), child: Container( padding: const EdgeInsets.all(10), decoration: BoxDecoration( color: isSelected ? Colors.amber.shade100 : Colors.transparent, borderRadius: BorderRadius.circular(12), border: isSelected ? Border.all( color: Colors.amber.shade700, width: 3, ) : null, boxShadow: isSelected ? [ BoxShadow( color: Colors.black.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 4), ), ] : null, ), child: DraggablePieceWidget( piece: piece, positionIndex: positionIndex, isSelected: isSelected, selectedPositionIndex: state.selectedPositionIndex, longPressDuration: Duration(milliseconds: settings.game.longPressDuration), onSelect: () {
```

