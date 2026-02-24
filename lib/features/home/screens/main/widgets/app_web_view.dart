// features/home/screens/main/widgets/app_payment_webview_screen.dart
// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AppPaymentWebViewScreen extends StatefulWidget {
  final String url;

  const AppPaymentWebViewScreen({
    super.key,
    required this.url,
  });

  @override
  State<AppPaymentWebViewScreen> createState() => _AppPaymentWebViewScreenState();
}

class _AppPaymentWebViewScreenState extends State<AppPaymentWebViewScreen> {
  late final WebViewController _controller;

  bool _isLoading = true;
  bool _isPopped = false;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            if (_isPopped) return;
            setState(() => _isLoading = true);
            log('[PaymentWebView] start: $url');
          },
          onPageFinished: (url) {
            if (_isPopped) return;
            setState(() => _isLoading = false);
            log('[PaymentWebView] finish: $url');

            // === УСПЕХ ===
            // В boostra: url.contains('best2pay_callback/payment')
            if (url.contains('best2pay_callback/payment')) {
              _pop(true);
              return;
            }

            // === ОШИБКА ===
            // В boostra: url.contains('error=')
            if (url.contains('error=')) {
              _pop(false);
              return;
            }
          },
          onWebResourceError: (e) {
            log('[PaymentWebView] resource error: ${e.description}');
          },
          onHttpError: (e) {
            log('[PaymentWebView] http error: ${e.response?.statusCode}');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  void _pop(bool ok) {
    if (_isPopped) return;
    _isPopped = true;
    if (!mounted) return;
    Navigator.of(context).pop(ok);
  }
}