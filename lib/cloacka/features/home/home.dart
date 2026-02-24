import 'package:flutter/material.dart';
import 'package:neomoney/cloacka/features/home/screens/my_finances_screen.dart';
import 'package:neomoney/cloacka/features/home/screens/planned_purchases_screen.dart';
import 'package:neomoney/cloacka/features/home/screens/progress_levels_screen.dart';
import 'package:neomoney/cloacka/features/home/screens/saving_speed_screen.dart';
import 'package:neomoney/core/ui/theme/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  final _tabs = const [MyFinancesScreen(), PlannedPurchasesScreen(), SavingsSpeedScreen(), ProgressLevelsScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HomeAppBar(),
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          currentIndex: _index,
          onTap: (i) => setState(() => _index = i),
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          backgroundColor: AppColors.backColor,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: _MenuIcon('assets/icons/menu_1_icon.png', isActive: _index == 0),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: _MenuIcon('assets/icons/menu_2_icon.png', isActive: _index == 1),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: _MenuIcon('assets/icons/menu_3_icon.png', isActive: _index == 2),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: _MenuIcon('assets/icons/menu_4_icon.png', isActive: _index == 3),
              label: '',
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuIcon extends StatelessWidget {
  final String asset;
  final bool isActive;

  const _MenuIcon(this.asset, {this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 2),
      padding: const EdgeInsets.all(8),

      child: AnimatedScale(
        duration: const Duration(milliseconds: 200),
        scale: isActive ? 1.1 : 1.0,
        child: ColorFiltered(
          colorFilter: ColorFilter.mode(
            isActive
                ? AppColors.primary
                : AppColors.primary.withOpacity(0.5),
            BlendMode.srcIn,
          ),
          child: Image.asset(
            asset,
            width: 26,
            height: 26,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar();

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        height: preferredSize.height,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.centerLeft,
        child: Image.asset('assets/icons/app_logo.png', height: 28, fit: BoxFit.contain),
      ),
    );
  }
}
