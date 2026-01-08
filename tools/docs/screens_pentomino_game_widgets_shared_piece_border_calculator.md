# screens/pentomino_game/widgets/shared/piece_border_calculator.dart

**Module:** screens

## Fonctions

### calculate

Calcule les bordures d'une cellule sur le plateau

Affiche des bordures épaisses aux frontières entre pièces différentes
et des bordures fines à l'intérieur d'une même pièce.

En mode paysage, les bordures sont adaptées à la rotation visuelle.
Construit un contour de pièce sur le plateau

[x], [y] : coordonnées logiques (toujours 6×10)
[plateau] : le plateau de jeu
[isLandscape] : true si en mode paysage (rotation 90° anti-horaire)


```dart
static Border calculate(int x, int y, Plateau plateau, bool isLandscape) {
```

### neighborId

```dart
int neighborId(int nx, int ny) {
```

### Border

```dart
return Border( top: BorderSide( color: (idLogicalRight != baseId) ? GameColors.pieceBorderColor : GameColors.pieceBorderLightColor, width: (idLogicalRight != baseId) ? borderWidthOuter : borderWidthInner, ), bottom: BorderSide( color: (idLogicalLeft != baseId) ? GameColors.pieceBorderColor : GameColors.pieceBorderLightColor, width: (idLogicalLeft != baseId) ? borderWidthOuter : borderWidthInner, ), left: BorderSide( color: (idLogicalTop != baseId) ? GameColors.pieceBorderColor : GameColors.pieceBorderLightColor, width: (idLogicalTop != baseId) ? borderWidthOuter : borderWidthInner, ), right: BorderSide( color: (idLogicalBottom != baseId) ? GameColors.pieceBorderColor : GameColors.pieceBorderLightColor, width: (idLogicalBottom != baseId) ? borderWidthOuter : borderWidthInner, ), );
```

### Border

```dart
return Border( top: BorderSide( color: (idLogicalTop != baseId) ? GameColors.pieceBorderColor : GameColors.pieceBorderLightColor, width: (idLogicalTop != baseId) ? borderWidthOuter : borderWidthInner, ), bottom: BorderSide( color: (idLogicalBottom != baseId) ? GameColors.pieceBorderColor : GameColors.pieceBorderLightColor, width: (idLogicalBottom != baseId) ? borderWidthOuter : borderWidthInner, ), left: BorderSide( color: (idLogicalLeft != baseId) ? GameColors.pieceBorderColor : GameColors.pieceBorderLightColor, width: (idLogicalLeft != baseId) ? borderWidthOuter : borderWidthInner, ), right: BorderSide( color: (idLogicalRight != baseId) ? GameColors.pieceBorderColor : GameColors.pieceBorderLightColor, width: (idLogicalRight != baseId) ? borderWidthOuter : borderWidthInner, ), );
```

