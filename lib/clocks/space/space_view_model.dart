import 'dart:math';
import 'dart:ui';

import 'package:adams_clock/config/space.dart';
import 'package:flutter/widgets.dart';

class SpaceViewModel {
  final double moonOrbit;
  final double earthOrbit;
  final double sunOrbit;
  final double sunDiameter;
  final double osunx;
  final double osuny;
  final double oearthx;
  final double oearthy;
  final double omoonx;
  final double omoony;
  final double moonScale;
  final double backgroundRotation;

  SpaceViewModel(
      {@required this.moonOrbit,
      @required this.earthOrbit,
      @required this.sunOrbit,
      @required this.sunDiameter,
      @required this.osunx,
      @required this.osuny,
      @required this.oearthx,
      @required this.oearthy,
      @required this.omoonx,
      @required this.omoony,
      @required this.moonScale,
      @required this.backgroundRotation});

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
    final sunOrbit = (time.hour / 12.0) * 2 * pi + (1 / 12.0 * earthOrbit);

    /// These are the offsets from center for the earth/sun/moon
    /// They travel in an Oval, in proportion to screen size
    //Sun orbits slightly outside the screen, because it's huge
    final sunDiameter = size.width * config.sunSize;
    final osunx = cos(sunOrbit - config.angleOffset) *
        size.width *
        config.sunOrbitMultiplierX;
    final osuny = sin(sunOrbit - config.angleOffset) *
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
    final backgroundRotation =
        earthOrbit * config.backgroundRotationSpeedMultiplier;

    /// Create the view model we draw with
    return SpaceViewModel(
      backgroundRotation: backgroundRotation,
      earthOrbit: earthOrbit,
      oearthx: oearthx,
      oearthy: oearthy,
      moonScale: moonScale,
      moonOrbit: moonOrbit,
      omoonx: omoonx,
      omoony: omoony,
      sunDiameter: sunDiameter,
      sunOrbit: sunOrbit,
      osunx: osunx,
      osuny: osuny,
    );
  }
}
