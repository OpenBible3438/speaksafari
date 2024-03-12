import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:speak_safari/src/service/theme_service.dart';
import 'package:speak_safari/src/view/main/chat_list/chat_list_view_model.dart';
import 'package:speak_safari/src/view/main/chat_list/chat_room/chat_message_widget.dart';

class ChatRoomPage extends StatefulWidget {
  const ChatRoomPage({super.key, this.chatDto});

   final ChatDto? chatDto;

  @override
  State<ChatRoomPage> createState() => _ChatroomState();
}

/// 스피킹 목록, 새로운 커스텀 대화, 토픽에서 진입
/// ChatDTO를 외부로부터 받는다(프롬프트 상황 설정 데이터)
/// 기존 대화내역도 받을 때가 있다(파이어베이스 조회)
/// 기존 대화내역이 있다면 이것도 제미나이한테 보낸다
/// 대화가 끝날때마다 파이어스토어에 저장한다
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
  bool isRepeat = false;

  bool isSetting = false;
  bool isSpeechRateSetting = false;
  bool isIntervalOpen = false;

  double isInterval = 0.0;
  double _currentSliderValue = 0.5;
  late final GenerativeModel _model;
  late final ChatSession _chatSession;

  static const _apiKey = const String.fromEnvironment("API_KEY");

  @override
  void initState() {
    super.initState();
    tts.setSpeechRate(_currentSliderValue);
    tts.setLanguage("en");
    // en-US
    _model = GenerativeModel(model: "gemini-pro", apiKey: _apiKey, );




    _chatSession = _model.startChat();
    sendfirstMessage();
  }

  void setSpeechRate(double ma) {
    tts.setSpeechRate(ma);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         title: AnimatedTextKit(
            animatedTexts : [ ColorizeAnimatedText(
              'Gemini',
              textStyle: TextStyle(
                fontFamily: "soyo_maple",
                // The color must be set to white for this to work
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 40,
              ),
                colors: [
                 Colors.red,
                  Colors.blue,
                  Colors.green,
                ],
              ),
              ],
            isRepeatingAnimation: true,
            ),
        ),
      body: Container(
        color : context.color.tertiary,
        child: Column(
            children: [

              Expanded(
                child: Stack(
                  children: [
                    ListView.builder(
                      itemBuilder: ((context, index) {
                        final content = _chatSession.history.toList()[index];
                        final text = content.parts
                            .whereType<TextPart>()
                            .map((part) => part.text)
                            .join();

                        final fs = _model.generateContentStream(
                            _chatSession.history.toList(),
                        );

                        print("------------------------");
                        fs.map((event) =>
                            print("text 확인 ${event.text}")
                        );
                        print("------------------------");


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
                    if(!isFloating)
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(30.0),
                                child: IconButton.filled(
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
                              ),
                            ],
                          ),
                        ],
                      ),
                    if (isLoading && isFloating) LinearProgressIndicator(
                      color: Colors.blue,
                      backgroundColor: Colors.transparent,
                    ),
                    if(isFloating)
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
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
                                        isSetting = false;
                                        isSpeechRateSetting = false;
                                      });
                                    },
                                    icon: const Icon(Icons.close),
                                  ),
                                  if(!isSetting)
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

                                  if(isSetting)
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        IconButton.filled(
                                          style: ButtonStyle(
                                            backgroundColor: MaterialStateProperty.all(Colors.green),
                                            iconColor: MaterialStateProperty.all(Colors.white),
                                          ),
                                          onPressed: () {
                                                setState(() {
                                                  if(isSpeechRateSetting){
                                                    isSpeechRateSetting = false;
                                                  } else {
                                                    isSpeechRateSetting = true;
                                                  }
                                                });
                                          },
                                          icon: const Icon(Icons.speed),
                                        ),

                                        if(isSpeechRateSetting)setSliderWidget(context),

                                        if(!isSpeechRateSetting)
                                        IconButton.filled(
                                          style: ButtonStyle(
                                            backgroundColor: MaterialStateProperty.all(isRepeat ? Colors.green : Colors.grey),
                                            iconColor: MaterialStateProperty.all(Colors.white),
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              if(isRepeat){
                                                isRepeat = false;
                                              } else {
                                                isRepeat = true;
                                              }
                                            });
                                          },
                                          icon: Icon(Icons.repeat,
                                          ),
                                        ),
                                        if(isRepeat && !isSpeechRateSetting && !isIntervalOpen)
                                          IconButton.filled(
                                            style: ButtonStyle(
                                              backgroundColor: MaterialStateProperty.all(Colors.green),
                                              iconColor: MaterialStateProperty.all(Colors.white),
                                            ),
                                            onPressed: () {
                                              if(isIntervalOpen){
                                                isIntervalOpen = false;
                                              } else {
                                                isIntervalOpen = true;
                                              }
                                            },
                                            icon: const Icon(Icons.straighten),
                                          ),
                                        // if(isIntervalOpen)


                                      ],
                                    ),
                                  ),
                                 settingIcon()
                                ],
                              ),
                            ),
                          ),
                          ),
                        ],
                      ),
                  ],
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

  Slider setSliderWidget(BuildContext context) {
    return Slider(
        value: _currentSliderValue,
        max: 2,
        activeColor: context.color.secondary,
        thumbColor: context.color.tertiary,
        label: _currentSliderValue.round().toString(),
        onChanged: (double value) {
          setState(() {
            _currentSliderValue = value;
            setSpeechRate(_currentSliderValue);
          });
        }
    );
  }

  void setInterval() {
    IconButton.filled(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.green),
        iconColor: MaterialStateProperty.all(Colors.white),
      ),
      onPressed: () {
        if(isIntervalOpen){
          isIntervalOpen = false;
        } else {
          isIntervalOpen = true;
        }
      },
      icon: const Icon(Icons.exposure_minus_1),
    );

    IconButton.filled(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.green),
        iconColor: MaterialStateProperty.all(Colors.white),
      ),
      onPressed: () {
        if(isIntervalOpen){
          isIntervalOpen = false;
        } else {
          isIntervalOpen = true;
        }
      },
      icon: const Icon(Icons.straighten),
    );

  }

  Padding settingIcon() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: IconButton.filled(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.green),
          iconColor: MaterialStateProperty.all(Colors.white),
        ),
        onPressed: () {
          setState(() {
            if(!isSetting){
              isSetting = true;
            } else {
              isSetting = false;
            }
          }
          );
        },
        icon: Icon(isSetting ? Icons.fast_forward : Icons.settings),
      ),
    );
  }



  Future<void> sendfirstMessage() async {

    //     '유효한 필드는 채팅 시간, 대화 내용, 번역 내용, 너의 역할, 나의 역할 입니다.채팅 시간은 현재 시간, 대화 내용은 너는 할 말을 영어로 해 , 너의 역할은 너는 입국 심사원, 나의 역할은 여행자, 번역 내용 은 한국어로 출력,'
    //         ' 입력 형태: {"chat_time": " 현재시간을 이러한 형태로 만들어서 넣어줘 '
    // '(2013/10/11 09:00)", "chat_content": "여권을 분실했어요", "ai_role" : "입국 심사관", "user_role" : "여행자", "chat_trans" : "번역 내용"}.'
    //
    //         '출력 형태: {"chat_time": " 현재시간을 이러한 형태로 만들어서 넣어줘 '
    //         '(2013/10/11 09:00)", "chat_content": "(너가 할말을 영어로)", "ai_role" : "입국 심사관", "user_role" : "여행자", "chat_trans" : "번역 내용"}.'
    //     '   상황극: 여행자가 입국하기 위해 입국 심사관과 대화하는 장면이고 너는 입국 심사원인데 '
    //     '"chat_content"'
    //     ' 의 내용을 보고 다음 상황에 어울리는 말 하나를 출력하고 Json 형태로 보내줘출력:'
    var sendMs = Content.text(

        '유효한 필드는 채팅 시간, 대화 내용,나의 말, 번역 내용, 너의 역할, 나의 역할 입니다.채팅 시간은 현재 시간, 대화 내용은 너는 할 말을 영어로 해 , 너의 역할은 너는 입국 심사원, 나의 역할은 여행자, 번역 내용 은 한국어로 출력,'
            '출력 형태: {"chat_time": " 현재시간을 이러한 형태로 만들어서 넣어줘 '
            '(2013/10/11 09:00)","user_chat_content" : "hello", "chat_content": "(너가 할말을 영어로)", "ai_role" : "${widget.chatDto?.aIRole}", "user_role" : "${widget.chatDto?.usrRole}", "chat_trans" : "번역 내용"}.'
            '   상황극: ${widget.chatDto?.chatNm} '
            '"user_chat_content"'
            ' 의 내용을 보고 다음 상황에 어울리는 말 하나를 chat_content 에 출력하고 Json 형태로 보내줘출력:'
    );


    final response = await _chatSession.sendMessage(sendMs);


    setState(() {
      isLoading = true;
      chatbotHistory.add(sendMs.toString());
      _textController.clear();
    });

    _scrollToBottom();
    _focusNode.requestFocus();

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        isLoading = false;
        chatbotHistory.add('I am a chatbot');
      });

      _scrollToBottom();
      _focusNode.requestFocus();
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

    final response = await _chatSession.sendMessage(Content.text(


        '유효한 필드는 채팅 시간, 대화 내용,나의 말, 번역 내용, 너의 역할, 나의 역할 입니다.채팅 시간은 현재 시간, 대화 내용은 너는 할 말을 영어로 해 , 너의 역할은 너는 입국 심사원, 나의 역할은 여행자, 번역 내용 은 한국어로 출력,'
            '출력 형태: {"chat_time": " 현재시간을 이러한 형태로 만들어서 넣어줘 '
            '(2013/10/11 09:00)","user_chat_content" : "$value", "chat_content": "(너가 할말을 영어로)", "ai_role" : "${widget.chatDto?.aIRole}", "user_role" : "${widget.chatDto?.usrRole}", "chat_trans" : "번역 내용"}.'
            '   상황극: ${widget.chatDto?.chatNm} '
            '"user_chat_content"'
            ' 의 내용을 보고 다음 상황에 어울리는 말 하나를 출력하고 Json 형태로 보내줘출력:'



    ));


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
