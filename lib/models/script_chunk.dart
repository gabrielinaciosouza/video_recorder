enum ChunkStatus { pending, recorded }

class ScriptChunk {
  final String id;
  String text;
  String? videoPath;
  ChunkStatus status;

  ScriptChunk({
    required this.id,
    required this.text,
    this.videoPath,
    this.status = ChunkStatus.pending,
  });

  ScriptChunk copyWith({
    String? text,
    String? videoPath,
    ChunkStatus? status,
  }) {
    return ScriptChunk(
      id: id,
      text: text ?? this.text,
      videoPath: videoPath ?? this.videoPath,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'videoPath': videoPath,
        'status': status.name,
      };

  factory ScriptChunk.fromJson(Map<String, dynamic> json) => ScriptChunk(
        id: json['id'] as String,
        text: json['text'] as String,
        videoPath: json['videoPath'] as String?,
        status: ChunkStatus.values.byName(json['status'] as String),
      );
}
