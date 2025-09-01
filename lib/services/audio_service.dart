import 'dart:io';
import 'dart:convert';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';

class AudioService {
  final _audioRecorder = AudioRecorder();
  final _audioPlayer = AudioPlayer();
  String? _currentAudioPath;

  Future<void> initAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
  }

  Future<void> startRecording() async {
    if (await _audioRecorder.hasPermission()) {
      final appDocDir = await getTemporaryDirectory();
      _currentAudioPath =
      '${appDocDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _audioPlayer.stop();
      await _audioRecorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: _currentAudioPath!,
      );
    } else {
      throw Exception("Microphone permission not granted.");
    }
  }

  Future<String?> stopRecording() async {
    if (_currentAudioPath != null) {
      final path = await _audioRecorder.stop();
      return path;
    }
    return null;
  }

  Future<void> playAudioResponse(String base64Audio) async {
    try {
      final bytes = base64Decode(base64Audio);
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/response_audio.mp3');
      await tempFile.writeAsBytes(bytes);

      await _audioPlayer.setFilePath(tempFile.path);
      await _audioPlayer.play();

      _audioPlayer.processingStateStream.listen((state) {
        if (state == ProcessingState.completed) {
          tempFile.delete();
        }
      });
    } catch (e) {
      print("Error playing audio response: $e");
      rethrow;
    }
  }

  void dispose() {
    _audioRecorder.dispose();
    _audioPlayer.dispose();
  }
}