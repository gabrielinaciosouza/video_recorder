import 'package:camera/camera.dart';

class CameraService {
  CameraController? _controller;

  CameraController get controller {
    assert(_controller != null, 'CameraService not initialized');
    return _controller!;
  }

  bool get isInitialized => _controller?.value.isInitialized ?? false;

  Future<void> initialize({ResolutionPreset preset = ResolutionPreset.high}) async {
    final cameras = await availableCameras();
    final front = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      front,
      preset,
      enableAudio: true,
    );

    await _controller!.initialize();
  }

  Future<void> startRecording() async {
    await _controller!.startVideoRecording();
  }

  /// Stops recording and returns the local file path of the recorded video.
  Future<String> stopRecording() async {
    final xfile = await _controller!.stopVideoRecording();
    return xfile.path;
  }

  bool get isRecording => _controller?.value.isRecordingVideo ?? false;

  void dispose() {
    _controller?.dispose();
    _controller = null;
  }
}
