import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../config/routes.dart';
import '../config/constants.dart';

class DiagnosisScreen extends StatefulWidget {
  const DiagnosisScreen({super.key});

  @override
  State<DiagnosisScreen> createState() => _DiagnosisScreenState();
}

class _DiagnosisScreenState extends State<DiagnosisScreen> {
  int _selectedLocationIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.gray100,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.chevron_left,
                color: AppTheme.gray700,
                size: 28,
              ),
            ),
          ),
        ),
        title: const Text(
          '🔬 곰팡이 진단',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppTheme.gray800,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 업로드 영역
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.mintLight, AppTheme.pinkLight],
                  ),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: AppTheme.mintMedium,
                    width: 3,
                    strokeAlign: BorderSide.strokeAlignInside,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 아이콘
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.camera_alt_outlined,
                        size: 40,
                        color: AppTheme.mintPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '곰팡이 사진을 올려주세요',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.gray700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '선명한 사진일수록 정확해요!',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.gray400,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 버튼들
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildUploadButton(
                          icon: '📷',
                          label: '촬영',
                          isPrimary: true,
                          onTap: () {
                            // TODO: 카메라 열기
                          },
                        ),
                        const SizedBox(width: 12),
                        _buildUploadButton(
                          icon: '🖼️',
                          label: '앨범',
                          isPrimary: false,
                          onTap: () {
                            // TODO: 갤러리 열기
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 장소 선택
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.gray100,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '곰팡이가 발생한 장소를 선택해주세요',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.gray700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: List.generate(
                      AppConstants.locationOptions.length,
                      (index) => _buildLocationChip(index),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 분석하기 버튼
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.diagnosisResult);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.mintPrimary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text(
                  '분석하기',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadButton({
    required String icon,
    required String label,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isPrimary ? AppTheme.mintPrimary : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border:
              isPrimary ? null : Border.all(color: AppTheme.gray200, width: 2),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isPrimary ? Colors.white : AppTheme.gray700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationChip(int index) {
    final option = AppConstants.locationOptions[index];
    final isSelected = _selectedLocationIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLocationIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.mintLight : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.mintPrimary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Text(
          '${option['icon']} ${option['label']}',
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? AppTheme.mintDark : AppTheme.gray600,
          ),
        ),
      ),
    );
  }
}
