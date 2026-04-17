import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/script_chunk.dart';

class PlaybackScreen extends StatefulWidget {
  final ScriptChunk chunk;

  const PlaybackScreen({super.key, required this.chunk});

  @override
  State<PlaybackScreen> createState() => _PlaybackScreenState();
}

class _PlaybackScreenState extends State<PlaybackScreen> {
  late VideoPlayerController _videoController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    _videoController = VideoPlayerController.file(File(widget.chunk.videoPath!));
    await _videoController.initialize();
    _videoController.addListener(_onVideoUpdate);
    await _videoController.play();
    if (mounted) setState(() => _isInitialized = true);
  }

  void _onVideoUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _videoController.removeListener(_onVideoUpdate);
    _videoController.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_videoController.value.isPlaying) {
      _videoController.pause();
    } else {
      _videoController.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          'Review — Chunk ${_chunkIndex()}',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: _isInitialized ? _buildPlayer() : _buildLoading(),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(color: Colors.white),
    );
  }

  Widget _buildPlayer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Video fills available vertical space, constrained so other widgets fit
        Expanded(
          child: Center(
            child: AspectRatio(
              aspectRatio: _videoController.value.aspectRatio,
              child: VideoPlayer(_videoController),
            ),
          ),
        ),
        VideoProgressIndicator(
          _videoController,
          allowScrubbing: true,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          colors: const VideoProgressColors(
            playedColor: Colors.red,
            bufferedColor: Colors.grey,
            backgroundColor: Colors.white24,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(
                _videoController.value.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 48,
              ),
              onPressed: _togglePlayPause,
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          child: Text(
            widget.chunk.text,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
            textAlign: TextAlign.center,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// Returns a display index by searching the text (no parent reference needed).
  String _chunkIndex() => widget.chunk.id;
}
