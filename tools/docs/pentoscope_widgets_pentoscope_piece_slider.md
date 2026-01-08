# pentoscope/widgets/pentoscope_piece_slider.dart

**Module:** pentoscope

## Fonctions

### PentoscopePieceSlider

```dart
const PentoscopePieceSlider({
```

### build

```dart
Widget build(BuildContext context, WidgetRef ref) {
```

### Padding

Convertit positionIndex interne en displayPositionIndex pour l'affichage


```dart
return Padding( padding: const EdgeInsets.symmetric(horizontal: 8), child: Container( padding: const EdgeInsets.all(12), decoration: BoxDecoration( color: isSelected ? Colors.amber.shade100 : Colors.transparent, borderRadius: BorderRadius.circular(12), border: isSelected ? Border.all(color: Colors.amber.shade700, width: 3) : null, boxShadow: isSelected ? [ BoxShadow( color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4), ), ] : null, ), child: Transform.rotate( angle: isLandscape ? -math.pi / 2 : 0.0, // ✅ rotation visuelle du slider en paysage child:  Transform.scale( scale:1.5 , child: DraggablePieceWidget( piece: piece, positionIndex: displayPositionIndex, isSelected: isSelected, selectedPositionIndex: isSelected ? displayPositionIndex : state.selectedPositionIndex, longPressDuration: Duration(milliseconds: settings.game.longPressDuration), onSelect: () {
```

