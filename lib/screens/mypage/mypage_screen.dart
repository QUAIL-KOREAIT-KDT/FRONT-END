import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../services/user_service.dart';
import '../../providers/user_provider.dart';

class MypageScreen extends StatefulWidget {
  const MypageScreen({super.key});

  @override
  State<MypageScreen> createState() => _MypageScreenState();
}

class _MypageScreenState extends State<MypageScreen> {
  // 필터 선택
  String _selectedFilter = '전체';
  final List<String> _filters = ['전체', '창문', '벽지', '주방', '욕실'];

  @override
  void initState() {
    super.initState();
    // 마이페이지 진입 시 사용자 정보 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().loadUser();
    });
  }

  // 더미 데이터 - 곰팡이 분석 기록
  final List<Map<String, dynamic>> _analysisRecords = [
    {
      'id': '1',
      'moldType': '검은 곰팡이',
      'location': '욕실',
      'locationColor': const Color(0xFF4DD9BC),
      'date': '2025.01.20 14:32',
      'emoji': '🦠',
    },
    {
      'id': '2',
      'moldType': '푸른 곰팡이',
      'location': '주방',
      'locationColor': const Color(0xFF4DD9BC),
      'date': '2025.01.18 09:15',
      'emoji': '🦠',
    },
    {
      'id': '3',
      'moldType': '검은 곰팡이',
      'location': '창문',
      'locationColor': const Color(0xFF4DD9BC),
      'date': '2025.01.15 11:20',
      'emoji': '🦠',
    },
  ];

  List<Map<String, dynamic>> get _filteredRecords {
    if (_selectedFilter == '전체') return _analysisRecords;
    return _analysisRecords
        .where((record) => record['location'] == _selectedFilter)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
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
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          const Text(
            '👤',
            style: TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 8),
          const Text(
            '마이페이지',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppTheme.gray800,
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
      child: Row(
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                '총 ${_analysisRecords.length}건',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.gray400,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 필터 탭
        if (_analysisRecords.isNotEmpty) _buildFilterTabs(),

        const SizedBox(height: 16),

        // 기록 리스트 또는 빈 상태
        Expanded(
          child: _analysisRecords.isEmpty
              ? _buildEmptyState()
              : _buildRecordList(),
        ),
      ],
    );
  }

  Widget _buildFilterTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: _filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _selectedFilter = filter),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
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
                        fontSize: 14,
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
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _filteredRecords.length,
      itemBuilder: (context, index) {
        final record = _filteredRecords[index];
        return _buildRecordCard(record);
      },
    );
  }

  Widget _buildRecordCard(Map<String, dynamic> record) {
    return Container(
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
            ),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    record['emoji'],
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
                Positioned(
                  bottom: 4,
                  left: 4,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppTheme.gray700,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record['moldType'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.gray800,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.mintLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '● ${record['location']}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.mintPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  record['date'],
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

                        // UserProvider를 통해 닉네임 업데이트 (API + 상태 갱신)
                        final userProvider = context.read<UserProvider>();
                        final success =
                            await userProvider.updateNickname(newNickname);

                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
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

  void _showDeleteConfirmDialog(Map<String, dynamic> record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('기록 삭제'),
        content: Text('${record['moldType']} 기록을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '취소',
              style: TextStyle(color: AppTheme.gray500),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _analysisRecords.removeWhere((r) => r['id'] == record['id']);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('기록이 삭제되었습니다'),
                  backgroundColor: AppTheme.mintPrimary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            child: Text(
              '삭제',
              style: TextStyle(color: AppTheme.danger),
            ),
          ),
        ],
      ),
    );
  }
}
