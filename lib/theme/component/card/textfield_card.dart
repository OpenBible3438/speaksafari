import 'package:flutter/material.dart';
import 'package:speak_safari/theme/component/card/card.dart';
import 'package:speak_safari/theme/foundation/app_theme.dart';
import 'package:speak_safari/theme/res/typo.dart';

class TextFieldCard extends StatelessWidget {
  const TextFieldCard(
      {super.key,
      required this.titleLabel,
      required this.hintText,
      required this.controller});

  final String titleLabel;
  final String hintText;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return CardComponent(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
              width: 100,
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(8),
                child: Text(titleLabel,
                    style: AppTypo(
                            typo: const SoyoMaple(),
                            fontColor: Colors.black,
                            fontWeight: FontWeight.w600)
                        .body2),
              )),
          Expanded(
              child: TextField(
            controller: controller,
            style: AppTypo(
                    typo: const SoyoMaple(),
                    fontColor: Colors.black,
                    fontWeight: FontWeight.w600)
                .body2,
            decoration: InputDecoration(
              hintText: hintText,
              border: InputBorder.none,
              hintStyle: AppTypo(
                      typo: const SoyoMaple(),
                      fontColor: Colors.grey,
                      fontWeight: FontWeight.w600)
                  .body2,
            ),
          )),
        ],
      ),
    );
  }
}
