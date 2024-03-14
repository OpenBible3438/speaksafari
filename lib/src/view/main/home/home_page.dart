import 'dart:convert';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:speak_safari/src/service/theme_service.dart';
import 'package:speak_safari/src/view/main/home/home_view_model.dart';
import 'package:speak_safari/src/view/main/word_quiz/word_quiz_view_model.dart';
import 'package:speak_safari/theme/component/card/card.dart';
import 'package:speak_safari/theme/component/card/small_hor_card.dart';
import 'package:speak_safari/theme/component/card/vertical_card.dart';
import 'package:speak_safari/theme/foundation/app_theme.dart';
import 'package:speak_safari/theme/res/typo.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // 단어퀴즈
  late WordQuizViewModel wordQuizViewModel;
  int todayWordRate = 0;

  // 진도 상태
  late HomeViewModel homeViewModel;
  List<WeeklyDto> weeklyList = [];

  // Rank
  String myRank = '';

  late Future<String>? getWordFuture;

  late final GenerativeModel _model =
      GenerativeModel(model: "gemini-pro", apiKey: _apiKey);
  static const _apiKey = String.fromEnvironment("API_KEY");

  Future<String> getWord() async {
    String responseData = "";

    try {
      final content = [
        Content.text('유효한 필드는 영어 문장, 한글 해석, 인물 이고 1개의 문장만 필요해 '
            '출력 형태: {"eng_word": "~~", "kor_word" : "~~", "person" : "~~ "} '
            '~~은 명언을 작성해 Json 형태로 보내줘')
      ];
      final response = await _model.generateContent(content);
      responseData = response.text ?? "";
    } catch (e) {
      debugPrint('Fail to getWord $e');
    }
    return responseData;
  }

  @override
  void initState() {
    super.initState();
    getWordFuture = getWord();

    // 단어 퀴즈
    wordQuizViewModel = WordQuizViewModel();
    _fetchTodayWordRate();

    // 진도 상태
    homeViewModel = HomeViewModel();
    _fetchWeeklyStudyStatus();
  }

  void reloadData() {
    Future.delayed(Duration.zero, () {
      setState(() {
        getWordFuture = getWord();
      });
    });
  }

  // 단어 퀴즈
  void _fetchTodayWordRate() async {
    int rate = await wordQuizViewModel.getTodayWordRate();
    setState(() {
      todayWordRate = rate;
    });
  }

  // 진도 상태
  void _fetchWeeklyStudyStatus() async {
    List<WeeklyDto> list = await homeViewModel.getWeeklyStudyStatus();
    int weeklyRank = await homeViewModel.getMyWeeklyRank();
    setState(() {
      weeklyList = list;
      myRank = weeklyRank.toString();
    });
  }

  Widget wordCardComponent(jsons) {
    return CardComponent(
      height: 180,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: RichText(
                text: TextSpan(
                  style: AppTypo(
                          typo: const SoyoMaple(),
                          fontColor: Colors.black,
                          fontWeight: FontWeight.w600)
                      .body2,
                  children: [
                    TextSpan(text: '${jsons['eng_word']}'),
                    TextSpan(text: '\n${jsons['kor_word']}'),
                  ],
                ),
              ),
            ),
          ),
          Text('- ${jsons['person']} -',
              style: AppTypo(
                      typo: const SoyoMaple(),
                      fontColor: Colors.black,
                      fontWeight: FontWeight.w600)
                  .body1),
        ],
      ),
    );
  }

  // 단어 퀴즈 Row Widget
  Widget setTodayWordRateWidget() {
    if (todayWordRate > 9) {
      // 10개 모두 끝냈을 때
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Text("오늘 단어 퀴즈 완료!",
                style: AppTypo(
                        typo: const SoyoMaple(),
                        fontColor: Colors.black,
                        fontWeight: FontWeight.w400)
                    .body1),
          ),
        ],
      );
    } else {
      // 단어 퀴즈 남았을 때
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('$todayWordRate / 10',
              style: AppTypo(
                      typo: const SoyoMaple(),
                      fontColor: Colors.black,
                      fontWeight: FontWeight.w600)
                  .headline5),
          const SizedBox(width: 10),
          Text("진행중!",
              style: AppTypo(
                      typo: const SoyoMaple(),
                      fontColor: Colors.black,
                      fontWeight: FontWeight.w400)
                  .body1),
        ],
      );
    }
  }

  // 진도 상태 Widget
  List<Widget> setWeeklyStudyStatusWidget(BuildContext context) {
    return weeklyList.map((day) {
      IconData iconData;
      if (day.isFuture) {
        iconData = Icons.pets;
      } else {
        iconData = day.studied ? Icons.done : Icons.close;
        if (day.isAllQuiz) {
          iconData = Icons.thumb_up;
        }
      }
      return Column(
        children: [
          Icon(
            iconData,
            color: day.isFuture
                ? Colors.grey
                : (day.studied ? context.color.tertiary : Colors.red),
          ),
          Text(
            day.day,
            style: AppTypo(
                    typo: const SoyoMaple(),
                    fontColor: Colors.black,
                    fontWeight: FontWeight.w600)
                .body1,
          ),
          Text(
            day.date,
            style: AppTypo(
                    typo: const SoyoMaple(),
                    fontColor: Colors.black,
                    fontWeight: FontWeight.w600)
                .body3,
          ),
        ],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    // TODO: implement build
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(top: height * 0.1, left: width * 0.1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              DefaultTextStyle(
                style: AppTypo(
                        typo: const SoyoMaple(),
                        fontColor: Colors.black,
                        fontWeight: FontWeight.w600)
                    .headline3,
                child: AnimatedTextKit(
                  animatedTexts: [
                    WavyAnimatedText('Hello, Welcome'),
                    WavyAnimatedText(
                        '${FirebaseAuth.instance.currentUser?.email}'),
                  ],
                  isRepeatingAnimation: false,
                  onTap: () {
                    print("Go To MyPage");
                  },
                ),
              ),
            ],
          ),
        ),
        const Spacer(
          flex: 1,
        ),
        Padding(
          padding: EdgeInsets.only(left: width * 0.1),
          child: Row(
            children: [
              Text("오늘의 명언",
                  style: AppTypo(
                          typo: const SoyoMaple(),
                          fontColor: Colors.black,
                          fontWeight: FontWeight.w600)
                      .headline3),
            ],
          ),
        ),
        FutureBuilder<String>(
          future: getWordFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CardComponent(
                  child: Center(child: CircularProgressIndicator()));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              var jsons = jsonDecode(
                  '{"eng_word": "The only thing we have to fear is fear itself.", "kor_word" : "우리가 두려워해야 할 유일한 것은 두려움 그 자체이다.", "person" : "Franklin D. Roosevelt"}');
              return wordCardComponent(jsons);
            } else if (snapshot.hasError) {
              debugPrint('Error : ${snapshot.error}');
              var jsons = jsonDecode(
                  '{"eng_word": "The only thing we have to fear is fear itself.", "kor_word" : "우리가 두려워해야 할 유일한 것은 두려움 그 자체이다.", "person" : "Franklin D. Roosevelt"}');

              return wordCardComponent(jsons);
            } else {
              var jsons = jsonDecode(snapshot.data ??
                  '{"eng_word": "The only thing we have to fear is fear itself.", "kor_word" : "우리가 두려워해야 할 유일한 것은 두려움 그 자체이다.", "person" : "Franklin D. Roosevelt"}');
              return wordCardComponent(jsons);
            }
          },
        ),
        const Spacer(
          flex: 1,
        ),
        Padding(
          padding: EdgeInsets.only(left: width * 0.1),
          child: Row(
            children: [
              Text("내 진도 상태",
                  style: AppTypo(
                          typo: const SoyoMaple(),
                          fontColor: Colors.black,
                          fontWeight: FontWeight.w600)
                      .headline3),
            ],
          ),
        ),
        InkWell(
          child: CardComponent(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: setWeeklyStudyStatusWidget(context),
                )
              ],
            ),
          ),
        ),
        const Spacer(
          flex: 1,
        ),
        Stack(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: width * 0.1),
                  child: Text("Today word ",
                      style: AppTypo(
                              typo: const SoyoMaple(),
                              fontColor: Colors.black,
                              fontWeight: FontWeight.w600)
                          .headline3),
                ),
              ],
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(left: width * 0.1),
              child: VerticalCardComponent(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("desolate",
                        style: AppTypo(
                                typo: const SoyoMaple(),
                                fontColor: Colors.white,
                                fontWeight: FontWeight.w600)
                            .headline6),
                    Text("황량한, 적막한",
                        style: AppTypo(
                                typo: const SoyoMaple(),
                                fontColor: Colors.white,
                                fontWeight: FontWeight.w600)
                            .body1),
                  ],
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 10, right: width * 0.1),
                  child: SmallHorCardComponent(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.local_library,
                                color: Colors.redAccent,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text("단어 퀴즈",
                                    style: AppTypo(
                                            typo: const SoyoMaple(),
                                            fontColor: Colors.black,
                                            fontWeight: FontWeight.w600)
                                        .body1),
                              ),
                            ],
                          ),
                          setTodayWordRateWidget(), // 단어 퀴즈 Widget 적용
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10, right: width * 0.1),
                  child: SmallHorCardComponent(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: Image.asset(
                                  'assets/icons/rankimage.png',
                                  color: Colors.blue,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text("HighestRank",
                                    style: AppTypo(
                                            typo: const SoyoMaple(),
                                            fontColor: Colors.black,
                                            fontWeight: FontWeight.w600)
                                        .subtitle2),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Spacer(
                                flex: 2,
                              ),
                              Text(myRank,
                                  style: AppTypo(
                                          typo: const SoyoMaple(),
                                          fontColor: Colors.black,
                                          fontWeight: FontWeight.w600)
                                      .headline2),
                              Text("등",
                                  style: AppTypo(
                                          typo: const SoyoMaple(),
                                          fontColor: Colors.black,
                                          fontWeight: FontWeight.w600)
                                      .body1),
                              const Spacer(
                                flex: 1,
                              ),
                              const Icon(
                                Icons.sentiment_satisfied_alt,
                                color: Colors.black,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
        const Spacer(
          flex: 1,
        ),
      ],
    );
  }
}
