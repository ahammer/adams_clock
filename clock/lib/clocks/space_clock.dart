import 'dart:math';
import 'dart:ui';
import 'package:adams_clock/util/animated_painter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:adams_clock/util/extensions.dart';
import 'dart:ui' as ui;
import 'package:adams_clock/util/image_loader.dart';
import 'package:adams_clock/clocks/stars.dart';
import 'package:flutter_clock_helper/model.dart';

///
/// Sun Clock
///
/// Draws the Actual Sun/Moon/Earth/Stars Clock
///
/// A general explanation is as follows
///
/// Draws in order
/// - Fixed star background (rotating over time, for motion effect)
///
/// - Star Simulation
///   - Matrix math for projecting and transforming to "time space" and screen space
///   - Batched by Z distance to set size/color and draw with drawPoints() to reduce draw calls
///
/// - Sun
///   - "Hour Hand".
///   - First draws a circle (Base Layer) in white
///   - Drawn in layers (4 images)
///   - The layers have varying blend modes (Multiply/Plus/SoftLight)
///     - Multiply to emulate sunspots
///     - Plus/Softlight to emulate light/glowing
///   - Layers rotate slowly in varying directions
///   - Each layer is drawn twice, once flipped and rotated in opposite direction
///   - The effective 8 layers do a Perlin compose a perlin noise that looks a lot like the sun.
///
/// - Earth
///   - "Minute Hand"
///   - Rotates around the center of the screen once per hour.
///   - Shadow layer is drawn over the earth, opposite the sun
///
/// - Moon
///   - "Seconds Hand"
///   - Rotates around earth once a minute
///   - Shadow layer is drawn over the moon, opposite the sun
///

///
/// Configuration


///
/// This class represents a config
/// 
/// The default values are the "Light" theme
/// Sun is more prominent in Light
/// Less prominent in dark
abstract class SpaceConfig {
// The size of earth as a ratio of screen width
  double get sunSize => 2.0;
  double get earthSize => 0.50;
  double get moonSize => 0.24;

  double get sunBaseSize => 0.96;
  double get sunOrbitMultiplierX => 0.8;
  double get sunOrbitMultiplierY => 1.4;
  double get sunSpeed => 20;
  List<double> get sunLayerSpeed => [2, -3, 7, -6, 5, -4];

  // Blend Mode for sun layers
  List<BlendMode> get sunBlendModes => [
        BlendMode.multiply,
        BlendMode.plus,
        BlendMode.multiply,
        BlendMode.plus,
        BlendMode.multiply,
        BlendMode.multiply,
      ];

  double get earthShadowShrink => 1.0;
  double get earthRotationSpeed => -20.0;
  double get earthOrbitDivisor => 3; //ScreenWidth / X

  double get moonOrbitDivisor => 4; //ScreenWidth / X
  double get moonRotationSpeed => 40;

  double get backgroundRotationSpeedMultiplier => 15;
  double get angleOffset => pi / 2;
}

/// Light Space Config
/// 
/// All values are default
class LightSpaceConfig extends SpaceConfig {
  static final LightSpaceConfig _singleton = LightSpaceConfig._internal();
  factory LightSpaceConfig() {
    return _singleton;
  }

  LightSpaceConfig._internal();
}

/// DarkSpaceConfig
///
/// Values are modified to make sun less prominent
/// and space/darkness more prominent
class DarkSpaceConfig extends SpaceConfig {
  static final DarkSpaceConfig _singleton = DarkSpaceConfig._internal();
  factory DarkSpaceConfig() {
    return _singleton;
  }

  DarkSpaceConfig._internal();

  double get sunSize => 0.4;
  double get earthSize => 0.35;
  double get moonSize => 0.20;

  double get sunOrbitMultiplierX => 0.2;
  double get sunOrbitMultiplierY => 0.2;
    
  double get earthOrbitDivisor => 6; //ScreenWidth / X
  double get moonOrbitDivisor => 5; //ScreenWidth / X
}

/// Background Rotation Speed
///
/// The background rotates
///

/// SpaceClockScene
/// The actual widget that draws this scene
///
/// Delegates out the actual Work to an AnimatedPaint with our SpaceClockPainter
///

final SpaceClockPainter painter = SpaceClockPainter();
class SpaceClockScene extends StatelessWidget {
  final ClockModel model;


