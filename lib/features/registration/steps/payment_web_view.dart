import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:neomoney/app/router.dart';

enum PaymentWebViewFlow {
  cardBind,
  payment,
}

class PaymentWebViewScreen extends StatefulWidget {
  final String url;

  final PaymentWebViewFlow flow;

  final Future<void> Function()? onSuccess;

  final Future<void> Function()? onFail;

  const PaymentWebViewScreen({super.key, required this.url, this.flow = PaymentWebViewFlow.cardBind, this.onSuccess, this.onFail});

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController _controller;

  bool _isPopped = false;

  bool isWebViewLoading = true;

  bool overlayLoading = false;
  int overlayDone = -1;

  bool _isCardSuccessUrl(String url) {
    final u = url.toLowerCase();
    return u.contains('best2pay_callback/add_card') || u.contains('https://boostra.ru/user');
  }

  bool _isCardFailUrl(String url) {
    final u = url.toLowerCase();
    return u.contains('&code=');
  }

  bool _isPaymentSuccessUrl(String url) {
    final u = url.toLowerCase();
    return u.contains('best2pay_callback/payment');
  }

  bool _isPaymentFailUrl(String url) {
    final u = url.toLowerCase();
    return u.contains('error=');
  }

  void _goHome() {
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(AppRouteNames.homeScreen, (route) => false);
  }

  Future<void> _finishAndClose({required bool success}) async {
    if (_isPopped || !mounted) return;
    _isPopped = true;

    // небольшая пауза чтобы пользователь увидел текст (как в старом: 2 сек)
    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;

    // Вариант 1: закрываем экран и отдаём результат наверх
    Navigator.of(context).pop(success);

    // Вариант 2 (если тебе нужно всегда на home) — вместо pop:
    // _goHome();
  }

  Future<void> _handleSuccess() async {
    if (!mounted) return;

    setState(() {
      overlayLoading = true;
      overlayDone = 1;
    });

    try {
      await widget.onSuccess?.call();
    } catch (_) {}

    await _finishAndClose(success: true);
  }

  Future<void> _handleFail() async {
    if (!mounted) return;

    setState(() {
      overlayLoading = true;
      overlayDone = 0;
    });

    try {
      await widget.onFail?.call();
    } catch (_) {}

    await _finishAndClose(success: false);
  }

  @override
  void initState() {
    super.initState();

    final initialUrl = widget.url.trim();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            if (_isPopped) return;
            log('webview onPageStarted: $url');

            setState(() {
              isWebViewLoading = true;
            });

            // В старом коде payment-loading включался когда url содержит webapi/Purchase.
            // Оставлю такой же триггер, но отображение оверлея я делаю по факту результата.
            if (url.contains('webapi/Purchase')) {
              // можно setState(() => overlayLoading = true); если хочешь блокировать сразу
            }
          },
          onPageFinished: (url) async {
            if (_isPopped) return;
            log('webview onPageFinished: $url');

            if (mounted) {
              setState(() {
                isWebViewLoading = false;
              });
            }

            // ======= ЛОГИКА 1:1 как в старом WebViewNfPage =======

            if (widget.flow == PaymentWebViewFlow.cardBind) {
              if (_isCardSuccessUrl(url)) {
                await _handleSuccess();
                return;
              }
              if (_isCardFailUrl(url)) {
                await _handleFail();
                return;
              }
            }

            if (widget.flow == PaymentWebViewFlow.payment) {
              if (_isPaymentSuccessUrl(url)) {
                await _handleSuccess();
                return;
              }
              if (_isPaymentFailUrl(url)) {
                await _handleFail();
                return;
              }
            }
          },
          onHttpError: (error) async {
            if (_isPopped) return;
            debugPrint('HTTP error: ${error.response?.uri}');
            if (mounted) {
              setState(() {
                isWebViewLoading = false;
              });
            }
            // в старом было: просто снимали лоадер, без pop
          },
          onWebResourceError: (error) async {
            if (_isPopped) return;
            debugPrint('WebResourceError: ${error.description}');
            if (mounted) {
              setState(() {
                isWebViewLoading = false;
              });
            }
            // аналогично
          },
          onNavigationRequest: (request) {
            // В старом почти всё пропускали.
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(initialUrl));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        // как у тебя раньше: по Back уходим на home
        _goHome();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.flow == PaymentWebViewFlow.payment ? 'Оплата' : 'Привязка карты'),
          leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: _goHome),
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),

            if (isWebViewLoading) const Center(child: CircularProgressIndicator()),

            if (overlayLoading)
              Container(
                color: Colors.white,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (overlayDone == -1)
                      Text(
                        widget.flow == PaymentWebViewFlow.payment
                            ? 'Процесс оплаты, это может занять несколько секунд...'
                            : 'Процесс добавления карты, это может занять несколько секунд...',
                        textAlign: TextAlign.center,
                      ),
                    if (overlayDone == 1)
                      Text(
                        widget.flow == PaymentWebViewFlow.payment
                            ? 'Оплата успешно проведена, перенаправляем...'
                            : 'Карта успешно добавлена, перенаправляем...',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.green),
                      ),
                    if (overlayDone == 0)
                      Text(
                        widget.flow == PaymentWebViewFlow.payment
                            ? 'При оплате произошла ошибка, перенаправляем...'
                            : 'При добавлении карты произошла ошибка, перенаправляем...',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                    const SizedBox(height: 14),
                    const CircularProgressIndicator(),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
