import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../config/theme.dart';
import '../config/routes.dart';
import '../config/constants.dart';
import '../services/diagnosis_service.dart';
import 'camera_screen.dart';
import 'image_crop_screen.dart';

class DiagnosisScreen extends StatefulWidget {
  final ValueChanged<bool>? onAnalyzingChanged;

  const DiagnosisScreen({super.key, this.onAnalyzingChanged});

  @override
  State<DiagnosisScreen> createState() => DiagnosisScreenState();
}

class DiagnosisScreenState extends State<DiagnosisScreen> {
  int _selectedLocationIndex = -1;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  bool _isAnalyzing = false;
  final DiagnosisService _diagnosisService = DiagnosisService();

  /// 화면 상태 초기화 (탭 이동 시 호출)
  void reset() {
    setState(() {
      _selectedImage = null;
      _selectedLocationIndex = -1;
      _isLoading = false;
      _isAnalyzing = false;
    });
  }

  // 선택된 장소 라벨 가져오기
  String get _selectedLocationLabel {
    if (_selectedLocationIndex < 0) return '기타';
    return AppConstants.locationOptions[_selectedLocationIndex]['label'] ??
        '기타';
  }

  // 장소가 선택되었는지 확인
  bool get _isLocationSelected => _selectedLocationIndex >= 0;

