import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speak_safari/src/view/base/base_view_model.dart';
import 'package:speak_safari/src/view/main/chat_list/chat_list_page.dart';
import 'package:speak_safari/src/view/main/home/home_page.dart';
import 'package:speak_safari/src/view/main/word_quiz/word_quiz_page.dart';

class MainPage<T extends BaseViewModel> extends StatefulWidget {
  const MainPage({
    super.key,
    required this.viewModel,
    required this.builder,
  });

  State<MainPage> createState() => _MainPageState();

  final T viewModel;
  final Widget Function(BuildContext context, T viewModel) builder;
}

class _MainPageState extends State<MainPage> {
  /* Bottom Tab Bar */
  int _selectedIndex = 0; // 현재 선택된 탭의 인덱스
  final List<String> _appBarTitle = ['홈', '게시판', '프로젝트'];

  // 각 탭에 해당하는 위젯 리스트
  static const List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    ChatListPage(),
    WordQuizPage(),
  ];
  // 탭 선택 시 호출되는 함수
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // 선택된 탭의 인덱스를 업데이트

      // context.read<ProjectProvider>().resetMyProjects(); // 프로젝트 탭 초기화
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => widget.viewModel,
      child: Consumer<Widget>(builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(_appBarTitle[_selectedIndex]),
            actions: [
              IconButton(
                onPressed: () {
                  debugPrint('giftcard');
                },
                icon: Icon(Icons.card_giftcard),
              ),
              IconButton(
                onPressed: () {
                  debugPrint('settings');
                },
                icon: Icon(Icons.settings),
              )
            ],
          ),
          body: Center(
            child: _widgetOptions.elementAt(_selectedIndex),
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: '홈',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.event_note),
                label: '게시판',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.featured_play_list_rounded),
                label: '프로젝트',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.people),
                label: '임직원',
              ),
            ],
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            selectedItemColor: Colors.blueGrey, // 선택된 아이템의 색상
            unselectedItemColor: Colors.grey, // 선택되지 않은 아이템의 색상
          ),
        );
      }),
    );
  }
}
