class OnboardingItem {
  final String image;
  final String greenText;

  const OnboardingItem({
    required this.image,
    required this.greenText,
  });
}

const onboardingItems = [
  OnboardingItem(
    image: 'assets/images/man1.png',
    greenText: 'Планируйте покупки',
  ),
  OnboardingItem(
    image: 'assets/images/man2.png',
    greenText: 'Календарь выплат',
  ),
  OnboardingItem(
    image: 'assets/images/man3.png',
    greenText: 'Рассчитаем путь до цели',
  ),
];