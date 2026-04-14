import 'package:flutter/material.dart';
import '../models/script.dart';
import '../screens/project_screen.dart';
import '../services/script_repository.dart';

class ScriptsScreen extends StatefulWidget {
  const ScriptsScreen({super.key});

  @override
  State<ScriptsScreen> createState() => _ScriptsScreenState();
}

class _ScriptsScreenState extends State<ScriptsScreen> {
  final _repo = ScriptRepository();
  final List<Script> _scripts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final scripts = await _repo.load();
    if (mounted) {
      setState(() {
        _scripts.addAll(scripts);
        _loading = false;
      });
    }
  }

  Future<void> _save() => _repo.save(_scripts);

  // ── Script management ─────────────────────────────────────────────────────

  void _addScript() async {
    final name = await _showNameDialog(title: 'New Script');
    if (name == null || name.trim().isEmpty) return;
    setState(() {
      _scripts.add(Script(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name.trim(),
      ));
    });
    _save();
  }

  void _renameScript(int index) async {
    final name = await _showNameDialog(
      title: 'Rename Script',
      initialName: _scripts[index].name,
    );
    if (name == null || name.trim().isEmpty) return;
    setState(() {
      _scripts[index] = _scripts[index].copyWith(name: name.trim());
    });
    _save();
  }

  void _deleteScript(int index) async {
    final script = _scripts[index];
    final confirmed = await _showConfirmDialog(
      title: 'Delete "${script.name}"?',
      content: 'All chunks and recordings in this script will be lost.',
    );
    if (!confirmed) return;
    setState(() => _scripts.removeAt(index));
    _save();
  }

  void _onScriptChanged(Script updated) {
    final index = _scripts.indexWhere((s) => s.id == updated.id);
    if (index == -1) return;
    setState(() => _scripts[index] = updated);
    _save();
  }

  // ── Navigation ────────────────────────────────────────────────────────────

  void _openScript(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProjectScreen(
          script: _scripts[index],
          onChanged: _onScriptChanged,
        ),
      ),
    );
  }

  // ── Dialogs ───────────────────────────────────────────────────────────────

  Future<String?> _showNameDialog({
    required String title,
    String initialName = '',
  }) async {
    final controller = TextEditingController(text: initialName);
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          maxLines: 1,
          decoration: const InputDecoration(
            hintText: 'e.g. "Intro", "Episode 3"…',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Scripts'),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _scripts.isEmpty
              ? _buildEmpty()
              : _buildList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _addScript,
        tooltip: 'New Script',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.article_outlined, size: 72, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No scripts yet.\nTap + to create your first one.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _scripts.length,
      itemBuilder: (context, index) => _buildScriptTile(index),
    );
  }

  Widget _buildScriptTile(int index) {
    final script = _scripts[index];
    final total = script.chunks.length;
    final recorded = script.recordedCount;
    final subtitle = total == 0
        ? 'No chunks'
        : '$recorded / $total chunk${total == 1 ? '' : 's'} recorded';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        onTap: () => _openScript(index),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            script.name.isNotEmpty ? script.name[0].toUpperCase() : '?',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(script.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Rename',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _renameScript(index),
            ),
            IconButton(
              tooltip: 'Delete',
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _deleteScript(index),
            ),
          ],
        ),
      ),
    );
  }
}
