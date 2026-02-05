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
  int _previousIndex = -1;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _homeScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _previousIndex = widget.initialIndex;
  }

  @override
  void dispose() {
    _homeScrollController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    // 드로어가 열려있으면 닫기
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }
    // 홈 탭으로 이동 시 스크롤을 상단으로 복귀
    if (index == 0) {
      _homeScrollController.jumpTo(0);
    }
    setState(() {
      _previousIndex = _currentIndex;
      _currentIndex = index;
    });
  }

  void openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    // 마이페이지 탭(인덱스 3)으로 전환 시 필터 초기화
    final resetMypageFilter = _currentIndex == 3 && _previousIndex != 3;

    return Scaffold(
      key: _scaffoldKey,
      drawer: const HamburgerMenu(),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreenContent(onMenuTap: openDrawer, scrollController: _homeScrollController),
          const DiagnosisScreen(),
          const DictionaryScreen(),
          MypageScreen(resetFilter: resetMypageFilter),
        ],
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
  final ScrollController? scrollController;

  const HomeScreenContent({super.key, this.onMenuTap, this.scrollController});

  @override
  Widget build(BuildContext context) {
    return HomeScreen(onMenuTap: onMenuTap, scrollController: scrollController);
  }
}
