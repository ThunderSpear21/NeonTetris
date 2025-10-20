import 'package:audioplayers/audioplayers.dart';

class AudioService {
  // Singleton pattern to ensure only one instance
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();
  // AudioCache.instance = AudioCache(prefix: '');
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentPlayingPath;

  Future<void> init() async {
    // Set the release mode to loop for continuous playback
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
  }

  void playLoopingMusic(String assetPath) {
    if (_audioPlayer.state == PlayerState.playing &&
        _currentPlayingPath == assetPath) {
      return;
    }
    _audioPlayer.play(AssetSource(assetPath));
    _currentPlayingPath = assetPath;
  }

  void stopMusic() {
    _audioPlayer.stop();
    _currentPlayingPath = null;
  }

  void setVolume(double volume) {
    _audioPlayer.setVolume(volume);
  }
}
