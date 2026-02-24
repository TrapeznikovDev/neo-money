import 'package:flutter/material.dart';
import 'package:neomoney/cloacka/app/router/app_routes.dart';
import 'package:neomoney/core/ui/theme/app_colors.dart';
import 'package:neomoney/core/ui/theme/app_text_styles.dart';
import 'package:package_info_plus/package_info_plus.dart';

class PrivacyPolicyWidget extends StatefulWidget {
  const PrivacyPolicyWidget({super.key,  this.whiteLabel = true});

  final bool whiteLabel;

  @override
  State<PrivacyPolicyWidget> createState() => _PrivacyPolicyWidgetState();
}

class _PrivacyPolicyWidgetState extends State<PrivacyPolicyWidget> {
  String _versionText = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _versionText = 'Версия приложения: ${info.version} (${info.buildNumber})';
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutesCloacka.privacyPolicy),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Политика конфиденциальности\n'
                'Политика в отношении обработки персональных данных\n'
                '$_versionText',
            textAlign: TextAlign.center,
            style: AppTypography.textTheme.bodySmall?.copyWith(
              color: widget.whiteLabel ? AppColors.scaffold: AppColors.textPrimary,
              fontSize: 11,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.scaffold,
            ),
          ),
        ),
      ),
    );
  }
}