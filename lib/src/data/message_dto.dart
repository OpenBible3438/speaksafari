class MessageDto {
  String? chatContent;
  String? chatSpeaker;
  String? chatTime;
  String? chatTrans;
  String? chatUid;

  MessageDto(
      {this.chatContent, this.chatSpeaker, this.chatTime, this.chatTrans, this.chatUid});

  factory MessageDto.fromJson(Map<String, dynamic> json) {
    return MessageDto(
      chatContent: json['chat_content'],
      chatSpeaker: json['chat_speaker'],
      chatTime: json['chat_time'],
      chatTrans: json['chat_trans'],
      chatUid: json['chat_uid'],
    );
  }

}