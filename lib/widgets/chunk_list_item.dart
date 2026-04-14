import 'package:flutter/material.dart';
import '../models/script_chunk.dart';

class ChunkListItem extends StatelessWidget {
  final ScriptChunk chunk;
  final int index;
  final VoidCallback onRecord;
  final VoidCallback? onPlay;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ChunkListItem({
    super.key,
    required this.chunk,
    required this.index,
    required this.onRecord,
    this.onPlay,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isRecorded = chunk.status == ChunkStatus.recorded;
    final preview = chunk.text.length > 80
        ? '${chunk.text.substring(0, 80)}…'
        : chunk.text;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isRecorded ? Colors.green : Colors.grey,
          child: Text(
            '${index + 1}',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          preview.isEmpty ? '(empty)' : preview,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          isRecorded ? 'Recorded' : 'Pending',
          style: TextStyle(
            color: isRecorded ? Colors.green : Colors.orange,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Record',
              icon: Icon(
                isRecorded ? Icons.videocam : Icons.fiber_manual_record,
                color: isRecorded ? Colors.blue : Colors.red,
              ),
              onPressed: onRecord,
            ),
            if (isRecorded)
              IconButton(
                tooltip: 'Play',
                icon: const Icon(Icons.play_circle_outline, color: Colors.green),
                onPressed: onPlay,
              ),
            IconButton(
              tooltip: 'Edit',
              icon: const Icon(Icons.edit_outlined),
              onPressed: onEdit,
            ),
            IconButton(
              tooltip: 'Delete',
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
        isThreeLine: false,
      ),
    );
  }
}
