import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/mold_info.dart';

class DictionaryDetailScreen extends StatelessWidget {
  const DictionaryDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 라우트에서 arguments로 전달받은 MoldInfoModel
    final mold = ModalRoute.of(context)?.settings.arguments as MoldInfoModel?;

    if (mold == null) {
      return Scaffold(
        body: Center(
          child: Text('곰팡이 정보를 찾을 수 없습니다.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // 상단 이미지 헤더
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: mold.gradientColors[0],
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
                    colors: mold.gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Text(
                        mold.emoji,
                        style: const TextStyle(fontSize: 80),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          mold.type,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 본문 내용
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 제목
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                mold.name,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.gray800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                mold.nameEn,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppTheme.gray400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!mold.isMold)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.pinkLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              '곰팡이 아님',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.pinkPrimary,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // 설명
                    _buildSection(
                      title: '설명',
                      icon: Icons.info_outline_rounded,
                      child: Text(
                        mold.description,
                        style: TextStyle(
                          fontSize: 15,
                          color: AppTheme.gray600,
                          height: 1.6,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 외관 특징
                    _buildSection(
                      title: '외관 특징',
                      icon: Icons.palette_outlined,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow('색상', mold.color),
                          const SizedBox(height: 8),
                          _buildInfoRow('특징', mold.characteristics),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 주요 발생 장소
                    _buildSection(
                      title: '주요 발생 장소',
                      icon: Icons.location_on_outlined,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: mold.commonLocations.map((location) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.mintLight,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              location,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.mintDark,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 제거 방법
                    _buildSection(
                      title: '제거 방법',
                      icon: Icons.cleaning_services_outlined,
                      child: Column(
                        children: mold.treatments.asMap().entries.map((entry) {
                          return _buildNumberedItem(entry.key + 1, entry.value);
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 예방 방법
                    _buildSection(
                      title: '예방 방법',
                      icon: Icons.shield_outlined,
                      child: Column(
                        children: mold.preventions.asMap().entries.map((entry) {
                          return _buildCheckItem(entry.value);
                        }).toList(),
                      ),
                    ),

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

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: AppTheme.mintPrimary,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.gray800,
              ),
            ),
          ],
        ),
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
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.gray500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.gray700,
            ),
          ),
        ),
      ],
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
              color: AppTheme.mintPrimary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.gray700,
                height: 1.5,
              ),
            ),
          ),
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
          Icon(
            Icons.check_circle_rounded,
            size: 20,
            color: AppTheme.safe,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.gray700,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
