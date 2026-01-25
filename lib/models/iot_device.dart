class IotDeviceModel {
  final String id;
  final String name;
  final String type; // plug, dehumidifier, air_conditioner, fan
  final String? productName;
  final bool isOnline;
  final bool isOn;
  final String? icon;

  IotDeviceModel({
    required this.id,
    required this.name,
    required this.type,
    this.productName,
    required this.isOnline,
    required this.isOn,
    this.icon,
  });

  factory IotDeviceModel.fromJson(Map<String, dynamic> json) {
    return IotDeviceModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? 'plug',
      productName: json['product_name'],
      isOnline: json['is_online'] ?? false,
      isOn: json['is_on'] ?? false,
      icon: json['icon'],
    );
  }

  String get typeIcon {
    switch (type) {
      case 'dehumidifier':
        return '💨';
      case 'air_conditioner':
        return '❄️';
      case 'fan':
        return '🌀';
      case 'plug':
      default:
        return '🔌';
    }
  }

  String get typeName {
    switch (type) {
      case 'dehumidifier':
        return '제습기';
      case 'air_conditioner':
        return '에어컨';
      case 'fan':
        return '선풍기';
      case 'plug':
      default:
        return '스마트 플러그';
    }
  }

  // 더미 데이터
  static List<IotDeviceModel> getDummyList() {
    return [
      IotDeviceModel(
        id: '1',
        name: '거실 스마트 플러그',
        type: 'plug',
        productName: 'Smart Life Plug',
        isOnline: true,
        isOn: false,
      ),
      IotDeviceModel(
        id: '2',
        name: '안방 제습기',
        type: 'dehumidifier',
        productName: 'Smart Dehumidifier',
        isOnline: true,
        isOn: true,
      ),
    ];
  }
}
