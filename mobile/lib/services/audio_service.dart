import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class AudioService {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();

  bool _isRecording = false;
  bool get isRecording => _isRecording;

  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  Future<bool> hasPermission() async {
    return await _recorder.hasPermission();
  }

  Future<String?> startRecording() async {
    if (!await hasPermission()) {
      throw Exception('Microphone permission required');
    }

    final tempDir = await getTemporaryDirectory();
    final path = '${tempDir.path}/gd_turn_${DateTime.now().millisecondsSinceEpoch}.m4a';

    const config = RecordConfig(
      encoder: AudioEncoder.aacLc,
      sampleRate: 44100,
      bitRate: 128000,
    );

    await _recorder.start(config, path: path);
    _isRecording = true;
    return path;
  }

  Future<String?> stopRecording() async {
    if (!_isRecording) return null;
    final path = await _recorder.stop();
    _isRecording = false;
    return path;
  }

  Future<void> playAudioUrl(String url) async {
    try {
      _isPlaying = true;
      await _player.setUrl(url);
      await _player.play();
    } catch (e) {
      debugPrint('Error playing audio: $e');
    } finally {
      _isPlaying = false;
    }
  }

  Future<void> stopPlayback() async {
    await _player.stop();
    _isPlaying = false;
  }

  void dispose() {
    _recorder.dispose();
    _player.dispose();
  }
}
