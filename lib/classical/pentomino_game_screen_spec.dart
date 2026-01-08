import 'package:flutter/material.dart';

/// Paramètres UI du PentominoGameScreen
/// Centralise toutes les valeurs "magiques"
abstract class PentominoGameScreenSpec {
  // AppBar
  static const double appBarHeight = 56.0;  // OK
  static const double leadingWidth = 90.0; // OK

  // Action rail / sliders
  static const double actionRailWidth = 44.0; // OK
  static const double sliderPortraitHeight = 170.0; // OK
  static const double sliderLandscapeWidth = 140.0; // OK

  // Animations
  static const Duration animFast = Duration(milliseconds: 150);
  static const Duration animPop = Duration(milliseconds: 200);

  // Décoration
  static const double radiusCard = 15.0; // OK
  static const double shadowBlur = 4.0; //OK
  static const double shadowSpread = 1.0;
  static const Offset shadowOffset = Offset(2, 2);

  // Couleurs (temporaire, passera au Theme plus tard)
  static const Color colorScore = Colors.orange;
  static const Color colorSolutions = Colors.green;
  static const Color colorDanger = Colors.red;
}
