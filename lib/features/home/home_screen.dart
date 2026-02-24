import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:neomoney/features/cards/cards_screen.dart';
import 'package:neomoney/features/chat/chat_screen.dart';
import 'package:neomoney/features/documents/documents_screen.dart';
import 'package:neomoney/features/faq/screens/faq_screen.dart';
import 'package:neomoney/features/home/screens/main/main_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final _screens = [OrdersMainScreen(), DocumentsScreen(), CardsScreen(), ChatScreen(), FaqScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        items: [
          BottomNavigationBarItem(
            icon: Image.asset('assets/icons/main_icon.png', width: 24, height: 22, color: Colors.grey, colorBlendMode: BlendMode.srcIn),
            activeIcon: Image.asset('assets/icons/main_icon.png', width: 24, height: 22, colorBlendMode: BlendMode.srcIn),
            label: 'Главная',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/icons/documents_icon.png', width: 24, height: 24, color: Colors.grey, colorBlendMode: BlendMode.srcIn),
            activeIcon: Image.asset('assets/icons/documents_icon.png', width: 24, height: 24, colorBlendMode: BlendMode.srcIn),
            label: 'Документы',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/icons/cards_icon.png', width: 24, height: 24, color: Colors.grey, colorBlendMode: BlendMode.srcIn),
            activeIcon: Image.asset('assets/icons/cards_icon.png', width: 24, height: 24, colorBlendMode: BlendMode.srcIn),
            label: 'Карты',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/icons/faq_icon.png', width: 24, height: 24, color: Colors.grey, colorBlendMode: BlendMode.srcIn),
            activeIcon: Image.asset('assets/icons/faq_icon.png', width: 24, height: 24, colorBlendMode: BlendMode.srcIn),
            label: 'Поддержка',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/ic_question_answer.svg',
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(
                Colors.grey,
                BlendMode.srcIn,
              ),
            ),
            activeIcon: SvgPicture.asset(
              'assets/icons/ic_question_answer.svg',
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(
                Colors.blue,
                BlendMode.srcIn,
              ),
            ),
            label: 'Вопросы',
          ),
        ],
      ),
    );
  }
}
