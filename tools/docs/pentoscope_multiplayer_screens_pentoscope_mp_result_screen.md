# pentoscope_multiplayer/screens/pentoscope_mp_result_screen.dart

**Module:** pentoscope_multiplayer

## Fonctions

### PentoscopeMPResultScreen

```dart
const PentoscopeMPResultScreen({super.key});
```

### build

```dart
Widget build(BuildContext context, WidgetRef ref) {
```

### Scaffold

```dart
return Scaffold( backgroundColor: Colors.grey[100], body: SafeArea( child: Column( children: [ const SizedBox(height: 24),  // Titre const Text( '🏆 Résultats', style: TextStyle( fontSize: 32, fontWeight: FontWeight.bold, ), ),  const SizedBox(height: 8),  // Mon rang if (me != null) _buildMyRankCard(me, rankings.length),  const SizedBox(height: 24),  // Podium (top 3) if (rankings.length >= 1) _buildPodium(rankings.take(3).toList()),  const SizedBox(height: 24),  // Liste complète Expanded( child: _buildRankingsList(rankings, me?.id), ),  // Boutons Padding( padding: const EdgeInsets.all(24), child: Row( children: [ Expanded( child: OutlinedButton.icon( onPressed: () async {
```

### SizedBox

```dart
const SizedBox(height: 24),  // Titre const Text( '🏆 Résultats', style: TextStyle( fontSize: 32, fontWeight: FontWeight.bold, ), ),  const SizedBox(height: 8),  // Mon rang if (me != null) _buildMyRankCard(me, rankings.length),  const SizedBox(height: 24),  // Podium (top 3) if (rankings.length >= 1) _buildPodium(rankings.take(3).toList()),  const SizedBox(height: 24),  // Liste complète Expanded( child: _buildRankingsList(rankings, me?.id), ),  // Boutons Padding( padding: const EdgeInsets.all(24), child: Row( children: [ Expanded( child: OutlinedButton.icon( onPressed: () async {
```

### Text

```dart
const Text( '🏆 Résultats', style: TextStyle( fontSize: 32, fontWeight: FontWeight.bold, ), ),  const SizedBox(height: 8),  // Mon rang if (me != null) _buildMyRankCard(me, rankings.length),  const SizedBox(height: 24),  // Podium (top 3) if (rankings.length >= 1) _buildPodium(rankings.take(3).toList()),  const SizedBox(height: 24),  // Liste complète Expanded( child: _buildRankingsList(rankings, me?.id), ),  // Boutons Padding( padding: const EdgeInsets.all(24), child: Row( children: [ Expanded( child: OutlinedButton.icon( onPressed: () async {
```

### SizedBox

```dart
const SizedBox(height: 8),  // Mon rang if (me != null) _buildMyRankCard(me, rankings.length),  const SizedBox(height: 24),  // Podium (top 3) if (rankings.length >= 1) _buildPodium(rankings.take(3).toList()),  const SizedBox(height: 24),  // Liste complète Expanded( child: _buildRankingsList(rankings, me?.id), ),  // Boutons Padding( padding: const EdgeInsets.all(24), child: Row( children: [ Expanded( child: OutlinedButton.icon( onPressed: () async {
```

### SizedBox

```dart
const SizedBox(height: 24),  // Podium (top 3) if (rankings.length >= 1) _buildPodium(rankings.take(3).toList()),  const SizedBox(height: 24),  // Liste complète Expanded( child: _buildRankingsList(rankings, me?.id), ),  // Boutons Padding( padding: const EdgeInsets.all(24), child: Row( children: [ Expanded( child: OutlinedButton.icon( onPressed: () async {
```

### SizedBox

```dart
const SizedBox(height: 24),  // Liste complète Expanded( child: _buildRankingsList(rankings, me?.id), ),  // Boutons Padding( padding: const EdgeInsets.all(24), child: Row( children: [ Expanded( child: OutlinedButton.icon( onPressed: () async {
```

### SizedBox

```dart
const SizedBox(width: 16), Expanded( child: ElevatedButton.icon( onPressed: () async {
```

### Container

```dart
return Container( margin: const EdgeInsets.symmetric(horizontal: 24), padding: const EdgeInsets.all(16), decoration: BoxDecoration( gradient: LinearGradient( colors: isWinner ? [Colors.amber.shade400, Colors.orange.shade400] : [Colors.blue.shade400, Colors.indigo.shade400], begin: Alignment.topLeft, end: Alignment.bottomRight, ), borderRadius: BorderRadius.circular(16), boxShadow: [ BoxShadow( color: (isWinner ? Colors.amber : Colors.blue).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6), ), ], ), child: Row( children: [ // Rang Container( width: 60, height: 60, decoration: BoxDecoration( color: Colors.white.withOpacity(0.2), shape: BoxShape.circle, ), child: Center( child: Text( isWinner ? '🥇' : '#${me.rank ?? "?"}',
```

### SizedBox

