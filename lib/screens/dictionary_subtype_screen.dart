import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/mold_category.dart';
import 'dictionary_subtype_detail_screen.dart';

class DictionarySubtypeScreen extends StatelessWidget {
  final MoldCategory category;

  const DictionarySubtypeScreen({
    super.key,
    required this.category,
  });

  /// 배경색이 밝은지 판단하여 텍스트 색상 결정
  bool _isLightBackground(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5;
  }

  @override
  Widget build(BuildContext context) {
    final isLight = _isLightBackground(category.gradientColors[0]);
    final textColor = isLight ? AppTheme.gray700 : Colors.white;
    final subTextColor = isLight ? AppTheme.gray500 : Colors.white.withOpacity(0.9);
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: category.gradientColors[0],
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
                    colors: category.gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        category.emoji,
                        style: const TextStyle(fontSize: 64),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        category.name,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${category.subTypes.length}가지 종류',
                        style: TextStyle(
                          fontSize: 15,
                          color: subTextColor,
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
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.description,
                    style: TextStyle(
                      fontSize: 15,
                      color: AppTheme.gray600,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    '세부 종류',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.gray800,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final subType = category.subTypes[index];
                  return _buildSubTypeCard(context, subType);
                },
                childCount: category.subTypes.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 40),
          ),
        ],
      ),
    );
  }

  Widget _buildSubTypeCard(BuildContext context, MoldSubType subType) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DictionarySubtypeDetailScreen(
              subType: subType,
              categoryName: category.name,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: subType.gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(20),
                ),
              ),
              child: const Center(
                child: Text(
                  '🦠',
                  style: TextStyle(fontSize: 36),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subType.name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.gray800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subType.scientificName,
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: AppTheme.gray400,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subType.shortDescription,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.gray500,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: AppTheme.gray300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
