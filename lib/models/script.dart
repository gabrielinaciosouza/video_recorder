import 'script_chunk.dart';

class Script {
  final String id;
  String name;
  List<ScriptChunk> chunks;

  Script({
    required this.id,
    required this.name,
    List<ScriptChunk>? chunks,
  }) : chunks = chunks ?? [];

  Script copyWith({String? name, List<ScriptChunk>? chunks}) => Script(
        id: id,
        name: name ?? this.name,
        chunks: chunks ?? this.chunks,
      );

  int get recordedCount => chunks.where((c) => c.status == ChunkStatus.recorded).length;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'chunks': chunks.map((c) => c.toJson()).toList(),
      };

  factory Script.fromJson(Map<String, dynamic> json) => Script(
        id: json['id'] as String,
        name: json['name'] as String,
        chunks: (json['chunks'] as List<dynamic>)
            .map((c) => ScriptChunk.fromJson(c as Map<String, dynamic>))
            .toList(),
      );
}
