import 'dart:convert';
import 'dart:io';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:speak_safari/src/data/message_dto.dart';
import 'package:speak_safari/src/service/message_service.dart';
import 'package:speak_safari/src/service/theme_service.dart';
import 'package:speak_safari/src/view/main/chat_list/chat_list_view_model.dart';
import 'package:speak_safari/src/view/main/chat_list/chat_room/chat_message_widget.dart';
import 'package:speak_safari/theme/foundation/app_theme.dart';
import 'package:speak_safari/theme/res/typo.dart';
import 'package:speak_safari/util/route_path.dart';

class ChatRoomPage extends StatefulWidget {
  const ChatRoomPage({super.key, this.chatDto});

  final ChatDto? chatDto;

  @override
  State<ChatRoomPage> createState() => _ChatroomState();
}

class _ChatroomState extends State<ChatRoomPage> {
  final MessageService service = MessageService();
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

  double _currentSliderValue = 0.5;
  int isInterval = 1;

  late bool isError = false;

  late final GenerativeModel _model;
  late final ChatSession _chatSession;

  bool isChatSessionLoading = true;

  List<MessageDto> allMessages = [];


  static const _apiKey = const String.fromEnvironment("API_KEY");

  @override
  void initState() {
    super.initState();
    tts.setSpeechRate(_currentSliderValue);
    tts.setLanguage("en");

    if (widget.chatDto?.chatUid == null) return;
    service.getMessages(widget.chatDto?.chatUid ?? '').then((response) {
      setState(() {
        allMessages = response;
      });

      if (allMessages.isEmpty) {
        _startFirstChat();
      } else {
        _startContinuedChat();
      }

      setState(() {
        isChatSessionLoading = false;
      });
    });
  }

  void _startFirstChat() {
    _model = GenerativeModel(
        model: "gemini-pro",
        apiKey: _apiKey,
        generationConfig: GenerationConfig(topK: 1, topP: 1));
    _chatSession = _model.startChat();
    _sendMessage("자 이제부터 영어로 대화하자");
  }

  void _startContinuedChat() {
    _model = GenerativeModel(
        model: 'gemini-pro',
        apiKey: _apiKey,
        generationConfig: GenerationConfig(maxOutputTokens: 1000));
    // Initialize the chat
    List<Content> contents = [];

    while (allMessages.isNotEmpty && allMessages.last.chatSpeaker == "me") {
      allMessages.removeLast();
    }

    int currentIndex = 0;
    while (currentIndex < allMessages.length - 1) {
      if (allMessages[currentIndex].chatSpeaker == "me" &&
          allMessages[currentIndex + 1].chatSpeaker == "me") {
        allMessages.removeAt(currentIndex);
      } else {
        currentIndex++;
      }
    }

    allMessages.forEach((element) {
      if (element.chatSpeaker == "me") {
        contents.add(Content.text(element.chatContent ?? "me의 오류 메세지"));
      } else {
        contents.add(Content.model([
          TextPart("${element.chatContent} \n한글 번역 : ${element.chatTrans}" ??
              "ai의 오류 메세지")
        ]));
      }
    });

    _chatSession = _model.startChat(history: contents);
  }

  void setSpeechRate(double ma) {
    tts.setSpeechRate(ma);
  }

  void reloadData () {
    setState(() {
      isError = false;
    });


  }

