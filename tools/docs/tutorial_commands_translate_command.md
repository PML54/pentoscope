# tutorial/commands/translate_command.dart

**Module:** tutorial

## Fonctions

### TranslateCommand

TRANSLATE - Translate une pièce vers une nouvelle position

Déplace une pièce placée vers une nouvelle position en utilisant sa mastercase.
La position de départ est détectée automatiquement.

Paramètres :
- pieceNumber: numéro de la pièce à déplacer
- toX, toY: position finale de la mastercase
- duration: durée de l'animation en ms (défaut: 500)
- animated: si true, anime le déplacement case par case (défaut: false)

Syntaxe YAML :
```yaml
- command: TRANSLATE
params:
pieceNumber: 6
toX: 5
toY: 7
duration: 1500
animated: true  # Animation progressive
```


```dart
const TranslateCommand({
```

### execute

```dart
Future<void> execute(TutorialContext context) async {
```

### FormatException

Translation directe (saut instantané)
Translation animée (déplacement progressif case par case)


```dart
throw FormatException( 'TRANSLATE: le paramètre "pieceNumber" est obligatoire', );
```

### FormatException

```dart
throw FormatException( 'TRANSLATE: les paramètres "toX" et "toY" sont obligatoires', );
```

### TranslateCommand

```dart
return TranslateCommand( pieceNumber: pieceNum is int ? pieceNum : int.parse(pieceNum.toString()), toX: tX is int ? tX : int.parse(tX.toString()), toY: tY is int ? tY : int.parse(tY.toString()), durationMs: dur == null ? 500 : (dur is int ? dur : int.parse(dur.toString())), animated: anim == true || anim == 'true', // Support bool et string );
```

