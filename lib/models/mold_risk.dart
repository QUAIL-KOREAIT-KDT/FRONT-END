class MoldRiskModel {
  final int riskPercentage;
  final String riskLevel; // safe, caution, warning, danger
  final String recommendation;
  final String? ventilationTimeStart;
  final String? ventilationTimeEnd;
  final DateTime updatedAt;

  MoldRiskModel({
    required this.riskPercentage,
    required this.riskLevel,
    required this.recommendation,
    this.ventilationTimeStart,
    this.ventilationTimeEnd,
    required this.updatedAt,
  });

  factory MoldRiskModel.fromJson(Map<String, dynamic> json) {
    return MoldRiskModel(
      riskPercentage: json['risk_percentage'] ?? 0,
      riskLevel: json['risk_level'] ?? 'safe',
      recommendation: json['recommendation'] ?? '',
      ventilationTimeStart: json['ventilation_time_start'],
      ventilationTimeEnd: json['ventilation_time_end'],
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  // 더미 데이터
  factory MoldRiskModel.dummy() {
    return MoldRiskModel(
      riskPercentage: 20,
      riskLevel: 'safe',
      recommendation: '오전 10시~12시 사이에 10분간 환기를 추천해요!',
      ventilationTimeStart: '10:00',
      ventilationTimeEnd: '12:00',
      updatedAt: DateTime.now(),
    );
  }
}
