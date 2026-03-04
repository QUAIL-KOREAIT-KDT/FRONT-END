import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../models/game/mold_tile_model.dart';
import '../../models/game/mold_game_state.dart';
import '../../utils/game/game_logic.dart';
import '../../widgets/game/game_board.dart';
import '../../services/game_service.dart';

/// 게임 플레이 화면
class MoldGamePlayScreen extends StatefulWidget {
  const MoldGamePlayScreen({super.key});

  @override
  State<MoldGamePlayScreen> createState() => _MoldGamePlayScreenState();
}

class _MoldGamePlayScreenState extends State<MoldGamePlayScreen> {
  late MoldGameState _gameState;
  Timer? _timer;
  Timer? _spawnLoopTimer;
  int? _startRow, _startCol;
  Set<MoldTileModel> _poppingTiles = {};
  int _nextTileId = MoldGameState.rows * MoldGameState.cols; // 리스폰 타일 ID 카운터
  Set<int> _spawningTileIds = {}; // 스폰 애니매 중인 ID 집합
  bool _spawnLoopStarted = false; // 첫 제거 이후에만 리스폰 루프 활성화
  int _highScore = 0;
  final _rng = Random();

  @override
  void initState() {
    super.initState();
    // 가로 모드 강제
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _loadHighScore();
    _startNewGame();
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
    _spawnLoopTimer?.cancel();

    final board = GameLogic.generateBoard();
    setState(() {
      _gameState = MoldGameState(
        board: board,
        status: GameStatus.playing,
        highScore: _highScore,
      );
      _poppingTiles = {};
      _spawningTileIds = {};
      _spawnLoopStarted = false;
      _nextTileId = MoldGameState.rows * MoldGameState.cols;
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
    _spawnLoopTimer?.cancel();

    // 최고 점수 저장
    _saveHighScore(_gameState.score);

    // 서버에 점수 제출 (fire-and-forget)
    GameService().submitScore(_gameState.score);

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
    _spawnLoopTimer?.cancel();
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
    // 첫 제거가 이미 발생한 경우에만 리스폰 루프 재개
    if (_spawnLoopStarted) _scheduleNextSpawn();
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
      _poppingTiles = {..._poppingTiles, ...tiles}; // 기존 낙하 중인 타일에 누적
      _gameState = _gameState.copyWith(
        board: newBoard,
        score: newScore,
        combo: combo,
        maxCombo: newMaxCombo,
        removedCount: newRemovedCount,
      );
    });

    // 첫 번째 제거 발생 시 리스폰 루프 시작
    if (!_spawnLoopStarted) {
      _spawnLoopStarted = true;
      _scheduleNextSpawn();
    }

    // 애니메이션 완료 후 정리
    Future.delayed(const Duration(milliseconds: 750), () {
      if (!mounted) return;

      setState(() {
        _poppingTiles = _poppingTiles.difference(tiles); // 이 배치만 제거
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

  // 6~8초마다 빈 칸 중 랜덤 1칸에 곰팡이 리스폰 루프
  void _scheduleNextSpawn() {
    _spawnLoopTimer?.cancel();
    final delay = Duration(milliseconds: 6000 + _rng.nextInt(2001)); // 6~8초
    _spawnLoopTimer = Timer(delay, () {
      if (!mounted || _gameState.status != GameStatus.playing) return;

      // 빈 칸(null 또는 isRemoved) 목록 수집
      final emptyPositions = <(int, int)>[];
      for (int r = 0; r < MoldGameState.rows; r++) {
        for (int c = 0; c < MoldGameState.cols; c++) {
          final tile = _gameState.board[r][c];
          if (tile == null || tile.isRemoved) {
            emptyPositions.add((r, c));
          }
        }
      }

      if (emptyPositions.isNotEmpty) {
        final pos = emptyPositions[_rng.nextInt(emptyPositions.length)];
        _spawnTileAt(pos.$1, pos.$2);
      }

      // 다음 스폰 예약
      _scheduleNextSpawn();
    });
  }

  // 지정 위치에 스폰 타일을 생성하고 페이드인 시작
  void _spawnTileAt(int row, int col) {
    final newId = _nextTileId++;
    final newTile = MoldTileModel(
      id: newId,
      row: row,
      col: col,
      value: _rng.nextInt(9) + 1,
    );
    final newBoard = List<List<MoldTileModel?>>.from(
      _gameState.board.map((r) => List<MoldTileModel?>.from(r)),
    );
    newBoard[row][col] = newTile;

    setState(() {
      _spawningTileIds = {..._spawningTileIds, newId};
      _gameState = _gameState.copyWith(board: newBoard);
    });

    // 애니메이션 완료 후 ID 제거 (1초 딜레이 + 650ms 애니메이션)
    Future.delayed(const Duration(milliseconds: 1650), () {
      if (mounted) {
        setState(() {
          _spawningTileIds = Set.from(_spawningTileIds)..remove(newId);
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _spawnLoopTimer?.cancel();
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              // 보드 패딩 상수 (GameBoard 패딩과 동일하게 유지)
              const boardPaddingH = 5.0;
              const boardPaddingV = 10.0;
              const topBarHeight = 60.0;
              const spacing = 3.0;

              final boardAreaWidth = constraints.maxWidth - boardPaddingH * 2;
              final boardAreaHeight =
                  constraints.maxHeight - topBarHeight - boardPaddingV * 2;

              final maxTileW =
                  (boardAreaWidth - spacing * (MoldGameState.cols - 1)) /
                      MoldGameState.cols;
              final maxTileH =
                  (boardAreaHeight - spacing * (MoldGameState.rows - 1)) /
                      MoldGameState.rows;
              final tileSize = maxTileW < maxTileH ? maxTileW : maxTileH;

              final boardWidth = tileSize * MoldGameState.cols +
                  spacing * (MoldGameState.cols - 1);

              // 보드 좌측 끝까지의 거리 (보드 패딩 + 보드 가운데 정렬 여백)
              final boardOffsetX =
                  boardPaddingH + (boardAreaWidth - boardWidth) / 2;

              return Column(
                children: [
                  // 상단 바: 보드 좌우 끝에 정렬
                  _buildTopBar(boardOffsetX: boardOffsetX),

                  // 게임 보드
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(boardPaddingH,
                          boardPaddingV, boardPaddingH, boardPaddingV),
                      child: GameBoard(
                        board: _gameState.board,
                        selectedTiles: _gameState.selectedTiles,
                        poppingTiles: _poppingTiles,
                        spawningTileIds: _spawningTileIds,
                        currentSum: _gameState.selectedSum,
                        onDragStart: _handleDragStart,
                        onDragUpdate: _handleDragUpdate,
                        onDragEnd: _handleDragEnd,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar({required double boardOffsetX}) {
    final timeProgress = _gameState.remainingSeconds / MoldGameState.totalTime;
    final isLowTime = _gameState.remainingSeconds <= 30;

    return Container(
      height: 60, // 고정 높이
      padding: EdgeInsets.symmetric(horizontal: boardOffsetX),
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
