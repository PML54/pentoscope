# config/ui_layout_provider.dart

**Module:** config

## Fonctions

### UILayoutState

State pour stocker les paramètres du layout


```dart
const UILayoutState({
```

### UILayoutState

État initial par défaut


```dart
return UILayoutState( screenWidth: 375, screenHeight: 812, boardCols: 6, boardRows: 10, layout: UILayout.defaults, );
```

### copyWith

Copie avec nouvelles valeurs


```dart
UILayoutState copyWith({
```

### UILayoutState

```dart
return UILayoutState( screenWidth: screenWidth ?? this.screenWidth, screenHeight: screenHeight ?? this.screenHeight, boardCols: boardCols ?? this.boardCols, boardRows: boardRows ?? this.boardRows, layout: layout ?? this.layout, );
```

### build

Notifier pour gérer les mises à jour du layout


```dart
UILayoutState build() {
```

### updateScreenSize

Met à jour le layout avec de nouvelles dimensions d'écran


```dart
void updateScreenSize(double width, double height) {
```

### updateBoardSize

Met à jour les dimensions du plateau (ex: Pentoscope avec plateau plus petit)


```dart
void updateBoardSize(int cols, int rows) {
```

### recalculate

Recalcule le layout complet


```dart
void recalculate({
```

### UILayoutNotifier

Provider principal pour le state du layout


```dart
return UILayoutNotifier();
```

### UILayoutInitializer

Provider de commodité pour accéder directement au layout calculé
Provider pour le type d'appareil
Provider pour l'orientation
Provider pour savoir si on est en mode paysage
Provider pour les dimensions du plateau
Provider pour les dimensions du slider
Provider pour les dimensions de la barre d'actions
Provider pour les dimensions typographiques
Widget qui initialise automatiquement le UILayout au démarrage

À placer en haut de l'arbre de widgets d'un écran de jeu :
```dart
@override
Widget build(BuildContext context) {
return UILayoutInitializer(
boardCols: 6,
boardRows: 10,
child: Scaffold(...),
);
}
```


```dart
const UILayoutInitializer({
```

### createState

```dart
ConsumerState<UILayoutInitializer> createState() => _UILayoutInitializerState();
```

### didChangeDependencies

```dart
void didChangeDependencies() {
```

### build

```dart
Widget build(BuildContext context) {
```

### calculateLayout

Extension sur WidgetRef pour un accès simplifié
Accès direct au layout
Accès aux dimensions du plateau
Accès aux dimensions du slider
Accès aux dimensions des actions
Accès aux dimensions texte
Est-on en mode paysage ?
Extension sur BuildContext pour calcul direct des dimensions
Utile quand on veut les dimensions immédiatement sans passer par le provider
Calcule le layout directement depuis le contexte


```dart
UILayout calculateLayout({int boardCols = 6, int boardRows = 10}) {
```

### calculateBoardDimensions

Raccourci pour les dimensions du plateau


```dart
BoardDimensions calculateBoardDimensions({int boardCols = 6, int boardRows = 10}) {
```

### calculateLayout

```dart
return calculateLayout(boardCols: boardCols, boardRows: boardRows).board;
```

### calculateSliderDimensions

Raccourci pour les dimensions du slider


```dart
SliderDimensions calculateSliderDimensions({int boardCols = 6, int boardRows = 10}) {
```

### calculateLayout

```dart
return calculateLayout(boardCols: boardCols, boardRows: boardRows).slider;
```

### calculateActionBarDimensions

Raccourci pour les dimensions de la barre d'actions


```dart
ActionBarDimensions calculateActionBarDimensions({int boardCols = 6, int boardRows = 10}) {
```

### calculateLayout

```dart
return calculateLayout(boardCols: boardCols, boardRows: boardRows).actionBar;
```

