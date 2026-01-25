import 'package:flutter/material.dart';
import '../models/iot_device.dart';

class IotProvider extends ChangeNotifier {
  List<IotDeviceModel> _devices = [];
  bool _isLoading = false;
  bool _isConnected = false; // Tuya 연동 여부

  List<IotDeviceModel> get devices => _devices;
  bool get isLoading => _isLoading;
  bool get isConnected => _isConnected;

  // 기기 목록 로드
  Future<void> loadDevices() async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Tuya API 연동
      await Future.delayed(const Duration(seconds: 1));

      // 더미 데이터
      _devices = IotDeviceModel.getDummyList();
      _isConnected = true;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 기기 제어
  Future<bool> controlDevice(String deviceId, bool turnOn) async {
    try {
      // TODO: Tuya API 연동
      await Future.delayed(const Duration(milliseconds: 500));

      // 로컬 상태 업데이트
      final index = _devices.indexWhere((d) => d.id == deviceId);
      if (index != -1) {
        _devices[index] = IotDeviceModel(
          id: _devices[index].id,
          name: _devices[index].name,
          type: _devices[index].type,
          productName: _devices[index].productName,
          isOnline: _devices[index].isOnline,
          isOn: turnOn,
        );
        notifyListeners();
      }

      return true;
    } catch (e) {
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
