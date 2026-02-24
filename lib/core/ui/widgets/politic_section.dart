import 'package:flutter/material.dart';
import 'package:neomoney/cloacka/app/router/app_routes.dart';
import 'package:package_info_plus/package_info_plus.dart';

class PoliticSection extends StatelessWidget {
  const PoliticSection({super.key});

  @override
  Widget build(BuildContext context) {
    final textStyleLink = Theme.of(context).textTheme.bodyMedium?.copyWith(
      decoration: TextDecoration.underline,
      fontWeight: FontWeight.w500,
      fontSize: 12,
    );

    final textStyleVersion = Theme.of(context).textTheme.bodySmall?.copyWith(
      fontSize: 12,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () => Navigator.pushNamed(context, AppRoutesCloacka.privacyPolicy),
          child: Text(
            'Политика конфиденциальности',
            style: textStyleLink,
            textAlign: TextAlign.center,
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, AppRoutesCloacka.privacyPolicy),
          child: Text(
            'Политика в отношении обработки персональных данных',
            style: textStyleLink,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 4),

        FutureBuilder<String>(
          future: _loadVersion(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox.shrink();
            }

            return Text(
              snapshot.data!,
              style: textStyleVersion,
              textAlign: TextAlign.center,
            );
          },
        ),
      ],
    );
  }

  Future<String> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    return 'Версия приложения: ${info.version} (${info.buildNumber})';
  }
}