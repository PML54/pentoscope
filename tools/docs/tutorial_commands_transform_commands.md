# tutorial/commands/transform_commands.dart

**Module:** tutorial

## Fonctions

### RotateAroundMasterCommand

ROTATE_AROUND_MASTER
Fait pivoter une pièce autour de sa mastercase

Paramètres :
- pieceNumber: numéro de la pièce
- quarterTurns: nombre de quarts de tour (1=90°, 2=180°, 3=270°)
- direction: 'cw' (horaire) ou 'ccw' (anti-horaire), défaut: 'cw'
- duration: durée de l'animation en ms (défaut: 500)


```dart
const RotateAroundMasterCommand({
```

### execute

```dart
Future<void> execute(TutorialContext context) async {
```

### FormatException

```dart
throw FormatException( 'ROTATE_AROUND_MASTER: le paramètre "pieceNumber" est obligatoire', );
```

### FormatException

```dart
throw FormatException( 'ROTATE_AROUND_MASTER: le paramètre "quarterTurns" est obligatoire', );
```

### RotateAroundMasterCommand

```dart
return RotateAroundMasterCommand( pieceNumber: pieceNum is int ? pieceNum : int.parse(pieceNum.toString()), quarterTurns: qTurns is int ? qTurns : int.parse(qTurns.toString()), direction: params['direction'] as String? ?? 'cw', durationMs: dur == null ? 500 : (dur is int ? dur : int.parse(dur.toString())), );
```

### SymmetryAroundMasterCommand

SYMMETRY_AROUND_MASTER
Applique une symétrie à une pièce autour de sa mastercase

Paramètres :
- pieceNumber: numéro de la pièce
- symmetryKind: 'H' (horizontale) ou 'V' (verticale)
- duration: durée de l'animation en ms (défaut: 500)


```dart
const SymmetryAroundMasterCommand({
```

### execute

```dart
Future<void> execute(TutorialContext context) async {
```

### FormatException

```dart
throw FormatException( 'SYMMETRY_AROUND_MASTER: symmetryKind doit être "H" ou "V", reçu: "$symmetryKind"', );
```

### FormatException

```dart
throw FormatException( 'SYMMETRY_AROUND_MASTER: le paramètre "pieceNumber" est obligatoire', );
```

### FormatException

```dart
throw FormatException( 'SYMMETRY_AROUND_MASTER: le paramètre "symmetryKind" est obligatoire', );
```

### SymmetryAroundMasterCommand

```dart
return SymmetryAroundMasterCommand( pieceNumber: pieceNum is int ? pieceNum : int.parse(pieceNum.toString()), symmetryKind: symKind.toString(), durationMs: dur == null ? 500 : (dur is int ? dur : int.parse(dur.toString())), );
```

