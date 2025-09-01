import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rafiqi/cubit/chat_cubit.dart'; // Adjust path as per your structure
import 'package:rafiqi/services/api_service.dart'; // Adjust path as per your structure
import 'chat_screen.dart'; // Adjust path as per your structure

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ChatCubit>(
          create: (context) => ChatCubit(ApiService()), // Ensure ApiService is correctly imported and instantiated
        ),
      ],
      child: Scaffold(
        body:  ChatScreen(),
      ),
    );
  }
}