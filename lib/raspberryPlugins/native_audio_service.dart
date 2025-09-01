import 'dart:io';
import 'dart:convert';
import 'dart:ffi'; // For FFI
import 'package:path_provider/path_provider.dart';
import 'package:just_audio/just_audio.dart'; // Still used for playback
import 'package:audio_session/audio_session.dart'; // Still used for audio session management
import 'package:ffi/ffi.dart'; // For converting Dart String to C string

// --- FFI Bindings for raspberry_audio.h ---
typedef AudioRecorderContextPtr = Pointer<Void>;

typedef InitAudioRecorderNativeC = AudioRecorderContextPtr Function(Int32 sampleRate, Int32 channels);
typedef InitAudioRecorderNativeDart = AudioRecorderContextPtr Function(int sampleRate, int channels);

typedef StartAudioRecordingNativeC = Int32 Function(AudioRecorderContextPtr context, Pointer<Utf8> filePath);
typedef StartAudioRecordingNativeDart = int Function(AudioRecorderContextPtr context, Pointer<Utf8> filePath);

typedef StopAudioRecordingNativeC = Int32 Function(AudioRecorderContextPtr context);
typedef StopAudioRecordingNativeDart = int Function(AudioRecorderContextPtr context);

typedef DeinitAudioRecorderNativeC = Void Function(AudioRecorderContextPtr context);
typedef DeinitAudioRecorderNativeDart = void Function(AudioRecorderContextPtr context);

// --- End FFI Bindings ---


class AudioService {
  // Removed _audioRecorder from 'record' package
  final _audioPlayer = AudioPlayer();
  String? _currentAudioPath;

  // NEW: FFI related members
  late DynamicLibrary _audioDylib;
  late InitAudioRecorderNativeDart _initAudioRecorder;
  late StartAudioRecordingNativeDart _startAudioRecording;
  late StopAudioRecordingNativeDart _stopAudioRecording;
  late DeinitAudioRecorderNativeDart _deinitAudioRecorder;
  AudioRecorderContextPtr? _audioRecorderContext;

  AudioService() {
    _initFFI(); // Initialize FFI in the constructor
  }

  void _initFFI() {
    if (Platform.isLinux) {
      // Adjust the path to where your .so file will be deployed
      _audioDylib = DynamicLibrary.open('libraspberry_audio.so');

      _initAudioRecorder = _audioDylib.lookupFunction<InitAudioRecorderNativeC, InitAudioRecorderNativeDart>(
          'init_audio_recorder_native');
      _startAudioRecording = _audioDylib.lookupFunction<StartAudioRecordingNativeC, StartAudioRecordingNativeDart>(
          'start_audio_recording_native');
      _stopAudioRecording = _audioDylib.lookupFunction<StopAudioRecordingNativeC, StopAudioRecordingNativeDart>(
          'stop_audio_recording_native');
      _deinitAudioRecorder = _audioDylib.lookupFunction<DeinitAudioRecorderNativeC, DeinitAudioRecorderNativeDart>(
          'deinit_audio_recorder_native');

      // Initialize the native audio recorder here
      _audioRecorderContext = _initAudioRecorder(44100, 1); // e.g., 44.1kHz, mono
      if (_audioRecorderContext == null || _audioRecorderContext!.address == 0) {
        print("Failed to initialize native audio recorder.");
        // Handle error: perhaps throw an exception or set a flag
      }
    } else {
      print("Native audio recording not supported on this platform.");
      // You might want to throw an UnsupportedError or use a fallback for other platforms
    }
  }


  Future<void> initAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
  }

  Future<void> startRecording() async {
    if (_audioRecorderContext == null || _audioRecorderContext!.address == 0) {
      throw Exception("Native audio recorder not initialized.");
    }

    // You might need to check for microphone permissions at the OS level
    // for Raspbian, this is usually handled via user groups or udev rules.
    // The C++ code doesn't directly check permissions in the same way Flutter plugins do.

    final appDocDir = await getTemporaryDirectory();
    _currentAudioPath =
    '${appDocDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.wav'; // Using .wav for ALSA output

    await _audioPlayer.stop(); // Stop any playback before recording

    final filePathC = _currentAudioPath!.toNativeUtf8(); // Convert Dart string to C string
    try {
      final result = _startAudioRecording(_audioRecorderContext!, filePathC);
      if (result != 0) {
        throw Exception("Failed to start native audio recording.");
      }
    } finally {
      calloc.free(filePathC); // Free the C string memory
    }
  }

  Future<String?> stopRecording() async {
    if (_audioRecorderContext == null || _audioRecorderContext!.address == 0) {
      print("Native audio recorder not initialized. Cannot stop recording.");
      return null;
    }
    if (_currentAudioPath != null) {
      final result = _stopAudioRecording(_audioRecorderContext!);
      if (result != 0) {
        print("Failed to stop native audio recording.");
        return null;
      }
      return _currentAudioPath;
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
          tempFile.delete(); // Delete temp file after playback
        }
      });
    } catch (e) {
      print("Error playing audio response: $e");
      rethrow;
    }
  }

  void dispose() {
    // Dispose native recorder
    if (_audioRecorderContext != null) {
      _deinitAudioRecorder(_audioRecorderContext!);
      _audioRecorderContext = null;
    }
    _audioPlayer.dispose();
  }
}

