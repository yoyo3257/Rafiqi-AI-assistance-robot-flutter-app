
part of 'chat_cubit.dart';


abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<Message> messages;
  final String currentLanguage;

  const ChatLoaded({required this.messages, required this.currentLanguage});

  @override
  List<Object?> get props => [messages, currentLanguage];
}

class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object?> get props => [message];
}