  SpaceClockScene(this.model,  {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {    
    /// We pass the current theme to the Painter so that 
    /// It knows what SpaceConfig to use
    painter.isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedPaint(
      painter: () => painter
    );
  }
}

///
/// Pngs in the Asset folder used in this scene
///
/// Images are all either hand-made (like the sun)
/// or public domain (Earth/Moon/Space thanks courtesy of Nasa)
const List<String> images = [
  "earth",
  "moon",
  "sun_1",
  "sun_2",
  "sun_3",
  "stars",
  "shadow"
];

/// SpaceClockPainter
///
/// Implementation of the Canvas Drawing of the Space Clock
///
/// Psuedo:
///   Load Images
///   While Loading
///     Draw Loading Screen
///   When done Loading
///     Calculate Gears and Rotations
///     Draw Background
///     Draw Stars
///     Draw Sun
///     Draw Earth
///     Draw Moon
///


class SpaceClockPainter extends AnimatedPainter {
  bool isDark = false;

  final Map<String, ui.Image> imageMap = Map();

  ///
  /// These paints serve as the brushes
  ///
  /// Most are getters as they like to be tweaked
  final Paint standardPaint = Paint()
    ..color = Colors.black
    ..filterQuality = FilterQuality.low;

  final Paint sunBasePaint = Paint()..color = Colors.white;
  final Paint sunLayerPaint = Paint()..filterQuality = FilterQuality.low;  

  bool get loaded => imageMap.length == images.length;

  @override
  void init() async {
    for (int i = 0; i < images.length; i++) {
      final image = images[i];
      imageMap[image] = await loadImageFromAsset(image);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));
    if (!loaded) {
      drawLoadingScreen(canvas, size);
    } else {
      drawSpace(canvas, size);
    }
  }

  /// drawLoadingScreen
  ///
  /// Psuedo
  ///   Build String "Loading ${PercentComplete}"
  ///   Draw String at the center of the screen
  ///
  void drawLoadingScreen(Canvas canvas, Size size) {
    // Fill the screen Black
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height), standardPaint);

    // Set up the TextSpan (Specifies Text, Font, Etc)
    TextSpan span = new TextSpan(
        style: new TextStyle(color: Colors.white, fontSize: 24).withNovaMono(),
        text:
            "Loading (${(imageMap.length / images.length.toDouble() * 100).toInt()}%)....");

    // Set up the TextPainter, which decides how to draw the span
    TextPainter tp = new TextPainter(
        text: span,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr);

    // Layouter the Text (Measure it, etc)
    tp.layout();

