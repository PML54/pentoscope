# duel/screens/duel_join_screen.dart

**Module:** duel

## Fonctions

### DuelJoinScreen

```dart
const DuelJoinScreen({super.key});
```

### createState

```dart
ConsumerState<DuelJoinScreen> createState() => _DuelJoinScreenState();
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
return Scaffold( appBar: AppBar( title: const Text('Rejoindre une partie'), backgroundColor: Colors.green, foregroundColor: Colors.white, ), body: Padding( padding: const EdgeInsets.all(24.0), child: Form( key: _formKey, child: Column( mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.stretch, children: [ const Icon(Icons.group_add, size: 80, color: Colors.green), const SizedBox(height: 32),  const Text( 'Rejoindre une partie', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center, ), const SizedBox(height: 24),  // Code (4 caractères) TextFormField( controller: _codeController, decoration: InputDecoration( labelText: 'Code de la partie', hintText: 'AB12', prefixIcon: const Icon(Icons.vpn_key), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.grey.shade50, counterText: '', ), textCapitalization: TextCapitalization.characters, maxLength: 4, inputFormatters: [ FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')), _UpperCaseFormatter(), ], style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 12), textAlign: TextAlign.center, validator: (value) {
```

### Icon

```dart
const Icon(Icons.group_add, size: 80, color: Colors.green), const SizedBox(height: 32),  const Text( 'Rejoindre une partie', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center, ), const SizedBox(height: 24),  // Code (4 caractères) TextFormField( controller: _codeController, decoration: InputDecoration( labelText: 'Code de la partie', hintText: 'AB12', prefixIcon: const Icon(Icons.vpn_key), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.grey.shade50, counterText: '', ), textCapitalization: TextCapitalization.characters, maxLength: 4, inputFormatters: [ FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')), _UpperCaseFormatter(), ], style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 12), textAlign: TextAlign.center, validator: (value) {
```

### SizedBox

```dart
const SizedBox(height: 32),  const Text( 'Rejoindre une partie', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center, ), const SizedBox(height: 24),  // Code (4 caractères) TextFormField( controller: _codeController, decoration: InputDecoration( labelText: 'Code de la partie', hintText: 'AB12', prefixIcon: const Icon(Icons.vpn_key), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.grey.shade50, counterText: '', ), textCapitalization: TextCapitalization.characters, maxLength: 4, inputFormatters: [ FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')), _UpperCaseFormatter(), ], style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 12), textAlign: TextAlign.center, validator: (value) {
```

### Text

```dart
const Text( 'Rejoindre une partie', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center, ), const SizedBox(height: 24),  // Code (4 caractères) TextFormField( controller: _codeController, decoration: InputDecoration( labelText: 'Code de la partie', hintText: 'AB12', prefixIcon: const Icon(Icons.vpn_key), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.grey.shade50, counterText: '', ), textCapitalization: TextCapitalization.characters, maxLength: 4, inputFormatters: [ FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')), _UpperCaseFormatter(), ], style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 12), textAlign: TextAlign.center, validator: (value) {
```

### SizedBox

```dart
const SizedBox(height: 24),  // Code (4 caractères) TextFormField( controller: _codeController, decoration: InputDecoration( labelText: 'Code de la partie', hintText: 'AB12', prefixIcon: const Icon(Icons.vpn_key), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.grey.shade50, counterText: '', ), textCapitalization: TextCapitalization.characters, maxLength: 4, inputFormatters: [ FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')), _UpperCaseFormatter(), ], style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 12), textAlign: TextAlign.center, validator: (value) {
```

### SizedBox

```dart
const SizedBox(height: 16),  // Pseudo TextFormField( controller: _nameController, decoration: InputDecoration( labelText: 'Votre pseudo', hintText: 'Ex: Max', prefixIcon: const Icon(Icons.person), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.grey.shade50, ), textCapitalization: TextCapitalization.words, maxLength: 20, validator: (value) {
```

### SizedBox

```dart
const SizedBox(height: 24),  ElevatedButton( onPressed: _isLoading ? null : _joinRoom, style: ElevatedButton.styleFrom( backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), ), child: _isLoading ? const SizedBox( height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white), ) : const Text('Rejoindre', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), ), ], ), ), ), );
```

### formatEditUpdate

```dart
TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
```

### TextEditingValue

```dart
return TextEditingValue( text: newValue.text.toUpperCase(), selection: newValue.selection, );
```

