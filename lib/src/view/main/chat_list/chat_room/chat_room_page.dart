import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:speak_safari/src/view/main/chat_list/chat_room/chat_message_widget.dart';

class ChatRoomPage extends StatefulWidget {
  const ChatRoomPage({super.key});

  @override
  State<ChatRoomPage> createState() => _ChatroomState();
}

class _ChatroomState extends State<ChatRoomPage> {
  List<String> chatbotHistory = [
    'Hi there!',
    'How can I assist you today?',
    'Sure, I can help with that!',
    'Here is the information you requested.',
    'Hi there!',
    'How can I assist you today?',
    'Sure, I can help with that!',
    'Here is the information you requested.',
    'Hi there!',
    'How can I assist you today?',
    'Sure, I can help with that!',
    'Here is the information you requested.',
  ];
  final FlutterTts tts = FlutterTts();

  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  bool isLoading = false;

  late final GenerativeModel _model;
  late final ChatSession _chatSession;

  static const _apiKey = const String.fromEnvironment("API_KEY");

  @override
  void initState() {
    super.initState();
    tts.setSpeechRate(0.5);
    tts.setLanguage("en");
    // en-US
    _model = GenerativeModel(model: "gemini-pro", apiKey: _apiKey);
    _chatSession = _model.startChat();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue, Colors.red],
            tileMode: TileMode.mirror,
          ).createShader(bounds),
          child: const Text(
            'Gemini',
            style: TextStyle(
              fontFamily: "soyo_maple",
              // The color must be set to white for this to work
              color: Colors.white,
              fontSize: 40,
            ),
          ),
        ),
      ),
      body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemBuilder: ((context, index) {
                  final content = _chatSession.history.toList()[index];
                  final text = content.parts
                      .whereType<TextPart>()
                      .map((part) => part.text)
                      .join();

                  return InkWell(
                    onTap: (){
                        tts.speak(text);
                    },
                    child: ChatMessageWidget(
                        message: text,
                        isUserMessage: content.role == 'user',
                    ),
                  );
                }),
                itemCount: _chatSession.history.length,
                controller: _scrollController,
              ),
            ),
            if (isLoading) const LinearProgressIndicator(),
            Row(
              children: [
                   Expanded(child: TextField(
                        controller: _textController,
                        focusNode: _focusNode,
                        onSubmitted: (value) {
                          if (!isLoading) {
                            _sendMessage(value);
                          }

                          tts.speak("TTS Test");
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Type a message',
                        ),
                   ),
                   ),
                IconButton(
                  onPressed: isLoading? null:() {
                    if (!isLoading) {
                      _sendMessage(_textController.text);

                    }

                  },
                  icon: const Icon(Icons.send),
                ),


              ],
            ),
          ],
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeOutCirc,
      );
    });
  }

  Future<void> _sendMessage(String value) async {
    if (value.isEmpty) {
      return;
    }

    setState(() {
      isLoading = true;
      _textController.clear();
    });
    _scrollToBottom();

    final response = await _chatSession.sendMessage(Content.text(value));


    setState(() {
      isLoading = false;
    });

    _scrollToBottom();
    _focusNode.requestFocus();


    setState(() {
      isLoading = true;
      chatbotHistory.add(value);
      _textController.clear();
    });
    _scrollToBottom();

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        isLoading = false;
        chatbotHistory.add('I am a chatbot');
      });

      _scrollToBottom();
      _focusNode.requestFocus();
    });
  }
}
