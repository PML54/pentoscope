# screens/solutions_browser_screen.dart

**Module:** screens

## Fonctions

### SolutionsBrowserScreen

Liste de solutions à afficher (BigInt).
Si null → on affiche toutes les solutions de solutionMatcher.
Titre personnalisé (affiché en petit au-dessus des flèches si fourni).
Constructeur standard : affiche toutes les solutions.


```dart
const SolutionsBrowserScreen({super.key})
```

### createState

Constructeur pour afficher une liste donnée de solutions.


```dart
ConsumerState<SolutionsBrowserScreen> createState() => _SolutionsBrowserScreenState();
```

### initState

```dart
void initState() {
```

### build

```dart
Widget build(BuildContext context) {
```

### Scaffold

```dart
return Scaffold( appBar: AppBar( title: const Text('Solutions'), backgroundColor: Colors.blue[700], ), body: const Center( child: Text( 'Aucune solution chargée.\n' 'Vérifie que SolutionMatcher est bien initialisé au démarrage.', textAlign: TextAlign.center, ), ), );
```

### Scaffold

```dart
return Scaffold( appBar: AppBar( backgroundColor: Colors.blue[700], iconTheme: IconThemeData(color: Colors.red.shade300), title: Column( mainAxisSize: MainAxisSize.min, children: [ if (widget.title != null) Text( widget.title!, style: TextStyle(fontSize: 12, color: Colors.red.shade100), ), Row( mainAxisSize: MainAxisSize.min, children: [ IconButton( icon: Icon(Icons.arrow_back, color: Colors.red.shade300), tooltip: 'Précédente', onPressed: _previousSolution, ), const SizedBox(width: 8), Text( '${_currentIndex + 1} / ${_allSolutions.length}',
```

### SizedBox

```dart
const SizedBox(width: 8), Text( '${_currentIndex + 1} / ${_allSolutions.length}',
```

### SizedBox

```dart
const SizedBox(width: 8), IconButton( icon: Icon(Icons.arrow_forward, color: Colors.red.shade300), tooltip: 'Suivante', onPressed: _nextSolution, ), ], ), ], ), centerTitle: true, ), body: Center( child: AspectRatio( aspectRatio: aspectRatio, child: Container( padding: const EdgeInsets.all(16), child: _buildGrid(grid, visualCols, visualRows, isLandscape), ), ), ), );
```

### Container

```dart
return Container( decoration: BoxDecoration( color: backgroundColor, border: border, ), child: Center( child: Text( pieceId.toString(), style: TextStyle( fontSize: 16, fontWeight: FontWeight.bold, color: backgroundColor.computeLuminance() > 0.5 ? Colors.red.shade900 : Colors.red.shade100, ), ), ), );
```

### Container

Slider vertical pour le mode paysage


```dart
return Container( width: 80, decoration: BoxDecoration( color: Colors.grey.shade100, border: Border( left: BorderSide(color: Colors.grey.shade300, width: 1), ), ), child: Column( mainAxisAlignment: MainAxisAlignment.center, children: [ // Bouton retour Material( color: Colors.transparent, child: InkWell( onTap: () => Navigator.of(context).pop(), child: Container( padding: const EdgeInsets.all(12), child: Icon(Icons.close, color: Colors.grey.shade700), ), ), ), const SizedBox(height: 20), // Bouton précédent Material( color: Colors.transparent, child: InkWell( onTap: _previousSolution, child: Container( padding: const EdgeInsets.all(12), child: Icon(Icons.arrow_upward, color: Colors.blue.shade700, size: 32), ), ), ), const SizedBox(height: 12), // Compteur Text( '${_currentIndex + 1}',
```

### SizedBox

```dart
const SizedBox(height: 20), // Bouton précédent Material( color: Colors.transparent, child: InkWell( onTap: _previousSolution, child: Container( padding: const EdgeInsets.all(12), child: Icon(Icons.arrow_upward, color: Colors.blue.shade700, size: 32), ), ), ), const SizedBox(height: 12), // Compteur Text( '${_currentIndex + 1}',
```

### SizedBox

```dart
const SizedBox(height: 12), // Compteur Text( '${_currentIndex + 1}',
```

### Divider

```dart
const Divider(height: 8), Text( '${_allSolutions.length}',
```

### SizedBox

```dart
const SizedBox(height: 12), // Bouton suivant Material( color: Colors.transparent, child: InkWell( onTap: _nextSolution, child: Container( padding: const EdgeInsets.all(12), child: Icon(Icons.arrow_downward, color: Colors.blue.shade700, size: 32), ), ), ), if (widget.title != null) ...[ const SizedBox(height: 20), Padding( padding: const EdgeInsets.symmetric(horizontal: 8), child: Text( widget.title!, style: TextStyle( fontSize: 10, color: Colors.grey.shade600, ), textAlign: TextAlign.center, maxLines: 3, overflow: TextOverflow.ellipsis, ), ), ], ], ), );
```

### SizedBox

```dart
const SizedBox(height: 20), Padding( padding: const EdgeInsets.symmetric(horizontal: 8), child: Text( widget.title!, style: TextStyle( fontSize: 10, color: Colors.grey.shade600, ), textAlign: TextAlign.center, maxLines: 3, overflow: TextOverflow.ellipsis, ), ), ], ], ), );
```

### neighborId

Decode un BigInt (360 bits) en 60 ids de pièces (1..12).
On suppose que le BigInt a été construit avec :
acc = (acc << 6) | code;
dans l'ordre des 60 cases.
Couleur d'une pièce selon les paramètres de l'utilisateur
Construit un contour de pièce : trait épais aux frontières entre pièces.
En paysage, les bordures sont adaptées à la rotation visuelle.


```dart
int neighborId(int nx, int ny) {
```

### Border

```dart
return Border( top: BorderSide( color: (idLogicalRight != id) ? Colors.black : Colors.grey.shade400, width: (idLogicalRight != id) ? borderWidthOuter : borderWidthInner, ), bottom: BorderSide( color: (idLogicalLeft != id) ? Colors.black : Colors.grey.shade400, width: (idLogicalLeft != id) ? borderWidthOuter : borderWidthInner, ), left: BorderSide( color: (idLogicalTop != id) ? Colors.black : Colors.grey.shade400, width: (idLogicalTop != id) ? borderWidthOuter : borderWidthInner, ), right: BorderSide( color: (idLogicalBottom != id) ? Colors.black : Colors.grey.shade400, width: (idLogicalBottom != id) ? borderWidthOuter : borderWidthInner, ), );
```

### Border

```dart
return Border( top: BorderSide( color: (idLogicalTop != id) ? Colors.black : Colors.grey.shade400, width: (idLogicalTop != id) ? borderWidthOuter : borderWidthInner, ), bottom: BorderSide( color: (idLogicalBottom != id) ? Colors.black : Colors.grey.shade400, width: (idLogicalBottom != id) ? borderWidthOuter : borderWidthInner, ), left: BorderSide( color: (idLogicalLeft != id) ? Colors.black : Colors.grey.shade400, width: (idLogicalLeft != id) ? borderWidthOuter : borderWidthInner, ), right: BorderSide( color: (idLogicalRight != id) ? Colors.black : Colors.grey.shade400, width: (idLogicalRight != id) ? borderWidthOuter : borderWidthInner, ), );
```

