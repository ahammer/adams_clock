import 'dart:math';
import 'dart:ui';
import 'package:adams_clock/util/animated_painter.dart';
import 'package:flutter/material.dart';
import 'package:adams_clock/util/extensions.dart';
import 'dart:ui' as ui;
import 'package:vector_math/vector_math_64.dart' as vector;
import 'package:adams_clock/util/image_loader.dart';

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

// A random generator for the Stars to use
final _random = Random();

// The default number of stars we will generate
const kNumberStars = 1500;

// The bigger this number, the slower the stars
const kStarSlowdown = 30;

/// Star
/// Represents a Star
///
/// It will be in the range of [-0.5->0.5, -0.5->0.5, 0.0->1.0]
/// This range makes it easy to get a correct perspective transform
class Star {
  final x = _random.nextDouble() - 0.5,
      y = _random.nextDouble() - 0.5,
      z = _random.nextDouble();

  /// zForTime(time)
  /// Adjusts Z for current time to simulate travelling
  ///
  /// We adjust Z for time, but always take the 0-1 range
  /// Assisted by our Extension function on double .fraction()
  double zForTime(double time) => (z - (time / kStarSlowdown)).fraction();

  /// Project(time, perspective)
  ///
  /// Takes the 3D point and Projects it to 2D space for Time and Perspective
  /// Screen Space translation is handled on the other side
  ///
  /// Psuedo:
  ///   Make Vector3(x,y,zForTime)
  ///   Apply Projection to Vector
  ///   Convert to Offset (discard Z)
  ///
  Offset project(double time, vector.Matrix4 perspective) =>
      (vector.Vector3(x, y, zForTime(time))..applyProjection(perspective))
          .toOffset();
}

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
  Paint get standardPaint => Paint()..color = Colors.black;
  Paint get sunBasePaint => Paint()..color = Colors.white;
  Paint get sunLayer1Paint => Paint()..blendMode = BlendMode.multiply;
  Paint get sunLayer2Paint => Paint()..blendMode = BlendMode.plus;
  Paint get sunLayer3Paint => Paint()..blendMode = BlendMode.multiply;
  Paint get sunLayer4Paint => Paint()..blendMode = BlendMode.softLight;

  /// For drawing the stars, we mutate this. Color/Opacity changes with Z distance
  final Paint starsPaint = Paint();

  // Generate a List of Stars
  final List<Star> stars = List.generate(kNumberStars, (idx) => Star());

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
    tp.paint(canvas, new Offset(size.width/2-tp.width/2, size.height/2-tp.height/2));
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
    final angleOffset = pi / 2;

    // The moon Orbit Angle, it rotates the earth once per minute
    final double moonOrbit =
        (time.second * 1000 + time.millisecond) / 60000 * 2 * pi;

    // The earth orbit, once per hour (millis precision for animations to not be choppy)
    final double earthOrbit =
        (time.minute * 60 * 1000 + time.second * 1000 + time.millisecond) /
            3600000 *
            2 *
            pi;

    // The suns orbit of the screen once per day
    final double sunOrbit =
        (time.hour / 12.0) * 2 * pi + (1 / 12.0 * earthOrbit);

    // These are the offsets from center for the earth/sun/moon
    // They travel in an Oval, in proportion to screen size

    //Sun orbits slightly outside the screen, because it's huge
    final sunDiameter = size.width * 1.4;
    final double osunx = cos(sunOrbit - angleOffset) * size.width;
    final double osuny = sin(sunOrbit - angleOffset) * size.height;

    //Earth orbits 1/4 the screen dimension around the center
    final double oearthx = cos(earthOrbit - angleOffset) * size.width / 4;
    final double oearthy = sin(earthOrbit - angleOffset) * size.height / 4;

    //Moon orbits 1/4 a screen distance away from the earth as well
    final double omoonx = cos(moonOrbit - angleOffset) * size.width / 4;
    final double omoony = sin(moonOrbit - angleOffset) * size.height / 4;

    drawBackground(canvas, size, earthOrbit);
    drawStars(canvas, size, earthOrbit, time.millisecondsSinceEpoch / 1000.0);
    drawSun(canvas, size, osunx, osuny, sunDiameter, sunOrbit);
    drawEarth(canvas, size, oearthx, oearthy, earthOrbit, sunOrbit);
    drawMoon(
        canvas, size, oearthx, omoonx, oearthy, omoony, earthOrbit, sunOrbit);
  }

  void drawMoon(Canvas canvas, Size size, double ox, double ox2, double oy,
      double oy2, double earthOrbit, double sunOrbit) {
    imageMap["moon"].drawRotatedSquare(
        canvas: canvas,
        size: size.width / 4,
        offset: Offset(size.width / 2 + ox + ox2, size.height / 2 + oy + oy2),
        rotation: earthOrbit * 20,
        paint: standardPaint);

    imageMap["shadow"].drawRotatedSquare(
        canvas: canvas,
        size: size.width / 4,
        offset: Offset(size.width / 2 + ox + ox2, size.height / 2 + oy + oy2),
        rotation: sunOrbit,
        paint: standardPaint);
  }

  void drawEarth(Canvas canvas, Size size, double ox, double oy,
      double earthOrbit, double sunOrbit) {
    imageMap["earth"].drawRotatedSquare(
        canvas: canvas,
        size: size.width * 0.50,
        offset: Offset(size.width / 2 + ox, size.height / 2 + oy),
        rotation: earthOrbit * 4,
        paint: standardPaint);

    imageMap["shadow"].drawRotatedSquare(
        canvas: canvas,
        size: size.width * 0.485,
        offset: Offset(size.width / 2 + ox, size.height / 2 + oy),
        rotation: sunOrbit,
        paint: standardPaint);
  }

  void drawSun(Canvas canvas, Size size, double x, double y, double sunDiameter,
      double sunRotation) {
    final speedMultiplier = 2.5;
    int phase = 1;
    final sunOffset = Offset(size.width / 2 + x, size.height / 2 + y);
    canvas.drawCircle(sunOffset, sunDiameter / 2 * 0.95, sunBasePaint);
    [true, false].forEach((shouldFlip) => imageMap["sun_1"].drawRotatedSquare(
        canvas: canvas,
        size: sunDiameter,
        offset: sunOffset,
        rotation: sunRotation * (phase++ * 5) * speedMultiplier,
        paint: sunLayer1Paint,
        flip: shouldFlip));

    [true, false].forEach((shouldFlip) => imageMap["sun_2"].drawRotatedSquare(
        canvas: canvas,
        size: sunDiameter,
        offset: sunOffset,
        rotation: sunRotation * (phase++ * 7) * speedMultiplier,
        flip: shouldFlip,
        paint: sunLayer2Paint));

    [true, false].forEach((shouldFlip) => imageMap["sun_3"].drawRotatedSquare(
        canvas: canvas,
        size: sunDiameter,
        offset: sunOffset,
        rotation: sunRotation * (phase++ * 9) * speedMultiplier,
        flip: shouldFlip,
        paint: sunLayer3Paint));

    [true, false].forEach((shouldFlip) => imageMap["sun_4"].drawRotatedSquare(
        canvas: canvas,
        size: sunDiameter,
        offset: sunOffset,
        rotation: sunRotation * (phase++ * 11) * speedMultiplier,
        flip: shouldFlip,
        paint: sunLayer4Paint));
  }

  void drawBackground(Canvas canvas, Size size, double earthOrbit) {
    imageMap["stars"].drawRotatedSquare(
        canvas: canvas,
        size: size.width + size.height,
        offset: Offset(size.width / 2, size.height / 2),
        rotation: earthOrbit * -20,
        paint: standardPaint);
  }

  void drawStars(Canvas canvas, Size size, double rotation, double time) {
    final projection =
        vector.makePerspectiveMatrix(140, size.width / size.height, 0, 1);
    projection.rotateZ(rotation * -20);
    final int steps = 16;
    final double intervalSize = 1.0 / steps;

    List.generate(steps, (idx) => idx / steps.toDouble()).forEach((interval) {
      starsPaint
        ..color = Colors.white.withOpacity(1 - interval)
        ..strokeWidth = interval * 2 + 1;

      canvas.drawPoints(
          PointMode.points,
          stars
              .where((star) {
                double z = star.zForTime(time);
                return (z > interval && z < (interval + intervalSize));
              })
              .map((star) => star
                  .project(time, projection)
                  .translate(0.5, 0.5)
                  .scale(size.width, size.height))
              .toList(),
          starsPaint);
    });
  }
}
