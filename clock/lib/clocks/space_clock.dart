import 'dart:math';
import 'dart:ui';
import 'package:adams_clock/util/animated_painter.dart';
import 'package:flutter/material.dart';
import 'package:adams_clock/util/extensions.dart';
import 'dart:ui' as ui;
import 'package:vector_math/vector_math_64.dart' as vector;
import 'package:adams_clock/util/image_loader.dart';

part 'space_clock.stars.dart';
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
/// Configuration Constants
///
const kEarthShadowShrink = 0.963;
const kEarthSize = 0.50;
const kSunSize = 1.8;
const kMoonSize = 0.24;
const kEarthShadowSize = 1.0;
const kEarthRotationSpeed = -20.0;
const kAngleOffset = pi / 2;
const kEarthOrbitDivisor = 5; //ScreenWidth / X
const kMoonOrbitDivisor = 4; //ScreenWidth / X
const kMoonRotationSpeed = 40;



/// SpaceClockScene
/// The actual widget that draws this scene
///
/// Delegates out the actual Work to an AnimatedPaint with our SpaceClockPainter
///
class SpaceClockScene extends StatelessWidget {
  SpaceClockScene({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) => AnimatedPaint(
        painter: () => SpaceClockPainter(),
      );
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
  "sun_4",
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
  final Map<String, ui.Image> imageMap = Map();

  ///
  /// These paints serve as the brushes
  ///
  /// Most are getters as they like to be tweaked
  final Paint standardPaint = Paint()..color = Colors.black;
  final Paint sunBasePaint = Paint()..color = Colors.white;
  final Paint sunLayerPaint = Paint();

  
  

  
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

    // Use this if you want to test a particular time
    // final time = DateTime.utc(2000,1,1,6,30,0);

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
    final sunDiameter = size.width * kSunSize;
    final double osunx = cos(sunOrbit - kAngleOffset) * size.width;
    final double osuny = sin(sunOrbit - kAngleOffset) * size.height;

    //Earth orbits 1/4 the screen dimension around the center
    final double oearthx =
        cos(earthOrbit - kAngleOffset) * size.width / kEarthOrbitDivisor;
    final double oearthy =
        sin(earthOrbit - kAngleOffset) * size.height / kEarthOrbitDivisor;

    //Moon orbits 1/4 a screen distance away from the earth as well
    final double omoonx =
        cos(moonOrbit - kAngleOffset) * size.width / kMoonOrbitDivisor;
    final double omoony =
        sin(moonOrbit - kAngleOffset) * size.height / kMoonOrbitDivisor;

    // Draw the various layers, back to front
    drawBackground(canvas, size, earthOrbit);
    drawStars(canvas, size, earthOrbit, time.millisecondsSinceEpoch / 1000.0);
    drawSun(canvas, size, osunx, osuny, sunDiameter, sunOrbit);
    drawEarth(canvas, size, oearthx, oearthy, earthOrbit, sunOrbit);
    drawMoon(canvas, size, oearthx, oearthy, omoonx, omoony, osunx, osuny,
        earthOrbit);
  }


  void drawMoon(
      Canvas canvas,
      Size size,
      double oEarthX,
      double oEarthY,
      double oMoonX,
      double oMoonY,
      double oSunX,
      double oSunY,
      double earthOrbit) {
    double x = size.width / 2 + oEarthX + oMoonX;
    double y = size.height / 2 + oEarthY + oMoonY;
    final offset = Offset(x, y);
    double shadowRotation = atan2(oEarthY + oMoonY - oSunY, oEarthX + oMoonX - oSunX) - pi / 2;
    imageMap["moon"].drawRotatedSquare(
        canvas: canvas,
        size: size.width * kMoonSize,
        offset: offset,
        rotation: earthOrbit * kMoonRotationSpeed,
        paint: standardPaint);

    imageMap["shadow"].drawRotatedSquare(
        canvas: canvas,
        size: size.width * kMoonSize,
        offset: offset,
        rotation: shadowRotation,
        paint: standardPaint);
  }

  void drawBackground(Canvas canvas, Size size, double earthOrbit) {
    imageMap["stars"].drawRotatedSquare(
        canvas: canvas,
        size: size.width + size.height,
        offset: Offset(size.width / 2, size.height / 2),
        rotation: earthOrbit * -20,
        paint: standardPaint);
  }

  void drawEarth(Canvas canvas, Size size, double ox, double oy,
      double earthOrbit, double sunOrbit) {
    imageMap["earth"].drawRotatedSquare(
        canvas: canvas,
        size: size.width * kEarthSize,
        offset: Offset(size.width / 2 + ox, size.height / 2 + oy),
        rotation: earthOrbit * kEarthRotationSpeed,
        paint: standardPaint);

    imageMap["shadow"].drawRotatedSquare(
        canvas: canvas,
        size: size.width * kEarthSize * kEarthShadowShrink,
        offset: Offset(size.width / 2 + ox, size.height / 2 + oy),
        rotation: sunOrbit,
        paint: standardPaint);
  }

  static const SunLayerSpeed = [-1, 3, -3, 5, -5, 7, -7, 9];
  static const List<BlendMode> blendModes = [
    BlendMode.multiply,
    BlendMode.hardLight,
    BlendMode.hardLight,
    BlendMode.multiply,
    BlendMode.plus,
    BlendMode.multiply,
    BlendMode.multiply,
    BlendMode.multiply,
  ];

  static const kSunSpeed = 25;

  void drawSun(Canvas canvas, Size size, double x, double y, double sunDiameter,
      double sunRotation) {
    int phase = 0;
    final sunOffset = Offset(size.width / 2 + x, size.height / 2 + y);
    canvas.drawCircle(sunOffset, sunDiameter / 2 * 0.95, sunBasePaint);
    [true, false].forEach((shouldFlip) {
      imageMap["sun_1"].drawRotatedSquare(
          canvas: canvas,
          size: sunDiameter,
          offset: sunOffset,
          rotation: sunRotation * SunLayerSpeed[phase] * kSunSpeed,
          paint: sunLayerPaint..blendMode = blendModes[phase++],
          flip: shouldFlip);
      imageMap["sun_2"].drawRotatedSquare(
          canvas: canvas,
          size: sunDiameter,
          offset: sunOffset,
          rotation: sunRotation * SunLayerSpeed[phase] * kSunSpeed,
          flip: shouldFlip,
          paint: sunLayerPaint..blendMode = blendModes[phase++]);
      imageMap["sun_3"].drawRotatedSquare(
          canvas: canvas,
          size: sunDiameter,
          offset: sunOffset,
          rotation: sunRotation * SunLayerSpeed[phase] * kSunSpeed,
          flip: shouldFlip,
          paint: sunLayerPaint..blendMode = blendModes[phase++]);
      imageMap["sun_3"].drawRotatedSquare(
          canvas: canvas,
          size: sunDiameter,
          offset: sunOffset,
          rotation: sunRotation * SunLayerSpeed[phase] * kSunSpeed,
          flip: shouldFlip,
          paint: sunLayerPaint..blendMode = blendModes[phase++]);
    });
  }


}
