import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class ChewieVideoPlayer extends StatefulWidget {
  final File? videoFile;
  final String? videoUrl;
  final double? width;
  final double? height;

  const ChewieVideoPlayer({
    super.key,
    this.videoFile,
    this.videoUrl,
    this.width,
    this.height,
  });

  @override
  _ChewieVideoPlayerState createState() => _ChewieVideoPlayerState();
}

class _ChewieVideoPlayerState extends State<ChewieVideoPlayer> {
  bool _initialized = false;
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;


  @override
  void initState() {
    super.initState();

    if (widget.videoFile != null) {
      // Local file
      _videoPlayerController = VideoPlayerController.file(widget.videoFile!);
    } else if (widget.videoUrl != null) {
      // Network URL
      _videoPlayerController = VideoPlayerController.network(widget.videoUrl!);
    } else {
      throw ArgumentError('Either file or url must be provided to ChewieVideoPlayerWidget.');
    }

    _videoPlayerController.initialize().then((_) {
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: false,
        looping: false,
        autoInitialize: false,
        showControlsOnInitialize: false,
        allowMuting: false,
        allowFullScreen: false,
      );
      setState(() {
        _initialized = true;
      });
    });
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return SizedBox(
      width: widget.width ?? 200,
      height: widget.height ?? 200,
      child: Chewie(controller: _chewieController!),
    );
  }
}

