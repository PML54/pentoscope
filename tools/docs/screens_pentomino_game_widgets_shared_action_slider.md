# screens/pentomino_game/widgets/shared/action_slider.dart

**Module:** screens

## Fonctions

### getCompatibleSolutionsIncludingSelected

✅ Fonction helper en dehors de la classe


```dart
List<BigInt> getCompatibleSolutionsIncludingSelected(PentominoGameState state) {
```

### ActionSlider

Formate le temps en secondes (max 999s)
Slider vertical d'actions en mode paysage


```dart
const ActionSlider({
```

### build

```dart
Widget build(BuildContext context, WidgetRef ref) {
```

### LayoutBuilder

```dart
return LayoutBuilder( builder: (context, constraints) {
```

### Column

Actions en mode TRANSFORMATION (pièce sélectionnée)
✨ Utilise les mêmes tailles que UISizes pour cohérence portrait/paysage


```dart
return Column( mainAxisAlignment: MainAxisAlignment.center, children: [ // Rotation anti-horaire IconButton( icon: Icon(GameIcons.isometryRotationTW.icon, size: effectiveIconSize), padding: buttonPadding, constraints: buttonConstraints, onPressed: () {
```

### Column

Actions en mode GÉNÉRAL (aucune pièce sélectionnée)
✨ Utilise les mêmes tailles que UISizes pour cohérence portrait/paysage


```dart
return Column( mainAxisAlignment: MainAxisAlignment.center, children: [ // ⏱️ Chronomètre compact (secondes, max 999s) Padding( padding: const EdgeInsets.only(bottom: 8), child: Text( _formatTimeCompact(state.elapsedSeconds), style: const TextStyle( fontSize: UISizes.timerFontSize, fontWeight: FontWeight.bold, color: Colors.black, ), ), ),  // Compteur de solutions if (state.solutionsCount != null && state.solutionsCount! > 0 && state.placedPieces.isNotEmpty) Padding( padding: const EdgeInsets.symmetric(vertical: 8), child: ElevatedButton( onPressed: () {
```

