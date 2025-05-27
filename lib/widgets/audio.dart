import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:web_portfolio/constants/size.dart';

class AudioPlayerWidget extends StatefulWidget {
  const AudioPlayerWidget({super.key});

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget>
    with TickerProviderStateMixin {
  late AudioPlayer player;
  bool isPlaying = false;
  @override
  void initState() {
    super.initState();
    setupAudio();
  }

  Future<void> setupAudio() async {
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.music());
    player = AudioPlayer();
    await player.setAsset('assets/audio/background-music-soft-calm-346480.mp3');
  }

  void togglePlay() async {
    if (isPlaying) {
      await player.pause();
    } else {
      player.play();
    }
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isDesktop = constraints.maxWidth >= kMinDesktopWidth;
      return IconButton(
        onPressed: togglePlay,
        icon: Icon(isPlaying ? Icons.pause_circle : Icons.play_circle),
        iconSize:isDesktop ? 32 : 20,
      );
    });
  }
}
