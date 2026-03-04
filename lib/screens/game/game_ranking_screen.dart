import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/theme.dart';
import '../../services/game_service.dart';

/// 팡팡팡 게임 랭킹 화면
class GameRankingScreen extends StatefulWidget {
  const GameRankingScreen({super.key});

  @override
  State<GameRankingScreen> createState() => _GameRankingScreenState();
}

class _GameRankingScreenState extends State<GameRankingScreen> {
  final GameService _gameService = GameService();
  RankingResponse? _rankingData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // 세로 모드로 전환
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _loadRanking();
  }

  @override
  void dispose() {
    // 방향 잠금 해제
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  Future<void> _loadRanking() async {
    final data = await _gameService.getRanking();
    if (mounted) {
      setState(() {
        _rankingData = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.gray50,
      appBar: AppBar(
        title: const Text(
          '팡팡팡 랭킹',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppTheme.gray800,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.gray800),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.mintPrimary))
          : RefreshIndicator(
              onRefresh: _loadRanking,
              color: AppTheme.mintPrimary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildMyRankCard(),
                    const SizedBox(height: 20),
                    _buildRankingList(),
                  ],
                ),
              ),
            ),
    );
  }

  /// 내 순위 카드
  Widget _buildMyRankCard() {
    final myRank = _rankingData?.myRank;
    final myScore = _rankingData?.myBestScore;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.mintGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.mintPrimary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            '나의 순위',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (myRank != null && myRank <= 3)
                Text(
                  _getMedal(myRank),
                  style: const TextStyle(fontSize: 36),
                ),
              if (myRank != null && myRank <= 3) const SizedBox(width: 8),
              Text(
                myRank != null ? '$myRank위' : '-',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            myScore != null ? '최고점수: ${_formatScore(myScore)}' : '아직 기록이 없어요',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// 상위 10명 랭킹 리스트
  Widget _buildRankingList() {
    final rankings = _rankingData?.rankings ?? [];

    if (rankings.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        child: const Column(
          children: [
            Text('🎮', style: TextStyle(fontSize: 48)),
            SizedBox(height: 12),
            Text(
              '아직 랭킹 데이터가 없어요\n게임을 플레이해보세요!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.gray500,
                height: 1.5,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 헤더
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                const SizedBox(width: 40, child: Text('순위', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.gray500))),
                const Expanded(child: Text('닉네임', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.gray500))),
                const Text('점수', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.gray500)),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.gray200),
          // 랭킹 항목들
          ...rankings.map((entry) => _buildRankingItem(entry)),
        ],
      ),
    );
  }

  /// 랭킹 항목 위젯
  Widget _buildRankingItem(RankingEntry entry) {
    final isMyRank = _rankingData?.myRank == entry.rank &&
        _rankingData?.myBestScore == entry.bestScore;

    return Container(
      decoration: BoxDecoration(
        color: isMyRank ? AppTheme.mintLight : Colors.transparent,
        border: Border(
          bottom: BorderSide(color: AppTheme.gray100, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          // 순위
          SizedBox(
            width: 40,
            child: _buildRankBadge(entry.rank),
          ),
          // 닉네임
          Expanded(
            child: Text(
              entry.nickname,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isMyRank ? FontWeight.w700 : FontWeight.w500,
                color: isMyRank ? AppTheme.mintDark : AppTheme.gray800,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // 점수
          Text(
            _formatScore(entry.bestScore),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isMyRank ? AppTheme.mintDark : AppTheme.gray700,
            ),
          ),
        ],
      ),
    );
  }

  /// 순위에 맞는 메달 이모지 반환
  String _getMedal(int rank) {
    const medals = ['👑', '🥈', '🥉'];
    if (rank >= 1 && rank <= 3) return medals[rank - 1];
    return '';
  }

  /// 순위 뱃지 (1~3위 메달)
  Widget _buildRankBadge(int rank) {
    final medal = _getMedal(rank);
    if (medal.isNotEmpty) {
      return Text(medal, style: const TextStyle(fontSize: 20));
    }
    return Text(
      '#$rank',
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppTheme.gray500,
      ),
    );
  }

  /// 점수 포맷팅 (천 단위 콤마)
  String _formatScore(int score) {
    if (score >= 1000) {
      final thousands = score ~/ 1000;
      final remainder = score % 1000;
      return '$thousands,${remainder.toString().padLeft(3, '0')}';
    }
    return score.toString();
  }
}
