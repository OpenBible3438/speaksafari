import 'package:flutter/material.dart';
import 'package:speak_safari/src/service/theme_service.dart';
import 'package:speak_safari/theme/component/button/button.dart';
import 'package:speak_safari/theme/component/card/card.dart';

class WordQuizPage extends StatelessWidget {
  const WordQuizPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      //mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        CardComponent(
          child: Column(
            children: [
              const Spacer(),
              const Text(
                '"아슬아슬했어"',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black,
                  ),
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
        const SizedBox(height: 20),
        Column(
          children: [
            Button(
              text: "close call",
              backgroundColor: context.color.tertiary,
              width: MediaQuery.of(context).size.width * 0.8,
              onPressed: () {},
            ),
            const SizedBox(height: 10),
            Button(
              text: "apple",
              backgroundColor: context.color.tertiary,
              width: MediaQuery.of(context).size.width * 0.8,
              onPressed: () {},
            ),
            const SizedBox(height: 10),
            Button(
              text: "google",
              backgroundColor: context.color.tertiary,
              width: MediaQuery.of(context).size.width * 0.8,
              onPressed: () {},
            ),
          ],
        ),
      ],
    );
  }
}
