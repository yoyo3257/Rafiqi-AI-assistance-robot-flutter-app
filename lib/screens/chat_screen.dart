import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rafiqi/constants/colors.dart';
import 'package:rafiqi/cubit/chat_cubit.dart';
import 'package:rafiqi/models/message_model.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late ImageProvider chatBackgroundImg =
      const AssetImage('assets/images/chat_background.jpg');
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  static const Color myBrown = Color(0xffb6976f);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: myBrown,
        title: const Text(
          'Egyptian Museum AI Guide',
          style: TextStyle(color: MyColor.brownOne),
        ),
        actions: [
          BlocBuilder<ChatCubit, ChatState>(
            builder: (context, state) {
              if (state is ChatLoaded) {
                return DropdownButton<String>(
                  value: state.currentLanguage,
                  icon: const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Icon(Icons.language, color: Colors.white),
                  ),
                  style: const TextStyle(color: MyColor.brownOne),
                  underline: Container(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      context.read<ChatCubit>().setCurrentLanguage(newValue);
                    }
                  },
                  items: <String>['en', 'ar']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value == 'en' ? 'English' : 'العربية'),
                    );
                  }).toList(),
                );
              }
              return Container();
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: chatBackgroundImg, fit: BoxFit.cover, opacity: 0.3),
        ),
        child: Column(
          children: [
            Expanded(
              child: BlocConsumer<ChatCubit, ChatState>(
                listener: (context, state) {
                  if (state is ChatLoaded) {
                    _scrollToBottom();
                  }
                  if (state is ChatError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message)),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is ChatLoaded) {
                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(8.0),
                      itemCount: state.messages.length,
                      itemBuilder: (context, index) {
                        final message = state.messages[index];
                        return _buildMessageBubble(
                            message, state.currentLanguage);
                      },
                    );
                  } else if (state is ChatLoading) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 10),
                          Text('AI is thinking...'),
                        ],
                      ),
                    );
                  } else if (state is ChatError) {
                    return Center(child: Text('Error: ${state.message}'));
                  }
                  return const Center(child: Text('Start chatting!'));
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 10.0),
                      ),
                      onSubmitted: (value) {
                        if (value.trim().isNotEmpty) {
                          context.read<ChatCubit>().sendMessage(value.trim());
                          _controller.clear();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  FloatingActionButton(
                    backgroundColor: MyColor.offWhite,
                    onPressed: () {
                      if (_controller.text.trim().isNotEmpty) {
                        context
                            .read<ChatCubit>()
                            .sendMessage(_controller.text.trim());
                        _controller.clear();
                      }
                    },
                    child: const Icon(
                      Icons.send,
                      color: MyColor.brownOne,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Message message, String currentLanguage) {
    final bool isUser = message.isUser;
    final Color bubbleColor = isUser ? MyColor.myBrown.withValues(alpha: 0.8) : Colors.white70;
    final Color textColor = isUser ? Colors.white : Colors.black;
    final Alignment alignment =
        isUser ? Alignment.centerRight : Alignment.centerLeft;
    final BorderRadius borderRadius = BorderRadius.circular(15.0);
    final EdgeInsetsGeometry containerPadding = isUser
        ? const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0)
        : const EdgeInsets.all(25.0); // This is the new part
    final EdgeInsetsGeometry containerMargin = isUser
        ? const EdgeInsets.symmetric(
            vertical: 4.0) // Example: less horizontal margin for user
        : const EdgeInsets.only(
            top: 10.0,
            right: 50.0,
            bottom: 10.0); // Example: more horizontal margin for AI

    return Align(
      alignment: alignment,
      child: Container(
        margin: containerMargin,
        padding: containerPadding,
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: borderRadius,
        ),
        child: Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(color: textColor, fontSize: 16.0),
            ),
            if (message.artifacts != null && message.artifacts!.isNotEmpty)
              ...message.artifacts!.map((artifact) {
                return _buildArtifactCard(artifact, currentLanguage);
              }).toList(),
            if (message.funFact != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  message.funFact!,
                  style: TextStyle(
                      color: textColor.withValues(alpha: 0.8),
                      fontSize: 13.0,
                      fontStyle: FontStyle.italic),
                ),
              ),
            if (message.followUp != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  message.followUp!,
                  style: TextStyle(
                      color: textColor.withValues(alpha: 0.8), fontSize: 13.0),
                ),
              ),
            if (message.suggestions != null && message.suggestions!.isNotEmpty)
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: message.suggestions!
                    .map((suggestion) => ActionChip(
                          label: Text(suggestion),
                          onPressed: () {
                            context
                                .read<ChatCubit>()
                                .sendSuggestion(suggestion);
                          },
                        ))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildArtifactCard(
      Map<String, dynamic> artifact, String currentLanguage) {
    return Card(
      margin: const EdgeInsets.only(top: 8.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (artifact['image_url'] != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Image.network(
                    'http://3.120.134.154:5000${artifact['image_url']}', // Your Lightsail IP
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.broken_image, size: 100),
                  ),
                ),
              ),
            Text(
              currentLanguage == 'en'
                  ? 'Name: ${artifact['name']}'
                  : 'الاسم: ${artifact['name']}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              currentLanguage == 'en'
                  ? 'Description: ${artifact['description']}'
                  : 'الوصف: ${artifact['description']}',
            ),
            Text(
              currentLanguage == 'en'
                  ? 'Material: ${artifact['material']}'
                  : 'المادة: ${artifact['material']}',
            ),
            Text(
              currentLanguage == 'en'
                  ? 'Gallery No.: ${artifact['location']}'
                  : 'رقم المعرض: ${artifact['location']}',
            ),
          ],
        ),
      ),
    );
  }
}
