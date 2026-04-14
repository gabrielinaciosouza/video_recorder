import 'package:flutter/material.dart';
import '../utils/orientation_helper.dart';

/// Overlays the teleprompter [text] on the camera preview, positioned near
/// the physical front camera lens based on the current [cameraEdge].
///
/// For landscape edges (left/right), the text is rotated so it reads correctly
/// relative to the user's eye orientation when the device is rotated.
class TeleprompterOverlay extends StatelessWidget {
  final CameraEdge cameraEdge;
  final String text;

  const TeleprompterOverlay({
    super.key,
    required this.cameraEdge,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [_buildPositionedText()],
    );
  }

  Widget _buildPositionedText() {
    final textWidget = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.black54,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          height: 1.4,
        ),
        textAlign: TextAlign.center,
      ),
    );

    switch (cameraEdge) {
      case CameraEdge.top:
        return Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: textWidget,
        );

      case CameraEdge.bottom:
        return Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: textWidget,
        );

      case CameraEdge.left:
        // Device rotated CCW → camera on left edge.
        // Rotate text 90° CCW so it reads correctly from that side.
        return Positioned(
          top: 0,
          bottom: 0,
          left: 0,
          child: RotatedBox(
            quarterTurns: -1,
            child: textWidget,
          ),
        );

      case CameraEdge.right:
        // Device rotated CW → camera on right edge.
        // Rotate text 90° CW so it reads correctly from that side.
        return Positioned(
          top: 0,
          bottom: 0,
          right: 0,
          child: RotatedBox(
            quarterTurns: 1,
            child: textWidget,
          ),
        );
    }
  }
}