    // Paint the Loading Text in the middle of the screen
    tp.paint(
        canvas,
        new Offset(
            size.width / 2 - tp.width / 2, size.height / 2 - tp.height / 2));
  }

  /// drawSpace
  ///
  /// Draws everything in space
  /// Psuedo:
  ///  Calculate Orbital Rotations
  ///  Draw the Background
  ///  Draw the Stars
  ///  Draw the Sun
  ///  Draw the Earth
  ///  Draw the Moon
  void drawSpace(Canvas canvas, Size size) {
    final time = DateTime.now();    
    final SpaceConfig config =
        (isDark) ? DarkSpaceConfig() : LightSpaceConfig();

    
    // Use this if you want to test a particular time
    //final time = DateTime.utc(2000,1,1,9,0,0);
    // Or just want to see it really fast
    //final time = DateTime.fromMillisecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch * 60*60);

    ///
    /// We prepare all the math of the clock layout/orientation here
    ///
    /// Since some bodies are relative to others it's useful to calculate this all at once
    /// e.g.
    ///  - Moon rotates the earth
    ///  - Shadows rotate with sun
    ///
    /// So we pass various rotation to various draw functions

    // This offset aligns the rotation so 12:00:00am everything will be at the top.

    // The moon Orbit Angle, it rotates the earth once per minute
    final double moonOrbit =
        (time.second * 1000 + time.millisecond) / 60000 * 2 * pi;

    // The earth orbit, once per hour (millis precision for animations to not be choppy)
    //Combined with second and millis for greater animation accuracy
    final double earthOrbit =
        (time.minute * 60 * 1000 + time.second * 1000 + time.millisecond) /
            3600000 *
            2 *
            pi;

    // The suns orbit of the screen once per day
    // Combined with the earth orbit to give it smooth precision
    final double sunOrbit =
        (time.hour / 12.0) * 2 * pi + (1 / 12.0 * earthOrbit);

    // These are the offsets from center for the earth/sun/moon
    // They travel in an Oval, in proportion to screen size

    //Sun orbits slightly outside the screen, because it's huge
    final sunDiameter = size.width * config.sunSize;
    final double osunx = cos(sunOrbit - config.angleOffset) *
        size.width *
        config.sunOrbitMultiplierX;
    final double osuny = sin(sunOrbit - config.angleOffset) *
        size.height *
        config.sunOrbitMultiplierY;

    //Earth orbits 1/4 the screen dimension around the center
    final double oearthx = cos(earthOrbit - config.angleOffset) *
        size.width /
        config.earthOrbitDivisor;
    final double oearthy = sin(earthOrbit - config.angleOffset) *
        size.height /
        config.earthOrbitDivisor;

    //Moon orbits 1/4 a screen distance away from the earth as well
    final double omoonx = cos(moonOrbit - config.angleOffset) *
        size.width /
        config.moonOrbitDivisor;
    final double omoony = sin(moonOrbit - config.angleOffset) *
        size.height /
        config.moonOrbitDivisor;

    // Draw the various layers, back to front
    drawBackground(
        canvas, size, earthOrbit * config.backgroundRotationSpeedMultiplier);
    drawStars(
        canvas,
        size,
        earthOrbit * config.backgroundRotationSpeedMultiplier,
        time.millisecondsSinceEpoch / 1000.0);
    drawSun(canvas, size, osunx, osuny, sunDiameter, sunOrbit, config);
    drawEarth(canvas, size, oearthx, oearthy, earthOrbit, sunOrbit, config);
    drawMoon(canvas, size, oearthx, oearthy, omoonx, omoony, osunx, osuny,
        earthOrbit, config);
  }

  ///
  /// Draws the Background
  ///
  /// It's size is "big enough" to cover the screen
  /// it's centered and rotated at the same speed as the star layer
  ///
  ///
  void drawBackground(Canvas canvas, Size size, double earthOrbit) =>
      imageMap["stars"].drawRotatedSquare(
          canvas: canvas,
          size: size.width + size.height,
          offset: Offset(size.width / 2, size.height / 2),
          rotation: earthOrbit,
          paint: standardPaint);

  ///
  /// Draw the Sun
  ///
  /// We have 4 Layers, we can draw them 8 times (flipped once) to increase randomness
  ///
  /// The layers are Blended/Transformed based on the kernels/arrays in the config
  /// This was just experimented with until I liked the way it looks
  ///
  /// The idea was to have it look bright and gaseous, with the occasional sunspot
  ///
  void drawSun(Canvas canvas, Size size, double x, double y, double sunDiameter,
      double sunRotation, SpaceConfig config) {
    int phase = 0;
    final sunOffset = Offset(size.width / 2 + x, size.height / 2 + y);
    canvas.drawCircle(
        sunOffset, sunDiameter / 2 * config.sunBaseSize, sunBasePaint);

    //We are going to go through layers 1-3 twice, once flipped
    [true, false].forEach((shouldFlip) {
      imageMap["sun_1"].drawRotatedSquare(
          canvas: canvas,
          size: sunDiameter,
          offset: sunOffset,
          rotation: sunRotation * config.sunLayerSpeed[phase] * config.sunSpeed,
          paint: sunLayerPaint..blendMode = config.sunBlendModes[phase++],
          flip: shouldFlip);
      imageMap["sun_2"].drawRotatedSquare(
          canvas: canvas,
          size: sunDiameter,
          offset: sunOffset,
          rotation: sunRotation * config.sunLayerSpeed[phase] * config.sunSpeed,
          flip: shouldFlip,
          paint: sunLayerPaint..blendMode = config.sunBlendModes[phase++]);
      imageMap["sun_3"].drawRotatedSquare(
          canvas: canvas,
          size: sunDiameter,
          offset: sunOffset,
          rotation: sunRotation * config.sunLayerSpeed[phase] * config.sunSpeed,
          flip: shouldFlip,
          paint: sunLayerPaint..blendMode = config.sunBlendModes[phase++]);
    });
  }

  ///
  /// Draws the Moon
  ///
  /// Most tweakable params should be accessible in the constants at the top
  ///
  /// We draw the moon, offset the earth, around it's rotation
  /// The shadow is calculated by looking at the suns position
  /// And figuring out the opposite angle.
  ///
  void drawMoon(
      Canvas canvas,
      Size size,
      double oEarthX,
      double oEarthY,
      double oMoonX,
      double oMoonY,
      double oSunX,
      double oSunY,
      double earthOrbit,
      SpaceConfig config) {
    double x = size.width / 2 + oEarthX + oMoonX;
    double y = size.height / 2 + oEarthY + oMoonY;
    final offset = Offset(x, y);
    double shadowRotation =
        atan2(oEarthY + oMoonY - oSunY, oEarthX + oMoonX - oSunX) - pi / 2;
    imageMap["moon"].drawRotatedSquare(
        canvas: canvas,
        size: size.width * config.moonSize,
        offset: offset,
        rotation: earthOrbit * config.moonRotationSpeed,
        paint: standardPaint);

    imageMap["shadow"].drawRotatedSquare(
        canvas: canvas,
        size: size.width * config.moonSize,
        offset: offset,
        rotation: shadowRotation,
        paint: standardPaint);
  }

  ///
  /// DrawEarth
  ///
  /// Draws the earth
  ///
  /// Draws the earth based on it's calculated position
  /// Shadow is drawn as a overlay, opposite the sun's position
  ///
  void drawEarth(Canvas canvas, Size size, double ox, double oy,
      double earthOrbit, double sunOrbit, SpaceConfig config) {
    imageMap["earth"].drawRotatedSquare(
        canvas: canvas,
        size: size.width * config.earthSize,
        offset: Offset(size.width / 2 + ox, size.height / 2 + oy),
        rotation: earthOrbit * config.earthRotationSpeed,
        paint: standardPaint);

    imageMap["shadow"].drawRotatedSquare(
        canvas: canvas,
        size: size.width * config.earthSize * config.earthShadowShrink,
        offset: Offset(size.width / 2 + ox, size.height / 2 + oy),
        rotation: sunOrbit,
        paint: standardPaint);
  }
}
