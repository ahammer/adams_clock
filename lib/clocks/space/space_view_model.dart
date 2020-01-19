import 'dart:math';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import '../../config/space.dart';

/// View Model for the Space Clock
class SpaceViewModel {
    /// Construct a Space Clock View Model
    SpaceViewModel(    
      {@required this.moonRotation,
      @required this.moonSize,      
      @required this.sunRotation,
      @required this.sunSize,
      @required this.sunOffset,
      @required this.sunBaseRadius,
      @required this.earthOffset,
      @required this.earthSize,
      @required this.moonOffset,
      @required this.backgroundRotation,
      @required this.centerOffset,
      @required this.backgroundSize,
      @required this.earthRotation,
      });

   /// Create a VM out of a time/config/screen size
  factory SpaceViewModel.of(DateTime time, SpaceConfig config, Size size) {
    ///
    /// We prepare all the math of the clock layout/orientation here
    ///
    /// Since some bodies are relative to others it's useful
    /// to calculate this all at once
    ///
    /// e.g.
    ///  - Moon rotates the earth
    ///  - Shadows rotate with sun
    ///
    /// So we pass various rotation to various draw functions

    final centerOffset = Offset(size.width / 2, size.height / 2);
    final backgroundSize =
        sqrt(size.width * size.width + size.height * size.height);

    /// The moon Orbit Angle, it rotates the earth once per minute
    final moonOrbit = (time.second * 1000 + time.millisecond) / 60000 * 2 * pi;

    ///  The earth orbit, once per hour
    /// (millis precision for animations to not be choppy)
    /// Combined with second and millis for greater animation accuracy
    final earthOrbit =
        (time.minute * 60 * 1000 + time.second * 1000 + time.millisecond) /
            3600000 *
            2 *
            pi;

    /// The suns orbit of the screen once per day
    /// Combined with the earth orbit to give it smooth precision
    final sunRotation =
        (time.hour / 12.0) * 2 * pi + (1 / 12.0 * earthOrbit) * config.sunSpeed;

    /// These are the offsets from center for the earth/sun/moon
    /// They travel in an Oval, in proportion to screen size
    //Sun orbits slightly outside the screen, because it's huge
    final sunDiameter = size.width * config.sunSize;
    final osunx = cos(sunRotation - config.angleOffset) *
        size.width *
        config.sunOrbitMultiplierX;
    final osuny = sin(sunRotation - config.angleOffset) *
        size.height *
        config.sunOrbitMultiplierY;

    ///Earth orbits around the center
    final oearthx = cos(earthOrbit - config.angleOffset) *
        size.width *
        config.earthOrbitMultiplierX;
    final oearthy = sin(earthOrbit - config.angleOffset) *
        size.height *
        config.earthOrbitMultiplierY;

    //Moon orbits 1/4 a screen distance away from the earth as well
    final omoonx = cos(moonOrbit - config.angleOffset) *
        size.width *
        config.moonOrbitMultiplierX;

    final moonSin = sin(moonOrbit - config.angleOffset);
    final omoony = moonSin * size.height * config.moonOrbitMultiplierY;
    final moonScale = moonSin * config.moonSizeVariation;
    final moonSize = size.width * (config.moonSize + moonScale);
    final backgroundRotation =
        earthOrbit * config.backgroundRotationSpeedMultiplier;

    final moonOffset = Offset(
        size.width / 2 + oearthx + omoonx, size.height / 2 + oearthy + omoony);
    final moonRotation = earthOrbit * config.moonRotationSpeed;
    final earthSize = size.width * config.earthSize;
    final earthOffset =
        Offset(size.width / 2 + oearthx, size.height / 2 + oearthy);
    final sunOffset = Offset(size.width / 2 + osunx, size.height / 2 + osuny);
    final sunBaseRadius = sunDiameter / 2 * config.sunBaseSize;

    /// Create the view model we draw with
    return SpaceViewModel(
      backgroundRotation: backgroundRotation,      
      earthOffset: earthOffset,
      earthSize: earthSize,
      earthRotation: earthOrbit * config.earthRotationSpeed,            
      moonSize: moonSize,
      sunBaseRadius: sunBaseRadius,
      sunSize: sunDiameter,
      sunRotation: sunRotation,
      sunOffset: sunOffset,
      moonOffset: moonOffset,
      moonRotation: moonRotation,
      centerOffset: centerOffset,
      backgroundSize: backgroundSize
    );
  }

  /// Rotation of the Moon
  final double moonRotation;

  /// Size of the Moon
  final double moonSize;

  /// Rotation of the Sun  
  final double sunRotation;

  /// Size of the sun
  final double sunSize;

  /// Sun's screen offset
  final Offset sunOffset;

  /// Radius of the suns's base disc
  final double sunBaseRadius;

  /// Size of the background
  final double backgroundSize;

  /// Center of the screen
  final Offset centerOffset;

  /// Size of the earth
  final double earthSize;

  /// Screen offset of the earth
  final Offset earthOffset;


  /// Rotation of the background
  final double backgroundRotation;

  /// Moons offset in screen coords
  final Offset moonOffset;

  /// Earth rotation 
  final double earthRotation;




 
}
