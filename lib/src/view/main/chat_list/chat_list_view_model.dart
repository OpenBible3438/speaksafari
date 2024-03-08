import 'dart:math';

import 'package:speak_safari/src/service/chat_list_service.dart';
import 'package:speak_safari/src/view/base/base_view_model.dart';

class ChatListViewModel extends BaseViewModel {
  ChatListViewModel({
    required this.chatListService,
  });

  final ChatListService chatListService;

  List<TabInfo> tabs = [
    TabInfo(title: '스피킹 목록', isActive: true),
    TabInfo(title: 'Topics'),
  ];

  List<ChatDto> chatDtoList = [];
  List<ChatDto> cusTomChatList = [];
  List<ChatDto> topicsChatList = [];

  void selectTab(int index) {
    tabs.asMap().entries.forEach((entry) {
      entry.value.isActive = (entry.key == index);
    });
    if (tabs[0].isActive) {
      chatDtoList = cusTomChatList;
    } else {
      chatDtoList = topicsChatList;
    }
    notifyListeners();
  }

  Future<bool> getChatList(int currentPage) async {
    print("hi");
    try {
      print("asdf");
      return true;
    } catch (e) {
      print(e.toString());
      throw Exception('Failed to create post.');
    }
  }

  void generateMockData(int count) {
    List<ChatDto> mockDataList = [];

    // 무작위로 선택할 값들의 목록
    List<String> chatNames = [
      '공항 입국심사에서 인터뷰',
      '제과점에서 계산하기',
      '서울 코엑스에서 행인에게 길물어보기',
      '고객센터에 버스정류장 분실물 신고',
      '편의점'
    ];
    List<String> chatContents = [
      'Content 1',
      'Content 2',
      'Content 3',
      'Content 4',
      'Content 5',
    ];
    List<String> aiRoles = ['AI Role 1', 'AI Role 2', 'AI Role 3'];
    List<String> usrRoles = ['User Role 1', 'User Role 2', 'User Role 3'];
    List<String> chatCategories = ['topics', 'custom'];

    Random random = Random();

    for (int i = 0; i < count; i++) {
      ChatDto chatDto = ChatDto(
        chatNm: chatNames[random.nextInt(chatNames.length)],
        chatCtt: chatContents[random.nextInt(chatContents.length)],
        aIRole: aiRoles[random.nextInt(aiRoles.length)],
        usrRole: usrRoles[random.nextInt(usrRoles.length)],
        chatCtgr: chatCategories[random.nextInt(chatCategories.length)],
      );
      mockDataList.add(chatDto);
    }

    for (ChatDto item in mockDataList) {
      if (item.chatCtgr == 'custom') {
        cusTomChatList.add(item);
      } else if (item.chatCtgr == 'topics') {
        topicsChatList.add(item);
      }
    }
  }
}

class ChatDto {
  String? chatNm;
  String? chatCtt;
  String? aIRole;
  String? usrRole;
  String? chatCtgr;

  ChatDto(
      {this.chatNm, this.chatCtt, this.aIRole, this.usrRole, this.chatCtgr});
}

class TabInfo {
  String title;
  bool isActive;

  TabInfo({required this.title, this.isActive = false});
}
