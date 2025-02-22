// test/fakes/fake_video_player_platform.dart

import 'dart:ui' show Size;
import 'package:flutter/material.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

// A fake platform implementation of the video player.
class FakeVideoPlayerPlatform extends VideoPlayerPlatform {
  @override
  Future<void> init() async {
    // No-op
  }

  @override
  Future<int> create(DataSource dataSource) async => 1;

  @override
  Future<void> dispose(int textureId) async {}

  @override
  Future<void> pause(int textureId) async {}

  @override
  Future<void> play(int textureId) async {}

  @override
  Future<void> setLooping(int textureId, bool looping) async {}

  @override
  Future<void> setVolume(int textureId, double volume) async {}

  @override
  Future<Duration> getPosition(int textureId) async {
    return const Duration(seconds: 1);
  }

  @override
  Future<void> seekTo(int textureId, Duration position) async {}

  @override
  Stream<VideoEvent> videoEventsFor(int textureId) {
    return Stream<VideoEvent>.value(
      VideoEvent(
        eventType: VideoEventType.initialized,
        size: Size(640, 480),
        duration: Duration(minutes: 1),
      ),
    );
  }


  @override
  Widget buildView(int textureId) {
    // Return placeholder widget
    return const SizedBox(width: 100, height: 100, child: ColoredBox(color: Colors.black));
  }
}