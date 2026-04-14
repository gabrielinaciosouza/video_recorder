import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

/// Wraps [CameraPreview] with a [FittedBox] that fills the available space
/// while preserving the camera's aspect ratio (cover fit).
///
/// On Android, [CameraController.value.previewSize] has width and height
/// swapped relative to the screen orientation, so we account for that here.
class CameraPreviewWidget extends StatelessWidget {
  final CameraController controller;

  const CameraPreviewWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final previewSize = controller.value.previewSize;

    // previewSize can be null briefly before initialization completes
    if (previewSize == null) {
      return const SizedBox.shrink();
    }

    // On Android, previewSize.width and height are in sensor space (landscape),
    // so we swap them to get the correct portrait aspect ratio.
    final double previewWidth = previewSize.height;
    final double previewHeight = previewSize.width;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: previewWidth,
              height: previewHeight,
              child: CameraPreview(controller),
            ),
          ),
        );
      },
    );
  }
}
