import 'dart:async';
import 'dart:convert';
import 'dart:io';
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

  Stream<Amplitude> onAmplitudeChanged([Duration interval = const Duration(milliseconds: 100)]) {
    return _recorder.onAmplitudeChanged(interval);
  }

  Future<bool> hasPermission() async {
    return await _recorder.hasPermission();
  }

  Future<String?> startRecording() async {
    if (!await hasPermission()) {
      throw Exception('Microphone permission required');
    }

    final tempDir = await getTemporaryDirectory();
    final path =
        '${tempDir.path}/gd_turn_${DateTime.now().millisecondsSinceEpoch}.m4a';

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

  Future<void> playBase64Audio(String base64String) async {
    try {
      _isPlaying = true;
      final bytes = base64Decode(base64String);
      final tempDir = await getTemporaryDirectory();
      final file = File(
          '${tempDir.path}/ai_reply_${DateTime.now().millisecondsSinceEpoch}.wav');
      await file.writeAsBytes(bytes);
      await _player.setFilePath(file.path);
      await _player.play();
    } catch (e) {
      debugPrint('Error playing base64 audio: $e');
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
