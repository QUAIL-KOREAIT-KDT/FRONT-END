// 네이티브용 - kpostal 사용

import 'package:flutter/material.dart';
import 'package:kpostal/kpostal.dart';

/// 네이티브에서 카카오 주소 검색 화면을 열고 결과 반환
Future<String?> openAddressSearch(BuildContext context) async {
  String? selectedAddress;

  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => KpostalView(
        useLocalServer: true,
        localPort: 8080,
        kakaoKey: '',
        callback: (Kpostal result) {
          // 도로명 주소 우선, 없으면 지번 주소 사용
          selectedAddress =
              result.address.isNotEmpty ? result.address : result.jibunAddress;
        },
      ),
    ),
  );

  return selectedAddress;
}
