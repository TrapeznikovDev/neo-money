import 'package:flutter/material.dart';
import 'package:neomoney/core/ui/theme/app_colors.dart';

class DefaultAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool automaticallyImplyLeading;
  final Widget? trailing;
  final String leadingAsset;

  const DefaultAppBar({super.key, this.title, this.automaticallyImplyLeading = true, this.trailing, this.leadingAsset = 'assets/icons/app_logo.png'});

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    final showBack = automaticallyImplyLeading && canPop;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: AppColors.scaffold,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: preferredSize.height,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (showBack)
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      size: 20,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),

              Image.asset(
                leadingAsset,
                height: 24,
                fit: BoxFit.contain,
              ),

              if (trailing != null)
                Align(
                  alignment: Alignment.centerRight,
                  child: trailing!,
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}
