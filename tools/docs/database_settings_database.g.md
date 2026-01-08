# database/settings_database.g.dart

**Module:** database

## Fonctions

### validateIntegrity

```dart
VerificationContext validateIntegrity( Insertable<Setting> instance, {
```

### map

```dart
Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
```

### Setting

```dart
return Setting( key: attachedDatabase.typeMapping.read( DriftSqlType.string, data['${effectivePrefix}key'],
```

### Setting

```dart
const Setting({required this.key, required this.value});
```

### toColumns

```dart
Map<String, Expression> toColumns(bool nullToAbsent) {
```

### toCompanion

```dart
SettingsCompanion toCompanion(bool nullToAbsent) {
```

### SettingsCompanion

```dart
return SettingsCompanion(key: Value(key), value: Value(value));
```

### Setting

```dart
return Setting( key: serializer.fromJson<String>(json['key']), value: serializer.fromJson<String>(json['value']), );
```

### toJson

```dart
Map<String, dynamic> toJson({ValueSerializer? serializer}) {
```

### copyWith

```dart
Setting copyWith({String? key, String? value}) =>
```

### copyWithCompanion

```dart
Setting copyWithCompanion(SettingsCompanion data) {
```

### Setting

```dart
return Setting( key: data.key.present ? data.key.value : this.key, value: data.value.present ? data.value.value : this.value, );
```

### toString

```dart
String toString() {
```

### SettingsCompanion

```dart
const SettingsCompanion({
```

### custom

```dart
static Insertable<Setting> custom({
```

### RawValuesInsertable

```dart
return RawValuesInsertable({
```

### copyWith

```dart
SettingsCompanion copyWith({
```

### SettingsCompanion

```dart
return SettingsCompanion( key: key ?? this.key, value: value ?? this.value, rowid: rowid ?? this.rowid, );
```

### toColumns

```dart
Map<String, Expression> toColumns(bool nullToAbsent) {
```

### toString

```dart
String toString() {
```

### VerificationMeta

```dart
const VerificationMeta('solutionsViewCount');
```

### validateIntegrity

```dart
VerificationContext validateIntegrity( Insertable<GameSession> instance, {
```

### map

```dart
GameSession map(Map<String, dynamic> data, {String? tablePrefix}) {
```

### GameSession

```dart
return GameSession( id: attachedDatabase.typeMapping.read( DriftSqlType.int, data['${effectivePrefix}id'],
```

### GameSession

```dart
const GameSession({
```

### toColumns

```dart
Map<String, Expression> toColumns(bool nullToAbsent) {
```

### toCompanion

```dart
GameSessionsCompanion toCompanion(bool nullToAbsent) {
```

### GameSessionsCompanion

```dart
return GameSessionsCompanion( id: Value(id), solutionNumber: Value(solutionNumber), elapsedSeconds: Value(elapsedSeconds), score: score == null && nullToAbsent ? const Value.absent() : Value(score), piecesPlaced: piecesPlaced == null && nullToAbsent ? const Value.absent() : Value(piecesPlaced), numUndos: numUndos == null && nullToAbsent ? const Value.absent() : Value(numUndos), isometriesCount: isometriesCount == null && nullToAbsent ? const Value.absent() : Value(isometriesCount), solutionsViewCount: solutionsViewCount == null && nullToAbsent ? const Value.absent() : Value(solutionsViewCount), completedAt: Value(completedAt), playerNotes: playerNotes == null && nullToAbsent ? const Value.absent() : Value(playerNotes), );
```

### GameSession

```dart
return GameSession( id: serializer.fromJson<int>(json['id']), solutionNumber: serializer.fromJson<int>(json['solutionNumber']), elapsedSeconds: serializer.fromJson<int>(json['elapsedSeconds']), score: serializer.fromJson<int?>(json['score']), piecesPlaced: serializer.fromJson<int?>(json['piecesPlaced']), numUndos: serializer.fromJson<int?>(json['numUndos']), isometriesCount: serializer.fromJson<int?>(json['isometriesCount']), solutionsViewCount: serializer.fromJson<int?>(json['solutionsViewCount']), completedAt: serializer.fromJson<DateTime>(json['completedAt']), playerNotes: serializer.fromJson<String?>(json['playerNotes']), );
```

### toJson

```dart
Map<String, dynamic> toJson({ValueSerializer? serializer}) {
```

### copyWith

```dart
GameSession copyWith({
```

### copyWithCompanion

```dart
GameSession copyWithCompanion(GameSessionsCompanion data) {
```

### GameSession

```dart
return GameSession( id: data.id.present ? data.id.value : this.id, solutionNumber: data.solutionNumber.present ? data.solutionNumber.value : this.solutionNumber, elapsedSeconds: data.elapsedSeconds.present ? data.elapsedSeconds.value : this.elapsedSeconds, score: data.score.present ? data.score.value : this.score, piecesPlaced: data.piecesPlaced.present ? data.piecesPlaced.value : this.piecesPlaced, numUndos: data.numUndos.present ? data.numUndos.value : this.numUndos, isometriesCount: data.isometriesCount.present ? data.isometriesCount.value : this.isometriesCount, solutionsViewCount: data.solutionsViewCount.present ? data.solutionsViewCount.value : this.solutionsViewCount, completedAt: data.completedAt.present ? data.completedAt.value : this.completedAt, playerNotes: data.playerNotes.present ? data.playerNotes.value : this.playerNotes, );
```

### toString

```dart
String toString() {
```

### GameSessionsCompanion

```dart
const GameSessionsCompanion({
```

### custom

