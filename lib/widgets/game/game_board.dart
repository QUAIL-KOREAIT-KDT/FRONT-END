import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/theme.dart';
import '../../models/game/mold_tile_model.dart';
import '../../models/game/mold_game_state.dart';
import 'mold_tile.dart';

/// 17x10 게임 보드 위젯
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
  double _tileSize = 32;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 화면 크기에 맞게 타일 크기 계산 (패딩 없음)
        final tileWidth = constraints.maxWidth / MoldGameState.cols;
        final tileHeight = constraints.maxHeight / MoldGameState.rows;
        _tileSize = tileWidth < tileHeight ? tileWidth : tileHeight;

        return GestureDetector(
          onPanStart: _handlePanStart,
          onPanUpdate: _handlePanUpdate,
          onPanEnd: _handlePanEnd,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                // 격자판 - 좌측 상단 정렬 (터치 좌표 계산 정확도)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(MoldGameState.rows, (row) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(MoldGameState.cols, (col) {
                        final tile = widget.board[row][col];
                        if (tile == null) {
                          return SizedBox(
                            width: _tileSize,
                            height: _tileSize,
                          );
                        }

                        final isSelected = widget.selectedTiles.contains(tile);
                        final isPopping = widget.poppingTiles.contains(tile);

                        return AnimatedMoldTile(
                          tile: tile,
                          isSelected: isSelected,
                          shouldPop: isPopping,
                          size: _tileSize,
                        );
                      }),
                    );
                  }),
                ),

                // 선택 영역 표시
                if (_startRow != null && _endRow != null)
                  _buildSelectionOverlay(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectionOverlay() {
    final minRow = _startRow! < _endRow! ? _startRow! : _endRow!;
    final maxRow = _startRow! > _endRow! ? _startRow! : _endRow!;
    final minCol = _startCol! < _endCol! ? _startCol! : _endCol!;
    final maxCol = _startCol! > _endCol! ? _startCol! : _endCol!;

    final left = minCol * _tileSize;
    final top = minRow * _tileSize;
    final width = (maxCol - minCol + 1) * _tileSize;
    final height = (maxRow - minRow + 1) * _tileSize;

    // 합계에 따른 테두리 색상
    Color borderColor;
    if (widget.currentSum == 10) {
      borderColor = const Color(0xFFFF6B6B); // 빨간색 (터뜨릴 수 있음)
    } else if (widget.currentSum > 10) {
      borderColor = AppTheme.gray400; // 회색 (불가능)
    } else {
      borderColor = AppTheme.mintPrimary; // 민트색 (계속 가능)
    }

    return Positioned(
      left: left,
      top: top,
      child: IgnorePointer(
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            border: Border.all(color: borderColor, width: 3),
            borderRadius: BorderRadius.circular(8),
            color: borderColor.withOpacity(0.1),
          ),
        ),
      ),
    );
  }

  void _handlePanStart(DragStartDetails details) {
    final position = details.localPosition;
    final row = (position.dy / _tileSize).floor();
    final col = (position.dx / _tileSize).floor();

    if (row >= 0 &&
        row < MoldGameState.rows &&
        col >= 0 &&
        col < MoldGameState.cols) {
      // 터치 시 매우 짧은 진동
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
    final row =
        (position.dy / _tileSize).floor().clamp(0, MoldGameState.rows - 1);
    final col =
        (position.dx / _tileSize).floor().clamp(0, MoldGameState.cols - 1);

    if (row != _endRow || col != _endCol) {
      // 새 타일 선택 시 매우 짧은 진동
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
}
