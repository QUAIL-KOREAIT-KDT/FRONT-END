import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import '../config/theme.dart';

/// 갤러리 이미지 크롭 화면
/// 고정된 크롭 박스 + 이미지 드래그/확대축소
class ImageCropScreen extends StatefulWidget {
  final File imageFile;

  const ImageCropScreen({super.key, required this.imageFile});

  @override
  State<ImageCropScreen> createState() => _ImageCropScreenState();
}

class _ImageCropScreenState extends State<ImageCropScreen> {
  bool _isCropping = false;

  // 이미지 변환 상태
  Offset _offset = Offset.zero;
  double _scale = 1.0;

  // 제스처 시작 시점 값
  late Offset _startOffset;
  late double _startScale;
  late Offset _startFocalPoint;

  // 가이드 영역 비율 (카메라와 동일)
  static const double _guideRatio = 0.7;

  // 이미지 원본 크기
  Size _imageSize = Size.zero;

  // 레이아웃 크기
  Size _viewSize = Size.zero;
  double _guideSize = 0;
  Rect _guideRect = Rect.zero;

  @override
  void initState() {
    super.initState();
    _loadImageSize();
  }

  Future<void> _loadImageSize() async {
    final bytes = await widget.imageFile.readAsBytes();
    final decoded = await decodeImageFromList(bytes);
    if (mounted) {
      setState(() {
        _imageSize = Size(decoded.width.toDouble(), decoded.height.toDouble());
      });
    }
  }

  /// 레이아웃 크기가 결정되면 초기 스케일/오프셋 계산
  void _initTransform(Size viewSize) {
    if (_imageSize == Size.zero) return;
    if (_viewSize == viewSize) return;

    _viewSize = viewSize;
    _guideSize = viewSize.width * _guideRatio;
    _guideRect = Rect.fromCenter(
      center: Offset(viewSize.width / 2, viewSize.height / 2),
      width: _guideSize,
      height: _guideSize,
    );

    // 이미지가 크롭 박스를 최소한 채우도록 초기 스케일 계산
    final scaleX = _guideSize / _imageSize.width;
    final scaleY = _guideSize / _imageSize.height;
    _scale = scaleX > scaleY ? scaleX : scaleY;

    // 이미지를 화면 중앙에 배치
    final scaledW = _imageSize.width * _scale;
    final scaledH = _imageSize.height * _scale;
    _offset = Offset(
      (viewSize.width - scaledW) / 2,
      (viewSize.height - scaledH) / 2,
    );
  }

  /// 오프셋을 가이드 영역 범위 내로 클램프
  Offset _clampOffset(Offset offset, double scale) {
    final scaledW = _imageSize.width * scale;
    final scaledH = _imageSize.height * scale;

    // 이미지가 가이드 영역을 벗어나지 않도록
    final minX = _guideRect.right - scaledW;
    final maxX = _guideRect.left;
    final minY = _guideRect.bottom - scaledH;
    final maxY = _guideRect.top;

    return Offset(
      scaledW <= _guideSize ? ((_viewSize.width - scaledW) / 2) : offset.dx.clamp(minX, maxX),
      scaledH <= _guideSize ? ((_viewSize.height - scaledH) / 2) : offset.dy.clamp(minY, maxY),
    );
  }

  /// 스케일 최솟값 (가이드 박스를 항상 채워야 함)
  double get _minScale {
    if (_imageSize == Size.zero) return 1.0;
    final scaleX = _guideSize / _imageSize.width;
    final scaleY = _guideSize / _imageSize.height;
    return scaleX > scaleY ? scaleX : scaleY;
  }

