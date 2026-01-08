# duel/screens/duel_result_screen.dart

**Module:** duel

## Fonctions

### DuelResultScreen

```dart
const DuelResultScreen({super.key});
```

### build

```dart
Widget build(BuildContext context, WidgetRef ref) {
```

### Scaffold

```dart
return Scaffold( body: Container( decoration: BoxDecoration( gradient: LinearGradient( begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: isDraw ? [Colors.grey.shade300, Colors.grey.shade100] : isWinner ? [Colors.green.shade300, Colors.green.shade50] : [Colors.red.shade300, Colors.red.shade50], ), ), child: SafeArea( child: Padding( padding: const EdgeInsets.all(24.0), child: Column( mainAxisAlignment: MainAxisAlignment.center, children: [ const Spacer(),  // Icône Icon( isDraw ? Icons.handshake : isWinner ? Icons.emoji_events : Icons.sentiment_dissatisfied, size: 100, color: isDraw ? Colors.grey.shade700 : isWinner ? Colors.amber : Colors.red.shade700, ), const SizedBox(height: 24),  // Titre Text( isDraw ? 'Égalité !' : isWinner ? 'Victoire ! 🎉' : 'Défaite...', style: TextStyle( fontSize: 36, fontWeight: FontWeight.bold, color: isDraw ? Colors.grey.shade800 : isWinner ? Colors.green.shade800 : Colors.red.shade800, ), ), const SizedBox(height: 32),  // Scores Container( padding: const EdgeInsets.all(24), decoration: BoxDecoration( color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [ BoxShadow( color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4), ), ], ), child: Column( children: [ // Joueur local _ScoreRow( name: localName, score: localScore, isWinner: isWinner && !isDraw, isLocal: true, ), const Padding( padding: EdgeInsets.symmetric(vertical: 12), child: Divider(), ), // Adversaire _ScoreRow( name: opponentName, score: opponentScore, isWinner: !isWinner && !isDraw, isLocal: false, ), ], ), ), const SizedBox(height: 16),  // Détails Text( 'Pièces totales placées: ${localScore + opponentScore}/12',
```

### Spacer

```dart
const Spacer(),  // Icône Icon( isDraw ? Icons.handshake : isWinner ? Icons.emoji_events : Icons.sentiment_dissatisfied, size: 100, color: isDraw ? Colors.grey.shade700 : isWinner ? Colors.amber : Colors.red.shade700, ), const SizedBox(height: 24),  // Titre Text( isDraw ? 'Égalité !' : isWinner ? 'Victoire ! 🎉' : 'Défaite...', style: TextStyle( fontSize: 36, fontWeight: FontWeight.bold, color: isDraw ? Colors.grey.shade800 : isWinner ? Colors.green.shade800 : Colors.red.shade800, ), ), const SizedBox(height: 32),  // Scores Container( padding: const EdgeInsets.all(24), decoration: BoxDecoration( color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [ BoxShadow( color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4), ), ], ), child: Column( children: [ // Joueur local _ScoreRow( name: localName, score: localScore, isWinner: isWinner && !isDraw, isLocal: true, ), const Padding( padding: EdgeInsets.symmetric(vertical: 12), child: Divider(), ), // Adversaire _ScoreRow( name: opponentName, score: opponentScore, isWinner: !isWinner && !isDraw, isLocal: false, ), ], ), ), const SizedBox(height: 16),  // Détails Text( 'Pièces totales placées: ${localScore + opponentScore}/12',
```

### SizedBox

```dart
const SizedBox(height: 24),  // Titre Text( isDraw ? 'Égalité !' : isWinner ? 'Victoire ! 🎉' : 'Défaite...', style: TextStyle( fontSize: 36, fontWeight: FontWeight.bold, color: isDraw ? Colors.grey.shade800 : isWinner ? Colors.green.shade800 : Colors.red.shade800, ), ), const SizedBox(height: 32),  // Scores Container( padding: const EdgeInsets.all(24), decoration: BoxDecoration( color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [ BoxShadow( color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4), ), ], ), child: Column( children: [ // Joueur local _ScoreRow( name: localName, score: localScore, isWinner: isWinner && !isDraw, isLocal: true, ), const Padding( padding: EdgeInsets.symmetric(vertical: 12), child: Divider(), ), // Adversaire _ScoreRow( name: opponentName, score: opponentScore, isWinner: !isWinner && !isDraw, isLocal: false, ), ], ), ), const SizedBox(height: 16),  // Détails Text( 'Pièces totales placées: ${localScore + opponentScore}/12',
```

### SizedBox

