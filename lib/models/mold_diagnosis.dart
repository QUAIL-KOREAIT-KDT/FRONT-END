class MoldDiagnosisModel {
  final String id;
  final String moldType; // G1, G2, G3, G4, G5, G6, G7
  final String moldName;
  final String moldNameEn;
  final String severity; // early, middle, late
  final String location;
  final String? imageUrl;
  final List<String> solutions;
  final List<String> preventions;
  final DateTime diagnosedAt;

  MoldDiagnosisModel({
    required this.id,
    required this.moldType,
    required this.moldName,
    required this.moldNameEn,
    required this.severity,
    required this.location,
    this.imageUrl,
    required this.solutions,
    required this.preventions,
    required this.diagnosedAt,
  });

  factory MoldDiagnosisModel.fromJson(Map<String, dynamic> json) {
    return MoldDiagnosisModel(
      id: json['id'] ?? '',
      moldType: json['mold_type'] ?? '',
      moldName: json['mold_name'] ?? '',
      moldNameEn: json['mold_name_en'] ?? '',
      severity: json['severity'] ?? 'early',
      location: json['location'] ?? '',
      imageUrl: json['image_url'],
      solutions: List<String>.from(json['solutions'] ?? []),
      preventions: List<String>.from(json['preventions'] ?? []),
      diagnosedAt: json['diagnosed_at'] != null
          ? DateTime.parse(json['diagnosed_at'])
          : DateTime.now(),
    );
  }

  // 더미 데이터
  factory MoldDiagnosisModel.dummy() {
    return MoldDiagnosisModel(
      id: '1',
      moldType: 'G1',
      moldName: '검은 곰팡이',
      moldNameEn: 'Black Mold',
      severity: 'middle',
      location: '창가',
      imageUrl: null,
      solutions: [
        '마스크와 장갑을 착용하고 창문을 열어 환기시켜 주세요.',
        '곰팡이 제거제를 분사하고 15분간 방치 후 닦아주세요.',
        '결로 방지 필름을 창문에 부착하면 재발을 예방할 수 있어요.',
      ],
      preventions: [
        '환기를 자주 해주세요.',
        '습도를 60% 이하로 유지해주세요.',
        '결로가 생기면 바로 닦아주세요.',
      ],
      diagnosedAt: DateTime.now(),
    );
  }

  String get severityText {
    switch (severity) {
      case 'early':
        return '초기 단계';
      case 'middle':
        return '중기 단계';
      case 'late':
        return '말기 단계';
      default:
        return '알 수 없음';
    }
  }

  int get severityLevel {
    switch (severity) {
      case 'early':
        return 1;
      case 'middle':
        return 2;
      case 'late':
        return 3;
      default:
        return 0;
    }
  }
}
