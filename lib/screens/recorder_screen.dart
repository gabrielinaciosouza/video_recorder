import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../models/script_chunk.dart';
import '../services/camera_service.dart';
import '../services/permission_service.dart';
import '../utils/orientation_helper.dart';
import '../widgets/camera_preview_widget.dart';
import '../widgets/teleprompter_overlay.dart';

class RecorderScreen extends StatefulWidget {
  final ScriptChunk chunk;

  const RecorderScreen({super.key, required this.chunk});

  @override
  State<RecorderScreen> createState() => _RecorderScreenState();
}

class _RecorderScreenState extends State<RecorderScreen> {
  final CameraService _cameraService = CameraService();
  StreamSubscription<AccelerometerEvent>? _accelSub;

  CameraEdge _cameraEdge = CameraEdge.top;
  bool _isInitialized = false;
  bool _isRecording = false;
  bool _permissionDenied = false;
  bool _isStopping = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _initCamera();
  }

  Future<void> _initCamera() async {
    final granted = await PermissionService.requestCameraAndMic();
    if (!granted) {
      if (mounted) setState(() => _permissionDenied = true);
      return;
    }

    try {
      await _cameraService.initialize();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Camera error: $e')),
        );
      }
      return;
    }

    if (!mounted) return;
    setState(() => _isInitialized = true);

    _accelSub = accelerometerEventStream().listen((event) {
      final edge = OrientationHelper.fromAccelerometer(event);
      if (edge != _cameraEdge) {
        setState(() => _cameraEdge = edge);
      }
    });
  }

  @override
  void dispose() {
    _accelSub?.cancel();
    _cameraService.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<void> _startRecording() async {
    await _cameraService.startRecording();
    setState(() => _isRecording = true);
  }

  Future<void> _stopRecording() async {
    if (_isStopping) return;
    setState(() => _isStopping = true);

    final tempPath = await _cameraService.stopRecording();
    final savedPath = await _saveVideo(tempPath);
    if (mounted) Navigator.pop(context, savedPath);
  }

  /// Moves the video to the app documents dir (for reliable in-app playback)
  /// and asynchronously saves a copy to the device Gallery so it appears in
  /// the Photos/Gallery app under Movies › Teleprompter.
  Future<String> _saveVideo(String tempPath) async {
    final docsDir = await getApplicationDocumentsDirectory();
    final name = 'teleprompter_${DateTime.now().millisecondsSinceEpoch}';
    final dest = '${docsDir.path}/$name.mp4';

    await File(tempPath).copy(dest);
    await File(tempPath).delete();

    // Fire-and-forget: save a copy to the Gallery (doesn't block the UI).
    SaverGallery.saveFile(
      filePath: dest,
      fileName: name,
      androidRelativePath: 'Movies/Teleprompter',
      skipIfExists: false,
    );

    return dest;
  }

  void _cancel() {
    Navigator.pop(context, null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_permissionDenied) return _buildPermissionDenied();
    if (!_isInitialized) return _buildLoading();
    return _buildCamera();
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(color: Colors.white),
    );
  }

  Widget _buildPermissionDenied() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.camera_alt, size: 64, color: Colors.white54),
            const SizedBox(height: 16),
            const Text(
              'Camera and microphone permissions are required.',
              style: TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: PermissionService.openSettings,
              child: const Text('Open Settings'),
            ),
            TextButton(
              onPressed: _cancel,
              child: const Text('Go Back', style: TextStyle(color: Colors.white70)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCamera() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Layer 1: full-screen camera preview
        CameraPreviewWidget(controller: _cameraService.controller),

        // Layer 2: teleprompter text near the camera lens
        TeleprompterOverlay(
          cameraEdge: _cameraEdge,
          text: widget.chunk.text,
        ),

        // Layer 3: recording indicator (top-right dot when recording)
        if (_isRecording)
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ),

        // Layer 4: controls at the bottom
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: _buildControls(),
        ),
      ],
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (!_isRecording) ...[
          TextButton(
            onPressed: _cancel,
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          const SizedBox(width: 24),
          GestureDetector(
            onTap: _startRecording,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                color: Colors.red,
              ),
              child: const Icon(Icons.fiber_manual_record, color: Colors.white, size: 36),
            ),
          ),
        ] else ...[
          GestureDetector(
            onTap: _isStopping ? null : _stopRecording,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                color: _isStopping ? Colors.grey : Colors.red,
              ),
              child: const Icon(Icons.stop, color: Colors.white, size: 36),
            ),
          ),
        ],
      ],
    );
  }
}