  @override
  Widget build(BuildContext context) {
    if (isChatSessionLoading == true) {
      // _chatSession이 초기화되지 않은 경우 로딩 상태를 표시하거나 초기화를 기다립니다.
      return const CircularProgressIndicator();
    } else if (isError == true) {
      return ElevatedButton(
        onPressed: reloadData, // 재시도 버튼 클릭 시 reloadData 호출
        child: const Text('재시도'),
      );
    } else {

      return Scaffold(
        appBar: AppBar(
          leading: IconButton(onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, RoutePath.main, (router) => false);

          }, icon: Icon(Icons.arrow_back)),
          title: AnimatedTextKit(
            animatedTexts: [
              ColorizeAnimatedText(
                'Gemini',
                textStyle: const TextStyle(
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
            isRepeatingAnimation: false,
          ),
        ),
        body: Container(
          color: context.color.tertiary,
          child: Column(
            children: [
              Expanded(
                child :

                 Stack(
                  children : [
                  ListView.builder(
                      itemBuilder: ((context, index) {
                        final content = _chatSession.history.toList()[index];
                        var speakText = "";
                        if (index == 0) {
                          return SizedBox.shrink();
                        }
                        final text =
                            content.parts.whereType<TextPart>().map((part) {
                          var jsonString = part.text;

                          if (allMessages.isEmpty) {
                            //새로운 대화일때

                            if (index % 2 == 1) {
                              Map<String, dynamic> user =
                                  jsonDecode(jsonString);
                              speakText = user['chat_content'];
                              return "${speakText} \n한글 번역 : ${user['chat_trans']}";
                            } else {
                              var first = jsonString.substring(
                                  jsonString.indexOf('{') - 1,
                                  jsonString.indexOf('}') + 1);
                              Map<String, dynamic> user = jsonDecode(first);
                              return user['user_chat_content'];
                            }
                          } else {
                            if (jsonString.startsWith('{')) {
                              Map<String, dynamic> user =
                                  jsonDecode(jsonString);
                              speakText = user['chat_content'];
                              return "${speakText} \n한글 번역 : ${user['chat_trans']}";
                            } else if (jsonString.startsWith('유효한')) {
                              var first = jsonString.substring(
                                  jsonString.indexOf('{') - 1,
                                  jsonString.indexOf('}') + 1);
                              Map<String, dynamic> user = jsonDecode(first);
                              return user['user_chat_content'];
                            }
                            //기존 대화 있을 때
                            int index = jsonString.indexOf("한글 번역");
                            if (index != -1) {
                              speakText = jsonString.substring(0, index).trim();
                            } else {}
                            return jsonString;
                          }

                          // return firstString;
                        }).join();

                        return InkWell(
                          onTap: () {
                            if (isRepeat) {
                              if (isInterval > 0) {
                                tts.setCompletionHandler(() {
                                  if (isRepeat) {
                                    sleep(Duration(seconds: isInterval));
                                    tts.speak(speakText);
                                  }
                                });
                                tts.speak(speakText);
                              }
                            } else {
                              tts.speak(speakText);
                            }
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
                      if (isLoading)
                      const LinearProgressIndicator(
                      color: Colors.blue,
                      backgroundColor: Colors.transparent,
                      ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Hero(
                    tag: "textField",
                    child: Container(
                      decoration: const ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(40.0),
                            topRight: Radius.circular(40.0),
                          ),
                        ),
                        color: Colors.white,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 20, top: 10, bottom: 10, right: 10),
                        child: Row(
                          children: [
                            if (!isSetting)
                              Expanded(
                                child: TextField(
                                  controller: _textController,
                                  focusNode: _focusNode,
                                  onSubmitted: (value) {
                                    if (!isLoading) {
                                      _sendMessage(value);
                                    }
                                  },
                                  decoration: InputDecoration(
                                    filled: true,
                                    //<-- SEE HERE
                                    fillColor: Colors.green.withAlpha(90),
                                    //<-- SEE HERE
                                    suffixIcon: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: IconButton.filled(
                                        style: ButtonStyle(
                                          backgroundColor:
                                          MaterialStateProperty.all(
                                              Colors.green),
                                          iconColor:
                                          MaterialStateProperty.all(
                                              Colors.white),
                                        ),
                                        onPressed: isLoading
                                            ? null
                                            : () {
                                          if (!isLoading) {
                                            _sendMessage(
                                                _textController
                                                    .text);
                                          }
                                        },
                                        icon: const Icon(Icons.send),
                                      ),
                                    ),
                                    enabledBorder:
                                    const OutlineInputBorder(
                                        borderRadius:
                                        BorderRadius.all(
                                            Radius.circular(
                                                40.0)),
                                        borderSide: BorderSide(
                                            color: Colors.white,
                                            style: BorderStyle.none)),
                                    disabledBorder:
                                    const OutlineInputBorder(
                                        borderRadius:
                                        BorderRadius.all(
                                            Radius.circular(
                                                40.0)),
                                        borderSide: BorderSide(
                                            color: Colors.white,
                                            style: BorderStyle.none)),
                                    focusedBorder:
                                    const OutlineInputBorder(
                                        borderRadius:
                                        BorderRadius.all(
                                            Radius.circular(
                                                40.0)),
                                        borderSide: BorderSide(
                                            color: Colors.white,
                                            style: BorderStyle.none)),
                                    border: const OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(40.0)),
                                        borderSide: BorderSide(
                                            color: Colors.white,
                                            style: BorderStyle.none)),
                                    labelText: '메세지 입력',
                                    floatingLabelBehavior:
                                    FloatingLabelBehavior.never,
                                  ),
                                ),
                              ),
                            if (isSetting)
                              Expanded(
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceEvenly,
                                  children: [
                                    if (!isIntervalOpen)
                                      IconButton.filled(
                                        style: ButtonStyle(
                                          backgroundColor:
                                          MaterialStateProperty.all(
                                              Colors.green),
                                          iconColor:
                                          MaterialStateProperty.all(
                                              Colors.white),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            if (isSpeechRateSetting) {
                                              isSpeechRateSetting = false;
                                            } else {
                                              isSpeechRateSetting = true;
                                            }
                                          });
                                        },
                                        icon: const Icon(Icons.speed),
                                      ),

                                    if (isSpeechRateSetting &&
                                        !isIntervalOpen)
                                      setSliderWidget(context),

                                    if (!isSpeechRateSetting)
                                      IconButton.filled(
                                        style: ButtonStyle(
                                          backgroundColor:
                                          MaterialStateProperty.all(
                                              isRepeat
                                                  ? Colors.green
                                                  : Colors.grey),
                                          iconColor:
                                          MaterialStateProperty.all(
                                              Colors.white),
                                        ),
                                        onPressed: () async {
                                          setState(() {
                                            if (isRepeat) {
                                              isRepeat = false;
                                            } else {
                                              isRepeat = true;
                                            }
                                          });
                                        },
                                        icon: Icon(
                                          Icons.repeat,
                                        ),
                                      ),
                                    if (!isSpeechRateSetting)
                                      IconButton.filled(
                                        style: ButtonStyle(
                                          backgroundColor:
                                          MaterialStateProperty.all(
                                              isIntervalOpen
                                                  ? Colors.green
                                                  : Colors.grey),
                                          iconColor:
                                          MaterialStateProperty.all(
                                              Colors.white),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            if (isIntervalOpen) {
                                              isIntervalOpen = false;
                                            } else {
                                              isIntervalOpen = true;
                                            }
                                          });
                                        },
                                        icon:
                                        const Icon(Icons.straighten),
                                      ),
                                    // if(isIntervalOpen)
                                    if (isIntervalOpen)
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                        children: [
                                          IconButton(
                                            style: ButtonStyle(
                                              backgroundColor:
                                              MaterialStateProperty
                                                  .all(isInterval > 1
                                                  ? Colors.green
                                                  : Colors.grey),
                                              iconColor:
                                              MaterialStateProperty
                                                  .all(Colors.white),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                if (isInterval > 1) {
                                                  isInterval -= 1;
                                                }
                                              });
                                            },
                                            icon: const Icon(
                                                Icons.exposure_minus_1),
                                          ),
                                          Card(
                                            shape: const ContinuousRectangleBorder(
                                                borderRadius:
                                                BorderRadiusDirectional.only(
                                                    topEnd: Radius
                                                        .circular(5),
                                                    topStart: Radius
                                                        .circular(5),
                                                    bottomEnd: Radius
                                                        .circular(5),
                                                    bottomStart:
                                                    Radius
                                                        .circular(
                                                        5))),
                                            child: Padding(
                                              padding:
                                              const EdgeInsets.all(
                                                  8.0),
                                              child: Text("$isInterval",
                                                  style: AppTypo(
                                                      typo:
                                                      const SoyoMaple(),
                                                      fontColor:
                                                      Colors
                                                          .black,
                                                      fontWeight:
                                                      FontWeight
                                                          .w600)
                                                      .headline2),
                                            ),
                                          ),
                                          IconButton(
                                            style: ButtonStyle(
                                              backgroundColor:
                                              MaterialStateProperty
                                                  .all(isInterval < 10
                                                  ? Colors.green
                                                  : Colors.grey),
                                              iconColor:
                                              MaterialStateProperty
                                                  .all(Colors.white),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                if (isInterval < 10) {
                                                  isInterval += 1;
                                                }
                                              });
                                            },
                                            icon: const Icon(
                                                Icons.plus_one),
                                          ),
                                        ],
                                      ),
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
      );
    }
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

  AnimatedOpacity setSliderWidget(BuildContext context) {
    return AnimatedOpacity(
      duration: Duration(milliseconds: 500),
      opacity: 1.0,
      child: Slider(
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
          }),
    );
  }

  void setInterval() {
    IconButton.filled(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.green),
        iconColor: MaterialStateProperty.all(Colors.white),
      ),
      onPressed: () {
        if (isIntervalOpen) {
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
        if (isIntervalOpen) {
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
            if (!isSetting) {
              isSetting = true;
            } else {
              isSetting = false;
            }
          });
        },
        icon: Icon(isSetting ? Icons.close : Icons.settings),
      ),
    );
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


    try {
      final response = await _chatSession.sendMessage(Content.text(
          '유효한 필드는 채팅 시간, 주제, 대화 내용,나의 말, 번역 내용, 너의 역할, 나의 역할 입니다.채팅 시간은 현재 시간, 대화 내용은 너는 할 말을 영어로 해 ,상황은  ${widget
              .chatDto?.chatNm} 이고, 너의 역할은 "${widget.chatDto
              ?.aIRole}", 나의 역할은 ${widget.chatDto?.usrRole}, 번역 내용 은 한국어로 출력,'
              '출력 형태: {"chat_time": "현재시간을 이러한 형태로 만들어서 넣어줘'
              '(2013/10/11 09:00)","user_chat_content" : "$value", "chat_topic" : "${widget
              .chatDto
              ?.chatCtt}" ,"chat_content": "(너가 할말을 영어로)", "ai_role" : "${widget
              .chatDto?.aIRole}", "user_role" : "${widget.chatDto
              ?.usrRole}", "chat_trans" : "번역 내용"}.'
              '   상황극: ${widget.chatDto?.chatNm} '
              '"user_chat_content"'
              ' 의 내용을 보고 다음 상황에 어울리는 말 하나를 출력하고 Json 형태로 보내줘출력:'));



