import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:speak_safari/theme/component/asset_icon.dart';
import 'package:speak_safari/theme/component/card/card.dart';
import 'package:speak_safari/theme/component/card/small_hor_card.dart';
import 'package:speak_safari/theme/component/card/vertical_card.dart';
import 'package:speak_safari/theme/foundation/app_theme.dart';
import 'package:speak_safari/theme/res/typo.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
  });

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
          padding: EdgeInsets.only( top : height * 0.1, left: width * 0.1),
          child:  Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              DefaultTextStyle(
                style: AppTypo(typo: const SoyoMaple(), fontColor: Colors.black, fontWeight: FontWeight.w600).headline3,
                child: AnimatedTextKit(
                  animatedTexts: [
                    WavyAnimatedText('Hello, Welcome'),
                    WavyAnimatedText('00000'),
                  ],
                  isRepeatingAnimation: false,
                  onTap: () {
                    print("Tap Event");
                  },
                ),
              ),
            ],
          ),
        ),
        const Spacer(flex: 1
          ,)
        ,
        Padding(
          padding: EdgeInsets.only(left: width * 0.1),
          child:  Row(
            children: [
              Text("내 진도 상태",
              style: AppTypo(typo: const SoyoMaple(), fontColor: Colors.black, fontWeight: FontWeight.w600).headline3
              ),
            ],
          ),
        ),
         CardComponent(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const AssetIcon("plus"),
                    Text("일",
                        style: AppTypo(typo: const SoyoMaple(), fontColor: Colors.black, fontWeight: FontWeight.w600).body2),
                  ],
                ),
                Column(
                  children: [
                    const AssetIcon("minus"),
                    Text("월",
                        style: AppTypo(typo: const SoyoMaple(), fontColor: Colors.black, fontWeight: FontWeight.w600).body2),
                  ],
                ),
                Column(
                  children: [
                    const AssetIcon("plus"),
                    Text("화",
                        style: AppTypo(typo: const SoyoMaple(), fontColor: Colors.black, fontWeight: FontWeight.w600).body2),
                  ],
                ),
                Column(
                  children: [
                    const AssetIcon(
                      "star",
                      color: Colors.red,
                    ),
                    Text("수",
                        style: AppTypo(typo: const SoyoMaple(), fontColor: Colors.black, fontWeight: FontWeight.w600).body2),
                  ],
                ),
                Column(
                  children: [
                    const AssetIcon(
                      "star",
                      color: Colors.red,
                    ),
                    Text("목",
                        style: AppTypo(typo: const SoyoMaple(), fontColor: Colors.black, fontWeight: FontWeight.w600).body2),
                  ],
                ),
                Column(
                  children: [
                    const AssetIcon(
                      "star",
                      color: Colors.red,
                    ),
                    Text("금",
                        style: AppTypo(typo: const SoyoMaple(), fontColor: Colors.black, fontWeight: FontWeight.w600).body2),
                  ],
                ),
                Column(
                  children: [
                    const AssetIcon(
                      "star",
                      color: Colors.red,
                    ),
                    Text("토",
                        style: AppTypo(typo: const SoyoMaple(), fontColor: Colors.black, fontWeight: FontWeight.w600).body2),
                  ],
                ),
              ],
            )
          ],
        )),
        const Spacer(flex: 1
          ,)
        ,
        Padding(
          padding: EdgeInsets.only( left: width * 0.1),
          child:  Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
               Text("Today word ",
              style: AppTypo(typo: const SoyoMaple(), fontColor: Colors.black, fontWeight: FontWeight.w600).headline3
               ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
              Padding(
                padding: EdgeInsets.only(
                    left :  width * 0.1 ),
                child:  VerticalCardComponent(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("desolate", style: AppTypo(typo: const SoyoMaple(), fontColor: Colors.white, fontWeight: FontWeight.w600).headline6
                    ),
                    Text(
                      "황량한, 적막한",
                      style: AppTypo(typo: const SoyoMaple(), fontColor: Colors.white, fontWeight: FontWeight.w600).body1
                    ),
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
                              const AssetIcon(
                                "check",
                                color: Colors.redAccent,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  "단어 퀴즈",
                                    style: AppTypo(typo: const SoyoMaple(),
                                    fontColor: Colors.black, fontWeight: FontWeight.w600).body1
                                    ),
                                ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                "5",
                                  style: AppTypo(typo: const SoyoMaple(),
                                      fontColor: Colors.black, fontWeight: FontWeight.w600).headline2
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Text(
                                  "일 연속 적중",
                                    style: AppTypo(typo: const SoyoMaple(),
                                        fontColor: Colors.black, fontWeight: FontWeight.w400).body1
                                ),
                              ),
                             const  AssetIcon("sunny", color : Colors.redAccent),
                            ],
                          ),
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
                              const AssetIcon(
                                "check",
                                color: Colors.redAccent,
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 8.0),
                                child: Text(
                                  "HighestRank",
                                    style: AppTypo(typo: const SoyoMaple(),
                                        fontColor: Colors.black, fontWeight: FontWeight.w600).subtitle1
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Spacer(
                                flex: 2,
                              ),
                              Text(
                                "64",
                                  style: AppTypo(typo: const SoyoMaple(),
                                      fontColor: Colors.black, fontWeight: FontWeight.w600).headline2
                              ),
                              Text(
                                "%",
                                  style: AppTypo(typo: const SoyoMaple(),
                                      fontColor: Colors.black, fontWeight: FontWeight.w600).body1
                              ),
                              const Spacer(
                                flex: 1,
                              ),
                              const AssetIcon("basket", color: Colors.blueAccent,),
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
        const Spacer(flex: 1
          ,)
        ,
        Padding(
          padding: EdgeInsets.only(left: width * 0.1),
          child:  Row(
            children: [
              Text("단어 Quiz",
                  style: AppTypo(typo: const SoyoMaple(), fontColor: Colors.black, fontWeight: FontWeight.w600).headline3
              ),
            ],
          ),
        ),
        CardComponent(
          child: Column(
            children: [
              const Spacer(),
              Text(
                '"아슬아슬했어"',
                  style: AppTypo(typo: const SoyoMaple(), fontColor: Colors.black, fontWeight: FontWeight.w600).body1
              ),
              RichText(
                text: TextSpan(
                    style: AppTypo(typo: const SoyoMaple(), fontColor: Colors.black, fontWeight: FontWeight.w600).body3,
                  children: [
                    const TextSpan(text: 'That was a '),
                    WidgetSpan(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.yellow,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          '                     ',
                          style: TextStyle(backgroundColor: Colors.transparent),
                        ),
                      ),
                    ),
                    const TextSpan(text: '. We almost hit that car!'),
                  ],
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
        const Spacer(flex: 1
          ,)
        ,

      ],
    );
  }
}