  // 곰팡이 진단 API 호출
  Future<void> _analyzeMold() async {
    if (_selectedImage == null) return;

    setState(() {
      _isLoading = true;
      _isAnalyzing = true;
    });
    widget.onAnalyzingChanged?.call(true);

    try {
      final response = await _diagnosisService.predictMold(
        _selectedImage!,
        _selectedLocationLabel,
      );

      if (mounted) {
        widget.onAnalyzingChanged?.call(false);

        // 결과 화면으로 이동하며 진단 결과 전달
        Navigator.pushNamed(
          context,
          AppRoutes.diagnosisResult,
          arguments: response,
        );

        // 진단 완료 후 화면 초기화
        setState(() {
          _isLoading = false;
          _isAnalyzing = false;
          _selectedImage = null;
          _selectedLocationIndex = -1;
        });
      }
    } catch (e) {
      if (mounted) {
        widget.onAnalyzingChanged?.call(false);
        setState(() {
          _isLoading = false;
          _isAnalyzing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('진단에 실패했습니다: $e'),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    }
  }

  // 카메라로 사진 촬영 (가이드 오버레이 포함 커스텀 카메라 사용)
  Future<void> _takePhoto() async {
    try {
      setState(() => _isLoading = true);

      // 커스텀 카메라 화면으로 이동 (초록 가이드 + 자동 크롭)
      final File? croppedImage = await Navigator.push<File>(
        context,
        MaterialPageRoute(
          builder: (context) => const CameraScreen(),
        ),
      );

      if (croppedImage != null) {
        // 크롭된 이미지 확인 로깅
        final fileSize = await croppedImage.length();
        debugPrint('[DiagnosisScreen] 받은 크롭 이미지: ${croppedImage.path}');
        debugPrint(
            '[DiagnosisScreen] 파일 크기: ${(fileSize / 1024).toStringAsFixed(1)} KB');

        setState(() {
          _selectedImage = croppedImage;
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

  // 갤러리에서 사진 선택 → 크롭 화면으로 이동
  Future<void> _pickFromGallery() async {
    try {
      setState(() => _isLoading = true);

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null && mounted) {
        // 크롭 화면으로 이동
        final File? croppedImage = await Navigator.push<File>(
          context,
          MaterialPageRoute(
            builder: (context) => ImageCropScreen(imageFile: File(image.path)),
          ),
        );

        if (croppedImage != null && mounted) {
          setState(() {
            _selectedImage = croppedImage;
          });
        }
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
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                // 헤더
                _buildHeader(),

                // 본문 (스크롤 가능하게 변경 - 작은 화면/큰 폰트 대응)
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // 남은 공간의 높이에서 업로드 영역 최소 높이 계산
                      final availableHeight = constraints.maxHeight;
                      // 업로드 영역: 전체 높이의 45% ~ 최소 200
                      final uploadHeight =
                          (availableHeight * 0.45).clamp(200.0, 500.0);

                      return SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                        child: Column(
                          children: [
                            // 업로드 영역 (고정 높이로 변경, 스크롤 가능)
                            Container(
                              width: double.infinity,
                              height: uploadHeight,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppTheme.mintLight,
                                    AppTheme.pinkLight
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(32),
                                border: Border.all(
                                  color: AppTheme.mintMedium,
                                  width: 3,
                                  strokeAlign: BorderSide.strokeAlignInside,
                                ),
                              ),
                              child: _selectedImage != null
                                  ? _buildImagePreview()
                                  : _buildUploadPlaceholder(),
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
                                crossAxisAlignment: CrossAxisAlignment.center,
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
                                  Center(
                                    child: Wrap(
                                      spacing: 10,
                                      runSpacing: 10,
                                      alignment: WrapAlignment.center,
                                      children: List.generate(
                                        AppConstants.locationOptions.length,
                                        (index) => _buildLocationChip(index),
                                      ),
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
                                onPressed: (_selectedImage != null &&
                                        _isLocationSelected &&
                                        !_isLoading)
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
                                child: Text(
                                  _selectedImage == null
                                      ? '사진을 먼저 선택해주세요'
                                      : !_isLocationSelected
                                          ? '장소를 선택해주세요'
                                          : '분석하기',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),

        // 전체 화면 분석 로딩 오버레이
        if (_isAnalyzing) _buildAnalyzingOverlay(),
      ],
    );
  }

  /// AI 분석 중 전체 화면 로딩 오버레이
  Widget _buildAnalyzingOverlay() {
    return PopScope(
      canPop: false,
      child: Container(
        color: Colors.black.withValues(alpha: 0.7),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.mintPrimary.withValues(alpha: 0.2),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 로딩 인디케이터
                const SizedBox(
                  width: 56,
                  height: 56,
                  child: CircularProgressIndicator(
                    strokeWidth: 5,
                    color: AppTheme.mintPrimary,
                    backgroundColor: AppTheme.gray200,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'AI가 곰팡이를 분석하고 있어요',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.gray800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  '잠시만 기다려주세요...',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.gray400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(width: 10),
              const Text(
                '곰팡이 진단',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.gray800,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _showPhotoGuideModal(),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.help_outline,
                      color: AppTheme.gray700,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            '스마트한 AI 곰팡이 진단 솔루션',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.gray400,
            ),
          ),
        ],
      ),
    );
  }

  void _showPhotoGuideModal() {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 헤더
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '촬영 가이드',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.gray800,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        child: const Icon(
                          Icons.close,
                          size: 24,
                          color: AppTheme.gray500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 올바른 예시
                _buildGuideExample(
                  title: '올바른 촬영 예시',
                  imagePath: 'assets/images/mold/correct.png',
                  description: '곰팡이 부분이 화면의 대부분을 차지하도록\n최대한 확대해서 촬영해주세요.',
                  isCorrect: true,
                ),
                const SizedBox(height: 16),

                // 아쉬운 예시
                _buildGuideExample(
                  title: '아쉬운 촬영 예시',
                  imagePath: 'assets/images/mold/not_correct.png',
                  description:
                      '배경이 많이 포함되면 분석 정확도가 떨어집니다.\n곰팡이를 최대한 가까이 촬영해주세요.',
                  isCorrect: false,
                ),
                const SizedBox(height: 20),

                // 주의 문구
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.warning.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 18,
                        color: AppTheme.warning,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'AI 진단 결과는 참고용이며, 100% 정확하지 않을 수 있습니다. 정확한 판단은 전문가에게 문의해주세요.',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.gray700,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 확인 버튼
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.mintPrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGuideExample({
    required String title,
    required String imagePath,
    required String description,
    required bool isCorrect,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
              size: 20,
              color: isCorrect ? AppTheme.safe : AppTheme.danger,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isCorrect ? AppTheme.safe : AppTheme.danger,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: double.infinity,
            height: 160,
            decoration: BoxDecoration(
              border: Border.all(
                color: isCorrect
                    ? AppTheme.safe.withValues(alpha: 0.4)
                    : AppTheme.danger.withValues(alpha: 0.4),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppTheme.gray100,
                    child: Center(
                      child: Text(
                        isCorrect ? '올바른 예시' : '잘못된 예시',
                        style: TextStyle(
                          color: AppTheme.gray400,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: TextStyle(
            fontSize: 13,
            color: AppTheme.gray600,
            height: 1.5,
          ),
        ),
      ],
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
              // 이미지 캐시 무효화를 위해 key 사용
              key: ValueKey(_selectedImage!.path),
              // 이미지 캐시 비활성화
              cacheWidth: null,
              cacheHeight: null,
              gaplessPlayback: false,
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
