import 'mold_tile_model.dart';

/// 게임 상태 열거형
enum GameStatus {
  ready, // 게임 시작 전
  playing, // 게임 중
  paused, // 일시정지
  finished, // 게임 종료
}

/// 게임 전체 상태 모델
class MoldGameState {
  final List<List<MoldTileModel?>> board; // 18x9 격자
  final int score;
  final int combo;
  final int maxCombo;
  final int removedCount; // 제거된 곰팡이 수
  final int remainingSeconds; // 남은 시간 (초)
  final int highScore;
  final GameStatus status;
  final Set<MoldTileModel> selectedTiles; // 현재 선택된 타일들

  static const int rows = 9;
  static const int cols = 18;
  static const int totalTime = 120; // 120초

  const MoldGameState({
    required this.board,
    this.score = 0,
    this.combo = 0,
    this.maxCombo = 0,
    this.removedCount = 0,
    this.remainingSeconds = totalTime,
    this.highScore = 0,
    this.status = GameStatus.ready,
    this.selectedTiles = const {},
  });

  /// 초기 게임 상태 생성
  factory MoldGameState.initial({int? highScore}) {
    return MoldGameState(
      board: List.generate(
        rows,
        (row) => List.generate(cols, (col) => null),
      ),
      highScore: highScore ?? 0,
    );
  }

  /// 선택된 타일들의 합
  int get selectedSum {
    return selectedTiles.fold(0, (sum, tile) => sum + tile.value);
  }

  /// 모든 타일이 제거되었는지 확인
  bool get isAllCleared {
    for (var row in board) {
      for (var tile in row) {
        if (tile != null && !tile.isRemoved) {
          return false;
        }
      }
    }
    return true;
  }

  /// 남아있는 타일 수
  int get remainingTiles {
    int count = 0;
    for (var row in board) {
      for (var tile in row) {
        if (tile != null && !tile.isRemoved) {
          count++;
        }
      }
    }
    return count;
  }

  /// 복사본 생성
  MoldGameState copyWith({
    List<List<MoldTileModel?>>? board,
    int? score,
    int? combo,
    int? maxCombo,
    int? removedCount,
    int? remainingSeconds,
    int? highScore,
    GameStatus? status,
    Set<MoldTileModel>? selectedTiles,
  }) {
    return MoldGameState(
      board: board ?? this.board,
      score: score ?? this.score,
      combo: combo ?? this.combo,
      maxCombo: maxCombo ?? this.maxCombo,
      removedCount: removedCount ?? this.removedCount,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      highScore: highScore ?? this.highScore,
      status: status ?? this.status,
      selectedTiles: selectedTiles ?? this.selectedTiles,
    );
  }
}