```dart
const SizedBox(width: 16),  // Infos Expanded( child: Column( crossAxisAlignment: CrossAxisAlignment.start, children: [ Text( isWinner ? 'Victoire ! 🎉' : 'Bien joué !', style: const TextStyle( fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white, ), ), const SizedBox(height: 4), Text( me.isCompleted ? 'Terminé en ${_formatTime(me.completionTime ?? 0)}'
```

### SizedBox

```dart
const SizedBox(height: 4), Text( me.isCompleted ? 'Terminé en ${_formatTime(me.completionTime ?? 0)}'
```

### Padding

```dart
return Padding( padding: const EdgeInsets.symmetric(horizontal: 24), child: Row( mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [ // 2ème place if (orderedPlayers[0] != null) _buildPodiumPlace(orderedPlayers[0]!, 2, 80) else const SizedBox(width: 80),  const SizedBox(width: 8),  // 1ère place if (orderedPlayers[1] != null) _buildPodiumPlace(orderedPlayers[1]!, 1, 100) else const SizedBox(width: 100),  const SizedBox(width: 8),  // 3ème place if (orderedPlayers[2] != null) _buildPodiumPlace(orderedPlayers[2]!, 3, 60) else const SizedBox(width: 80), ], ), );
```

### SizedBox

```dart
const SizedBox(width: 80),  const SizedBox(width: 8),  // 1ère place if (orderedPlayers[1] != null) _buildPodiumPlace(orderedPlayers[1]!, 1, 100) else const SizedBox(width: 100),  const SizedBox(width: 8),  // 3ème place if (orderedPlayers[2] != null) _buildPodiumPlace(orderedPlayers[2]!, 3, 60) else const SizedBox(width: 80), ], ), );
```

### SizedBox

```dart
const SizedBox(width: 8),  // 1ère place if (orderedPlayers[1] != null) _buildPodiumPlace(orderedPlayers[1]!, 1, 100) else const SizedBox(width: 100),  const SizedBox(width: 8),  // 3ème place if (orderedPlayers[2] != null) _buildPodiumPlace(orderedPlayers[2]!, 3, 60) else const SizedBox(width: 80), ], ), );
```

### SizedBox

```dart
const SizedBox(width: 100),  const SizedBox(width: 8),  // 3ème place if (orderedPlayers[2] != null) _buildPodiumPlace(orderedPlayers[2]!, 3, 60) else const SizedBox(width: 80), ], ), );
```

### SizedBox

```dart
const SizedBox(width: 8),  // 3ème place if (orderedPlayers[2] != null) _buildPodiumPlace(orderedPlayers[2]!, 3, 60) else const SizedBox(width: 80), ], ), );
```

### SizedBox

```dart
const SizedBox(width: 80), ], ), );
```

### Column

```dart
return Column( mainAxisSize: MainAxisSize.min, children: [ // Avatar CircleAvatar( radius: rank == 1 ? 30 : 24, backgroundColor: colors[rank], child: Text( player.name.isNotEmpty ? player.name[0].toUpperCase() : '?', style: TextStyle( fontSize: rank == 1 ? 24 : 18, fontWeight: FontWeight.bold, color: Colors.white, ), ), ), const SizedBox(height: 4),  // Nom Text( player.name.length > 8 ? '${player.name.substring(0, 8)}...' : player.name,
```

### SizedBox

```dart
const SizedBox(height: 4),  // Nom Text( player.name.length > 8 ? '${player.name.substring(0, 8)}...' : player.name,
```

### SizedBox

```dart
const SizedBox(height: 4),  // Socle Container( width: rank == 1 ? 80 : 70, height: height, decoration: BoxDecoration( color: colors[rank], borderRadius: const BorderRadius.only( topLeft: Radius.circular(8), topRight: Radius.circular(8), ), ), child: Center( child: Text( emojis[rank] ?? '$rank', style: const TextStyle(fontSize: 28), ), ), ), ], );
```

### Container

```dart
return Container( margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12), decoration: BoxDecoration( color: isMe ? Colors.blue.shade50 : Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all( color: isMe ? Colors.blue.shade200 : Colors.grey.shade200, ), ), child: Row( children: [ // Rang Container( width: 36, height: 36, decoration: BoxDecoration( color: _getRankColor(player.rank ?? index + 1), shape: BoxShape.circle, ), child: Center( child: Text( '${player.rank ?? index + 1}',
```

### SizedBox

```dart
const SizedBox(width: 12),  // Nom Expanded( child: Column( crossAxisAlignment: CrossAxisAlignment.start, children: [ Row( children: [ Text( player.name, style: TextStyle( fontWeight: isMe ? FontWeight.bold : FontWeight.normal, ), ), if (isMe) Container( margin: const EdgeInsets.only(left: 8), padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration( color: Colors.blue, borderRadius: BorderRadius.circular(8), ), child: const Text( 'Moi', style: TextStyle(color: Colors.white, fontSize: 10), ), ), ], ), Text( player.isCompleted ? 'Terminé' : '${player.placedCount} pièces',
```

### Text

```dart
const Text( 'DNF', style: TextStyle(color: Colors.grey), ), ], ), );
```

