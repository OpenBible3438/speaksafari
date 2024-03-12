import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
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

  void generateMockData() {
    List<ChatDto> mockDataList = [
      ChatDto(
        // chat_: '공항 입국심사에서 인터뷰',
        chat_content: '공항 입국심사에서 인터뷰',
        ai_role: '입국심사관',
        user_role: '입국여행자',
        // chatCtgr: 'topics',
      ),
      ChatDto(
        // chat_: '공항 입국심사에서 인터뷰',
        chat_content: '공항 입국심사에서 인터뷰',
        ai_role: '입국심사관',
        user_role: '입국여행자',
        // chatCtgr: 'topics',
      ),
      ChatDto(
        // chat_: '공항 입국심사에서 인터뷰',
        chat_content: '공항 입국심사에서 인터뷰',
        ai_role: '입국심사관',
        user_role: '입국여행자',
        // chatCtgr: 'topics',
      ),
      ChatDto(
        // chat_: '공항 입국심사에서 인터뷰',
        chat_content: '공항 입국심사에서 인터뷰',
        ai_role: '입국심사관',
        user_role: '입국여행자',
        // chatCtgr: 'topics',
      ),
      ChatDto(
        // chat_: '공항 입국심사에서 인터뷰',
        chat_content: '공항 입국심사에서 인터뷰',
        ai_role: '입국심사관',
        user_role: '입국여행자',
        // chatCtgr: 'topics',
      )
      // ),
      // ChatDto(
      //   chatNm: '제과점에서 계산하기',
      //   chatCtt: 'Content 2',
      //   aIRole: 'AI Role 2',
      //   usrRole: 'User Role 2',
      //   chatCtgr: 'topics',
      // ),
      // ChatDto(
      //   chatNm: '서울 코엑스에서 행인에게 길물어보기',
      //   chatCtt: 'Content 3',
      //   aIRole: 'AI Role 3',
      //   usrRole: 'User Role 3',
      //   chatCtgr: 'topics',
      // ),
      // ChatDto(
      //   chatNm: '고객센터에 버스정류장 분실물 신고',
      //   chatCtt: 'Content 4',
      //   aIRole: 'AI Role 1',
      //   usrRole: 'User Role 2',
      //   chatCtgr: 'topics',
      // ),
      // ChatDto(
      //   chatNm: '편의점',
      //   chatCtt: 'Content 5',
      //   aIRole: 'AI Role 2',
      //   usrRole: 'User Role 3',
      //   chatCtgr: 'topics',
      // ),
      // 나머지 ChatDto 5개를 여기에 추가해주세요
    ];



        topicsChatList = mockDataList;

  }



  Future<List<ChatDto>> fromFirestore() async {
    FirebaseFirestore _firestore = FirebaseFirestore.instance;

    /// 대화내역 저장
    // _firestore.collection("chat").doc("123456789").set(
    //   {
    //     "brand": "Genesis",
    //     "name": "G70",
    //     "price": 5000,
    //   },);

    /// 대화내역 몽땅 불러오기
    QuerySnapshot<Map<String, dynamic>> _snapshot =
    await _firestore.collection("chat").get();

    _snapshot.docs.forEach((doc) {
      print(doc.data());
    });

    print(_snapshot);
    List<ChatDto> _result =
    _snapshot.docs.map((e) => ChatDto.fromJson(e.data())).toList();
    print(_result);
    cusTomChatList = _result;

    notifyListeners();

    return _result;
  }



}

class ChatDto {
  String? chat_time;
  String? user_chat_content;
  String? chat_content;
  String? ai_role;
  String? user_role;
  String? chat_trans;

  ChatDto(
      {this.chat_time, this.user_chat_content, this.chat_content, this.ai_role, this.user_role, this.chat_trans});

  factory ChatDto.fromJson(Map<String, dynamic> json) {
    return ChatDto(
      chat_time: json['user_chat_content'],
      user_chat_content: json['user_chat_content'],
      chat_content: json['chat_content'],
      ai_role: json['ai_role'],
      user_role: json['user_role'],
      chat_trans: json['chat_trans'],
    );
  }

}

class TabInfo {
  String title;
  bool isActive;

  TabInfo({required this.title, this.isActive = false});
}
