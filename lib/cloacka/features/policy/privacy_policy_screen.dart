import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  late final WebViewController _controller;
  String? _lastError;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)

    // 🔥 Часто решает: сервер перестаёт "понимать", что это WebView
      ..setUserAgent(
        // Safari iOS (универсально норм)
        'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) '
            'AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 '
            'Mobile/15E148 Safari/604.1',
      )

      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (p) => debugPrint('WebView progress: $p%'),
          onPageStarted: (url) {
            debugPrint('WebView started: $url');
            setState(() => _lastError = null);
          },
          onPageFinished: (url) => debugPrint('WebView finished: $url'),
          onWebResourceError: (err) {
            debugPrint('WebView error: ${err.errorCode} ${err.description}');
            setState(() => _lastError = '${err.errorCode}: ${err.description}');
          },
          onHttpError: (err) {
            debugPrint('HTTP error: ${err.response?.statusCode} ${err.request?.uri}');
            setState(() => _lastError = 'HTTP ${err.response?.statusCode}');
          },
        ),
      )
      ..loadRequest(Uri.parse('https://api.neornoney.ru/neomani/privacy-policy'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Политика конфиденциальности')),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_lastError != null)
            Positioned.fill(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Не удалось загрузить страницу\n$_lastError',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}