import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class Avatar extends StatelessWidget {
  final String letter;
  final double size;
  final Color? color;

  const Avatar({
    super.key,
    required this.letter,
    this.size = 42,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color ?? AppColors.peach,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Text(
        letter,
        style: TextStyle(
          fontSize: size * .36,
          fontWeight: FontWeight.w800,
          color: AppColors.primaryDark,
        ),
      ),
    );
  }
}
