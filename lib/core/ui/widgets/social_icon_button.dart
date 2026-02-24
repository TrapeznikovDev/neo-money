import 'package:flutter/material.dart';

class SocialIconButton extends StatelessWidget {
  final String iconAsset;
  final VoidCallback onTap;
  final double size;
  final EdgeInsets padding;

  const SocialIconButton({super.key, required this.iconAsset, required this.onTap, this.size = 64, this.padding = const EdgeInsets.all(12)});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(behavior: HitTestBehavior.opaque, onTap: onTap, child: Image.asset(iconAsset));
  }
}
