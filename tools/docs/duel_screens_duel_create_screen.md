# duel/screens/duel_create_screen.dart

**Module:** duel

## Fonctions

### DuelCreateScreen

```dart
const DuelCreateScreen({super.key});
```

### createState

```dart
ConsumerState<DuelCreateScreen> createState() => _DuelCreateScreenState();
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

### Scaffold

```dart
return Scaffold( appBar: AppBar( title: const Text('Créer une partie'), backgroundColor: Colors.blue, foregroundColor: Colors.white, ), body: Padding( padding: const EdgeInsets.all(24.0), child: Form( key: _formKey, child: Column( mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.stretch, children: [ const Icon(Icons.person_add, size: 80, color: Colors.blue), const SizedBox(height: 32),  const Text( 'Entrez votre pseudo', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center, ), const SizedBox(height: 8),  if (savedName != null && savedName.isNotEmpty) Text( 'Dernier pseudo utilisé', style: TextStyle(fontSize: 14, color: Colors.grey.shade600), textAlign: TextAlign.center, ), const SizedBox(height: 24),  TextFormField( controller: _nameController, decoration: InputDecoration( labelText: 'Pseudo', hintText: 'Ex: Max', prefixIcon: const Icon(Icons.person), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.grey.shade50, ), textCapitalization: TextCapitalization.words, maxLength: 20, validator: (value) {
```

### Icon

```dart
const Icon(Icons.person_add, size: 80, color: Colors.blue), const SizedBox(height: 32),  const Text( 'Entrez votre pseudo', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center, ), const SizedBox(height: 8),  if (savedName != null && savedName.isNotEmpty) Text( 'Dernier pseudo utilisé', style: TextStyle(fontSize: 14, color: Colors.grey.shade600), textAlign: TextAlign.center, ), const SizedBox(height: 24),  TextFormField( controller: _nameController, decoration: InputDecoration( labelText: 'Pseudo', hintText: 'Ex: Max', prefixIcon: const Icon(Icons.person), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.grey.shade50, ), textCapitalization: TextCapitalization.words, maxLength: 20, validator: (value) {
```

### SizedBox

```dart
const SizedBox(height: 32),  const Text( 'Entrez votre pseudo', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center, ), const SizedBox(height: 8),  if (savedName != null && savedName.isNotEmpty) Text( 'Dernier pseudo utilisé', style: TextStyle(fontSize: 14, color: Colors.grey.shade600), textAlign: TextAlign.center, ), const SizedBox(height: 24),  TextFormField( controller: _nameController, decoration: InputDecoration( labelText: 'Pseudo', hintText: 'Ex: Max', prefixIcon: const Icon(Icons.person), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.grey.shade50, ), textCapitalization: TextCapitalization.words, maxLength: 20, validator: (value) {
```

### Text

```dart
const Text( 'Entrez votre pseudo', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center, ), const SizedBox(height: 8),  if (savedName != null && savedName.isNotEmpty) Text( 'Dernier pseudo utilisé', style: TextStyle(fontSize: 14, color: Colors.grey.shade600), textAlign: TextAlign.center, ), const SizedBox(height: 24),  TextFormField( controller: _nameController, decoration: InputDecoration( labelText: 'Pseudo', hintText: 'Ex: Max', prefixIcon: const Icon(Icons.person), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.grey.shade50, ), textCapitalization: TextCapitalization.words, maxLength: 20, validator: (value) {
```

### SizedBox

```dart
const SizedBox(height: 8),  if (savedName != null && savedName.isNotEmpty) Text( 'Dernier pseudo utilisé', style: TextStyle(fontSize: 14, color: Colors.grey.shade600), textAlign: TextAlign.center, ), const SizedBox(height: 24),  TextFormField( controller: _nameController, decoration: InputDecoration( labelText: 'Pseudo', hintText: 'Ex: Max', prefixIcon: const Icon(Icons.person), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.grey.shade50, ), textCapitalization: TextCapitalization.words, maxLength: 20, validator: (value) {
```

### SizedBox

```dart
const SizedBox(height: 24),  TextFormField( controller: _nameController, decoration: InputDecoration( labelText: 'Pseudo', hintText: 'Ex: Max', prefixIcon: const Icon(Icons.person), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.grey.shade50, ), textCapitalization: TextCapitalization.words, maxLength: 20, validator: (value) {
```

### SizedBox

```dart
const SizedBox(height: 24),  ElevatedButton( onPressed: _isLoading ? null : _createRoom, style: ElevatedButton.styleFrom( backgroundColor: Colors.blue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), ), child: _isLoading ? const SizedBox( height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white), ) : const Text('Créer la partie', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), ), ], ), ), ), );
```

