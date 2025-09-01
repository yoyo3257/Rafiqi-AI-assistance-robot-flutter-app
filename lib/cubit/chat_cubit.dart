import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:rafiqi/models/message_model.dart';
import 'package:rafiqi/services/api_service.dart';
part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ApiService _apiService;
  List<Message> _messages = [];
  String _currentLanguage = 'en'; // Default language

  ChatCubit(this._apiService) : super(ChatInitial()) {
    _messages.add(
      const Message(
        text: 'Hello and welcome to the Egyptian Museum! I\'m your AI guide. What would you like to explore today?',
        isUser: false,
        suggestions: ['Tutankhamun\'s mask', 'Narmer Palette', 'Museum hours'],
      ),
    );
    emit(ChatLoaded(messages: List.from(_messages), currentLanguage: _currentLanguage));
  }

  void setCurrentLanguage(String lang) {
    _currentLanguage = lang;
    emit(ChatLoaded(messages: List.from(_messages), currentLanguage: _currentLanguage));
  }

  Future<void> sendMessage(String text) async {
    _messages.add(Message(text: text, isUser: true));
    emit(ChatLoaded(messages: List.from(_messages), currentLanguage: _currentLanguage));

    emit(ChatLoading()); // Show loading indicator

    try {
      final response = await _apiService.sendMessage(
        query: text,
        language: _currentLanguage,
      );

      final String responseText = response['response'] ?? 'Could not get a response.';
      final List<dynamic>? artifacts = response['artifacts'];
      final String? followUp = response['follow_up'];
      final List<String>? suggestions = (response['suggestions'] as List?)?.map((e) => e.toString()).toList();

      if (artifacts != null && artifacts.isNotEmpty) {
        // Handle artifact specific response
        for (var artifactData in artifacts) {
          _messages.add(
            Message(
              text: '${responseText}',
              isUser: false,
              artifacts: [artifactData], // Send each artifact individually or as a list
              imageUrl: artifactData['image_url'],
              funFact: artifactData['fun_fact'],
              followUp: followUp,
            ),
          );
        }
      } else {
        _messages.add(
          Message(
            text: responseText,
            isUser: false,
            suggestions: suggestions,
          ),
        );
      }

      emit(ChatLoaded(messages: List.from(_messages), currentLanguage: _currentLanguage));
    } catch (e) {
      _messages.add(
        const Message(
          text: 'Error: Could not connect to the museum guide. Please try again.',
          isUser: false,
        ),
      );
      emit(ChatError('Failed to send message: $e'));
    }
  }

  // Optional: Function to handle suggestion taps
  void sendSuggestion(String suggestion) {
    sendMessage(suggestion);
  }
}