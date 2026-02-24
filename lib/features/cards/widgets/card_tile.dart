import 'package:flutter/material.dart';
import 'package:neomoney/core/ui/theme/app_colors.dart';
import 'package:neomoney/features/cards/data/hepler/helper.dart';
import 'package:neomoney/features/cards/data/models/card_model.dart';

class CardTile extends StatelessWidget {
  final CardModel model;
  const CardTile({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    final asset = getCardTypeAsset(model.cardNumber);

    final isPrimary = model.autoDebiting == 1;
    final numberColor = isPrimary ? Colors.white : AppColors.primary;

    final decoration = isPrimary
        ? BoxDecoration(
      color: const Color(0xFF00B140),
      borderRadius: BorderRadius.circular(22),
    )
        : BoxDecoration(
      borderRadius: BorderRadius.circular(22),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFEFF7FF), Color(0xFFDDEEFF)],
      ),
    );

    return Container(
      height: 182,
      padding: const EdgeInsets.all(18),
      decoration: decoration,
      child: Stack(
        children: [
          if (asset.isNotEmpty)
            Align(
              alignment: Alignment.topRight,
              child: Image.asset(asset, height: 34, fit: BoxFit.contain),
            ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatCardMasked(model.cardNumber),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: numberColor,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}