      var first = response.text?.startsWith("```");

    if (first ?? false) {
      var sfa = response.text;
      var second = sfa?.substring(
          sfa.indexOf('{'),
          sfa.indexOf('}') + 1);
      Map<String, dynamic> user = jsonDecode(second ?? "");

      print("-----------test");
      print(second);
      MessageDto messageDto = MessageDto();
      messageDto.chatUid = widget.chatDto?.chatUid;
      messageDto.chatSpeaker = "me";
      messageDto.chatContent = value;
      service.saveMessage(widget.chatDto?.chatNm ?? '', messageDto);


      MessageDto resMessageDto = MessageDto();
      resMessageDto.chatUid = widget.chatDto?.chatUid;
      resMessageDto.chatSpeaker = "ai";
      resMessageDto.chatContent = user['chat_content'];
      resMessageDto.chatTrans = user['chat_trans'];
      service.saveMessage(widget.chatDto?.chatNm ?? '', resMessageDto);
    } else {
      Map<String, dynamic> user = jsonDecode(response.text ?? '');

      MessageDto messageDto = MessageDto();
      messageDto.chatUid = widget.chatDto?.chatUid;
      messageDto.chatSpeaker = "me";
      messageDto.chatContent = value;
      service.saveMessage(widget.chatDto?.chatNm ?? '', messageDto);


      MessageDto resMessageDto = MessageDto();
      resMessageDto.chatUid = widget.chatDto?.chatUid;
      resMessageDto.chatSpeaker = "ai";
      resMessageDto.chatContent = user['chat_content'];
      resMessageDto.chatTrans = user['chat_trans'];
      service.saveMessage(widget.chatDto?.chatNm ?? '', resMessageDto);
    }
  } catch(e){
      print("===============");
        print("$e");
      setState(() {
    isError = true;
      });
    }

    setState(() {
      isLoading = false;
    });

    _scrollToBottom();
    _focusNode.requestFocus();

    setState(() {
      isLoading = true;
      _textController.clear();
    });
    _scrollToBottom();

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        isLoading = false;
      });

      _scrollToBottom();
      _focusNode.requestFocus();
    });
  }
}
