import 'package:flutter/material.dart';
import '../../theme/theme.dart';

class SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  const SkeletonBox({super.key, required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.colors.feedbackSkeleton,
        borderRadius: BorderRadius.circular(context.dimens.radiusSm),
      ),
    );
  }
}
