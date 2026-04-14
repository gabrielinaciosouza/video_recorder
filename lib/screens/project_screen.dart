import 'package:flutter/material.dart';
import '../models/script.dart';
import '../models/script_chunk.dart';
import '../screens/playback_screen.dart';
import '../screens/recorder_screen.dart';
import '../widgets/chunk_list_item.dart';

class ProjectScreen extends StatefulWidget {
  final Script script;
  final ValueChanged<Script> onChanged;

  const ProjectScreen({
    super.key,
    required this.script,
    required this.onChanged,
  });

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  late Script _script;

  @override
  void initState() {
    super.initState();
    _script = widget.script;
  }

  void _mutate(Script updated) {
    setState(() => _script = updated);
    widget.onChanged(updated);
  }

  // ── Chunk management ──────────────────────────────────────────────────────

  void _addChunk() async {
    final text = await _showTextDialog(title: 'New Chunk');
    if (text == null || text.trim().isEmpty) return;
    final updated = _script.copyWith(chunks: [
      ..._script.chunks,
      ScriptChunk(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: text.trim(),
      ),
    ]);
    _mutate(updated);
  }

  void _editChunk(int index) async {
    final chunk = _script.chunks[index];
    final text = await _showTextDialog(title: 'Edit Chunk', initialText: chunk.text);
    if (text == null || text.trim().isEmpty) return;
    final newChunks = List<ScriptChunk>.from(_script.chunks);
    newChunks[index] = chunk.copyWith(text: text.trim());
    _mutate(_script.copyWith(chunks: newChunks));
  }

  void _deleteChunk(int index) async {
    final confirmed = await _showConfirmDialog(
      title: 'Delete chunk?',
      content: 'This will also remove the recorded video for this chunk.',
    );
    if (!confirmed) return;
    final newChunks = List<ScriptChunk>.from(_script.chunks)..removeAt(index);
    _mutate(_script.copyWith(chunks: newChunks));
  }

  // ── Navigation ────────────────────────────────────────────────────────────

  Future<void> _navigateToRecord(int index) async {
    final chunk = _script.chunks[index];
    final videoPath = await Navigator.push<String?>(
      context,
      MaterialPageRoute(builder: (_) => RecorderScreen(chunk: chunk)),
    );
    if (!mounted || videoPath == null) return;
    final newChunks = List<ScriptChunk>.from(_script.chunks);
    newChunks[index] = newChunks[index].copyWith(
      videoPath: videoPath,
      status: ChunkStatus.recorded,
    );
    _mutate(_script.copyWith(chunks: newChunks));
  }

  void _navigateToPlayback(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlaybackScreen(chunk: _script.chunks[index]),
      ),
    );
  }

  // ── Dialogs ───────────────────────────────────────────────────────────────

  Future<String?> _showTextDialog({
    required String title,
    String initialText = '',
  }) async {
    final controller = TextEditingController(text: initialText);
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          maxLines: 6,
          decoration: const InputDecoration(
            hintText: 'Enter the script for this chunk…',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<bool> _showConfirmDialog({
    required String title,
    String content = '',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: content.isNotEmpty ? Text(content) : null,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final chunks = _script.chunks;
    return Scaffold(
      appBar: AppBar(
        title: Text(_script.name),
        centerTitle: true,
      ),
      body: chunks.isEmpty ? _buildEmpty() : _buildList(chunks),
      floatingActionButton: FloatingActionButton(
        onPressed: _addChunk,
        tooltip: 'Add Chunk',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.video_camera_front_outlined, size: 72, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No chunks yet.\nTap + to add your first one.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<ScriptChunk> chunks) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: chunks.length,
      itemBuilder: (context, index) {
        final chunk = chunks[index];
        return ChunkListItem(
          chunk: chunk,
          index: index,
          onRecord: () => _navigateToRecord(index),
          onPlay: chunk.status == ChunkStatus.recorded
              ? () => _navigateToPlayback(index)
              : null,
          onEdit: () => _editChunk(index),
          onDelete: () => _deleteChunk(index),
        );
      },
    );
  }
}
