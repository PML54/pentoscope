# screens/pentomino_game/widgets/shared/highlighted_icon_button.dart

**Module:** screens

## Fonctions

### HighlightedIconButton

Widget qui wrappe un IconButton et affiche une surbrillance animée
quand isHighlighted == true


```dart
const HighlightedIconButton({
```

### createState

```dart
State<HighlightedIconButton> createState() => _HighlightedIconButtonState();
```

### initState

```dart
void initState() {
```

### dispose

```dart
void dispose() {
```

### build

```dart
Widget build(BuildContext context) {
```

### AnimatedBuilder

```dart
return AnimatedBuilder( animation: _animation, builder: (context, child) {
```

### Container

```dart
return Container( decoration: BoxDecoration( shape: BoxShape.circle, boxShadow: [ BoxShadow( color: widget.highlightColor.withOpacity(_animation.value * 0.6), blurRadius: 12, spreadRadius: 2, ), ], border: Border.all( color: widget.highlightColor.withOpacity(_animation.value), width: 3, ), ), child: widget.child, );
```

