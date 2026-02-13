import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../services/user_service.dart';
import '../../services/mypage_service.dart';
import '../../providers/user_provider.dart';
import '../../providers/notification_provider.dart';
import '../diagnosis_result_screen.dart' show RagSolution;

class MypageScreen extends StatefulWidget {
  final bool resetFilter;

  const MypageScreen({super.key, this.resetFilter = false});

  @override
  State<MypageScreen> createState() => _MypageScreenState();
}

class _MypageScreenState extends State<MypageScreen> {
  // 필터 선택
  String _selectedFilter = '전체';
  final List<String> _filters = ['전체', '창문', '벽지', '주방', '욕실', '음식', '기타'];

  // 필터 탭 스크롤 컨트롤러
  final ScrollController _filterScrollController = ScrollController();

  // 기록 리스트 스크롤 컨트롤러
  final ScrollController _recordListScrollController = ScrollController();

  // API 서비스
  final MyPageService _myPageService = MyPageService();

  // 진단 기록 데이터
  List<DiagnosisThumbnail> _diagnosisRecords = [];
  bool _isLoading = true;
  bool _isProcessing = false; // CRUD 작업 중 로딩 상태
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // 마이페이지 진입 시 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().loadUser();
      _loadDiagnosisHistory();
    });
  }

  @override
  void dispose() {
    _filterScrollController.dispose();
    _recordListScrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant MypageScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 탭 전환으로 다시 표시될 때 필터 및 스크롤 위치 초기화
    if (widget.resetFilter && !oldWidget.resetFilter) {
      setState(() {
        _selectedFilter = '전체';
      });
      // 필터 스크롤 위치도 초기화
      if (_filterScrollController.hasClients) {
        _filterScrollController.jumpTo(0);
      }
      // 기록 리스트 스크롤 위치도 초기화
      if (_recordListScrollController.hasClients) {
        _recordListScrollController.jumpTo(0);
      }
    }
  }

  Future<void> _loadDiagnosisHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final records = await _myPageService.getDiagnosisHistory();
      if (mounted) {
        setState(() {
          _diagnosisRecords = records;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = '기록을 불러올 수 없습니다';
          _isLoading = false;
        });
      }
    }
  }

  /// 필터 라벨 → 백엔드 location enum 매핑
  static const Map<String, String> _filterToLocation = {
    '창문': 'windows',
    '벽지': 'wallpaper',
    '주방': 'kitchen',
    '욕실': 'bathroom',
    '음식': 'food',
    '기타': 'living_room',
  };

  /// 곰팡이 결과 코드 → 한글명 매핑
  static String getMoldResultName(String result) {
    switch (result.toUpperCase()) {
      case 'G0':
        return '곰팡이 미검출';
      case 'G1':
        return '검은곰팡이';
      case 'G2':
        return '푸른/초록 곰팡이';
      case 'G3':
        return '하얀 곰팡이 / 백화현상';
      case 'G4':
        return '붉은 곰팡이 / 박테리아';
      case 'MULTI':
        return '복합 곰팡이';
      case 'UNCLASSIFIED':
        return '재진단 필요';
      default:
        return result.isNotEmpty ? result : '재진단 필요';
    }
  }

  List<DiagnosisThumbnail> get _filteredRecords {
    if (_selectedFilter == '전체') return _diagnosisRecords;
    final locationEnum = _filterToLocation[_selectedFilter];
    if (locationEnum == null) return _diagnosisRecords;
    return _diagnosisRecords
        .where((r) => r.moldLocation == locationEnum)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // 헤더
                _buildHeader(context),

                // 프로필 카드
                _buildProfileCard(),

                // 분석 기록 섹션
                Expanded(
                  child: _buildAnalysisSection(),
                ),
              ],
            ),
            // 로딩 오버레이
            if (_isProcessing) _buildLoadingOverlay(),
          ],
        ),
      ),
    );
  }

  /// 로딩 오버레이 위젯
  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.4),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(
                  strokeWidth: 4,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppTheme.mintPrimary),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '처리 중...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.gray700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '👤',
                style: TextStyle(fontSize: 28),
              ),
              const SizedBox(width: 10),
              const Text(
                '마이페이지',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.gray800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            '진단 기록을 관리하세요',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.gray400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    final userProvider = context.watch<UserProvider>();
    final nickname = userProvider.user?.nickname ?? '회원님';

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.mintLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // 프로필 이미지
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: AppTheme.mintLight2, width: 2),
                ),
                child: ClipOval(
                  child: Image.network(
                    'https://via.placeholder.com/56',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppTheme.gray100,
                        child: const Icon(
                          Icons.person_rounded,
                          color: AppTheme.gray400,
                          size: 32,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // 사용자 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nickname,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.gray800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'heewon@kakao.com',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.gray500,
                      ),
                    ),
                  ],
                ),
              ),
              // 수정 버튼
              GestureDetector(
                onTap: () => _showNicknameEditModal(),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.edit_outlined,
                        size: 18,
                        color: AppTheme.mintPrimary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '수정',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.mintPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 🧪 테스트 알림 버튼
          _buildTestNotificationButton(),
        ],
      ),
    );
  }

  /// 테스트 알림 전송 버튼
  Widget _buildTestNotificationButton() {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, _) {
        return GestureDetector(
          onTap: () async {
            // 로딩 표시
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text('테스트 알림 전송 중...'),
                  ],
                ),
                duration: Duration(seconds: 1),
              ),
            );

            // 테스트 알림 전송
            final success = await notificationProvider.sendTestNotification();

            if (mounted) {
              // 결과 표시
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(
                        success ? Icons.check_circle : Icons.error,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        success
                            ? '✅ 테스트 알림이 전송되었습니다!'
                            : '❌ 전송 실패 (FCM 토큰 확인 필요)',
                      ),
                    ],
                  ),
                  backgroundColor:
                      success ? AppTheme.mintPrimary : AppTheme.danger,
                  duration: const Duration(seconds: 3),
                ),
              );

              // 성공 시 알림 목록 새로고침
              if (success) {
                await Future.delayed(const Duration(seconds: 1));
                notificationProvider.fetchNotifications();
              }
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.mintPrimary.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🧪', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(
                  '테스트 알림 보내기',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.mintPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.notifications_active_outlined,
                  size: 18,
                  color: AppTheme.mintPrimary,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnalysisSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 섹션 헤더
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              const Text(
                '📋',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(width: 8),
              const Text(
                '곰팡이 분석 기록',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.gray800,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '총 ${_diagnosisRecords.length}건',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.gray400,
                ),
              ),
              const Spacer(),
              // 새로고침 버튼
              GestureDetector(
                onTap: _loadDiagnosisHistory,
                child: Icon(
                  Icons.refresh_rounded,
                  color: AppTheme.gray400,
                  size: 20,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 필터 탭
        if (_diagnosisRecords.isNotEmpty) _buildFilterTabs(),

        const SizedBox(height: 16),

        // 기록 리스트 또는 빈 상태
        Expanded(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppTheme.mintPrimary),
                )
              : _errorMessage != null
                  ? Center(child: Text(_errorMessage!))
                  : _diagnosisRecords.isEmpty
                      ? _buildEmptyState()
                      : _buildRecordList(),
        ),
      ],
    );
  }

  Widget _buildFilterTabs() {
    return SingleChildScrollView(
      controller: _filterScrollController,
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: _filters.asMap().entries.map((entry) {
          final index = entry.key;
          final filter = entry.value;
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: EdgeInsets.only(
              right: index < _filters.length - 1 ? 8 : 0,
            ),
            child: GestureDetector(
              onTap: () => setState(() => _selectedFilter = filter),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.mintPrimary : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppTheme.mintPrimary : AppTheme.gray200,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (filter != '전체') ...[
                      Text(
                        _getFilterIcon(filter),
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      filter,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : AppTheme.gray600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getFilterIcon(String filter) {
    switch (filter) {
      case '창문':
        return '🪟';
      case '벽지':
        return '🧱';
      case '주방':
        return '🍳';
      case '욕실':
        return '🚿';
      case '음식':
        return '🍞';
      case '기타':
        return '📦';
      default:
        return '';
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppTheme.gray100,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.search_off_rounded,
                size: 48,
                color: AppTheme.gray300,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '기록이 없습니다',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.gray700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '아직 곰팡이 진단 기록이 없어요.\n첫 번째 진단을 시작해보세요!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.gray400,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.diagnosis),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.mintPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.camera_alt_outlined, color: Colors.white),
            label: const Text(
              '곰팡이 진단하기',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 80), // 하단 네비게이션 여유 공간
        ],
      ),
    );
  }

  Widget _buildRecordList() {
    return RefreshIndicator(
      onRefresh: _loadDiagnosisHistory,
      color: AppTheme.mintPrimary,
      child: ListView.builder(
        controller: _recordListScrollController,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _filteredRecords.length,
        itemBuilder: (context, index) {
          final record = _filteredRecords[index];
          return _buildRecordCard(record);
        },
      ),
    );
  }

  Widget _buildRecordCard(DiagnosisThumbnail record) {
    return GestureDetector(
      onTap: () => _showDiagnosisDetail(record.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.gray200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // 곰팡이 이미지
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppTheme.gray100,
                borderRadius: BorderRadius.circular(12),
                image: record.imagePath.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(record.imagePath),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: record.imagePath.isEmpty
                  ? const Center(
                      child: Text('🦠', style: TextStyle(fontSize: 32)),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            // 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          record.result.isNotEmpty
                              ? getMoldResultName(record.result)
                              : '진단 기록 #${record.id}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.gray800,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (record.result.isNotEmpty &&
                          record.locationKorean.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Text(
                          record.locationKorean,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.gray500,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    record.formattedDate,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.gray400,
                    ),
                  ),
                ],
              ),
            ),
            // 삭제 버튼
            IconButton(
              onPressed: () => _showDeleteConfirmDialog(record),
              icon: Icon(
                Icons.delete_outline_rounded,
                color: AppTheme.gray400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDiagnosisDetail(int id) async {
    // 로딩 오버레이 표시
    setState(() => _isProcessing = true);

    try {
      final detail = await _myPageService.getDiagnosisInfo(id);

      // 로딩 오버레이 숨김
      if (mounted) {
        setState(() => _isProcessing = false);
      }

      if (mounted) {
        // RAG 솔루션 파싱
        final ragSolution = RagSolution.parse(detail.modelSolution);

        showDialog(
          context: context,
          builder: (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 헤더
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.mintPrimary.withOpacity(0.1),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Text('📋', style: TextStyle(fontSize: 24)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '진단 결과: ${getMoldResultName(detail.result)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.gray800,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${detail.locationKorean} · ${detail.formattedDate}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.gray500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppTheme.gray200,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.close_rounded,
                              color: AppTheme.gray600,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 이미지 표시 (CAM 이미지 우선, 없으면 원본)
                  if (detail.displayImagePath.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      height: 260,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.gray200),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.network(
                          detail.displayImagePath,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                color: AppTheme.mintPrimary,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppTheme.gray100,
                              child: const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('🦠', style: TextStyle(fontSize: 48)),
                                    SizedBox(height: 8),
                                    Text(
                                      '이미지를 불러올 수 없습니다',
                                      style: TextStyle(
                                        color: AppTheme.gray400,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                  // 드래그 인디케이터
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 4, bottom: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.gray300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // 스크롤 가능한 내용 (신뢰도 포함)
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 신뢰도 배지 (높을수록 초록색, 낮을수록 빨간색)
                          Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: detail.confidencePercent >= 80
                                  ? Colors.green.withOpacity(0.1)
                                  : detail.confidencePercent >= 60
                                      ? AppTheme.warning.withOpacity(0.1)
                                      : AppTheme.danger.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: detail.confidencePercent >= 80
                                    ? Colors.green.withOpacity(0.3)
                                    : detail.confidencePercent >= 60
                                        ? AppTheme.warning.withOpacity(0.3)
                                        : AppTheme.danger.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.analytics_rounded,
                                  color: detail.confidencePercent >= 80
                                      ? Colors.green
                                      : detail.confidencePercent >= 60
                                          ? AppTheme.warning
                                          : AppTheme.danger,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '신뢰도: ${detail.confidence.toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: detail.confidencePercent >= 80
                                        ? Colors.green
                                        : detail.confidencePercent >= 60
                                            ? AppTheme.warning
                                            : AppTheme.danger,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // 🔬 진단 결과
                          if (ragSolution.diagnosis.isNotEmpty) ...[
                            _buildSectionTitle('🔬', '진단 결과'),
                            _buildSectionContent(ragSolution.diagnosis),
                            const SizedBox(height: 16),
                          ],

                          // 📍 발생 장소
                          if (ragSolution
                              .frequentlyVisitedAreas.isNotEmpty) ...[
                            _buildSectionTitle('📍', '주요 발생 장소'),
                            ...ragSolution.frequentlyVisitedAreas
                                .map((area) => _buildBulletItem(area)),
                            const SizedBox(height: 16),
                          ],

                          // 💡 해결 방법
                          if (ragSolution.solutions.isNotEmpty) ...[
                            _buildSectionTitle('💡', '해결 방법'),
                            ...ragSolution.solutions
                                .map((sol) => _buildBulletItem(sol)),
                            const SizedBox(height: 16),
                          ],

                          // 🛡️ 예방법
                          if (ragSolution.preventions.isNotEmpty) ...[
                            _buildSectionTitle('🛡️', '예방법'),
                            ...ragSolution.preventions
                                .map((prev) => _buildBulletItem(prev)),
                            const SizedBox(height: 16),
                          ],

                          // 🤖 AI 조언
                          if (ragSolution.insight.isNotEmpty) ...[
                            _buildSectionTitle('🤖', 'AI 조언'),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.gray100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                ragSolution.insight,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.gray700,
                                  fontStyle: FontStyle.italic,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),

                  // 닫기 버튼
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.mintPrimary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          '확인',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    } catch (e) {
      // 로딩 오버레이 숨김
      if (mounted) {
        setState(() => _isProcessing = false);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('상세 정보를 불러올 수 없습니다: $e'),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    }
  }

  /// 섹션 타이틀 위젯
  Widget _buildSectionTitle(String emoji, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.gray800,
            ),
          ),
        ],
      ),
    );
  }

  /// 섹션 내용 위젯
  Widget _buildSectionContent(String content) {
    return Text(
      content,
      style: TextStyle(
        fontSize: 14,
        color: AppTheme.gray700,
        height: 1.5,
      ),
    );
  }

  /// 불렛 아이템 위젯
  Widget _buildBulletItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 7),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: AppTheme.mintPrimary,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.gray700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showNicknameEditModal() {
    final userProvider = context.read<UserProvider>();
    final currentNickname = userProvider.user?.nickname ?? '회원님';
    final controller = TextEditingController(text: currentNickname);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text('✏️', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      const Text(
                        '닉네임 수정',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.gray800,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.close_rounded,
                      color: AppTheme.gray400,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 라벨
              const Text(
                '닉네임',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.gray700,
                ),
              ),

              const SizedBox(height: 8),

              // 입력 필드
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: '닉네임을 입력하세요',
                  hintStyle: TextStyle(color: AppTheme.gray400),
                  filled: true,
                  fillColor: AppTheme.gray100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Text(
                '2~10자 이내로 입력해주세요',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.gray400,
                ),
              ),

              const SizedBox(height: 24),

              // 버튼들
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: AppTheme.gray300),
                      ),
                      child: Text(
                        '취소',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.gray600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final newNickname = controller.text.trim();
                        if (newNickname.isEmpty ||
                            newNickname.length < 2 ||
                            newNickname.length > 10) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('닉네임은 2~10자로 입력해주세요'),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                          return;
                        }

                        // 다이얼로그 닫기 먼저
                        Navigator.pop(context);

                        // 로딩 오버레이 표시
                        setState(() => _isProcessing = true);

                        // UserProvider를 통해 닉네임 업데이트 (API + 상태 갱신)
                        final userProvider = this.context.read<UserProvider>();
                        final success =
                            await userProvider.updateNickname(newNickname);

                        // 로딩 오버레이 숨김
                        if (mounted) {
                          setState(() => _isProcessing = false);

                          ScaffoldMessenger.of(this.context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  success ? '닉네임이 변경되었습니다' : '닉네임 변경에 실패했습니다'),
                              backgroundColor:
                                  success ? AppTheme.mintPrimary : Colors.red,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.mintPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        '저장',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog(DiagnosisThumbnail record) {
    final moldName = getMoldResultName(record.result);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 경고 아이콘
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppTheme.danger.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_forever_rounded,
                  color: AppTheme.danger,
                  size: 32,
                ),
              ),

              const SizedBox(height: 16),

              // 제목
              const Text(
                '기록을 삭제할까요?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.gray800,
                ),
              ),

              const SizedBox(height: 8),

              // 대상 기록 정보
              Text(
                moldName,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.gray600,
                ),
              ),

              const SizedBox(height: 16),

              // 영구 삭제 경고 박스
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.danger.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.danger.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: AppTheme.danger,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '삭제된 기록은 복구할 수 없습니다.\n진단 이미지와 AI 분석 결과가 영구적으로 삭제됩니다.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.danger,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 버튼
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: AppTheme.gray300),
                      ),
                      child: Text(
                        '취소',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.gray600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        setState(() => _isProcessing = true);

                        final success =
                            await _myPageService.deleteDiagnosis(record.id);

                        if (mounted) {
                          setState(() => _isProcessing = false);

                          if (success) {
                            setState(() {
                              _diagnosisRecords
                                  .removeWhere((r) => r.id == record.id);
                            });
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              SnackBar(
                                content: const Text('기록이 삭제되었습니다'),
                                backgroundColor: AppTheme.mintPrimary,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              SnackBar(
                                content: const Text('삭제에 실패했습니다'),
                                backgroundColor: AppTheme.danger,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.danger,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        '영구 삭제',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
