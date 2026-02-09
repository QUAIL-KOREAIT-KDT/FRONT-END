import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import '../config/theme.dart';

/// 카메라 화면 (초록색 가이드 오버레이 포함)
class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isCapturing = false;

  // 줌 관련
  double _currentZoom = 1.0;
  double _minZoom = 1.0;
  double _maxZoom = 1.0;

  // 가이드 영역 비율 (화면 대비)
  static const double _guideRatio = 0.7;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('사용 가능한 카메라가 없습니다.')),
          );
        }
        return;
      }

      // 후면 카메라 선택
      final backCamera = _cameras!.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras!.first,
      );

      _controller = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();

      // 줌 범위 가져오기
      _minZoom = await _controller!.getMinZoomLevel();
      _maxZoom = await _controller!.getMaxZoomLevel();
      _currentZoom = _minZoom;

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('카메라 초기화 오류: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('카메라 초기화 실패: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  /// 사진 촬영 및 크롭 처리
  Future<void> _captureAndCrop() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isCapturing) {
      return;
    }

    setState(() {
      _isCapturing = true;
    });

    try {
      // 사진 촬영
      final XFile photo = await _controller!.takePicture();
      debugPrint('[CameraScreen] 원본 사진 경로: ${photo.path}');

      // 원본 이미지 로드
      final bytes = await photo.readAsBytes();
      debugPrint(
          '[CameraScreen] 원본 바이트 크기: ${(bytes.length / 1024).toStringAsFixed(1)} KB');

      final originalImage = img.decodeImage(bytes);

      if (originalImage == null) {
        throw Exception('이미지 디코딩 실패');
      }

      debugPrint(
          '[CameraScreen] 디코딩된 원본: ${originalImage.width}x${originalImage.height}');

      // EXIF 회전 정보 적용 (카메라 사진은 회전 메타데이터가 있을 수 있음)
      final orientedImage = img.bakeOrientation(originalImage);
      debugPrint(
          '[CameraScreen] 회전 적용 후: ${orientedImage.width}x${orientedImage.height}');

      // 크롭 영역 계산 (가이드 영역에 맞춰)
      final croppedImage = _cropToGuide(orientedImage);

      debugPrint(
          '[CameraScreen] 크롭 결과: ${croppedImage.width}x${croppedImage.height}');

      // 크롭된 이미지를 파일로 저장
      final croppedBytes =
          Uint8List.fromList(img.encodeJpg(croppedImage, quality: 85));
      debugPrint(
          '[CameraScreen] 크롭된 바이트 크기: ${(croppedBytes.length / 1024).toStringAsFixed(1)} KB');

      final croppedFile = await _saveCroppedImage(croppedBytes, photo.path);

      if (mounted) {
        Navigator.pop(context, croppedFile);
      }
    } catch (e) {
      debugPrint('사진 촬영 오류: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('사진 촬영에 실패했습니다: $e'),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  /// 가이드 영역에 맞춰 이미지 크롭
  img.Image _cropToGuide(img.Image image) {
    // 카메라 이미지는 보통 가로가 더 긴 상태로 찍힘 (회전 전)
    // 세로 모드에서 촬영했으므로 이미지가 회전되어 있을 수 있음

    final int imgWidth = image.width;
    final int imgHeight = image.height;

    // 화면에서 가이드는 화면 너비의 70%를 정사각형으로 표시
    // 카메라 이미지도 동일한 비율로 중앙에서 정사각형 크롭

    // 이미지의 짧은 쪽을 기준으로 70% 크기의 정사각형 크롭
    final int shorterSide = imgWidth < imgHeight ? imgWidth : imgHeight;
    final int guideSize = (shorterSide * _guideRatio).toInt();

    // 중앙 기준 크롭 좌표 계산
    final int centerX = imgWidth ~/ 2;
    final int centerY = imgHeight ~/ 2;

    final int left = (centerX - guideSize ~/ 2).clamp(0, imgWidth - guideSize);
    final int top = (centerY - guideSize ~/ 2).clamp(0, imgHeight - guideSize);

    debugPrint('[CameraScreen] 원본 이미지: ${imgWidth}x$imgHeight');
    debugPrint('[CameraScreen] 크롭 영역: left=$left, top=$top, size=$guideSize');

    return img.copyCrop(
      image,
      x: left,
      y: top,
      width: guideSize,
      height: guideSize,
    );
  }

  /// 크롭된 이미지를 파일로 저장
  Future<File> _saveCroppedImage(Uint8List bytes, String originalPath) async {
    final directory = Directory(originalPath).parent;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final croppedPath = '${directory.path}/cropped_$timestamp.jpg';
    final file = File(croppedPath);
    await file.writeAsBytes(bytes);

    // 저장된 파일 크기 확인
    final fileSize = await file.length();
    debugPrint('[CameraScreen] 크롭된 이미지 저장: $croppedPath');
    debugPrint(
        '[CameraScreen] 파일 크기: ${(fileSize / 1024).toStringAsFixed(1)} KB');

    return file;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 카메라 프리뷰
          if (_isInitialized && _controller != null)
            Positioned.fill(
              child: AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: CameraPreview(_controller!),
              ),
            )
          else
            const Center(
              child: CircularProgressIndicator(
                color: AppTheme.mintPrimary,
              ),
            ),

          // 가이드 오버레이
          if (_isInitialized) _buildGuideOverlay(),

          // 상단 헤더
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: _buildHeader(),
            ),
          ),

          // 하단 컨트롤
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: _buildBottomControls(),
            ),
          ),

          // 로딩 오버레이
          if (_isCapturing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: AppTheme.mintPrimary,
                    ),
                    SizedBox(height: 16),
                    Text(
                      '사진 처리 중...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
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

  /// 초록색 가이드 오버레이
  Widget _buildGuideOverlay() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;
        final guideSize = screenWidth * _guideRatio;
        final left = (screenWidth - guideSize) / 2;
        final top = (screenHeight - guideSize) / 2;
        final cornerLength = guideSize * 0.15;
        const strokeWidth = 4.0;
        const cornerColor = Color(0xFF00E676); // 밝은 초록색

        return Stack(
          children: [
            // 어두운 오버레이 (가이드 영역 외부)
            CustomPaint(
              size: Size(screenWidth, screenHeight),
              painter: _DimOverlayPainter(
                guideRect: Rect.fromLTWH(left, top, guideSize, guideSize),
              ),
            ),

            // 좌상단 코너
            Positioned(
              left: left,
              top: top,
              child: _buildCorner(
                cornerLength: cornerLength,
                strokeWidth: strokeWidth,
                color: cornerColor,
                isTopLeft: true,
              ),
            ),

            // 우상단 코너
            Positioned(
              right: left,
              top: top,
              child: _buildCorner(
                cornerLength: cornerLength,
                strokeWidth: strokeWidth,
                color: cornerColor,
                isTopRight: true,
              ),
            ),

            // 좌하단 코너
            Positioned(
              left: left,
              bottom: screenHeight - top - guideSize,
              child: _buildCorner(
                cornerLength: cornerLength,
                strokeWidth: strokeWidth,
                color: cornerColor,
                isBottomLeft: true,
              ),
            ),

            // 우하단 코너
            Positioned(
              right: left,
              bottom: screenHeight - top - guideSize,
              child: _buildCorner(
                cornerLength: cornerLength,
                strokeWidth: strokeWidth,
                color: cornerColor,
                isBottomRight: true,
              ),
            ),

            // 가이드 텍스트
            Positioned(
              left: 0,
              right: 0,
              bottom: top + guideSize + 20,
              child: const Text(
                '초록색 영역 안에 곰팡이를 맞춰주세요',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  shadows: [
                    Shadow(
                      color: Colors.black54,
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// 코너 라인 빌더
  Widget _buildCorner({
    required double cornerLength,
    required double strokeWidth,
    required Color color,
    bool isTopLeft = false,
    bool isTopRight = false,
    bool isBottomLeft = false,
    bool isBottomRight = false,
  }) {
    return CustomPaint(
      size: Size(cornerLength, cornerLength),
      painter: _CornerPainter(
        strokeWidth: strokeWidth,
        color: color,
        isTopLeft: isTopLeft,
        isTopRight: isTopRight,
        isBottomLeft: isBottomLeft,
        isBottomRight: isBottomRight,
      ),
    );
  }

  /// 상단 헤더
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // 닫기 버튼
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.black38,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          const Spacer(),
          // 타이틀
          const Text(
            '곰팡이 촬영',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 40), // 균형 맞추기
        ],
      ),
    );
  }

  /// 줌 변경 핸들러
  Future<void> _onZoomChanged(double value) async {
    setState(() {
      _currentZoom = value;
    });
    await _controller?.setZoomLevel(value);
  }

  /// 하단 컨트롤
  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24, top: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 줌 슬라이더
          if (_maxZoom > _minZoom) _buildZoomSlider(),
          const SizedBox(height: 16),
          // 촬영 버튼
          GestureDetector(
            onTap: _isCapturing ? null : _captureAndCrop,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 4,
                ),
              ),
              child: Center(
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: _isCapturing
                      ? const Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: AppTheme.mintPrimary,
                          ),
                        )
                      : const Icon(
                          Icons.camera_alt,
                          color: AppTheme.gray700,
                          size: 28,
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 줌 슬라이더 위젯
  Widget _buildZoomSlider() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.zoom_out,
            color: Colors.white70,
            size: 18,
          ),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: AppTheme.mintPrimary,
                inactiveTrackColor: Colors.white24,
                thumbColor: Colors.white,
                overlayColor: AppTheme.mintPrimary.withValues(alpha: 0.2),
                thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 7,
                ),
                trackHeight: 3,
              ),
              child: Slider(
                value: _currentZoom,
                min: _minZoom,
                max: _maxZoom,
                onChanged: _onZoomChanged,
              ),
            ),
          ),
          const Icon(
            Icons.zoom_in,
            color: Colors.white70,
            size: 18,
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 40,
            child: Text(
              '${_currentZoom.toStringAsFixed(1)}x',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

/// 어두운 오버레이 페인터 (가이드 영역 제외)
class _DimOverlayPainter extends CustomPainter {
  final Rect guideRect;

  _DimOverlayPainter({required this.guideRect});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    // 전체 화면을 어둡게
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      // 가이드 영역은 제외
      ..addRect(guideRect)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 코너 직각 라인 페인터
class _CornerPainter extends CustomPainter {
  final double strokeWidth;
  final Color color;
  final bool isTopLeft;
  final bool isTopRight;
  final bool isBottomLeft;
  final bool isBottomRight;

  _CornerPainter({
    required this.strokeWidth,
    required this.color,
    this.isTopLeft = false,
    this.isTopRight = false,
    this.isBottomLeft = false,
    this.isBottomRight = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    if (isTopLeft) {
      path.moveTo(0, size.height);
      path.lineTo(0, 0);
      path.lineTo(size.width, 0);
    } else if (isTopRight) {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
    } else if (isBottomLeft) {
      path.moveTo(0, 0);
      path.lineTo(0, size.height);
      path.lineTo(size.width, size.height);
    } else if (isBottomRight) {
      path.moveTo(0, size.height);
      path.lineTo(size.width, size.height);
      path.lineTo(size.width, 0);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
