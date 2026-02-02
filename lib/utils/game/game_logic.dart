import 'dart:math';
import '../../models/game/mold_tile_model.dart';
import '../../models/game/mold_game_state.dart';

/// 게임 로직 유틸리티
class GameLogic {
  static final Random _random = Random();

  /// 새 게임 보드 생성 (17x10 랜덤 숫자 배치)
  static List<List<MoldTileModel?>> generateBoard() {
    int id = 0;
    return List.generate(MoldGameState.rows, (row) {
      return List.generate(MoldGameState.cols, (col) {
        return MoldTileModel(
          id: id++,
          row: row,
          col: col,
          value: _random.nextInt(9) + 1, // 1~9
        );
      });
    });
  }

  /// 점수 계산
  /// - 2개: 10점
  /// - 3개: 30점
  /// - 4개: 60점
  /// - 5개 이상: 개수 × 20점
  static int calculateScore(int tileCount, int combo) {
    int baseScore;
    switch (tileCount) {
      case 2:
        baseScore = 10;
        break;
      case 3:
        baseScore = 30;
        break;
      case 4:
        baseScore = 60;
        break;
      default:
        baseScore = tileCount >= 5 ? tileCount * 20 : 0;
    }

    // 콤보 보너스 (콤보당 10% 추가)
    final comboMultiplier = 1.0 + (combo * 0.1);
    return (baseScore * comboMultiplier).round();
  }

  /// 올클리어 보너스 점수
  static const int allClearBonus = 500;

  /// 빠른 클리어 보너스 계산 (남은 시간 × 5점)
  static int calculateTimeBonus(int remainingSeconds) {
    return remainingSeconds * 5;
  }

  /// 사각형 영역 내의 타일 선택
  static Set<MoldTileModel> selectTilesInRect({
    required List<List<MoldTileModel?>> board,
    required int startRow,
    required int startCol,
    required int endRow,
    required int endCol,
  }) {
    final selected = <MoldTileModel>{};

    final minRow = min(startRow, endRow);
    final maxRow = max(startRow, endRow);
    final minCol = min(startCol, endCol);
    final maxCol = max(startCol, endCol);

    for (int row = minRow; row <= maxRow; row++) {
      for (int col = minCol; col <= maxCol; col++) {
        if (row >= 0 &&
            row < board.length &&
            col >= 0 &&
            col < board[row].length) {
          final tile = board[row][col];
          if (tile != null && !tile.isRemoved) {
            selected.add(tile);
          }
        }
      }
    }

    return selected;
  }

  /// 선택된 타일들의 합 계산
  static int calculateSum(Set<MoldTileModel> tiles) {
    return tiles.fold(0, (sum, tile) => sum + tile.value);
  }

  /// 합이 10인지 확인
  static bool isSumTen(Set<MoldTileModel> tiles) {
    return calculateSum(tiles) == 10;
  }

  /// 더 이상 합 10 조합이 가능한지 확인
  static bool hasValidCombination(List<List<MoldTileModel?>> board) {
    final activeTiles = <MoldTileModel>[];

    // 활성 타일 수집
    for (var row in board) {
      for (var tile in row) {
        if (tile != null && !tile.isRemoved) {
          activeTiles.add(tile);
        }
      }
    }

    if (activeTiles.isEmpty) return false;

    // 단순화된 검사: 2~5개 조합으로 합 10이 가능한지 확인
    // (완전 탐색은 비용이 크므로 인접 타일 기준으로 검사)
    return _checkCombinations(activeTiles, 0, 0, 5);
  }

  /// 재귀적으로 합 10 조합 확인
  static bool _checkCombinations(
    List<MoldTileModel> tiles,
    int index,
    int currentSum,
    int maxDepth,
  ) {
    if (currentSum == 10) return true;
    if (currentSum > 10) return false;
    if (index >= tiles.length || maxDepth <= 0) return false;

    // 현재 타일 포함
    if (_checkCombinations(
        tiles, index + 1, currentSum + tiles[index].value, maxDepth - 1)) {
      return true;
    }

    // 현재 타일 제외
    return _checkCombinations(tiles, index + 1, currentSum, maxDepth);
  }

  /// 시간 포맷팅 (MM:SS)
  static String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  /// 점수 포맷팅 (1,000 형식)
  static String formatScore(int score) {
    final scoreStr = score.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < scoreStr.length; i++) {
      if (i > 0 && (scoreStr.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(scoreStr[i]);
    }
    return buffer.toString();
  }
}
