import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speak_safari/src/service/chat_list_service.dart';
import 'package:speak_safari/src/service/theme_service.dart';
import 'package:speak_safari/src/view/main/chat_list/chat_list_view_model.dart';
import 'package:speak_safari/theme/component/card/card.dart';
import 'package:speak_safari/util/route_path.dart';
import 'package:speak_safari/theme/res/typo.dart';
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
  String emoticonsd = "😊💄🧛‍♂️🐶🐹🐳👍🤣🥳💕😍😘💋🤪🔥😇😈🥱🙄😮🙁😠👎";
  late List<int> emoticons = emoticonsd.runes.toList();

  /// 파이어베이스에서 채팅방 목록 불러오기

  @override
  Widget build(BuildContext context) {

    emoticons.shuffle();
    return ChangeNotifierProvider(
        create: (context) {
          final provider =
              ChatListViewModel(chatListService: ChatListService());
          provider.generateMockData();
          provider.fromFirestore().then((_) {
            if (provider.tabs[0].isActive) {
              provider.chatDtoList = provider.cusTomChatList;
            } else {
              provider.chatDtoList = provider.topicsChatList;
            }
          });

          return provider;
        },
        child: Consumer<ChatListViewModel>(
            builder: (context, provider, child) => Scaffold(

              backgroundColor: Color.fromARGB(255, 248, 248, 248),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(context,
                          RoutePath.newchat, (route) => false);
                },
                child: Icon(
                  Icons.edit,
                  color: Colors.white,
                ),
                backgroundColor: context.color.onTertiary,
              ),
              body: Column(
                children: [
                      SizedBox(
                        height: 80,
                      ),
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
                        padding: EdgeInsets.only(top: 5),
                        child: Container(),
                      ),
                      Container(
                        color: Colors.grey,
                        height: 0.5,
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 15),
                        child: Container(),
                      ),
                      Expanded(
                        child: provider.chatDtoList.isEmpty == true
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image(
                                        height: 200,
                                        image: AssetImage(
                                            'assets/images/cutylion.png')),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    Text('스피킹 목록이 없습니다. 대화를 시작해 보세요!'),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                itemCount: provider.chatDtoList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return Padding(
                                    padding: const EdgeInsets.all(0.5),
                                    child: Center(
                                      child: Container(
                                        child: GestureDetector(
                                          onTap: () {
                                            if (provider.chatDtoList[index]
                                                    .chatCtgr ==
                                                "topics") {
                                              print("탭탭탭메뉴");

                                              provider.createFirestore(
                                                  provider.chatDtoList[index]);
                                            }
                                            Navigator.pushNamed(
                                                context, RoutePath.chatroom,
                                                arguments: provider
                                                    .chatDtoList[index]);
                                            // provider.fromFirestore();
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                top: 10.0),
                                            child: CardComponent(
                                              child: Row(
                                                children: [
                                                  Center(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Icon(
                                                          IconData(
                                                            emoticons[index],
                                                            fontFamily:
                                                                'MaterialIcons',
                                                          ),
                                                          size: 50),
                                                    ),
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        provider
                                                                .chatDtoList[
                                                                    index]
                                                                .chatNm ??
                                                            '',
                                                        style: AppTypo(
                                                                typo:
                                                                    const SoyoMaple(),
                                                                fontColor:
                                                                    Colors
                                                                        .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600)
                                                            .body1,
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(top: 3.0),
                                                        child: Row(
                                                          children: [
                                                            SizedBox(
                                                              width : 100,
                                                              child: Card(
                                                                color: context
                                                                    .color
                                                                    .tertiary,
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          top: 4,
                                                                          bottom:
                                                                              4,
                                                                          left:
                                                                              5,
                                                                          right:
                                                                              5),
                                                                  child: Center(
                                                                    child: Text(
                                                                      "AI : ${provider.chatDtoList[index].aIRole}",
                                                                      overflow: TextOverflow.ellipsis,
                                                                      style: AppTypo(
                                                                              typo:
                                                                                  const SoyoMaple(),
                                                                              fontColor:
                                                                                  Colors.white,
                                                                              fontWeight: FontWeight.w600)
                                                                          .body3,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: 100,
                                                              child: Card(
                                                                color: context
                                                                    .color
                                                                    .tertiary,
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          top: 4,
                                                                          bottom:
                                                                              4,
                                                                          left:
                                                                              5,
                                                                          right:
                                                                              5),
                                                                  child: Center(
                                                                    child: Text(
                                                                      "YOU : ${provider.chatDtoList[index].usrRole}",
                                                                      overflow: TextOverflow.ellipsis,
                                                                      style: AppTypo(
                                                                              typo:
                                                                                  const SoyoMaple(),
                                                                              fontColor:
                                                                                  Colors.white,
                                                                              fontWeight: FontWeight.w600)
                                                                          .body3,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                      ),
                    ],
                  ),
                )));
  }
}
