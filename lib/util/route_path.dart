import 'package:flutter/material.dart';
import 'package:speak_safari/src/view/login/login_page.dart';
import 'package:speak_safari/src/view/main/chat_list/chat_room/chat_room_page.dart';
import 'package:speak_safari/src/view/main/chat_list/new_chat_page.dart';
import 'package:speak_safari/src/view/main/main_page.dart';
import 'package:speak_safari/theme/component/constrained_screen.dart';

abstract class RoutePath {
  static const String main = 'main';
  static const String login = 'login';
  static const String chatroom = 'chatroom';
  static const String newchat = 'newchat';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    late final Widget page;
    switch (settings.name) {
      case RoutePath.main:
        page = const MainPage();
        break;
      case RoutePath.login:
        page = const LoginPage();
        break;
      case RoutePath.chatroom:
        page = const ChatRoomPage();
        break;
      case RoutePath.newchat:
        page = const NewChatPage();
        break;
    }

    return MaterialPageRoute(
      builder: (context) => ConstrainedScreen(child: page),
    );
  }
}