```dart
static Insertable<GameSession> custom({
```

### RawValuesInsertable

```dart
return RawValuesInsertable({
```

### copyWith

```dart
GameSessionsCompanion copyWith({
```

### GameSessionsCompanion

```dart
return GameSessionsCompanion( id: id ?? this.id, solutionNumber: solutionNumber ?? this.solutionNumber, elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds, score: score ?? this.score, piecesPlaced: piecesPlaced ?? this.piecesPlaced, numUndos: numUndos ?? this.numUndos, isometriesCount: isometriesCount ?? this.isometriesCount, solutionsViewCount: solutionsViewCount ?? this.solutionsViewCount, completedAt: completedAt ?? this.completedAt, playerNotes: playerNotes ?? this.playerNotes, );
```

### toColumns

```dart
Map<String, Expression> toColumns(bool nullToAbsent) {
```

### toString

```dart
String toString() {
```

### validateIntegrity

```dart
VerificationContext validateIntegrity( Insertable<SolutionStat> instance, {
```

### map

```dart
SolutionStat map(Map<String, dynamic> data, {String? tablePrefix}) {
```

### SolutionStat

```dart
return SolutionStat( id: attachedDatabase.typeMapping.read( DriftSqlType.int, data['${effectivePrefix}id'],
```

### SolutionStat

```dart
const SolutionStat({
```

### toColumns

```dart
Map<String, Expression> toColumns(bool nullToAbsent) {
```

### toCompanion

```dart
SolutionStatsCompanion toCompanion(bool nullToAbsent) {
```

### SolutionStatsCompanion

```dart
return SolutionStatsCompanion( id: Value(id), solutionNumber: Value(solutionNumber), timesPlayed: Value(timesPlayed), bestTime: Value(bestTime), averageTime: averageTime == null && nullToAbsent ? const Value.absent() : Value(averageTime), bestScore: bestScore == null && nullToAbsent ? const Value.absent() : Value(bestScore), firstPlayed: firstPlayed == null && nullToAbsent ? const Value.absent() : Value(firstPlayed), lastPlayed: lastPlayed == null && nullToAbsent ? const Value.absent() : Value(lastPlayed), );
```

### SolutionStat

```dart
return SolutionStat( id: serializer.fromJson<int>(json['id']), solutionNumber: serializer.fromJson<int>(json['solutionNumber']), timesPlayed: serializer.fromJson<int>(json['timesPlayed']), bestTime: serializer.fromJson<int>(json['bestTime']), averageTime: serializer.fromJson<int?>(json['averageTime']), bestScore: serializer.fromJson<int?>(json['bestScore']), firstPlayed: serializer.fromJson<DateTime?>(json['firstPlayed']), lastPlayed: serializer.fromJson<DateTime?>(json['lastPlayed']), );
```

### toJson

```dart
Map<String, dynamic> toJson({ValueSerializer? serializer}) {
```

### copyWith

```dart
SolutionStat copyWith({
```

### copyWithCompanion

```dart
SolutionStat copyWithCompanion(SolutionStatsCompanion data) {
```

### SolutionStat

```dart
return SolutionStat( id: data.id.present ? data.id.value : this.id, solutionNumber: data.solutionNumber.present ? data.solutionNumber.value : this.solutionNumber, timesPlayed: data.timesPlayed.present ? data.timesPlayed.value : this.timesPlayed, bestTime: data.bestTime.present ? data.bestTime.value : this.bestTime, averageTime: data.averageTime.present ? data.averageTime.value : this.averageTime, bestScore: data.bestScore.present ? data.bestScore.value : this.bestScore, firstPlayed: data.firstPlayed.present ? data.firstPlayed.value : this.firstPlayed, lastPlayed: data.lastPlayed.present ? data.lastPlayed.value : this.lastPlayed, );
```

### toString

```dart
String toString() {
```

### SolutionStatsCompanion

```dart
const SolutionStatsCompanion({
```

### custom

```dart
static Insertable<SolutionStat> custom({
```

### RawValuesInsertable

```dart
return RawValuesInsertable({
```

### copyWith

```dart
SolutionStatsCompanion copyWith({
```

### SolutionStatsCompanion

```dart
return SolutionStatsCompanion( id: id ?? this.id, solutionNumber: solutionNumber ?? this.solutionNumber, timesPlayed: timesPlayed ?? this.timesPlayed, bestTime: bestTime ?? this.bestTime, averageTime: averageTime ?? this.averageTime, bestScore: bestScore ?? this.bestScore, firstPlayed: firstPlayed ?? this.firstPlayed, lastPlayed: lastPlayed ?? this.lastPlayed, );
```

### toColumns

```dart
Map<String, Expression> toColumns(bool nullToAbsent) {
```

### toString

```dart
String toString() {
```

### DriftDatabaseOptions

```dart
const DriftDatabaseOptions(storeDateTimeAsText: true);
```

### Function

```dart
SettingsCompanion Function({
```

### Function

```dart
SettingsCompanion Function({
```

### Function

```dart
PrefetchHooks Function() > {
```

### Function

```dart
PrefetchHooks Function() >;
```

### Function

```dart
GameSessionsCompanion Function({
```

### Function

```dart
GameSessionsCompanion Function({
```

### Function

```dart
PrefetchHooks Function() > {
```

### Function

```dart
PrefetchHooks Function() >;
```

### Function

```dart
SolutionStatsCompanion Function({
```

### Function

```dart
SolutionStatsCompanion Function({
```

### Function

```dart
PrefetchHooks Function() > {
```

### Function

```dart
PrefetchHooks Function() >;
```

