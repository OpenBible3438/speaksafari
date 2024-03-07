
import 'package:flutter/cupertino.dart';
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

    // TODO: implement build
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [

        Padding(
          padding: EdgeInsets.only(
              left: width  * 0.1
          ),
          child: Row(
            children: [
              const Text("내 진도 상태"),
            ],
          ),
        ),
        const CardComponent(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      AssetIcon("plus"),
                      Text("일"),
                    ],
                  ),
                  Column(
                    children: [
                      AssetIcon("minus"),
                      Text("월"),
                    ],
                  ),
                  Column(
                    children: [
                      AssetIcon("plus"),
                      Text("화"),
                    ],
                  ),
                  Column(
                    children: [
                      AssetIcon("star", color: Colors.red,),
                      Text("수"),
                    ],
                  ),
                  Column(
                    children: [
                      AssetIcon("star", color: Colors.red,),
                      Text("목"),
                    ],
                  ),
                  Column(
                    children: [
                      AssetIcon("star", color: Colors.red,),
                      Text("금"),
                    ],
                  ),
                  Column(
                    children: [
                      AssetIcon("star", color: Colors.red,),
                      Text("토"),
                    ],
                  ),

                ],
              )
            ],
          )
        ),
        Padding(
          padding: EdgeInsets.only(
              top : 10.0, left: width  * 0.1
          ),
          child:  Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
               Text("Today word ",
              style: AppTypo(typo: const NotoSans(), fontColor: Colors.black).headline2
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
                    Text("desolate", style: AppTypo(typo: const NotoSans(), fontColor: Colors.white).headline3,
                    ),
                    Text("황량한, 적막한",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: NotoSans().semiBold,
                        fontFamily: NotoSans().name,
                        fontSize: 14.0,
                      )
                    ),
                  ],
                ),
                            ),
              ),



            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding:  EdgeInsets.only(
                    left: 10, right: width * 0.1
                  ),
                  child: const SmallHorCardComponent(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              AssetIcon("check", color: Colors.redAccent,),
                              Padding(
                                padding: EdgeInsets.only( left : 8.0),
                                child: Text("단어 퀴즈",
                                  style: TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w500
                                  ),
                                ),
                              ),

                            ],
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text("5",
                                style: TextStyle(
                                fontSize: 18.0,
                                    fontWeight: FontWeight.w700
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only( right : 8.0),
                                child: Text("일 연속 적중",
                                  style: TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w500
                                  ),
                                ),
                              ),
                              AssetIcon("sunny", color : Colors.redAccent),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      left: 10, right: width * 0.1
                  ),
                  child: const SmallHorCardComponent(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              AssetIcon("check", color: Colors.redAccent,),
                              Padding(
                                padding: EdgeInsets.only( left : 8.0),
                                child: Text("HighestRank",
                                  style: TextStyle(
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.w700
                                  ),
                                ),
                              ),

                            ],
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Spacer(flex: 2,),

                              Text("64",
                                style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w700
                                ),
                              ),
                              Text("%",
                                style: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w500
                                ),
                              ),
                              Spacer(flex: 1,),

                              AssetIcon("basket"),
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

      ],
    );
  }
}