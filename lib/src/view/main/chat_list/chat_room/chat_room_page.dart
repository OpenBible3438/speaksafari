import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:speak_safari/src/service/theme_service.dart';
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
  bool isFloating = false;

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
              fontWeight: FontWeight.w600,
              fontSize: 40,
            ),
          ),
        ),
      ),
      body: Container(
        color : context.color.tertiary,
        child: Column(
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

              if(!isFloating)
                Hero(tag: "textField", child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton.filled(
                        onPressed: () {
                          setState(() {
                            isFloating = true;
                          });
                        },
                        iconSize: MediaQuery
                            .of(context)
                            .size
                            .width * 0.1,
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                              context.color.primary),
                          iconColor: MaterialStateProperty.all(Colors.green),
                        ),
                        icon: const Icon(Icons.send_rounded,
                        ),
                      ),
                    ],
                  ),
                ),
                ),
              if (isLoading && isFloating) LinearProgressIndicator(
                color: context.color.primary,
                backgroundColor: context.color.primary.withAlpha(20),
              ),
              if(isFloating)
                Hero(tag: "textField", child:
                  Container(
                    decoration: const ShapeDecoration(shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40.0),topRight: Radius.circular(40.0),
                      ),
                      ),
                      color: Colors.white,
                    ),

                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        children: [
                          IconButton.filled(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(Colors.white),
                              iconColor: MaterialStateProperty.all(Colors.black),
                              elevation: MaterialStateProperty.all(5),
                            ),
                            onPressed: () {
                              setState(() {
                                isFloating = false;

                              });
                             },
                            icon: const Icon(Icons.close),
                          ),


                             Expanded(child: TextField(

                                  controller: _textController,
                                  focusNode: _focusNode,
                                  onSubmitted: (value) {
                                    if (!isLoading) {
                                      _sendMessage(value);
                                    }
                                  },
                                  decoration: InputDecoration(
                                    filled: true, //<-- SEE HERE
                                    fillColor: Colors.green.withAlpha(90), //<-- SEE HERE
                                    suffixIcon: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: IconButton.filled(
                                        style: ButtonStyle(
                                          backgroundColor: MaterialStateProperty.all(Colors.green),
                                          iconColor: MaterialStateProperty.all(Colors.white),
                                        ),
                                        onPressed: isLoading? null:() {
                                          if (!isLoading) {
                                            _sendMessage(_textController.text);
                                            }
                                          },
                                          icon: const Icon(Icons.send),
                                        ),
                                    ),
                                      enabledBorder: const OutlineInputBorder(
                                          borderRadius:  BorderRadius.all(Radius.circular(40.0)),
                                          borderSide: BorderSide(
                                          color: Colors.white,
                                          style : BorderStyle.none
                                          )
                                      ),
                                      disabledBorder : const OutlineInputBorder(
                                          borderRadius:  BorderRadius.all(Radius.circular(40.0)),
                                          borderSide: BorderSide(
                                              color: Colors.white,
                                              style : BorderStyle.none
                                          )
                                      ),
                                      focusedBorder: const OutlineInputBorder(
                                        borderRadius:  BorderRadius.all(Radius.circular(40.0)),
                                            borderSide: BorderSide(
                                            color: Colors.white,
                                            style : BorderStyle.none
                                          )
                                      ),
                                      border: const OutlineInputBorder(
                                      borderRadius:  BorderRadius.all(Radius.circular(40.0)),
                                        borderSide: BorderSide(
                                          color: Colors.white,
                                            style : BorderStyle.none
                                        )

                                    ),
                                    labelText: '메세지 입력',
                                  ),
                              ),
                             ),
                          IconButton.filled(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(Colors.green),
                              iconColor: MaterialStateProperty.all(Colors.white),
                            ),
                            onPressed: isLoading? null:() {
                              if (!isLoading) {
                                _sendMessage(_textController.text);
                              }
                            },
                            icon: const Icon(Icons.settings),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
        ),
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
