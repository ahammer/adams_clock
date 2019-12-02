part of 'space_clock.dart';

///
/// The StarField portion of the Space Clock
/// 


// The default number of stars we will generate
const kNumberStars = 2000;

// The bigger this number, the slower the stars
const kStarSlowdown = 100;

final _random = Random();
final Paint _starsPaint = Paint();
final List<Star> _stars = List.generate(kNumberStars, (idx) => Star());

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


void drawStars(Canvas canvas, Size size, double rotation, double time) {
  final projection =
      vector.makePerspectiveMatrix(140, size.width / size.height, 0, 1);
  projection.rotateZ(rotation * -20);
  final int steps = 16;
  final double intervalSize = 1.0 / steps;

  List.generate(steps, (idx) => idx / steps.toDouble()).forEach((interval) {
    _starsPaint
      ..color = Colors.white.withOpacity(1 - interval)
      ..strokeWidth = (1 - interval) * 2 + 1;

    canvas.drawPoints(
        PointMode.points,
        _stars
            .where((star) {
              double z = star.zForTime(time);
              return (z > interval && z < (interval + intervalSize));
            })
            .map((star) => star
                .project(time, projection)
                .translate(0.5, 0.5)
                .scale(size.width, size.height))
            .toList(),
        _starsPaint);
  });
}
