// Modified: 2025-12-06 16:00 → 251226 (Avec numérotation)
// lib/main.dart
// Version adaptée avec pré-chargement des solutions BigInt + Numérotation

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pentapol/pentoscope/pentoscope_provider.dart';
import 'package:pentapol/pentoscope/pentoscope_generator.dart';
import 'package:pentapol/pentoscope/screens/pentoscope_game_screen.dart';

import 'package:pentapol/screens/home_screen.dart';
import 'package:pentapol/services/pentapol_solutions_loader.dart';
import 'package:pentapol/services/solution_matcher.dart';
import 'package:pentapol/classical/pentomino_game_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✨ PRÉ-CHARGEMENT des solutions en arrière-plan
  debugPrint('🔄 Pré-chargement des solutions pentomino (BigInt)...');

  Future.microtask(() async {
    final startTime = DateTime.now();
    try {
      // 1) Charger et décoder les solutions normalisées depuis le .bin
      final solutionsBigInt = await loadNormalizedSolutionsAsBigInt();

      // 2) Initialiser le matcher global avec ces solutions
      solutionMatcher.initWithBigIntSolutions(solutionsBigInt);

      final duration = DateTime.now().difference(startTime).inMilliseconds;
      final count = solutionMatcher.totalSolutions;
      debugPrint('✅ $count solutions BigInt chargées en ${duration}ms');
    } catch (e, st) {
      debugPrint('❌ Erreur lors du pré-chargement des solutions: $e');
      debugPrint('$st');
    }
  });

  runApp(const ProviderScope(child: PentapolApp()));
}

class PentapolApp extends ConsumerStatefulWidget {
  const PentapolApp({super.key});

  @override
  ConsumerState<PentapolApp> createState() => _PentapolAppState();
}

class _PentapolAppState extends ConsumerState<PentapolApp> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Initialiser un puzzle 5x3 au démarrage
      final notifier = ref.read(pentoscopeProvider.notifier);
      await notifier.startPuzzle(
        PentoscopeSize.size5x5, // 5x5 qui correspond à 5 pièces
        difficulty: PentoscopeDifficulty.random,
        showSolution: false,
      );

      if (mounted) {
        setState(() => _isInitialized = true);
      }
    } catch (e) {
      debugPrint('❌ Erreur lors de l\'initialisation du puzzle: $e');
      // En cas d'erreur, on lance quand même l'app avec HomeScreen
      if (mounted) {
        setState(() => _isInitialized = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pentapol',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: _isInitialized ? const PentoscopeGameScreen() : _buildLoadingScreen(),

      routes: {
        '/game': (context) => const PentominoGameScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }

  Widget _buildLoadingScreen() {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Chargement de Pentoscope...'),
          ],
        ),
      ),
    );
  }
}