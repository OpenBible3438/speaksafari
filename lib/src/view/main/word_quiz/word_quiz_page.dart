import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:speak_safari/src/service/theme_service.dart';
import 'package:speak_safari/src/view/main/word_quiz/word_quiz_view_model.dart';
import 'package:speak_safari/theme/component/button/button.dart';
import 'package:speak_safari/theme/component/card/card.dart';

class WordQuizPage extends StatefulWidget {
  const WordQuizPage({
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _WordQuizPageState();
}

class _WordQuizPageState extends State<WordQuizPage> {
  late Future<List<String>>? getWordQuizFuture;
  late WordQuizViewModel viewModel;
  int todayWordRate = 0;

  late final GenerativeModel _model =
      GenerativeModel(model: "gemini-pro", apiKey: _apiKey);
  static const _apiKey = String.fromEnvironment("API_KEY");

  Future<List<String>> getWordQuiz() async {
    List<String> responseData = [];

    try {
      final content = [
        Content.text('''
  영어 단어 1개와 단어 형태를 변형하지 않은 예문 1개 그리고 영단어와 유사한 뜻을 가진 유사 단어 2개를 알려주고 아래 양식으로 응답해.

  1. 영어 단어
  2. 예문
  3. 예문 한국어 번역
  4. 유사단어 1
  5. 유사단어 2''')
      ];
      final response = await _model.generateContent(content);
      responseData = splitResponseIntoList(response.text!);
    } catch (e) {
      debugPrint('Fail to getWordQuiz $e');
    }
    return responseData;
  }

  @override
  void initState() {
    super.initState();
    getWordQuizFuture = getWordQuiz();

    viewModel = WordQuizViewModel();
    _fetchTodayWordRate();
  }

  void reloadData() {
    Future.delayed(Duration.zero, () {
      setState(() {
        getWordQuizFuture = getWordQuiz();
      });
    });
  }

  // Quiz Count
  void _fetchTodayWordRate() async {
    int rate = await viewModel.getTodayWordRate();
    setState(() {
      todayWordRate = rate;
    });
  }

  void _updateTodayWordRate() async {
    todayWordRate += 1;
    await viewModel.updateTodayWordRate(todayWordRate);
  }

  // 영어 예문 공백 처리
  TextSpan addBlankInExample(String exampleString, String word) {
    const TextStyle textStyle =
        TextStyle(fontSize: 18, color: Colors.black, fontFamily: 'soyo_maple');
    const TextStyle highlightStyle = TextStyle(
      fontSize: 18,
      color: Colors.yellow,
      backgroundColor: Colors.yellow, // 배경색 적용
    );

    List<TextSpan> spans = [];
    try {
      String lowerExampleString = exampleString.toLowerCase();
      String lowerWord = word.toLowerCase();

      int index = lowerExampleString.indexOf(lowerWord);
      int lastIndex = index + word.length - 1;

      String frontString = exampleString.substring(0, index);
      String backString =
          exampleString.substring(lastIndex + 1, exampleString.length);

      spans.add(TextSpan(text: frontString, style: textStyle));
      spans.add(TextSpan(text: word, style: highlightStyle));
      spans.add(TextSpan(text: backString, style: textStyle));
    } catch (e) {
      debugPrint('Fail to addBlankInExample $e');
      debugPrint('reloadData');
      reloadData();
    }
    return TextSpan(children: spans);
  }

  // 정답 버튼 랜덤 섞기
  List<Widget> getButtons(String button1, String button2, String button3) {
    List<Widget> shuffledButtons = [
      createButton(button1, button1, true),
      createButton(button2, button1, false),
      createButton(button3, button1, false)
    ];
    shuffledButtons.shuffle(Random());

    List<Widget> buttonsWithSpaces = [];
    for (int i = 0; i < shuffledButtons.length; i++) {
      buttonsWithSpaces.add(shuffledButtons[i]);
      if (i < shuffledButtons.length - 1) {
        buttonsWithSpaces.add(const SizedBox(height: 10));
      }
    }
    return buttonsWithSpaces;
  }

  // 버튼 생성
  Widget createButton(
      String buttonString, String correctString, bool isCorrect) {
    return Button(
        text: buttonString,
        backgroundColor: context.color.tertiary,
        width: MediaQuery.of(context).size.width * 0.8,
        onPressed: () {
          showOverlay(context, true);
          _updateTodayWordRate();
          if (isCorrect) {
            // 정답 BottomSheet
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.green.withOpacity(0.5),
              builder: (BuildContext context) {
                return Container(
                  margin: const EdgeInsets.all(20),
                  height: 130,
                  child: Column(
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.check_circle_outline),
                          Text(
                            '정답!',
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Button(
                        text: '계속하기',
                        width: MediaQuery.of(context).size.width,
                        backgroundColor: Colors.green,
                        onPressed: () {
                          Navigator.pop(context);
                          _overlayEntry?.remove();
                          reloadData();
                        },
                      ),
                    ],
                  ),
                );
              },
              isDismissible: false,
            );
          } else {
            // 오답 BottomSheet
            showModalBottomSheet(
              backgroundColor: Colors.red.withOpacity(0.5),
              context: context,
              builder: (BuildContext context) {
                return Container(
                  margin: const EdgeInsets.all(20),
                  height: 150,
                  child: Column(
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.cancel_outlined),
                          Text(
                            '오답',
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Answer : $correctString',
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Button(
                        text: '계속하기',
                        width: MediaQuery.of(context).size.width,
                        backgroundColor: Colors.red,
                        onPressed: () {
                          Navigator.pop(context);
                          _overlayEntry?.remove();
                          reloadData();
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          }
        });
  }

  // 정답 & 오답 이미지 설정
  OverlayEntry? _overlayEntry;

  void showOverlay(BuildContext context, bool type) {
    String imagePath = 'assets/images/lion_x_image.png';
    if (type) {
      imagePath = 'assets/images/lion_o_image.png';
    }
    _overlayEntry = OverlayEntry(
      builder: (context) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image(
                  image: AssetImage(imagePath),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Overlay에 엔트리 추가
    Overlay.of(context).insert(_overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    if (todayWordRate > 9) {
      return const Scaffold(
        body: Center(
          child: Text('내일 봐요~'),
        ),
      );
    } else {
      return Scaffold(
        body: FutureBuilder<List<String>?>(
          future: getWordQuizFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: reloadData, // 재시도 버튼 클릭 시 reloadData 호출
                      child: const Text('재시도'),
                    ),
                  ],
                ),
              );
            } else if (snapshot.hasError) {
              debugPrint('Error : ${snapshot.error}');
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: reloadData, // 재시도 버튼 클릭 시 reloadData 호출
                      child: const Text('재시도'),
                    ),
                  ],
                ),
              );
            } else {
              return SafeArea(
                child: Column(
                  children: [
                    LinearProgressIndicator(
                      value: todayWordRate > 10 ? 1.0 : todayWordRate / 10,
                      color: context.color.tertiary,
                    ),
                    const SizedBox(height: 20),
                    CardComponent(
                      height: 200,
                      child: Column(
                        children: [
                          const Spacer(),
                          Container(
                            margin: const EdgeInsets.all(10),
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                ),
                                children: [
                                  addBlankInExample(
                                      snapshot.data![1], snapshot.data![0]),
                                ],
                              ),
                            ),
                          ),
                          Text(
                            snapshot.data![2],
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'soyo_maple',
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Column(
                      children: getButtons(snapshot.data![0], snapshot.data![3],
                          snapshot.data![4]),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      );
    }
  }
}

// AI 반환 String To List
List<String> splitResponseIntoList(String response) {
  response = response.replaceAll('*', '');
  response = response.replaceAll('예문', '');

  var regex = RegExp(r'\d+\.\s*\**');
  var matches = regex.allMatches(response);

  List<String> parts = [];
  int previousMatchEnd = 0;

  for (var match in matches) {
    if (previousMatchEnd != 0) {
      var part = response.substring(previousMatchEnd, match.start).trim();
      if (part.isNotEmpty) {
        parts.add(part);
      }
    }
    previousMatchEnd = match.end;
  }

  if (previousMatchEnd != 0 && previousMatchEnd < response.length) {
    parts.add(response.substring(previousMatchEnd).trim());
  }

  // 영어 이외 문자 제거
  parts[0] = parts[0].replaceAll(RegExp(r'[^A-Za-z\s]'), '');
  parts[3] = parts[3].replaceAll(RegExp(r'[^A-Za-z\s]'), '');
  parts[4] = parts[4].replaceAll(RegExp(r'[^A-Za-z\s]'), '');

  return parts;
}
