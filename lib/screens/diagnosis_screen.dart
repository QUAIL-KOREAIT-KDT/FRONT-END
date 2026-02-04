import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../config/theme.dart';
import '../config/routes.dart';
import '../config/constants.dart';
import '../services/diagnosis_service.dart';

class DiagnosisScreen extends StatefulWidget {
  const DiagnosisScreen({super.key});

  @override
  State<DiagnosisScreen> createState() => _DiagnosisScreenState();
}

class _DiagnosisScreenState extends State<DiagnosisScreen> {
  int _selectedLocationIndex = 0;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  final DiagnosisService _diagnosisService = DiagnosisService();

  // 선택된 장소 라벨 가져오기
  String get _selectedLocationLabel {
    return AppConstants.locationOptions[_selectedLocationIndex]['label'] ??
        '기타';
  }

  // 곰팡이 진단 API 호출
  Future<void> _analyzeMold() async {
    if (_selectedImage == null) return;

    setState(() => _isLoading = true);

    try {
      final response = await _diagnosisService.predictMold(
        _selectedImage!,
        _selectedLocationLabel,
      );

      if (mounted) {
        setState(() => _isLoading = false);

        // 결과 화면으로 이동하며 진단 결과 전달
        Navigator.pushNamed(
          context,
          AppRoutes.diagnosisResult,
          arguments: response,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('진단에 실패했습니다: $e'),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    }
  }

  // 카메라로 사진 촬영
  Future<void> _takePhoto() async {
    try {
      setState(() => _isLoading = true);

      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (photo != null) {
        setState(() {
          _selectedImage = File(photo.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('카메라를 사용할 수 없습니다: $e'),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // 갤러리에서 사진 선택
  Future<void> _pickFromGallery() async {
    try {
      setState(() => _isLoading = true);

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('갤러리를 열 수 없습니다: $e'),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // 선택한 이미지 삭제
  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
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
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.mintPrimary,
                        ),
                      )
                    : _selectedImage != null
                        ? _buildImagePreview()
                        : _buildUploadPlaceholder(),
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
                onPressed: (_selectedImage != null && !_isLoading)
                    ? _analyzeMold
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.mintPrimary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppTheme.gray200,
                  disabledForegroundColor: AppTheme.gray400,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: _isLoading
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            '분석 중...',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        _selectedImage != null ? '분석하기' : '사진을 먼저 선택해주세요',
                        style: const TextStyle(
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

  // 업로드 플레이스홀더 (이미지 선택 전)
  Widget _buildUploadPlaceholder() {
    return Column(
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
              onTap: _takePhoto,
            ),
            const SizedBox(width: 12),
            _buildUploadButton(
              icon: '🖼️',
              label: '앨범',
              isPrimary: false,
              onTap: _pickFromGallery,
            ),
          ],
        ),
      ],
    );
  }

  // 이미지 미리보기 (이미지 선택 후)
  Widget _buildImagePreview() {
    return Stack(
      children: [
        // 이미지
        ClipRRect(
          borderRadius: BorderRadius.circular(29),
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Image.file(
              _selectedImage!,
              fit: BoxFit.cover,
            ),
          ),
        ),
        // 오버레이 (하단)
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(29),
                bottomRight: Radius.circular(29),
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildUploadButton(
                  icon: '📷',
                  label: '다시 촬영',
                  isPrimary: true,
                  onTap: _takePhoto,
                ),
                const SizedBox(width: 12),
                _buildUploadButton(
                  icon: '🖼️',
                  label: '앨범',
                  isPrimary: false,
                  onTap: _pickFromGallery,
                ),
              ],
            ),
          ),
        ),
        // 삭제 버튼 (우상단)
        Positioned(
          top: 12,
          right: 12,
          child: GestureDetector(
            onTap: _removeImage,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
        // 선택 완료 표시 (좌상단)
        Positioned(
          top: 12,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.mintPrimary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 16),
                SizedBox(width: 4),
                Text(
                  '사진 선택됨',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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
