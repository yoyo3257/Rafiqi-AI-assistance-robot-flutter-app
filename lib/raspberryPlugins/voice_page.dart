import 'package:flutter/material.dart';
import 'package:rafiqi/constants/colors.dart';
import 'package:rafiqi/services/audio_service.dart';
import 'package:rafiqi/services/api_service_voice.dart';

class VoiceChatScreen2 extends StatefulWidget {
  @override
  _VoiceChatScreen2State createState() => _VoiceChatScreen2State();
}

class _VoiceChatScreen2State extends State<VoiceChatScreen2> {
  final AudioService _audioService = AudioService();
  final ApiService _apiService = ApiService();

  bool _isRecording = false;
  String _response = "Press and hold the microphone to speak!";

  final ImageProvider informationBackgroundImg =
  const AssetImage('assets/images/voiceBackground.png');

  @override
  void initState() {
    super.initState();
    _initializeVoiceChat();
  }

  Future<void> _initializeVoiceChat() async {
    // REMOVED: PermissionsHelper.checkMicrophonePermission
    // The permission will now be handled by the OS setup on Raspberry Pi.
    // Ensure your Raspberry Pi user is in the 'audio' group for microphone access.
    // Any failures to access the microphone will be reported by the native FFI code.

    await _audioService.initAudioSession();
  }

  Future<void> _startRecording() async {
    try {
      await _audioService.startRecording();
      setState(() {
        _isRecording = true;
        _response = "Recording...";
      });
    } catch (e) {
      setState(() {
        _response = "Error starting recording: $e\n"
            "Ensure microphone is connected and user has OS-level permissions."; // Added helpful message
      });
    }
  }

  Future<void> _stopRecording() async {
    try {
      final audioPath = await _audioService.stopRecording();
      if (audioPath != null) {
        setState(() {
          _isRecording = false;
          _response = "Processing audio...";
        });
        _sendAudioAndGetResponse(audioPath);
      }
    } catch (e) {
      setState(() {
        _response = "Error stopping recording: $e";
      });
    }
  }

  Future<void> _sendAudioAndGetResponse(String audioFilePath) async {
    try {
      final responseData = await _apiService.sendAudioToApi(audioFilePath);
      setState(() {
        _response = responseData['response'] ?? 'No response from API.';
      });

      String? base64ResponseAudio = responseData['audio_response_data'];
      if (base64ResponseAudio != null && base64ResponseAudio.isNotEmpty) {
        _audioService.playAudioResponse(base64ResponseAudio);
      }
    } catch (e) {
      setState(() {
        _response = "Error: $e";
      });
    }
  }

  void _toggleRecording() async {
    if (_isRecording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.offWhite,
      appBar: AppBar(
        title: const Text(
          "Voice Help",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: MyColor.myBrown,
      ),
      body: Center(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: MyColor.offWhite,
            image: DecorationImage(
              image: informationBackgroundImg,
              fit: BoxFit.cover,
              opacity: 0.3,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 20),
              Container(
                width: MediaQuery.of(context).size.width * 0.1,
                height: MediaQuery.of(context).size.width * 0.1,
                decoration: const BoxDecoration(
                    color: MyColor.offWhite,
                    borderRadius: BorderRadius.all(
                      Radius.circular(100),
                    )),
                child: IconButton(
                  icon: Icon(
                    _isRecording ? Icons.mic_off : Icons.mic,
                    size: MediaQuery.of(context).size.width * 0.08,
                    color: _isRecording ? MyColor.accentBrown : MyColor.brownOne,
                  ),
                  onPressed: _toggleRecording,
                  splashColor: Colors.white.withAlpha(0x4D),
                  highlightColor: Colors.white.withAlpha(0x1A),
                  tooltip: _isRecording ? 'Stop Recording' : 'Start Recording',
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _isRecording ? "Press again to stop" : "Press to speak",
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: MyColor.brownOne),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(25.0),
                child: Container(
                  decoration: BoxDecoration(
                      color: MyColor.offWhite.withValues(alpha: 0.6),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(35),
                      )),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      _response,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 18, color: MyColor.brownOne),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}