  void _onScaleStart(ScaleStartDetails details) {
    _startOffset = _offset;
    _startScale = _scale;
    _startFocalPoint = details.focalPoint;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      // 스케일 적용
      _scale = (_startScale * details.scale).clamp(_minScale, _minScale * 5);

      // 이동 적용 (시작 focal point 대비 누적 이동량)
      final delta = details.focalPoint - _startFocalPoint;
      _offset = _startOffset + delta;
      _offset = _clampOffset(_offset, _scale);
    });
  }

  void _onScaleEnd(ScaleEndDetails details) {
    // 최종 클램프
    setState(() {
      _offset = _clampOffset(_offset, _scale);
    });
  }

  /// 크롭 실행
  Future<void> _cropAndReturn() async {
    if (_isCropping) return;

    setState(() => _isCropping = true);

    try {
      final bytes = await widget.imageFile.readAsBytes();
      final originalImage = img.decodeImage(bytes);
      if (originalImage == null) throw Exception('이미지 디코딩 실패');

      final orientedImage = img.bakeOrientation(originalImage);

      // 화면상 좌표 → 원본 이미지 좌표 변환
      final imgToScreenScale = _scale;
      final originX = (_guideRect.left - _offset.dx) / imgToScreenScale;
      final originY = (_guideRect.top - _offset.dy) / imgToScreenScale;
      final cropSize = _guideSize / imgToScreenScale;

      final x = originX.round().clamp(0, orientedImage.width - 1);
      final y = originY.round().clamp(0, orientedImage.height - 1);
      final size = cropSize.round().clamp(1, orientedImage.width - x);
      final sizeH = cropSize.round().clamp(1, orientedImage.height - y);

      final cropped = img.copyCrop(
        orientedImage,
        x: x,
        y: y,
        width: size,
        height: sizeH,
      );

      final croppedBytes = Uint8List.fromList(img.encodeJpg(cropped, quality: 85));

      // 파일 저장
      final directory = Directory(widget.imageFile.path).parent;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final croppedPath = '${directory.path}/gallery_cropped_$timestamp.jpg';
      final croppedFile = File(croppedPath);
      await croppedFile.writeAsBytes(croppedBytes);

      if (mounted) {
        Navigator.pop(context, croppedFile);
      }
    } catch (e) {
      debugPrint('크롭 오류: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('이미지 크롭에 실패했습니다: $e'),
            backgroundColor: AppTheme.danger,
          ),
        );
        setState(() => _isCropping = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 이미지 + 제스처
          if (_imageSize != Size.zero)
            LayoutBuilder(
              builder: (context, constraints) {
                final viewSize = Size(constraints.maxWidth, constraints.maxHeight);
                _initTransform(viewSize);

                return GestureDetector(
                  onScaleStart: _onScaleStart,
                  onScaleUpdate: _onScaleUpdate,
                  onScaleEnd: _onScaleEnd,
                  child: Stack(
                    children: [
                      // 이미지
                      Positioned(
                        left: _offset.dx,
                        top: _offset.dy,
                        width: _imageSize.width * _scale,
                        height: _imageSize.height * _scale,
                        child: Image.file(
                          widget.imageFile,
                          fit: BoxFit.fill,
                          gaplessPlayback: true,
                        ),
                      ),

                      // 어두운 오버레이 + 가이드
                      _buildGuideOverlay(viewSize),
                    ],
                  ),
                );
              },
            )
          else
            const Center(
              child: CircularProgressIndicator(color: AppTheme.mintPrimary),
            ),

          // 상단 헤더
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(child: _buildHeader()),
          ),

          // 하단 컨트롤
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(child: _buildBottomControls()),
          ),

          // 로딩 오버레이
          if (_isCropping)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppTheme.mintPrimary),
                    SizedBox(height: 16),
                    Text(
                      '이미지 처리 중...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 가이드 오버레이 (카메라 화면과 동일한 스타일)
  Widget _buildGuideOverlay(Size viewSize) {
    final guideSize = viewSize.width * _guideRatio;
    final left = (viewSize.width - guideSize) / 2;
    final top = (viewSize.height - guideSize) / 2;
    final cornerLength = guideSize * 0.15;
    const strokeWidth = 4.0;
    const cornerColor = Color(0xFF00E676);

    return IgnorePointer(
      child: Stack(
        children: [
          // 어두운 오버레이
          CustomPaint(
            size: viewSize,
            painter: _DimOverlayPainter(
              guideRect: Rect.fromLTWH(left, top, guideSize, guideSize),
            ),
          ),

          // 좌상단 코너
          Positioned(
            left: left,
            top: top,
            child: _buildCorner(cornerLength, strokeWidth, cornerColor, topLeft: true),
          ),
          // 우상단 코너
          Positioned(
            right: left,
            top: top,
            child: _buildCorner(cornerLength, strokeWidth, cornerColor, topRight: true),
          ),
          // 좌하단 코너
          Positioned(
            left: left,
            bottom: viewSize.height - top - guideSize,
            child: _buildCorner(cornerLength, strokeWidth, cornerColor, bottomLeft: true),
          ),
          // 우하단 코너
          Positioned(
            right: left,
            bottom: viewSize.height - top - guideSize,
            child: _buildCorner(cornerLength, strokeWidth, cornerColor, bottomRight: true),
          ),

          // 안내 텍스트
          Positioned(
            left: 0,
            right: 0,
            top: top + guideSize + 20,
            child: const Text(
              '사진을 움직여 곰팡이 부분을 맞춰주세요',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorner(
    double cornerLength,
    double strokeWidth,
    Color color, {
    bool topLeft = false,
    bool topRight = false,
    bool bottomLeft = false,
    bool bottomRight = false,
  }) {
    return CustomPaint(
      size: Size(cornerLength, cornerLength),
      painter: _CornerPainter(
        strokeWidth: strokeWidth,
        color: color,
        isTopLeft: topLeft,
        isTopRight: topRight,
        isBottomLeft: bottomLeft,
        isBottomRight: bottomRight,
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Colors.black38,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 24),
            ),
          ),
          const Spacer(),
          const Text(
            '사진 크롭',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 확인 버튼
          GestureDetector(
            onTap: _isCropping ? null : _cropAndReturn,
            child: Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 48),
              decoration: BoxDecoration(
                color: AppTheme.mintPrimary,
                borderRadius: BorderRadius.circular(26),
              ),
              child: Center(
                child: _isCropping
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        '확인',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
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
      ..color = Colors.black.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
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
