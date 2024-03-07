import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speak_safari/src/service/theme_service.dart';

class CardComponent extends ConsumerWidget {
  const CardComponent({
    super.key,
    required this.child,
    this.padding,
    this.isRoundAll,
  });

  final Widget child;
  final EdgeInsets? padding;
  final bool? isRoundAll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return  Container(
      child: SizedBox(
        height: 80,
        width: MediaQuery.of(context).size.width * 0.8,
        child: Card(
          shape: ContinuousRectangleBorder(
            borderRadius:
            BorderRadius.circular(25.0),
          ),
          elevation: 4.0,
          color: ref.context.color.primary,
          child: child,
        ),
      ),
    );
  }
}