import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
        chatNm: '공항 입국심사에서 인터뷰',
        chatCtt: 'Content 1',
        aIRole: '입국심사관',
        usrRole: '입국여행자',
        chatCtgr: 'topics',
        chatUid:  "${FirebaseAuth.instance.currentUser?.email}${DateTime.now()}",
          usrEmail: FirebaseAuth.instance.currentUser?.email
      ),
      ChatDto(
        chatNm: '제과점에서 계산하기',
        chatCtt: 'Content 2',
        aIRole: '캐셔',
        usrRole: '손님',
        chatCtgr: 'topics',
          chatUid:  "${FirebaseAuth.instance.currentUser?.email}${DateTime.now()}",
          usrEmail: FirebaseAuth.instance.currentUser?.email
      ),
      ChatDto(
        chatNm: '서울 코엑스에서 행인에게 길물어보기',
        chatCtt: 'Content 3',
        aIRole: 'AI Role 3',
        usrRole: 'User Role 3',
        chatCtgr: 'topics', chatUid:  "${FirebaseAuth.instance.currentUser?.email}${DateTime.now()}",
          usrEmail: FirebaseAuth.instance.currentUser?.email
      ),
      ChatDto(
        chatNm: '고객센터에 버스정류장 분실물 신고',
        chatCtt: 'Content 4',
        aIRole: 'AI Role 1',
        usrRole: 'User Role 2',
        chatCtgr: 'topics',
          chatUid:  "${FirebaseAuth.instance.currentUser?.email}${DateTime.now()}",
          usrEmail: FirebaseAuth.instance.currentUser?.email
      ),
      ChatDto(
        chatNm: '편의점',
        chatCtt: 'Content 5',
        aIRole: 'AI Role 2',
        usrRole: 'User Role 3',
        chatCtgr: 'topics',
          chatUid:  "${FirebaseAuth.instance.currentUser?.email}${DateTime.now()}",
          usrEmail: FirebaseAuth.instance.currentUser?.email
      ),
      // 나머지 ChatDto 5개를 여기에 추가해주세요
    ];



    topicsChatList = mockDataList;

  }


  Future<void> createFirestore(ChatDto chatDto) async {
    FirebaseFirestore _firestore = FirebaseFirestore.instance;

    _firestore.collection("chat").doc("${FirebaseAuth.instance.currentUser?.email}${DateTime.now()}").set(
      {
        "ai_role": chatDto.aIRole,
        "chat_nm": chatDto.chatNm,
        "chat_uid": "${FirebaseAuth.instance.currentUser?.email}${DateTime.now()}",
        "usr_email": FirebaseAuth.instance.currentUser?.email,
        "usr_role" : chatDto.usrRole,
      } ,);

  }

  Future<List<ChatDto>> fromFirestore() async {
    FirebaseFirestore _firestore = FirebaseFirestore.instance;

    QuerySnapshot<Map<String, dynamic>> _snapshot =
    await _firestore.collection("chat").where("usr_email", isEqualTo: FirebaseAuth.instance.currentUser?.email ) .get();

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
  String? chatUid;
  String? chatNm;
  String? chatCtt;
  String? aIRole;
  String? usrRole;
  String? chatCtgr;
  String? usrEmail;

  ChatDto(
      {this.chatNm, this.chatCtt, this.aIRole, this.usrRole, this.chatCtgr, this.chatUid, this.usrEmail});

  factory ChatDto.fromJson(Map<String, dynamic> json) {
    return ChatDto(
      chatNm: json['chat_nm'],
      chatCtt: json['chat_ctt'],
      aIRole: json['ai_role'],
      usrRole: json['usr_role'],
      chatCtgr: json['chat_ctgr'],
      chatUid: json['chat_uid'],
      usrEmail: json['usr_email'],
    );
  }

}

class TabInfo {
  String title;
  bool isActive;

  TabInfo({required this.title, this.isActive = false});
}
