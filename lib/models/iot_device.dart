class IotDeviceModel {
  final String id;
  final String name;
  final String type; // plug, dehumidifier, air_conditioner, fan
  final String? productName;
  final bool isOnline;
  final bool isOn;

  IotDeviceModel({
    required this.id,
    required this.name,
    required this.type,
    this.productName,
    required this.isOnline,
    required this.isOn,
  });

  factory IotDeviceModel.fromJson(Map<String, dynamic> json) {
    return IotDeviceModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? 'plug',
      productName: json['product_name'],
      isOnline: json['is_online'] ?? false,
      isOn: json['is_on'] ?? false,
    );
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
}
