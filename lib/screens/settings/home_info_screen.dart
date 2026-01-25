import 'package:flutter/material.dart';
import '../../config/theme.dart';

class HomeInfoScreen extends StatefulWidget {
  const HomeInfoScreen({super.key});

  @override
  State<HomeInfoScreen> createState() => _HomeInfoScreenState();
}

class _HomeInfoScreenState extends State<HomeInfoScreen> {
  // 더미 데이터
  String _houseType = '아파트';
  String _roomCount = '3개';
  String _area = '84㎡ (약 25평)';
  bool _hasBasement = false;
  bool _hasNorthFacing = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 헤더
            _buildHeader(context),

            // 폼
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('주거 형태'),
                    _buildDropdownField(
                      value: _houseType,
                      items: ['아파트', '빌라/연립', '단독주택', '오피스텔', '기타'],
                      onChanged: (value) => setState(() => _houseType = value!),
                    ),

                    const SizedBox(height: 24),

                    _buildSectionTitle('방 개수'),
                    _buildDropdownField(
                      value: _roomCount,
                      items: ['1개', '2개', '3개', '4개', '5개 이상'],
                      onChanged: (value) => setState(() => _roomCount = value!),
                    ),

                    const SizedBox(height: 24),

                    _buildSectionTitle('면적'),
                    _buildDropdownField(
                      value: _area,
                      items: [
                        '33㎡ 이하 (약 10평)',
                        '49㎡ (약 15평)',
                        '66㎡ (약 20평)',
                        '84㎡ (약 25평)',
                        '99㎡ (약 30평)',
                        '115㎡ 이상 (약 35평 이상)',
                      ],
                      onChanged: (value) => setState(() => _area = value!),
                    ),

                    const SizedBox(height: 24),

                    _buildSectionTitle('추가 정보'),
                    _buildSwitchItem(
                      title: '지하/반지하 거주',
                      subtitle: '습기에 취약할 수 있어요',
                      value: _hasBasement,
                      onChanged: (value) =>
                          setState(() => _hasBasement = value),
                    ),
                    const SizedBox(height: 12),
                    _buildSwitchItem(
                      title: '북향 방 보유',
                      subtitle: '일조량이 적어 곰팡이 위험이 높아요',
                      value: _hasNorthFacing,
                      onChanged: (value) =>
                          setState(() => _hasNorthFacing = value),
                    ),

                    const SizedBox(height: 40),

                    // 저장 버튼
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _saveInfo,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.mintPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          '저장하기',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppTheme.gray700,
              size: 22,
            ),
          ),
          const SizedBox(width: 8),
          Row(
            children: [
              const Text(
                '🏠',
                style: TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 8),
              const Text(
                '집 정보 수정',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.gray800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppTheme.gray700,
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.gray100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.gray200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon:
              Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.gray500),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppTheme.gray800,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildSwitchItem({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.gray100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.gray800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.gray400,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.mintPrimary,
          ),
        ],
      ),
    );
  }

  void _saveInfo() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('집 정보가 저장되었습니다'),
        backgroundColor: AppTheme.mintPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    Navigator.pop(context);
  }
}
