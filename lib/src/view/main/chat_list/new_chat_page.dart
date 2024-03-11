import 'package:flutter/material.dart';
import 'package:speak_safari/src/service/theme_service.dart';
import 'package:speak_safari/theme/component/button/button.dart';
import 'package:speak_safari/theme/component/card/textfield_card.dart';

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
              child: Column(
                children: [
                  TextFieldCard(
                    titleLabel: '제목',
                    hintText: '채팅방 제목을 입력하세요',
                    controller: titleController,
                  ),
                  SizedBox(height: 10), // 여기에 SizedBox를 추가
                  TextFieldCard(
                    titleLabel: '😊 나의 역할',
                    hintText: '입력하세요',
                    controller: myRoleController,
                  ),
                  SizedBox(height: 10), // 또 다른 SizedBox 추가
                  TextFieldCard(
                    titleLabel: '🤖 AI의 역할',
                    hintText: '입력하세요',
                    controller: aiRoleController,
                  ),
                  SizedBox(height: 10), // 마지막 TextFieldCard 사이에도 추가
                  TextFieldCard(
                    titleLabel: '🗣️ 대화 주제',
                    hintText: '입력하세요',
                    controller: subjectController,
                  ),
                  const SizedBox(height: 10),
                  Button(
                    text: "대화 시작하기",
                    backgroundColor: context.color.tertiary,
                    width: MediaQuery.of(context).size.width * 0.8,
                    onPressed: () {},
                  ),
                ],
              ),
            )));
  }
}
