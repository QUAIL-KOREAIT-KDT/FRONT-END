import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/mold_category.dart';
import '../config/constants.dart';

class DictionarySubtypeDetailScreen extends StatelessWidget {
  final MoldSubType subType;
  final String categoryName;

  const DictionarySubtypeDetailScreen({
    super.key,
    required this.subType,
    required this.categoryName,
  });

  /// 이미지 URL 생성 (S3 또는 백엔드 static)
  String? _getImageUrl() {
    if (subType.imagePath == null || subType.imagePath!.isEmpty) {
      return null;
    }
    final path = subType.imagePath!;
    // 이미 완전한 URL인 경우
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    // 백엔드 static 경로인 경우 baseUrl 사용
    final baseUrl = AppConstants.baseUrl.replaceAll('/api', '');
    return '$baseUrl$path';
  }

  /// 배경색이 밝은지 판단하여 텍스트 색상 결정
  bool _isLightBackground(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5;
  }

  @override
  Widget build(BuildContext context) {
    final isLight = _isLightBackground(subType.gradientColors[0]);
    final textColor = isLight ? AppTheme.gray700 : Colors.white;
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: subType.gradientColors[0],
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppTheme.gray700,
                  size: 20,
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: subType.gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 30),
                      // S3 이미지가 있으면 네트워크 이미지, 없으면 이모지
                      _getImageUrl() != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                _getImageUrl()!,
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Text('🦠',
                                      style: TextStyle(fontSize: 72));
                                },
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                          : const Text('🦠', style: TextStyle(fontSize: 72)),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: isLight
                              ? AppTheme.gray700.withOpacity(0.15)
                              : Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          categoryName,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: textColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(subType.name,
                        style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.gray800)),
                    const SizedBox(height: 4),
                    Text(subType.scientificName,
                        style: TextStyle(
                            fontSize: 15,
                            fontStyle: FontStyle.italic,
                            color: AppTheme.gray400)),
                    const SizedBox(height: 24),
                    _buildSection(
                        title: '설명',
                        icon: Icons.info_outline_rounded,
                        child: Text(subType.fullDescription,
                            style: TextStyle(
                                fontSize: 15,
                                color: AppTheme.gray600,
                                height: 1.6))),
                    const SizedBox(height: 24),
                    _buildSection(
                        title: '외관 특징',
                        icon: Icons.palette_outlined,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInfoRow('색상', subType.color),
                              const SizedBox(height: 8),
                              _buildInfoRow('특징', subType.characteristics)
                            ])),
                    const SizedBox(height: 24),
                    _buildSection(
                        title: '주요 발생 장소',
                        icon: Icons.location_on_outlined,
                        child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: subType.commonLocations
                                .map((location) => Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(
                                        color: AppTheme.mintLight,
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: Text(location,
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: AppTheme.mintDark))))
                                .toList())),
                    const SizedBox(height: 24),
                    _buildSection(
                        title: '건강 영향',
                        icon: Icons.health_and_safety_outlined,
                        iconColor: AppTheme.warning,
                        child: Column(
                            children: subType.healthRisks
                                .map((risk) => _buildWarningItem(risk))
                                .toList())),
                    const SizedBox(height: 24),
                    _buildSection(
                        title: '제거 방법',
                        icon: Icons.cleaning_services_outlined,
                        child: Column(
                            children: subType.removalMethods
                                .asMap()
                                .entries
                                .map((entry) => _buildNumberedItem(
                                    entry.key + 1, entry.value))
                                .toList())),
                    const SizedBox(height: 24),
                    _buildSection(
                        title: '예방 방법',
                        icon: Icons.shield_outlined,
                        child: Column(
                            children: subType.preventions
                                .map(
                                    (prevention) => _buildCheckItem(prevention))
                                .toList())),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
      {required String title,
      required IconData icon,
      Color? iconColor,
      required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(icon, size: 22, color: iconColor ?? AppTheme.mintPrimary),
          const SizedBox(width: 8),
          Text(title,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.gray800))
        ]),
        const SizedBox(height: 16),
        child,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
            width: 60,
            child: Text(label,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.gray500))),
        Expanded(
            child: Text(value,
                style: TextStyle(fontSize: 14, color: AppTheme.gray700))),
      ],
    );
  }

  Widget _buildWarningItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, size: 18, color: AppTheme.warning),
          const SizedBox(width: 10),
          Expanded(
              child: Text(text,
                  style: TextStyle(
                      fontSize: 14, color: AppTheme.gray700, height: 1.4))),
        ],
      ),
    );
  }

  Widget _buildNumberedItem(int number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                  color: AppTheme.mintPrimary, shape: BoxShape.circle),
              child: Center(
                  child: Text('$number',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)))),
          const SizedBox(width: 12),
          Expanded(
              child: Text(text,
                  style: TextStyle(
                      fontSize: 14, color: AppTheme.gray700, height: 1.5))),
        ],
      ),
    );
  }

  Widget _buildCheckItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_rounded, size: 20, color: AppTheme.safe),
          const SizedBox(width: 12),
          Expanded(
              child: Text(text,
                  style: TextStyle(
                      fontSize: 14, color: AppTheme.gray700, height: 1.5))),
        ],
      ),
    );
  }
}
