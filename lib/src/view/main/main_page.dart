import 'package:flutter/material.dart';
import 'package:speak_safari/src/view/main/chat_list/chat_list_page.dart';
import 'package:speak_safari/src/view/main/home/home_page.dart';
import 'package:speak_safari/src/view/main/word_quiz/word_quiz_page.dart';

class MainPage extends StatefulWidget {



   MainPage( {
    super.key
  });

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  /* Bottom Tab Bar */
  int _selectedIndex = 0; // 현재 선택된 탭의 인덱스

  _MainPageState(
      // this._selectedIndex
      );

  final List<String> _appBarTitle = ['Home', 'Chat', '단어 퀴즈'];

  // 각 탭에 해당하는 위젯 리스트
  static const List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    ChatListPage(),
    WordQuizPage(),
  ];
  // 탭 선택 시 호출되는 함수
  void _onItemTapped(int index) {
    setState(
      () {
        _selectedIndex = index; // 선택된 탭의 인덱스를 업데이트
        // context.read<ProjectProvider>().resetMyProjects(); // 프로젝트 탭 초기화
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_note),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.featured_play_list_rounded),
            label: 'Quiz',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blueGrey, // 선택된 아이템의 색상
        unselectedItemColor: Colors.grey, // 선택되지 않은 아이템의 색상
      ),
    );
  }
}
