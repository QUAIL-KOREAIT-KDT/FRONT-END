import 'package:flutter/material.dart';
import '../models/iot_device.dart';
import '../services/iot_service.dart';

class IotProvider extends ChangeNotifier {
  List<IotDeviceModel> _devices = [];
  bool _isLoading = false;
  bool _isConnected = false; // Tuya 연동 여부
  bool _isMaster = false; // 마스터 유저 여부
  String? _errorMessage;

  final IotService _iotService = IotService();

  List<IotDeviceModel> get devices => _devices;
  bool get isLoading => _isLoading;
  bool get isConnected => _isConnected;
  bool get isMaster => _isMaster;
  String? get errorMessage => _errorMessage;

  // 접근 권한 확인 + 기기 목록 로드
  Future<void> loadDevices() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. 접근 권한 확인
      final accessResult = await _iotService.checkAccess();
      _isMaster = accessResult.isMaster;

      if (!_isMaster) {
        _devices = [];
        _isConnected = false;
        _isLoading = false;
        notifyListeners();
        return;
      }

      // 2. 마스터 유저만 기기 목록 로드
      final result = await _iotService.getDevices();
      _devices = result.devices;
      _isConnected = true;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('[IotProvider] 기기 로드 실패: $e');
      _errorMessage = '기기 정보를 불러올 수 없습니다.';
      _isLoading = false;
      notifyListeners();
    }
  }

  // 기기 제어
  Future<bool> controlDevice(String deviceId, bool turnOn) async {
    try {
      final result = await _iotService.controlDevice(deviceId, turnOn);

      if (result.success) {
        // 로컬 상태 업데이트
        final index = _devices.indexWhere((d) => d.id == deviceId);
        if (index != -1) {
          _devices[index] = IotDeviceModel(
            id: _devices[index].id,
            name: _devices[index].name,
            type: _devices[index].type,
            productName: _devices[index].productName,
            isOnline: _devices[index].isOnline,
            isOn: result.isOn,
          );
          notifyListeners();
        }
      }

      return result.success;
    } catch (e) {
      debugPrint('[IotProvider] 기기 제어 실패: $e');
      return false;
    }
  }

  // Tuya 연동 해제
  void disconnect() {
    _devices = [];
    _isConnected = false;
    notifyListeners();
  }
}
