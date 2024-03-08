import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speak_safari/src/service/chat_list_service.dart';
import 'package:speak_safari/src/service/theme_service.dart';
import 'package:speak_safari/src/view/main/chat_list/chat_list_view_model.dart';
import 'package:speak_safari/theme/component/card/card.dart';
import 'package:speak_safari/theme/foundation/app_theme.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({
    super.key,
  });

  @override
  State<ChatListPage> createState() => _ChatListPage();
}

class _ChatListPage extends State<ChatListPage> {
  int currentPage = 1;

  @override
  Widget build(BuildContext context) {
    return
        ChangeNotifierProvider(
          create: (context) {
            final provider =
                ChatListViewModel(chatListService: ChatListService());
            provider.generateMockData(20);
            if (provider.tabs[0].isActive) {
              provider.chatDtoList = provider.cusTomChatList;
            } else {
              provider.chatDtoList = provider.topicsChatList;
            }

            return provider;
          },
          child: Consumer<ChatListViewModel>(
              builder: (context, provider, child) => Scaffold(
                    backgroundColor: Color.fromARGB(255, 248, 248, 248),
                    floatingActionButton: FloatingActionButton(
                      onPressed: () {},
                      child: Icon(
                        Icons.edit,
                        color: Colors.white,
                      ),
                      backgroundColor: context.color.onTertiary,
                    ),
                    body: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: provider.tabs
                              .asMap()
                              .entries
                              .map(
                                (entry) => GestureDetector(
                                  onTap: () {
                                    provider.selectTab(entry.key);
                                  },
                                  child: Text(
                                    entry.value.title,
                                    style: TextStyle(
                                      fontSize: entry.value.isActive
                                          ? 20
                                          : 16, // 활성화된 탭은 글씨 크게
                                      fontWeight: entry.value.isActive
                                          ? FontWeight.bold
                                          : FontWeight.normal, // 활성화된 탭은 진하게
                                      color: entry.value.isActive
                                          ? Colors.black
                                          : Colors
                                              .grey, // 활성화된 탭은 검은색, 비활성화된 탭은 회색
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 20),
                          child: Container(),
                        ),
                        Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: provider.chatDtoList.length + 1,
                            itemBuilder: (BuildContext context, int index) {
                              if (index == provider.chatDtoList.length) {
                                currentPage++;
                                provider.getChatList(
                                    currentPage); // 스크롤 끝에 도달하면 새로운 아이템 로드
                              } else {
                                return Padding(
                                  padding: const EdgeInsets.all(0.5),
                                  child: Container(
                                    child: GestureDetector(
                                      onTap: () {
                                        // Navigator.of(context).push(
                                        //   MaterialPageRoute(
                                        //       builder: (context) =>
                                        //           ()),
                                        // );
                                      },
                                      child: CardComponent(
                                        child: Row(
                                          children: [
                                            Center(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Icon(Icons.chat_bubble),
                                              ),
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        provider
                                                                .chatDtoList[
                                                                    index]
                                                                .chatCtgr ??
                                                            '',
                                                        style: TextStyle(
                                                            fontSize: 13),
                                                      ),
                                                      Spacer(),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets.only(
                                                                right: 8),
                                                        child: Text(
                                                          'AI ${provider.chatDtoList[index].aIRole}' ??
                                                              '',
                                                          style: TextStyle(
                                                              fontSize: 10,
                                                              color: Colors.grey),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Text(
                                                    provider.chatDtoList[index]
                                                            .chatNm ??
                                                        '',
                                                    style:
                                                        TextStyle(fontSize: 13),
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets.only(
                                                                right: 8),
                                                        child: Text(
                                                          '나 ${provider.chatDtoList[index].usrRole}' ??
                                                              '',
                                                          style: TextStyle(
                                                              fontSize: 10,
                                                              color: Colors.grey),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  )));
    }
  }
}
BoxConstrains({required int minWidth, required int minHeight}) {}
