import 'dart:math';

import 'package:flutter/material.dart';


///
/// Configuration of the Space Clock
///


/// LightSpaceConfig and DarkSpaceConfig are consumed
/// 
/// Values in SpaceConfig (Abstract Class == Light Values)
/// DarkSpaceConfig over-rides and changes the values
/// 
abstract class SpaceConfig {
// The size of earth as a ratio of screen width
  double get sunSize => 2.0;
  double get earthSize => 0.35;
  double get moonSize => 0.15;

  double get sunBaseSize => 0.96;
  double get sunOrbitMultiplierX => 0.8;
  double get sunOrbitMultiplierY => 1.4;
  double get sunSpeed => 25;

  List<SunLayer> get sunLayers => [
    SunLayer("sun_1",  BlendMode.multiply, false, -1),    
    SunLayer("sun_2",  BlendMode.plus, false, 5),
    SunLayer("sun_3",  BlendMode.plus, false, -4),            
    SunLayer("sun_3",  BlendMode.multiply, true, -3),    
    SunLayer("sun_4",  BlendMode.multiply, true, 1),    
  ];

  //We use a gradient for the sun
  //Mainly to give it soft edges
  RadialGradient get sunGradient => RadialGradient(
      center: Alignment.center,
      radius: 0.5,
      colors: [Colors.white, Colors.deepOrange.withOpacity(0.0)],
      stops: [0.985, 1.0]);

  double get earthShadowShrink => 1.0;
  double get earthRotationSpeed => -10.0;
  double get earthOrbitDivisor => 6; //ScreenWidth / X

  double get moonOrbitDivisorX => 4; //ScreenWidth / X
  double get moonOrbitDivisorY => 4; //ScreenWidth / X
  double get moonRotationSpeed => -10;
  double get moonSizeVariation => 0.03;
  double get backgroundRotationSpeedMultiplier => 15;
  double get angleOffset => pi / 2;
}

/// Light Space Config
/// 
/// Basic implementation of config
/// No params set
class LightSpaceConfig extends SpaceConfig {
  static final LightSpaceConfig _singleton = LightSpaceConfig._internal();
  factory LightSpaceConfig() {
    return _singleton;
  }

  LightSpaceConfig._internal();
}

/// DarkSpaceConfig
///
/// What we show in dark-mode
/// Some values are over-ridden
/// to make screen darker
class DarkSpaceConfig extends SpaceConfig {
  static final DarkSpaceConfig _singleton = DarkSpaceConfig._internal();
  factory DarkSpaceConfig() {
    return _singleton;
  }

  DarkSpaceConfig._internal();

  double get sunSize => 0.3;
  double get earthSize => 0.25;
  double get moonSize => 0.08;
  double get sunOrbitMultiplierX => 0.3;
  double get sunOrbitMultiplierY => 0.25;
  double get moonOrbitDivisorX => 5.5; //ScreenWidth / X
  double get moonOrbitDivisorY => 5.5; //ScreenWidth / X
  double get moonRotationSpeed => -10;
  double get moonSizeVariation => 0.01;

}

/// Represents a "layer" of the sun
class SunLayer {
  final String image;
  final BlendMode mode;
  final bool flip;
  final double speed;

  SunLayer(this.image, this.mode, this.flip, this.speed);
}