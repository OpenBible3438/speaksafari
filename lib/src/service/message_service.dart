import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:speak_safari/src/data/message_dto.dart';

class MessageService {
  Future<void> saveMessage(String chatNm, MessageDto messageDto) async {
    FirebaseFirestore _firestore = FirebaseFirestore.instance;

    _firestore.collection("chat_history").doc("${chatNm}${DateTime.now()}").set(
      {
        "chat_content": messageDto.chatContent,
        "chat_speaker": messageDto.chatSpeaker,
        "chat_time": "${DateTime.now()}",
        "chat_trans": messageDto.chatTrans,
        "chat_uid": messageDto.chatUid,
      },
    );
  }

  Future<List<MessageDto>> getMessages(String chatUid) async {
    FirebaseFirestore _firestore = FirebaseFirestore.instance;

    QuerySnapshot<Map<String, dynamic>> _snapshot = await _firestore
        .collection("chat_history")
        .where("chat_uid", isEqualTo: chatUid)
        .get();

    return _snapshot.docs.map((e) => MessageDto.fromJson(e.data())).toList();
  }
}
