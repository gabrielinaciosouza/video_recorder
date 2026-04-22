import 'package:flutter/services.dart';

class AudioInputDevice {
  final int id;
  final String name;
  final bool isUsb;

  const AudioInputDevice({
    required this.id,
    required this.name,
    required this.isUsb,
  });
}

class AudioRoutingService {
  static const _channel = MethodChannel('audio_routing');

  Future<List<AudioInputDevice>> getInputDevices() async {
    try {
      final List<dynamic> result = await _channel.invokeMethod('getInputDevices');
      return result.map((d) => AudioInputDevice(
        id: (d['id'] as num).toInt(),
        name: d['name'] as String,
        isUsb: d['isUsb'] as bool,
      )).toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> hasUsbMic() async {
    final devices = await getInputDevices();
    return devices.any((d) => d.isUsb);
  }
}
