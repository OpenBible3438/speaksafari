import 'package:flutter/material.dart';
 
import 'package:speak_safari/src/service/theme_service.dart';

class VerticalCardComponent extends  StatelessWidget {
  const VerticalCardComponent({
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
    return  Container(
      child: SizedBox(
        height: 160,
        width: MediaQuery.of(context).size.width * 0.3,
        child: Card(
          shape: ContinuousRectangleBorder(
            borderRadius:
            BorderRadius.circular(25.0),
          ),
          elevation: 4.0,
          color:  context.color.tertiary,
          child: child,
        ),
      ),
    );
  }
}
