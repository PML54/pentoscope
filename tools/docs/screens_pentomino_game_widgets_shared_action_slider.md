# screens/pentomino_game/widgets/shared/action_slider.dart

**Module:** screens

## Fonctions

### getCompatibleSolutionsIncludingSelected

✅ Fonction helper en dehors de la classe


```dart
List<BigInt> getCompatibleSolutionsIncludingSelected(PentominoGameState state) {
```

### ActionSlider

Slider vertical d'actions en mode paysage


```dart
const ActionSlider({
```

### build

```dart
Widget build(BuildContext context, WidgetRef ref) {
```

### Column

Actions en mode TRANSFORMATION (pièce sélectionnée)


```dart
return Column( mainAxisAlignment: MainAxisAlignment.center, children: [ // ✅ Bouton Solutions (si > 0) if (state.solutionsCount != null && state.solutionsCount! > 0) Padding( padding: const EdgeInsets.only(bottom: 12), child: ElevatedButton( onPressed: () {
```

### SizedBox

```dart
const SizedBox(height: 8),  // Rotation horaire IconButton( icon: Icon(GameIcons.isometryRotationCW.icon, size: 28), padding: const EdgeInsets.all(8), constraints: const BoxConstraints(minWidth: 40, minHeight: 40), onPressed: () {
```

### SizedBox

```dart
const SizedBox(height: 8),  // Symétrie Horizontale (visuelle) // ✅ En mode paysage : H visuel = V logique (à cause de la rotation du plateau) IconButton( icon: Icon(GameIcons.isometrySymmetryH.icon, size: 28), padding: const EdgeInsets.all(8), constraints: const BoxConstraints(minWidth: 40, minHeight: 40), onPressed: () {
```

### SizedBox

```dart
const SizedBox(height: 8),  // Symétrie Verticale (visuelle) // ✅ En mode paysage : V visuel = H logique (à cause de la rotation du plateau) IconButton( icon: Icon(GameIcons.isometrySymmetryV.icon, size: 28), padding: const EdgeInsets.all(8), constraints: const BoxConstraints(minWidth: 40, minHeight: 40), onPressed: () {
```

### SizedBox

```dart
const SizedBox(height: 8), IconButton( icon: Icon(GameIcons.removePiece.icon, size: 28), padding: const EdgeInsets.all(8), constraints: const BoxConstraints(minWidth: 40, minHeight: 40), onPressed: () {
```

### Column

Actions en mode GÉNÉRAL (aucune pièce sélectionnée)


```dart
return Column( mainAxisAlignment: MainAxisAlignment.center, children: [ // Paramètres Material( color: Colors.transparent, child: InkWell( onTap: () {
```

### SizedBox

```dart
const SizedBox(height: 12),  // Compteur de solutions if (state.solutionsCount != null && state.solutionsCount! > 0 && state.placedPieces.isNotEmpty) Padding( padding: const EdgeInsets.only(bottom: 8), child: ElevatedButton( onPressed: () {
```

### SizedBox

```dart
const SizedBox(height: 8),  // Bouton Undo IconButton( icon: Icon(GameIcons.undo.icon, size: 22), padding: const EdgeInsets.all(8), constraints: const BoxConstraints(minWidth: 40, minHeight: 40), onPressed: state.placedPieces.isNotEmpty ? () {
```

