import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> requestCameraAndMic() async {
    final cameraStatus = await Permission.camera.request();
    final micStatus = await Permission.microphone.request();
    // Storage permission for Android < 10; on newer versions this is a no-op
    // or auto-granted — saver_gallery uses MediaStore which needs no extra grant.
    await Permission.storage.request();
    return cameraStatus.isGranted && micStatus.isGranted;
  }

  static Future<bool> checkCameraAndMic() async {
    return await Permission.camera.isGranted &&
        await Permission.microphone.isGranted;
  }

  static Future<void> openSettings() => openAppSettings();
}
