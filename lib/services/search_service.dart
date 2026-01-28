import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'api_service.dart';

/// RAG 검색 응답 모델
class SearchResponse {
  final String question;
  final String answer;

  SearchResponse({
    required this.question,
    required this.answer,
  });

  factory SearchResponse.fromJson(Map<String, dynamic> json) {
    return SearchResponse(
      question: json['question'] ?? '',
      answer: json['answer'] ?? '',
    );
  }

  /// 더미 데이터
  static SearchResponse dummy(String query) {
    return SearchResponse(
      question: query,
      answer: '곰팡이 관련 질문에 대한 답변입니다. 곰팡이는 습한 환경에서 잘 자라며, 환기와 제습이 중요합니다.',
    );
  }
}

/// RAG 검색 API 서비스
class SearchService {
  final ApiService _apiService = ApiService();

  /// 곰팡이 관련 질의응답
  Future<SearchResponse> searchQuery(String query) async {
    try {
      final response = await _apiService.dio.get(
        '/search/query',
        queryParameters: {'q': query},
      );
      debugPrint('[SearchService] 검색 성공');
      return SearchResponse.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('[SearchService] 검색 실패: ${e.response?.data}');
      debugPrint('[SearchService] 더미 데이터 사용');
      return SearchResponse.dummy(query);
    }
  }
}
