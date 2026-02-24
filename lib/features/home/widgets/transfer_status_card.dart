import 'package:flutter/material.dart';
import 'package:neomoney/core/ui/theme/app_colors.dart';

class TransferStatusCard extends StatelessWidget {
  final String title;
  final String buttonText;
  final bool isLoading;
  final VoidCallback onRefresh;

  const TransferStatusCard({
    super.key,
    required this.title,
    required this.buttonText,
    required this.isLoading,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            blurRadius: 24,
            offset: const Offset(0, 10),
            color: Colors.black.withOpacity(0.12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    height: 1.2,
                  ),
                ),
              ),
              Image.asset('assets/icons/waiting_icon.png'),
            ],
          ),
          const SizedBox(height: 60 ),
          SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: isLoading ? null : onRefresh,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonColor,
                foregroundColor: AppColors.textPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              child: isLoading
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(buttonText),
            ),
          ),
        ],
      ),
    );
  }
}