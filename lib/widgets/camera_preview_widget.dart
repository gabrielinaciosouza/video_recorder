import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

/// Wraps [CameraPreview] with a [FittedBox] that fills the available space
/// while preserving the camera's aspect ratio (cover fit).
///
/// On Android, [CameraController.value.previewSize] is always in sensor
/// (landscape) coordinates. In portrait we swap width/height; in landscape
/// the sensor and screen are aligned so we use the values as-is.
class CameraPreviewWidget extends StatelessWidget {
  final CameraController controller;

  const CameraPreviewWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final previewSize = controller.value.previewSize;
    if (previewSize == null) return const SizedBox.shrink();

    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    // Sensor space is landscape (width > height). Swap only in portrait so the
    // FittedBox receives the correct visual aspect ratio for each orientation.
    final double displayW = isPortrait ? previewSize.height : previewSize.width;
    final double displayH = isPortrait ? previewSize.width : previewSize.height;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: displayW,
              height: displayH,
              child: CameraPreview(controller),
            ),
          ),
        );
      },
    );
  }
}
