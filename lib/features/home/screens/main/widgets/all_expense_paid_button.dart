import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neomoney/core/ui/theme/app_colors.dart';

class AllExpensePaidButton extends StatelessWidget {
  const AllExpensePaidButton({
    super.key,
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: onTap,
      child: Ink(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.buttonColor,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.primary.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Я уже оплатил заём полностью',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: AppColors.primary
                ),
              ),
            ),
            SizedBox(width: 8),
            Icon(
              CupertinoIcons.arrow_right,
              size: 30,
              color: AppColors.primary,
            )
          ],
        ),
      ),
    );
  }
}