import 'package:flutter/material.dart';
import 'package:speak_safari/src/service/theme_service.dart';

class SmallHorCardComponent extends StatelessWidget {
  const SmallHorCardComponent({
    super.key,
    required this.child,
    this.padding,
    this.isRoundAll,
  });

  final Widget child;
  final EdgeInsets? padding;
  final bool? isRoundAll;

  @override
  Widget build(BuildContext context ) {
    return Container(
      child: SizedBox(
        height: 80,
        width: MediaQuery.of(context).size.width * 0.45,
        child: Card(
          shape: ContinuousRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
          elevation: 4.0,
          color: context.color.primary,
          child: child,
        ),
      ),
    );
  }
}
