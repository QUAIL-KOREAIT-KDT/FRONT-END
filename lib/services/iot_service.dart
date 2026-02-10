import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'api_service.dart';
import '../models/iot_device.dart';

/// IoT API 서비스
class IotService {
  final ApiService _apiService = ApiService();

  /// IoT 접근 권한 확인
  Future<IotAccessCheckResult> checkAccess() async {
    try {
      final response = await _apiService.dio.get('/iot/access-check');
      debugPrint('[IotService] 접근 권한 확인 성공');
      return IotAccessCheckResult(
        isMaster: response.data['is_master'] ?? false,
        message: response.data['message'] ?? '',
      );
    } on DioException catch (e) {
      debugPrint('[IotService] 접근 권한 확인 실패: ${e.response?.data}');
      rethrow;
    }
  }

  /// 기기 목록 조회
  Future<IotDeviceListResult> getDevices() async {
    try {
      final response = await _apiService.dio.get('/iot/devices');
      debugPrint('[IotService] 기기 목록 조회 성공');

      final List<dynamic> deviceList = response.data['devices'] ?? [];
      final devices =
          deviceList.map((json) => IotDeviceModel.fromJson(json)).toList();

      return IotDeviceListResult(
        isMaster: response.data['is_master'] ?? false,
        devices: devices,
      );
    } on DioException catch (e) {
      debugPrint('[IotService] 기기 목록 조회 실패: ${e.response?.data}');
      rethrow;
    }
  }

  /// 기기 제어 (ON/OFF)
  Future<IotControlResult> controlDevice(
      String deviceId, bool turnOn) async {
    try {
      final response = await _apiService.dio.post(
        '/iot/devices/$deviceId/control',
        data: {'turn_on': turnOn},
      );
      debugPrint('[IotService] 기기 제어 성공: $deviceId -> $turnOn');
      return IotControlResult(
        success: response.data['status'] == 'success',
        message: response.data['message'] ?? '',
        isOn: response.data['is_on'] ?? turnOn,
      );
    } on DioException catch (e) {
      debugPrint('[IotService] 기기 제어 실패: ${e.response?.data}');
      rethrow;
    }
  }
}

/// 접근 권한 확인 결과
class IotAccessCheckResult {
  final bool isMaster;
  final String message;
  IotAccessCheckResult({required this.isMaster, required this.message});
}

/// 기기 목록 결과
class IotDeviceListResult {
  final bool isMaster;
  final List<IotDeviceModel> devices;
  IotDeviceListResult({required this.isMaster, required this.devices});
}

/// 기기 제어 결과
class IotControlResult {
  final bool success;
  final String message;
  final bool isOn;
  IotControlResult({
    required this.success,
    required this.message,
    required this.isOn,
  });
}
