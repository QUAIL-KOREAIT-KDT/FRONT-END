import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../models/game/mold_tile_model.dart';
import '../../models/game/mold_game_state.dart';
import '../../utils/game/game_logic.dart';
import '../../widgets/game/game_board.dart';

/// 게임 플레이 화면
class MoldGamePlayScreen extends StatefulWidget {
  const MoldGamePlayScreen({super.key});

  @override
  State<MoldGamePlayScreen> createState() => _MoldGamePlayScreenState();
}

class _MoldGamePlayScreenState extends State<MoldGamePlayScreen>
    with TickerProviderStateMixin {
  late MoldGameState _gameState;
  Timer? _timer;
  int? _startRow, _startCol;
  Set<MoldTileModel> _poppingTiles = {};
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  int _highScore = 0;

  @override
  void initState() {
    super.initState();
    // 가로 모드 강제
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _loadHighScore();
    _initShakeAnimation();
    _startNewGame();
  }

  void _initShakeAnimation() {
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 4).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _highScore = prefs.getInt('mold_game_high_score') ?? 0;
    });
  }

  Future<void> _saveHighScore(int score) async {
    if (score > _highScore) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('mold_game_high_score', score);
      setState(() {
        _highScore = score;
      });
    }
  }

  void _startNewGame() {
    _timer?.cancel();

    final board = GameLogic.generateBoard();
    setState(() {
      _gameState = MoldGameState(
        board: board,
        status: GameStatus.playing,
        highScore: _highScore,
      );
      _poppingTiles = {};
    });

    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_gameState.status != GameStatus.playing) {
        timer.cancel();
        return;
      }

      setState(() {
        final newSeconds = _gameState.remainingSeconds - 1;
        if (newSeconds <= 0) {
          _endGame();
        } else {
          _gameState = _gameState.copyWith(remainingSeconds: newSeconds);
        }
      });
    });
  }

  void _endGame() {
    _timer?.cancel();

    // 최고 점수 저장
    _saveHighScore(_gameState.score);

    setState(() {
      _gameState = _gameState.copyWith(status: GameStatus.finished);
    });

    // 결과 화면으로 이동
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.moldGameResult,
          arguments: {
            'score': _gameState.score,
            'removedCount': _gameState.removedCount,
            'maxCombo': _gameState.maxCombo,
            'highScore': _highScore,
            'isNewRecord': _gameState.score > _highScore,
          },
        );
      }
    });
  }

  void _pauseGame() {
    _timer?.cancel();
    setState(() {
      _gameState = _gameState.copyWith(status: GameStatus.paused);
    });
    _showPauseDialog();
  }

  void _resumeGame() {
    setState(() {
      _gameState = _gameState.copyWith(status: GameStatus.playing);
    });
    _startTimer();
  }

  void _showPauseDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Center(
          child: Text(
            '일시정지',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPauseButton(
              icon: Icons.play_arrow_rounded,
              label: '계속하기',
              color: AppTheme.mintPrimary,
              onTap: () {
                Navigator.pop(context);
                _resumeGame();
              },
            ),
            const SizedBox(height: 12),
            _buildPauseButton(
              icon: Icons.refresh_rounded,
              label: '다시 시작',
              color: Colors.orange,
              onTap: () {
                Navigator.pop(context);
                _startNewGame();
              },
            ),
            const SizedBox(height: 12),
            _buildPauseButton(
              icon: Icons.exit_to_app_rounded,
              label: '나가기',
              color: AppTheme.gray500,
              onTap: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPauseButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _handleDragStart(int row, int col) {
    if (_gameState.status != GameStatus.playing) return;

    _startRow = row;
    _startCol = col;
    _updateSelection(row, col);
  }

  void _handleDragUpdate(int row, int col) {
    if (_gameState.status != GameStatus.playing) return;
    if (_startRow == null || _startCol == null) return;

    _updateSelection(row, col);
  }

  void _updateSelection(int endRow, int endCol) {
    final selectedTiles = GameLogic.selectTilesInRect(
      board: _gameState.board,
      startRow: _startRow!,
      startCol: _startCol!,
      endRow: endRow,
      endCol: endCol,
    );

    setState(() {
      _gameState = _gameState.copyWith(selectedTiles: selectedTiles);
    });
  }

  void _handleDragEnd() {
    if (_gameState.status != GameStatus.playing) return;

    final selectedTiles = _gameState.selectedTiles;

    if (selectedTiles.length >= 2 && GameLogic.isSumTen(selectedTiles)) {
      _popTiles(selectedTiles);
    }

    _startRow = null;
    _startCol = null;
    setState(() {
      _gameState = _gameState.copyWith(selectedTiles: {});
    });
  }

  void _popTiles(Set<MoldTileModel> tiles) {
    // 화면 흔들림
    _shakeController.forward().then((_) => _shakeController.reverse());

    // 점수 계산
    final combo = _gameState.combo + 1;
    final score = GameLogic.calculateScore(tiles.length, combo);
    final newScore = _gameState.score + score;
    final newRemovedCount = _gameState.removedCount + tiles.length;
    final newMaxCombo =
        combo > _gameState.maxCombo ? combo : _gameState.maxCombo;

    // 팝 애니메이션 시작
    setState(() {
      _poppingTiles = tiles;
      _gameState = _gameState.copyWith(
        score: newScore,
        combo: combo,
        maxCombo: newMaxCombo,
        removedCount: newRemovedCount,
      );
    });

    // 타일 제거
    Future.delayed(const Duration(milliseconds: 200), () {
      if (!mounted) return;

      final newBoard = List<List<MoldTileModel?>>.from(
        _gameState.board.map((row) => List<MoldTileModel?>.from(row)),
      );

      for (final tile in tiles) {
        newBoard[tile.row][tile.col] = tile.copyWith(isRemoved: true);
      }

      setState(() {
        _poppingTiles = {};
        _gameState = _gameState.copyWith(board: newBoard);
      });

      // 올클리어 체크
      if (_gameState.isAllCleared) {
        final bonusScore = GameLogic.allClearBonus;
        setState(() {
          _gameState = _gameState.copyWith(
            score: _gameState.score + bonusScore,
          );
        });
        _endGame();
      }

      // 더 이상 조합 불가능 체크
      if (!GameLogic.hasValidCombination(newBoard)) {
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted && _gameState.status == GameStatus.playing) {
            _endGame();
          }
        });
      }
    });

    // 콤보 리셋 타이머 (2초 내 추가 팝 없으면 리셋)
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && _gameState.combo == combo) {
        setState(() {
          _gameState = _gameState.copyWith(combo: 0);
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _shakeController.dispose();
    // 세로 모드로 복원
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // 앱의 primary 민트색 배경
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.mintLight.withOpacity(0.3),
              AppTheme.mintPrimary.withOpacity(0.2),
            ],
          ),
        ),
        child: SafeArea(
          child: Row(
            children: [
              // 왼쪽: 게임 보드
              Expanded(
                flex: 3,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 4, 8, 20), // 하단 마진 추가
                    child: AnimatedBuilder(
                      animation: _shakeAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(
                            _shakeAnimation.value *
                                (_shakeController.status ==
                                        AnimationStatus.forward
                                    ? 1
                                    : -1),
                            0,
                          ),
                          child: child,
                        );
                      },
                      child: GameBoard(
                        board: _gameState.board,
                        selectedTiles: _gameState.selectedTiles,
                        poppingTiles: _poppingTiles,
                        currentSum: _gameState.selectedSum,
                        onDragStart: _handleDragStart,
                        onDragUpdate: _handleDragUpdate,
                        onDragEnd: _handleDragEnd,
                      ),
                    ),
                  ),
                ),
              ),

              // 오른쪽: UI 패널
              _buildRightPanel(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRightPanel() {
    final timeColor = _gameState.remainingSeconds <= 30
        ? const Color(0xFFFF6B6B)
        : AppTheme.gray700;

    return Container(
      width: 140,
      margin: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 상단: 일시정지 버튼만
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: _pauseGame,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.pause_rounded, size: 20),
              ),
            ),
          ),

          // 중앙: 타이머 + 점수
          Column(
            children: [
              // 타이머
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _gameState.remainingSeconds <= 30
                      ? const Color(0xFFFF6B6B).withOpacity(0.9)
                      : Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(Icons.timer_outlined,
                        color: _gameState.remainingSeconds <= 30
                            ? Colors.white
                            : timeColor,
                        size: 24),
                    const SizedBox(height: 4),
                    Text(
                      GameLogic.formatTime(_gameState.remainingSeconds),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: _gameState.remainingSeconds <= 30
                            ? Colors.white
                            : timeColor,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // 점수 (아이콘 없이 간결하게)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      'SCORE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.gray500,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      GameLogic.formatScore(_gameState.score),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.mintPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // 하단: 최고기록 (심플하게)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  'BEST',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.gray500,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  GameLogic.formatScore(_highScore),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.gray700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
