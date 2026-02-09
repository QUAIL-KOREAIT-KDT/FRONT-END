import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/theme.dart';
import '../../models/game/mold_tile_model.dart';
import '../../models/game/mold_game_state.dart';
import 'mold_tile.dart';

/// 18x9 게임 보드 위젯
class GameBoard extends StatefulWidget {
  final List<List<MoldTileModel?>> board;
  final Set<MoldTileModel> selectedTiles;
  final Set<MoldTileModel> poppingTiles;
  final int currentSum;
  final Function(int startRow, int startCol)? onDragStart;
  final Function(int endRow, int endCol)? onDragUpdate;
  final VoidCallback? onDragEnd;

  const GameBoard({
    super.key,
    required this.board,
    this.selectedTiles = const {},
    this.poppingTiles = const {},
    this.currentSum = 0,
    this.onDragStart,
    this.onDragUpdate,
    this.onDragEnd,
  });

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  int? _startRow;
  int? _startCol;
  int? _endRow;
  int? _endCol;
  double _tileSize = 32; // 정사각형 타일 크기

  static const double _spacing = 3.0; // 타일 간 간격

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 정사각형 타일 크기 계산 (가로/세로 중 작은 쪽에 맞춤)
        final availableWidth = constraints.maxWidth;
        final availableHeight = constraints.maxHeight;

        // 간격을 고려한 타일 크기 계산
        final maxTileWidth =
            (availableWidth - (_spacing * (MoldGameState.cols - 1))) /
                MoldGameState.cols;
        final maxTileHeight =
            (availableHeight - (_spacing * (MoldGameState.rows - 1))) /
                MoldGameState.rows;

        // 정사각형 유지: 작은 쪽에 맞춤
        _tileSize = maxTileWidth < maxTileHeight ? maxTileWidth : maxTileHeight;

        // 보드 전체 크기 계산
        final boardWidth = (_tileSize * MoldGameState.cols) +
            (_spacing * (MoldGameState.cols - 1));
        final boardHeight = (_tileSize * MoldGameState.rows) +
            (_spacing * (MoldGameState.rows - 1));

        return Center(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque, // 빈 영역도 터치 이벤트 받음
            onPanStart: _handlePanStart,
            onPanUpdate: _handlePanUpdate,
            onPanEnd: _handlePanEnd,
            child: SizedBox(
              width: boardWidth,
              height: boardHeight,
              child: Stack(
                children: [
                  // 격자판 - 간격 포함
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(MoldGameState.rows, (row) {
                      return Padding(
                        padding: EdgeInsets.only(
                            bottom:
                                row < MoldGameState.rows - 1 ? _spacing : 0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(MoldGameState.cols, (col) {
                            final tile = widget.board[row][col];

                            return Padding(
                              padding: EdgeInsets.only(
                                  right: col < MoldGameState.cols - 1
                                      ? _spacing
                                      : 0),
                              child: tile == null
                                  ? SizedBox(
                                      width: _tileSize, height: _tileSize)
                                  : AnimatedMoldTile(
                                      key: ValueKey(
                                          tile.id), // Unique key로 깜빡임 방지
                                      tile: tile,
                                      isSelected:
                                          widget.selectedTiles.contains(tile),
                                      shouldPop:
                                          widget.poppingTiles.contains(tile),
                                      tileSize: _tileSize,
                                    ),
                            );
                          }),
                        ),
                      );
                    }),
                  ),

                  // 선택 영역 표시
                  if (_startRow != null && _endRow != null)
                    _buildSelectionOverlay(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// 타일 인덱스에서 실제 픽셀 좌표 계산 (간격 포함)
  double _colToX(int col) => col * (_tileSize + _spacing);
  double _rowToY(int row) => row * (_tileSize + _spacing);

  Widget _buildSelectionOverlay() {
    final minRow = _startRow! < _endRow! ? _startRow! : _endRow!;
    final maxRow = _startRow! > _endRow! ? _startRow! : _endRow!;
    final minCol = _startCol! < _endCol! ? _startCol! : _endCol!;
    final maxCol = _startCol! > _endCol! ? _startCol! : _endCol!;

    final left = _colToX(minCol);
    final top = _rowToY(minRow);
    final width = _colToX(maxCol) + _tileSize - left;
    final height = _rowToY(maxRow) + _tileSize - top;

    Color borderColor;
    if (widget.currentSum == 10) {
      borderColor = const Color(0xFFFF6B6B);
    } else if (widget.currentSum > 10) {
      borderColor = AppTheme.gray400;
    } else {
      borderColor = AppTheme.mintPrimary;
    }

    return Positioned(
      left: left,
      top: top,
      child: IgnorePointer(
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            border: Border.all(color: borderColor, width: 2.5),
            borderRadius: BorderRadius.circular(8),
            color: borderColor.withOpacity(0.1),
          ),
        ),
      ),
    );
  }

  void _handlePanStart(DragStartDetails details) {
    final position = details.localPosition;
    final col = _posToCol(position.dx);
    final row = _posToRow(position.dy);

    // 빈 타일이든 곰팡이 타일이든 보드 범위 안이면 드래그 시작 가능
    if (row >= 0 &&
        row < MoldGameState.rows &&
        col >= 0 &&
        col < MoldGameState.cols) {
      HapticFeedback.lightImpact();
      setState(() {
        _startRow = row;
        _startCol = col;
        _endRow = row;
        _endCol = col;
      });
      widget.onDragStart?.call(row, col);
    }
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (_startRow == null) return;

    final position = details.localPosition;
    final row = _posToRow(position.dy).clamp(0, MoldGameState.rows - 1);
    final col = _posToCol(position.dx).clamp(0, MoldGameState.cols - 1);

    if (row != _endRow || col != _endCol) {
      HapticFeedback.lightImpact();
      setState(() {
        _endRow = row;
        _endCol = col;
      });
      widget.onDragUpdate?.call(row, col);
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    widget.onDragEnd?.call();
    setState(() {
      _startRow = null;
      _startCol = null;
      _endRow = null;
      _endCol = null;
    });
  }

  /// 픽셀 좌표 → 타일 인덱스 (간격 포함)
  int _posToCol(double x) => (x / (_tileSize + _spacing)).floor();
  int _posToRow(double y) => (y / (_tileSize + _spacing)).floor();
}
