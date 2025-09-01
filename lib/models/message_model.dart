import 'package:equatable/equatable.dart';

class Message extends Equatable {
  final String text;
  final bool isUser; // true if from user, false if from AI
  final List<dynamic>? artifacts; // For artifact data
  final String? imageUrl; // For artifact images
  final String? funFact; // For artifact fun facts
  final String? followUp; // For AI follow-up questions
  final List<String>? suggestions; // For AI suggestions

  const Message({
    required this.text,
    required this.isUser,
    this.artifacts,
    this.imageUrl,
    this.funFact,
    this.followUp,
    this.suggestions,
  });

  @override
  List<Object?> get props => [text, isUser, artifacts, imageUrl, funFact, followUp, suggestions];
}