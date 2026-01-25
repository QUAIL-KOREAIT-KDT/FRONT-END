import 'package:flutter/material.dart';
import '../models/mold_risk.dart';
import '../models/weather.dart';

class MoldRiskProvider extends ChangeNotifier {
  MoldRiskModel? _moldRisk;
  WeatherModel? _weather;
  bool _isLoading = false;

  MoldRiskModel? get moldRisk => _moldRisk;
  WeatherModel? get weather => _weather;
  bool get isLoading => _isLoading;

  // 위험도 및 날씨 데이터 로드
  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: API 연동
      await Future.delayed(const Duration(seconds: 1));

      // 더미 데이터
      _moldRisk = MoldRiskModel.dummy();
      _weather = WeatherModel.dummy();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 새로고침
  Future<void> refresh() async {
    await loadData();
  }
}
