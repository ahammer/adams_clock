import 'dart:math';

import 'package:flutter/material.dart';

///
/// Configuration of the Space Clock
///

// We make these getters so we can runtime chang the themes
SpaceConfig get lightSpaceConfig => _LightSpaceConfig();
SpaceConfig get darkSpaceConfig => _DarkSpaceConfig();

/// Overall Config object
///
/// Sun Options
/// - sunSize = Size of the Sun as a multiplier of the screen size
/// - sunBaseSize = The "disc" that serves as the "surface" for the sun.
///   Small values give more "corona"
/// - sunOrbitMultiplierX - 0 = Center of Screen, 1 = Left/Right align with center of sun
/// - sunOrbitMultiplierY - 0 = Center of Screen, 1 = Top/Bottom algin with center of sun
/// - sunSpeed = Animation multiplier for the sun. 
///   Higher values make the sun more active
/// - sunLayers = Images that are drawn at the sun's location at various rotations/blend modes
/// - sunGradient = The sunBase is painted with this gradient. 
///   It's set to give a soft warm glow around the edges
///
/// Earth Options
/// - earthSize = Size of the earth as a multiplier of screen size
/// - earthOrbitMultiplierX = Same as Sun
/// - earthOrbitMultiplierY = Same as Sun
/// - earthRotationSpeed = Speed the earth rotates on the screen cosmetic only
///
/// Moon Options
/// - moonSize = Size of the moon as a multiplier of screen size
/// - moonOrbitMultiplierX = Same as Sun/Earth
/// - moonOrbitMultiplierY = Same as Sun/Earth but moon pivots around earth
/// - moonRotationSpeed = Speed the earth rotates on the screen cosmetic only
/// - moonSizeVariation = moonSize +- moonSizeVariation 
///   as moon travels "front" to "back"
///
/// Generic
/// - backgroundRotationSpeedMultiplier = How fast the background and stars spin
/// - angleOffset = 0 degrees != 12:00, this constant offsets the 
///   clock to correct

abstract class SpaceConfig {
// The size of earth as a ratio of screen width

  double get sunSize => 2.0;
  double get sunBaseSize => 0.95;
  double get sunOrbitMultiplierX => 0.8;
  double get sunOrbitMultiplierY => 1.4;
  double get sunSpeed => 40;

  List<SunLayer> get sunLayers => [
        SunLayer(
            image: "sun_1",
            mode: BlendMode.multiply,
            flipped: false,
            speed: -1),
        SunLayer(
            image: "sun_2", mode: BlendMode.plus, flipped: false, speed: 5),
        SunLayer(
            image: "sun_3", mode: BlendMode.plus, flipped: false, speed: -4),
        SunLayer(
            image: "sun_3", mode: BlendMode.multiply, flipped: true, speed: -3),
        SunLayer(
            image: "sun_4", mode: BlendMode.multiply, flipped: true, speed: 1),
      ];

  RadialGradient get sunGradient => RadialGradient(
      center: Alignment.center,
      radius: 0.5,
      colors: [Colors.white, Colors.deepOrange.withOpacity(0.0)],
      stops: [0.985, 1.0]);

  double get earthSize => 0.35;
  double get earthRotationSpeed => -10.0;
  double get earthOrbitMultiplierX => 0.3; //ScreenWidth / X
  double get earthOrbitMultiplierY => 0.3; //ScreenWidth / X

  double get moonSize => 0.15;
  double get moonOrbitMultiplierX => 0.25; //ScreenWidth / X
  double get moonOrbitMultiplierY => 0.25; //ScreenWidth / X
  double get moonRotationSpeed => -10;
  double get moonSizeVariation => 0.03;

  double get backgroundRotationSpeedMultiplier => 15;
  double get angleOffset => pi / 2;
}

/// Light Space Config, Defaults Only
class _LightSpaceConfig extends SpaceConfig {}

/// DarkSpaceConfig, Orbits/Scales changed slightly
class _DarkSpaceConfig extends SpaceConfig {
  @override
  double get sunSize => 0.3;
  @override
  double get earthSize => 0.25;
  @override
  double get moonSize => 0.08;
  @override
  double get sunOrbitMultiplierX => 0.3;
  @override
  double get sunOrbitMultiplierY => 0.25;
  @override
  double get moonOrbitMultiplierX => 0.18; //ScreenWidth / X
  @override
  double get moonOrbitMultiplierY => 0.1; //ScreenWidth / X
  @override
  double get moonRotationSpeed => -10;
  @override
  double get moonSizeVariation => 0.01;
}

/// Represents a "layer" of the sun
///
/// This is baked into the config so we can say
/// what layers are drawn, with what blend mode,
/// and if they are visually flipped
class SunLayer {
  /// The image name, e.g. sun_1 or sun_2, that would be in the map
  final String image;

  /// The blend mode we will draw this layer
  final BlendMode mode;

  /// We can flip layers to give fake randomness
  final bool flipped;

  /// And we should set a speed the layers transition
  final double speed;

  /// Construct a sun layer
  SunLayer(
      {@required this.image,
      @required this.mode,
      @required this.flipped,
      @required this.speed});
}
