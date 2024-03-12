import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:speak_safari/src/service/theme_service.dart';
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
  }

  void reloadData() {
    setState(() {
      getWordQuizFuture = getWordQuiz();
    });
  }

  // Quiz Count
  int _counter = 1;

  void _quizCounter() {
    setState(() {
      if (_counter == 10) {
        _counter = 0;
      }
      _counter++;
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
                  const Text('API ERROR'),
                  ElevatedButton(
                    onPressed: reloadData, // 재시도 버튼 클릭 시 reloadData 호출
                    child: const Text('데이터 재시도'),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error : ${snapshot.error}'));
          } else {
            return SafeArea(
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: _counter > 10 ? 1.0 : _counter / 10,
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
                                TextSpan(text: snapshot.data![1]),
                                WidgetSpan(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.yellow,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Text(
                                      '        공백처리             ',
                                      style: TextStyle(
                                          backgroundColor: Colors.transparent),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Text(
                          snapshot.data![2],
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Column(
                    children: [
                      Button(
                        text: snapshot.data![0],
                        backgroundColor: context.color.tertiary,
                        width: MediaQuery.of(context).size.width * 0.8,
                        onPressed: () {
                          showOverlay(context, true);
                          _quizCounter();

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
                                        // const Spacer(),
                                        // IconButton(
                                        //   onPressed: () {
                                        //     Navigator.pop(context);
                                        //     _overlayEntry?.remove();
                                        //   },
                                        //   icon: const Icon(Icons.close),
                                        // ),
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
                                        setState(() {
                                          getWordQuizFuture = getWordQuiz();
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                            isDismissible: false,
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      Button(
                        text: snapshot.data![3],
                        backgroundColor: context.color.tertiary,
                        width: MediaQuery.of(context).size.width * 0.8,
                        onPressed: () {
                          showOverlay(context, false);
                          _quizCounter();

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
                                        // const Spacer(),
                                        // IconButton(
                                        //   onPressed: () {
                                        //     Navigator.pop(context);
                                        //     _overlayEntry?.remove();
                                        //   },
                                        //   icon: const Icon(Icons.close),
                                        // ),
                                      ],
                                    ),
                                    const Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'Answer : close call',
                                        style: TextStyle(fontSize: 20),
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
                        },
                      ),
                      const SizedBox(height: 10),
                      Button(
                        text: snapshot.data![4],
                        backgroundColor: context.color.tertiary,
                        width: MediaQuery.of(context).size.width * 0.8,
                        onPressed: () {},
                      ),
                    ],
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

List<String> splitResponseIntoList(String response) {
  response = response.replaceAll('*', '');

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

  return parts;
}
