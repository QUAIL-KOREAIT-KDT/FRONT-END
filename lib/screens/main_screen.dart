import 'package:flutter/material.dart';
import '../widgets/common/bottom_nav_bar.dart';
import '../widgets/menu/hamburger_menu.dart';
import 'home_screen.dart';
import 'diagnosis_screen.dart';
import 'dictionary_screen.dart';
import 'mypage/mypage_screen.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;

  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // 각 탭의 화면들
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _screens = [
      const HomeScreenContent(),
      const DiagnosisScreen(),
      const DictionaryScreen(),
      const MypageScreenContent(),
    ];
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const HamburgerMenu(),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens.map((screen) {
          // HomeScreenContent에 drawer 열기 콜백 전달
          if (screen is HomeScreenContent) {
            return HomeScreenContent(onMenuTap: openDrawer);
          }
          return screen;
        }).toList(),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}

// HomeScreen을 MainScreen 내에서 사용하기 위한 컨텐츠 버전
class HomeScreenContent extends StatelessWidget {
  final VoidCallback? onMenuTap;

  const HomeScreenContent({super.key, this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    return const _HomeContent();
  }
}

class _HomeContent extends StatefulWidget {
  const _HomeContent();

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  @override
  Widget build(BuildContext context) {
    // HomeScreen의 내용을 그대로 가져옴 - 추후 리팩토링 가능
    return const HomeScreen();
  }
}

// MypageScreen을 MainScreen 내에서 사용하기 위한 컨텐츠 버전
class MypageScreenContent extends StatelessWidget {
  const MypageScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const MypageScreen();
  }
}
