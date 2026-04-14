import 'package:sensors_plus/sensors_plus.dart';

/// The physical edge of the device where the front camera lens is located.
enum CameraEdge { top, bottom, left, right }

/// Maps an [AccelerometerEvent] to the [CameraEdge] where the front camera sits.
///
/// Front camera is at the physical TOP in portrait orientation.
/// When the device rotates, gravity shifts to a different axis, letting us
/// determine which edge is now "up" (where the camera is).
///
/// Coordinate system (Android / sensors_plus):
///   x → points to the right of the device in portrait
///   y → points to the top of the device in portrait
///   z → points out of the screen
///
/// In portrait upright: y ≈ +9.8 (gravity reaction)
/// Rotated CW 90° (top→right): x ≈ -9.8, camera is now on the RIGHT
/// Rotated CCW 90° (top→left): x ≈ +9.8, camera is now on the LEFT
/// Upside-down: y ≈ -9.8, camera is at BOTTOM
class OrientationHelper {
  static const double _threshold = 6.0;

  static CameraEdge fromAccelerometer(AccelerometerEvent event) {
    final x = event.x;
    final y = event.y;

    if (x < -_threshold) return CameraEdge.right;
    if (x > _threshold) return CameraEdge.left;
    if (y < -_threshold) return CameraEdge.bottom;
    return CameraEdge.top; // default: portrait upright
  }
}
