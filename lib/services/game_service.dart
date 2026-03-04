import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'api_service.dart';

/// 랭킹 항목 모델
class RankingEntry {
  final int rank;
  final String nickname;
  final int bestScore;

  RankingEntry({
    required this.rank,
    required this.nickname,
    required this.bestScore,
  });

  factory RankingEntry.fromJson(Map<String, dynamic> json) {
    return RankingEntry(
      rank: json['rank'] ?? 0,
      nickname: json['nickname'] ?? '',
      bestScore: json['best_score'] ?? 0,
    );
  }
}

/// 랭킹 응답 모델
class RankingResponse {
  final List<RankingEntry> rankings;
  final int? myRank;
  final int? myBestScore;

  RankingResponse({
    required this.rankings,
    this.myRank,
    this.myBestScore,
  });

  factory RankingResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['rankings'] as List<dynamic>?)
            ?.map((e) => RankingEntry.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    return RankingResponse(
      rankings: list,
      myRank: json['my_rank'],
      myBestScore: json['my_best_score'],
    );
  }
}

/// 게임 API 서비스
class GameService {
  final ApiService _apiService = ApiService();

  /// 게임 종료 시 점수 제출
  Future<void> submitScore(int score) async {
    try {
      await _apiService.dio.post('/game/score', data: {'score': score});
      debugPrint('[GameService] 점수 제출 성공: $score');
    } on DioException catch (e) {
      debugPrint('[GameService] 점수 제출 실패: ${e.message}');
    }
  }

  /// 상위 10명 랭킹 + 내 순위 조회
  Future<RankingResponse> getRanking() async {
    try {
      final response = await _apiService.dio.get('/game/ranking');
      debugPrint('[GameService] 랭킹 조회 성공');
      return RankingResponse.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('[GameService] 랭킹 조회 실패: ${e.message}');
      return RankingResponse(rankings: []);
    }
  }
}
