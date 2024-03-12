import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:speak_safari/src/service/theme_service.dart';
import 'package:speak_safari/theme/foundation/app_theme.dart';
import 'package:speak_safari/theme/res/typo.dart';

class ChatMessageWidget extends StatelessWidget {
  const ChatMessageWidget({super.key, required this.isUserMessage, required this.message });

  final bool isUserMessage;
  final String message;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Row(
      mainAxisAlignment: isUserMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
            constraints: BoxConstraints(maxWidth: size.width * 0.7),
            decoration: BoxDecoration(
              color: isUserMessage ? context.color.primary : Color.fromRGBO(215, 215, 215, 1.0),
              borderRadius: isUserMessage ? const BorderRadius.only(topRight: Radius.circular(10), topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)) :
              const BorderRadius.only(topRight: Radius.circular(10), topLeft: Radius.circular(10), bottomRight: Radius.circular(10))
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child:
            MarkdownBody(data: message, selectable: true,)
        ),
        //    Text("${isUserMessage ? userMessage : message}", style: AppTypo(typo: const SoyoMaple(), fontColor: Colors.black).body1,)),


      ],
    );
  }
}