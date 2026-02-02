/// 개별 곰팡이 타일 데이터 모델
class MoldTileModel {
  final int id;
  final int row;
  final int col;
  final int value; // 1~9
  bool isRemoved;
  bool isSelected;

  MoldTileModel({
    required this.id,
    required this.row,
    required this.col,
    required this.value,
    this.isRemoved = false,
    this.isSelected = false,
  });

  /// 타일 복사본 생성
  MoldTileModel copyWith({
    int? id,
    int? row,
    int? col,
    int? value,
    bool? isRemoved,
    bool? isSelected,
  }) {
    return MoldTileModel(
      id: id ?? this.id,
      row: row ?? this.row,
      col: col ?? this.col,
      value: value ?? this.value,
      isRemoved: isRemoved ?? this.isRemoved,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MoldTileModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'MoldTileModel(id: $id, row: $row, col: $col, value: $value, isRemoved: $isRemoved)';
  }
}
