# tutorial/commands/highlight_isometry_icon.dart

**Module:** tutorial

## Fonctions

### HighlightIsometryIconCommand

Commande : Surligne une icône d'isométrie

Syntaxe YAML :
```yaml
- type: highlight_isometry_icon
icon: rotation  # rotation, rotation_cw, symmetry_h, symmetry_v
```

Valeurs possibles pour `icon` :
- `rotation` : Rotation 90° anti-horaire (🔄 `Icons.rotate_right`)
- `rotation_cw` : Rotation 90° horaire (🔃 `Icons.rotate_left`)
- `symmetry_h` : Symétrie horizontale (↔️ `Icons.swap_horiz`)
- `symmetry_v` : Symétrie verticale (↕️ `Icons.swap_vert`)


```dart
const HighlightIsometryIconCommand({required this.icon});
```

### FormatException

```dart
throw FormatException( 'highlight_isometry_icon: le paramètre "icon" est obligatoire', );
```

### FormatException

```dart
throw FormatException( 'highlight_isometry_icon: icône invalide "$icon". ' 'Valeurs possibles : ${validIcons.join(", ")}',
```

### HighlightIsometryIconCommand

```dart
return HighlightIsometryIconCommand(icon: icon);
```

### validate

```dart
bool validate() {
```

### execute

```dart
Future<void> execute(TutorialContext context) async {
```

### ClearIsometryIconHighlightCommand

Commande : Efface la surbrillance des icônes d'isométrie

Syntaxe YAML :
```yaml
- type: clear_isometry_icon_highlight
```


```dart
const ClearIsometryIconHighlightCommand();
```

### execute

```dart
Future<void> execute(TutorialContext context) async {
```

