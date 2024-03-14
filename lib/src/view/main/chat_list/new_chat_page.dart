import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:speak_safari/src/service/theme_service.dart';
import 'package:speak_safari/src/view/main/chat_list/chat_list_view_model.dart';
import 'package:speak_safari/theme/component/button/button.dart';
import 'package:speak_safari/theme/component/card/textfield_card.dart';
import 'package:speak_safari/theme/foundation/app_theme.dart';
import 'package:speak_safari/theme/res/typo.dart';
import 'package:speak_safari/util/route_path.dart';

class NewChatPage extends StatefulWidget {
  const NewChatPage({super.key});

  @override
  State<NewChatPage> createState() => _NewChatPageState();
}

class _NewChatPageState extends State<NewChatPage> {
  late TextEditingController titleController; // 제목을 위한 컨트롤러
  late TextEditingController myRoleController;
  late TextEditingController aiRoleController;
  late TextEditingController subjectController;
  final _formKey = GlobalKey<FormState>(); // Form 상태를 관리하기 위한 키

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    myRoleController = TextEditingController();
    aiRoleController = TextEditingController();
    subjectController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          centerTitle: true,
          title: const Text('새로운 채팅 생성'),
        ),
        body: Container(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              // 스크롤 가능하게 만들기
              // padding: const EdgeInsets.all(16), // 전체적인 패딩
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('영어로 대화하고 싶은 상황을 입력하면\nAI와 대화할 수 있어요.',
                          textAlign: TextAlign.center,
                          style: AppTypo(
                                  typo: const SoyoMaple(),
                                  fontColor: Colors.black,
                                  fontWeight: FontWeight.w400)
                              .body2),
                    ),
                    TextFieldCard(
                      titleLabel: '제목',
                      hintText: '채팅방 제목을 입력하세요',
                      controller: titleController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '제목을 입력해주세요';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10), // 여기에 SizedBox를 추가
                    TextFieldCard(
                      titleLabel: '😊 나의 역할',
                      hintText: '입력하세요',
                      controller: myRoleController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '역할을 입력해주세요';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10), // 또 다른 SizedBox 추가
                    TextFieldCard(
                      titleLabel: '🤖 AI의 역할',
                      hintText: '입력하세요',
                      controller: aiRoleController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'AI의 역할을 입력해주세요';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10), // 마지막 TextFieldCard 사이에도 추가
                    TextFieldCard(
                      titleLabel: '🗣️ 대화 주제',
                      hintText: '입력하세요',
                      controller: subjectController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '대화 주제를 입력해주세요';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    Button(
                      text: "대화 시작하기",
                      backgroundColor: context.color.tertiary,
                      width: MediaQuery.of(context).size.width * 0.8,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          ChatDto newChatDto = ChatDto(
                              chatNm: titleController.text,
                              chatCtt: subjectController.text,
                              aIRole: aiRoleController.text,
                              usrRole: myRoleController.text,
                              chatCtgr: 'custom',
                              chatUid:
                                  "${FirebaseAuth.instance.currentUser?.email}${DateTime.now()}",
                              usrEmail:
                                  FirebaseAuth.instance.currentUser?.email);

                          createFirestore2(newChatDto);

                          Navigator.popAndPushNamed(context, RoutePath.chatroom,
                              arguments: newChatDto);
                        }
                      },
                    ),
                  ],
                ),
              ),
            )));
  }

  Future<void> createFirestore2(ChatDto chatDto) async {
    FirebaseFirestore _firestore = FirebaseFirestore.instance;

    _firestore
        .collection("chat")
        .doc("${FirebaseAuth.instance.currentUser?.email}${DateTime.now()}")
        .set(
      {
        "ai_role": chatDto.aIRole,
        "chat_nm": chatDto.chatNm,
        "chat_uid": chatDto.chatUid,
        "usr_email": FirebaseAuth.instance.currentUser?.email,
        "usr_role": chatDto.usrRole,
      },
    );
  }
}
