import 'package:flutter/material.dart';
import '../models/mold_category.dart';
import '../services/dictionary_service.dart';

/// label(G1~G5) → 카테고리 메타정보 매핑
class _CategoryMeta {
  final String id;
  final String name;
  final String description;
  final List<Color> gradientColors;
  final String emoji;

  const _CategoryMeta({
    required this.id,
    required this.name,
    required this.description,
    required this.gradientColors,
    required this.emoji,
  });
}

const _labelMetaMap = <String, _CategoryMeta>{
  'G1': _CategoryMeta(
    id: 'G1',
    name: '검은 곰팡이',
    description: '가장 흔한 유형, 습한 벽면에 발생',
    gradientColors: [Color(0xFF2D3436), Color(0xFF636E72)],
    emoji: '🦠',
  ),
  'G2': _CategoryMeta(
    id: 'G2',
    name: '푸른 곰팡이',
    description: '음식물, 습한 실내에서 발생',
    gradientColors: [Color(0xFF00B894), Color(0xFF55EFC4)],
    emoji: '🦠',
  ),
  'G3': _CategoryMeta(
    id: 'G3',
    name: '흰 곰팡이',
    description: '초기 균사체 형태, 음식물',
    gradientColors: [Color(0xFFDFE6E9), Color(0xFFFFFFFF)],
    emoji: '🦠',
  ),
  'G4': _CategoryMeta(
    id: 'G4',
    name: '붉은 곰팡이',
    description: '주로 욕실에서 발견',
    gradientColors: [Color(0xFFE17055), Color(0xFFFAB1A0)],
    emoji: '🧫',
  ),
  'G5': _CategoryMeta(
    id: 'G5',
    name: '백화현상',
    description: '곰팡이가 아닌 소금 결정 현상',
    gradientColors: [Color(0xFFB2BEC3), Color(0xFFDFE6E9)],
    emoji: '⚪',
  ),
};

class DictionaryProvider extends ChangeNotifier {
  final DictionaryService _service = DictionaryService();

  List<MoldCategory> _categories = [];
  bool _isLoading = false;
  bool _hasError = false;
  bool _isLoaded = false;

  List<MoldCategory> get categories => _categories;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  bool get isLoaded => _isLoaded;

  /// API에서 도감 목록을 가져와 카테고리별로 그룹핑
  Future<void> loadDictionary() async {
    if (_isLoaded && _categories.isNotEmpty) return;

    _isLoading = true;
    _hasError = false;
    notifyListeners();

    try {
      final responses = await _service.getDictionaryList();
      _categories = _groupByLabel(responses);
      _isLoaded = true;
    } catch (e) {
      debugPrint('[DictionaryProvider] 로드 실패: $e');
      _categories = MoldCategory.getCategories();
      _hasError = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 강제 새로고침
  Future<void> refresh() async {
    _isLoaded = false;
    await loadDictionary();
  }

  /// DictionaryResponse 리스트를 label별로 그룹핑하여 MoldCategory 리스트로 변환
  List<MoldCategory> _groupByLabel(List<DictionaryResponse> responses) {
    // label별로 그룹핑
    final grouped = <String, List<DictionaryResponse>>{};
    for (final resp in responses) {
      grouped.putIfAbsent(resp.label, () => []).add(resp);
    }

    // label 순서 보장 (G1, G2, G3, G4, G5)
    final sortedLabels = grouped.keys.toList()..sort();

    final categories = <MoldCategory>[];
    for (final label in sortedLabels) {
      final meta = _labelMetaMap[label];
      if (meta == null) continue;

      final subTypes = grouped[label]!
          .map((resp) => resp.toMoldSubType())
          .toList();

      categories.add(MoldCategory(
        id: meta.id,
        name: meta.name,
        description: meta.description,
        gradientColors: meta.gradientColors,
        emoji: meta.emoji,
        subTypes: subTypes,
      ));
    }

    return categories;
  }
}
