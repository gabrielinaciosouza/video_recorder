import 'package:flutter/material.dart';

import '../utils/orientation_helper.dart';

/// Overlays the teleprompter [text] on the camera preview, positioned near
/// the physical front camera lens based on the current [cameraEdge].
///
/// Flutter automatically rotates the UI, so no manual rotation is needed
/// for landscape edges; we just position the text near the camera lens.
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
    return Stack(children: [_buildPositionedText(context)]);
  }

  Widget _buildPositionedText(BuildContext context) {
    final textWidget = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.black54,
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 20, height: 1.4),
        textAlign: TextAlign.center,
      ),
    );

    switch (cameraEdge) {
      case CameraEdge.top:
        return Positioned(top: 0, left: 0, right: 0, child: textWidget);

      case CameraEdge.bottom:
        return Positioned(bottom: 0, left: 0, right: 0, child: textWidget);

      case CameraEdge.left:
        return Positioned(
          top: 0,
          bottom: 0,
          left: 0,
          child: Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              child: textWidget,
            ),
          ),
        );

      case CameraEdge.right:
        return Positioned(
          top: 0,
          bottom: 0,
          right: 0,
          child: Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              child: textWidget,
            ),
          ),
        );
    }
  }
}
