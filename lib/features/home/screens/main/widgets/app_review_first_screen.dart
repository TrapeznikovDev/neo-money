import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppReviewFirstScreen extends StatefulWidget {
  const AppReviewFirstScreen({
    super.key,
    required this.starAssetPath,
    required this.bigStarAssetPath,
    required this.onClose,
    required this.onSubmit,
    required this.onTryNativeReview,
  });

  final String starAssetPath;
  final String bigStarAssetPath;

  final VoidCallback onClose;

  /// user нажал "Оставить отзыв"
  final ValueChanged<int> onSubmit;

  /// если stars >= 4 — вызываем in_app_review (или твой сервис)
  final Future<void> Function(int stars) onTryNativeReview;

  @override
  State<AppReviewFirstScreen> createState() => _AppReviewFirstScreenState();
}

class _AppReviewFirstScreenState extends State<AppReviewFirstScreen> {
  int selectedStars = 0;
  bool tryShowReview = false;

  Widget _buildStar(int index) {
    final isActive = index <= selectedStars && selectedStars > 0;
    return GestureDetector(
      onTap: () async {
        setState(() => selectedStars = index);

        if (selectedStars >= 4) {
          setState(() => tryShowReview = true);
          await widget.onTryNativeReview(selectedStars);
        }
      },
      child: SizedBox(
        width: 44,
        height: 44,
        child: SvgPicture.asset(
          widget.starAssetPath,
          color: isActive ? const Color(0xFFFFCA0D) : const Color(0xFFE5F3FF),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        widget.onClose();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: widget.onClose,
          ),
        ),
        body: SafeArea(
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 28),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2FBFF),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Column(
                          children: [
                            Text(
                              'Нам важен ваш\nотзыв!',
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Напишите нам, пожалуйста, что вам нравится или не нравится в нашем приложении',
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (i) => _buildStar(i + 1)),
                      ),
                      const SizedBox(height: 28),
                      const Text(
                        'Спасибо!',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 90), // место под нижнюю кнопку
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: SizedBox(
                    height: 56,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: selectedStars == 0 ? null : () => widget.onSubmit(selectedStars),
                      child: const Text('Оставить отзыв'),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 20,
                top: 90,
                child: SvgPicture.asset(
                  widget.bigStarAssetPath,
                  width: 60,
                  height: 60,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}