```dart
const SizedBox(height: 32),  // Scores Container( padding: const EdgeInsets.all(24), decoration: BoxDecoration( color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [ BoxShadow( color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4), ), ], ), child: Column( children: [ // Joueur local _ScoreRow( name: localName, score: localScore, isWinner: isWinner && !isDraw, isLocal: true, ), const Padding( padding: EdgeInsets.symmetric(vertical: 12), child: Divider(), ), // Adversaire _ScoreRow( name: opponentName, score: opponentScore, isWinner: !isWinner && !isDraw, isLocal: false, ), ], ), ), const SizedBox(height: 16),  // Détails Text( 'Pièces totales placées: ${localScore + opponentScore}/12',
```

### Padding

```dart
const Padding( padding: EdgeInsets.symmetric(vertical: 12), child: Divider(), ), // Adversaire _ScoreRow( name: opponentName, score: opponentScore, isWinner: !isWinner && !isDraw, isLocal: false, ), ], ), ), const SizedBox(height: 16),  // Détails Text( 'Pièces totales placées: ${localScore + opponentScore}/12',
```

### SizedBox

```dart
const SizedBox(height: 16),  // Détails Text( 'Pièces totales placées: ${localScore + opponentScore}/12',
```

### Spacer

```dart
const Spacer(),  // Boutons SizedBox( width: double.infinity, height: 56, child: ElevatedButton.icon( onPressed: () {
```

### SizedBox

```dart
const SizedBox(height: 12),  // Bouton retour menu principal TextButton( onPressed: () {
```

### SizedBox

```dart
const SizedBox(height: 24), ], ), ), ), ), );
```

### build

```dart
Widget build(BuildContext context) {
```

### Row

```dart
return Row( children: [ // Icône joueur Container( width: 48, height: 48, decoration: BoxDecoration( color: isLocal ? Colors.blue.shade100 : Colors.grey.shade200, shape: BoxShape.circle, ), child: Icon( isLocal ? Icons.person : Icons.person_outline, color: isLocal ? Colors.blue : Colors.grey, ), ), const SizedBox(width: 16),  // Nom Expanded( child: Column( crossAxisAlignment: CrossAxisAlignment.start, children: [ Text( name, style: TextStyle( fontSize: 18, fontWeight: FontWeight.bold, color: isWinner ? Colors.green.shade700 : Colors.black87, ), ), if (isLocal) Text( 'Vous', style: TextStyle( fontSize: 12, color: Colors.grey.shade500, ), ), ], ), ),  // Score Container( padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), decoration: BoxDecoration( color: isWinner ? Colors.green.shade100 : Colors.grey.shade100, borderRadius: BorderRadius.circular(20), ), child: Row( mainAxisSize: MainAxisSize.min, children: [ Text( '$score', style: TextStyle( fontSize: 24, fontWeight: FontWeight.bold, color: isWinner ? Colors.green.shade700 : Colors.grey.shade700, ), ), const SizedBox(width: 4), Text( 'pièces', style: TextStyle( fontSize: 12, color: Colors.grey.shade600, ), ), if (isWinner) ...[ const SizedBox(width: 8), const Icon(Icons.emoji_events, color: Colors.amber, size: 20), ], ], ), ), ], );
```

### SizedBox

```dart
const SizedBox(width: 16),  // Nom Expanded( child: Column( crossAxisAlignment: CrossAxisAlignment.start, children: [ Text( name, style: TextStyle( fontSize: 18, fontWeight: FontWeight.bold, color: isWinner ? Colors.green.shade700 : Colors.black87, ), ), if (isLocal) Text( 'Vous', style: TextStyle( fontSize: 12, color: Colors.grey.shade500, ), ), ], ), ),  // Score Container( padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), decoration: BoxDecoration( color: isWinner ? Colors.green.shade100 : Colors.grey.shade100, borderRadius: BorderRadius.circular(20), ), child: Row( mainAxisSize: MainAxisSize.min, children: [ Text( '$score', style: TextStyle( fontSize: 24, fontWeight: FontWeight.bold, color: isWinner ? Colors.green.shade700 : Colors.grey.shade700, ), ), const SizedBox(width: 4), Text( 'pièces', style: TextStyle( fontSize: 12, color: Colors.grey.shade600, ), ), if (isWinner) ...[ const SizedBox(width: 8), const Icon(Icons.emoji_events, color: Colors.amber, size: 20), ], ], ), ), ], );
```

### SizedBox

```dart
const SizedBox(width: 4), Text( 'pièces', style: TextStyle( fontSize: 12, color: Colors.grey.shade600, ), ), if (isWinner) ...[ const SizedBox(width: 8), const Icon(Icons.emoji_events, color: Colors.amber, size: 20), ], ], ), ), ], );
```

### SizedBox

```dart
const SizedBox(width: 8), const Icon(Icons.emoji_events, color: Colors.amber, size: 20), ], ], ), ), ], );
```

### Icon

```dart
const Icon(Icons.emoji_events, color: Colors.amber, size: 20), ], ], ), ), ], );
```

