import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../models/mold_category.dart';
import '../providers/dictionary_provider.dart';
import 'dictionary_subtype_screen.dart';
import 'dictionary_subtype_detail_screen.dart';

/// 곰팡이 사전 메인 화면
/// 색상별 곰팡이 카테고리를 보여주고, 클릭하면 세부 종류 목록으로 이동
class DictionaryScreen extends StatefulWidget {
  const DictionaryScreen({super.key});

  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Provider를 통해 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DictionaryProvider>().loadDictionary();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<MoldCategory> _filterCategories(List<MoldCategory> categories) {
    if (_searchQuery.isEmpty) return categories;
    return categories
        .where((category) =>
            category.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            category.description
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()))
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

            // 검색창
            _buildSearchBar(),

            // 카테고리 그리드
            Expanded(
              child: _buildBody(),
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
          // 타이틀
          Row(
            children: [
              const Text(
                '📚',
                style: TextStyle(fontSize: 28),
              ),
              const SizedBox(width: 10),
              const Text(
                '곰팡이 사전',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.gray800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.gray100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.gray200, width: 1),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (query) {
            setState(() {
              _searchQuery = query;
            });
          },
          decoration: InputDecoration(
            hintText: '곰팡이 종류 검색',
            hintStyle: TextStyle(
              color: AppTheme.gray400,
              fontSize: 16,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: AppTheme.gray400,
              size: 24,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Consumer<DictionaryProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppTheme.mintPrimary,
            ),
          );
        }

        if (provider.categories.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: AppTheme.gray400),
                const SizedBox(height: 16),
                Text(
                  '도감 데이터를 불러올 수 없습니다',
                  style: TextStyle(fontSize: 16, color: AppTheme.gray500),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.refresh(),
                  child: const Text('다시 시도'),
                ),
              ],
            ),
          );
        }

        final filteredList = _filterCategories(provider.categories);
        return _buildCategoryGrid(filteredList);
      },
    );
  }

  Widget _buildCategoryGrid(List<MoldCategory> filteredList) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        padding: const EdgeInsets.only(bottom: 24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.78,
        ),
        itemCount: filteredList.length,
        itemBuilder: (context, index) {
          return _buildCategoryCard(filteredList[index]);
        },
      ),
    );
  }

  Widget _buildCategoryCard(MoldCategory category) {
    return GestureDetector(
      onTap: () {
        if (category.subTypes.length == 1) {
          // 세부 종류가 1개면 바로 상세 화면으로 이동
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DictionarySubtypeDetailScreen(
                subType: category.subTypes.first,
                categoryName: category.name,
              ),
            ),
          );
        } else if (category.subTypes.isNotEmpty) {
          // 세부 종류가 여러 개면 SubtypeScreen으로 이동
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  DictionarySubtypeScreen(category: category),
            ),
          );
        } else {
          // 세부 종류가 없으면 스낵바 표시
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${category.name}의 세부 정보를 준비 중입니다'),
              backgroundColor: AppTheme.mintPrimary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 이미지 영역
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: category.gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Text(
                          category.emoji,
                          style: const TextStyle(fontSize: 52),
                        ),
                      ),
                      // 세부 종류 개수 뱃지
                      if (category.subTypes.isNotEmpty)
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${category.subTypes.length}종',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: category.gradientColors[0],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // 텍스트 영역
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      category.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.gray800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      category.description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.gray500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
