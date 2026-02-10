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
  bool _isPopping = false; // 팝 애니메이션 진행 중 플래그
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
      _isPopping = false;
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

    if (!_isPopping &&
        selectedTiles.length >= 2 &&
        GameLogic.isSumTen(selectedTiles)) {
      _popTiles(selectedTiles);
    }

    _startRow = null;
    _startCol = null;
    setState(() {
      _gameState = _gameState.copyWith(selectedTiles: {});
    });
  }

  void _popTiles(Set<MoldTileModel> tiles) {
    _isPopping = true;

    // 점수 계산
    final combo = _gameState.combo + 1;
    final score = GameLogic.calculateScore(tiles.length, combo);
    final newScore = _gameState.score + score;
    final newRemovedCount = _gameState.removedCount + tiles.length;
    final newMaxCombo =
        combo > _gameState.maxCombo ? combo : _gameState.maxCombo;

    // 보드에서 즉시 제거 마킹 + 팝 애니메이션 시작
    final newBoard = List<List<MoldTileModel?>>.from(
      _gameState.board.map((row) => List<MoldTileModel?>.from(row)),
    );
    for (final tile in tiles) {
      newBoard[tile.row][tile.col] = tile.copyWith(isRemoved: true);
    }

    setState(() {
      _poppingTiles = tiles;
      _gameState = _gameState.copyWith(
        board: newBoard,
        score: newScore,
        combo: combo,
        maxCombo: newMaxCombo,
        removedCount: newRemovedCount,
      );
    });

    // 애니메이션 완료 후 정리
    Future.delayed(const Duration(milliseconds: 750), () {
      if (!mounted) return;

      setState(() {
        _poppingTiles = {};
        _isPopping = false;
      });

      // 올클리어 체크
      if (_gameState.isAllCleared) {
        setState(() {
          _gameState = _gameState.copyWith(
            score: _gameState.score + GameLogic.allClearBonus,
          );
        });
        _endGame();
        return;
      }

      // 더 이상 조합 불가능 체크
      if (!GameLogic.hasValidCombination(_gameState.board)) {
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
        color: const Color(0xFFE8E8D0),
        child: SafeArea(
          child: Column(
            children: [
              // 상단 바: 일시정지(좌), 타이머(중), 점수(우) - 높이 고정
              _buildTopBar(),

              // 게임 보드 - 상단 10, 좌우 5, 하단 10 패딩
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    final timeProgress = _gameState.remainingSeconds / MoldGameState.totalTime;
    final isLowTime = _gameState.remainingSeconds <= 30;

    return Container(
      height: 60, // 고정 높이
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 좌측: 일시정지 버튼
          GestureDetector(
            onTap: _pauseGame,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.pause_rounded,
                  size: 20, color: AppTheme.gray700),
            ),
          ),

          const SizedBox(width: 16),

          // 중앙: 타이머
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 18,
                  color: isLowTime ? const Color(0xFFFF6B6B) : AppTheme.gray600,
                ),
                const SizedBox(width: 6),
                Text(
                  '${_gameState.remainingSeconds}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color:
                        isLowTime ? const Color(0xFFFF6B6B) : AppTheme.gray700,
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 160,
                  height: 12,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: timeProgress,
                      backgroundColor: Colors.white.withOpacity(0.5),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isLowTime
                            ? const Color(0xFFFF6B6B)
                            : const Color(0xFFE8E052),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // 우측: Score + Best Score
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Score',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.gray500,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  GameLogic.formatScore(_gameState.score),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.gray800,
                  ),
                ),
                Container(
                  width: 1,
                  height: 18,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  color: AppTheme.gray300,
                ),
                const Text(
                  'Best',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.gray500,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  GameLogic.formatScore(_highScore),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.mintPrimary,
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
