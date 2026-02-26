import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// 조건부 import: 웹에서는 stub, 네이티브에서는 kpostal 사용
import 'address_search_stub.dart'
    if (dart.library.io) 'address_search_native.dart' as address_search;
import '../config/theme.dart';
import '../config/routes.dart';
import '../config/constants.dart';
import '../providers/user_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _addressController =
      TextEditingController(); // 웹용 주소 입력
  String _selectedLocation = ''; // 주소 검색으로 입력
  double _selectedTemperature = 22.0;
  double _selectedHumidity = 50.0; // 평균 실내 습도
  int _selectedDirectionIndex = 0;
  bool _isBasement = false; // 반지하 여부
  bool _isSubmitting = false; // 제출 중복 방지
  bool _isSearchingAddress = false; // 주소 검색 중복 방지

  @override
  void dispose() {
    _nicknameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // 온보딩 제출 (API 호출)
  Future<void> _submitOnboarding(BuildContext context) async {
    if (_isSubmitting) return;

    final nickname = _nicknameController.text.trim();
    if (nickname.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('닉네임을 입력해주세요')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // 방향 변환: 북향 -> N, 남향 -> S, 기타 -> O
    final directions = ['N', 'S', 'O'];
    final windowDirection = directions[_selectedDirectionIndex];

    // 반지하 여부: 일반 -> others, 반지하 -> semi-basement
    final underground = _isBasement ? 'semi-basement' : 'others';

    final userProvider = Provider.of<UserProvider>(context, listen: false);

    final success = await userProvider.completeOnboarding(
      nickname: nickname,
      address: _selectedLocation,
      underground: underground,
      windowDirection: windowDirection,
      indoorTemp: _selectedTemperature,
      indoorHumidity: _selectedHumidity,
    );

    if (success && mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else if (mounted) {
      setState(() => _isSubmitting = false);
      // 실패해도 일단 홈으로 이동 (더미 데이터 사용)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('서버 연결 실패 - 나중에 다시 시도해주세요')),
      );
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.mintLight,
              Colors.white,
              AppTheme.pinkLight,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 헤더
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 40, 0, 20),
                  child: Center(
                    child: Column(
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [
                              AppTheme.mintPrimary,
                              AppTheme.pinkPrimary
                            ],
                          ).createShader(bounds),
                          child: const Text(
                            '팡팡팡',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '곰팡이 없는 쾌적한 우리 집',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.gray500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 로고 이미지
                Center(
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [AppTheme.mintLight2, AppTheme.pinkLight2],
                      ),
                      border: Border.all(
                        color: AppTheme.mintPrimary,
                        width: 4,
                        strokeAlign: BorderSide.strokeAlignOutside,
                      ),
                    ),
                    child: ClipOval(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Image.asset(
                          'assets/images/character/pangpangpang_logo_small.webp',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('🧚',
                                    style: TextStyle(fontSize: 48)),
                                Text(
                                  '팡이',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.gray500,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // 폼
                const Text(
                  '우리 집 정보를 알려주세요!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.gray800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '정확한 곰팡이 위험도 예측을 위해\n간단한 정보가 필요해요',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.gray500,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),

                // 닉네임 입력
                _buildLabel('👤 닉네임'),
                const SizedBox(height: 8),
                _buildNicknameInput(),
                const SizedBox(height: 20),

                // 거주지 위치
                _buildLabel('📍 거주지 위치'),
                const SizedBox(height: 8),
                _buildAddressInput(),
                const SizedBox(height: 20),

                // 반지하 여부
                _buildLabel('🏠 반지하 여부'),
                const SizedBox(height: 8),
                _buildBasementSelector(),
                const SizedBox(height: 20),

                // 평균 실내 온도
                _buildLabel('🌡️ 평균 실내 온도'),
                const SizedBox(height: 8),
                _buildTemperatureSlider(),
                const SizedBox(height: 20),

                // 평균 실내 습도 (선택사항)
                _buildLabel('💧 평균 실내 습도 (선택)'),
                const SizedBox(height: 8),
                _buildHumiditySlider(),
                const SizedBox(height: 20),

                // 집 방향
                _buildLabel('🧭 집 방향'),
                const SizedBox(height: 8),
                _buildDirectionSelector(),

                const SizedBox(height: 20),

                // 버튼
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed:
                        _isSubmitting ? null : () => _submitOnboarding(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.mintPrimary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shadowColor: AppTheme.mintPrimary.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '시작하기',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text('✨', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppTheme.gray700,
      ),
    );
  }

  Widget _buildNicknameInput() {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.gray200, width: 2),
      ),
      child: TextField(
        controller: _nicknameController,
        decoration: InputDecoration(
          hintText: '닉네임을 입력해주세요',
          hintStyle: TextStyle(
            fontSize: 15,
            color: AppTheme.gray400,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        style: const TextStyle(
          fontSize: 15,
          color: AppTheme.gray800,
        ),
      ),
    );
  }

  Widget _buildBasementSelector() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _isBasement = false;
              });
            },
            child: Container(
              height: 52,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: !_isBasement ? AppTheme.mintLight : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: !_isBasement ? AppTheme.mintPrimary : AppTheme.gray200,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  '일반 주거',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: !_isBasement ? AppTheme.mintDark : AppTheme.gray500,
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _isBasement = true;
              });
            },
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: _isBasement ? AppTheme.pinkLight : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isBasement ? AppTheme.pinkPrimary : AppTheme.gray200,
                  width: 2,
                ),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '반지하',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _isBasement
                            ? AppTheme.pinkPrimary
                            : AppTheme.gray500,
                      ),
                    ),
                    if (_isBasement) ...[
                      const SizedBox(width: 4),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 카카오 우편번호 서비스를 이용한 주소 검색 (네이티브 전용)
  Future<void> _openAddressSearch() async {
    if (_isSearchingAddress) return;
    setState(() => _isSearchingAddress = true);

    try {
      final result = await address_search.openAddressSearch(context);
      if (result != null && result.isNotEmpty) {
        setState(() {
          _selectedLocation = result;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isSearchingAddress = false);
      }
    }
  }

  Widget _buildAddressInput() {
    // 웹에서는 직접 입력, 네이티브에서는 kpostal 검색 사용
    if (kIsWeb) {
      return _buildWebAddressInput();
    } else {
      return _buildNativeAddressInput();
    }
  }

  /// 웹용 주소 직접 입력 필드
  Widget _buildWebAddressInput() {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.gray200, width: 2),
      ),
      child: TextField(
        controller: _addressController,
        onChanged: (value) {
          setState(() {
            _selectedLocation = value;
          });
        },
        decoration: InputDecoration(
          hintText: '주소를 입력해주세요 (예: 서울시 강남구)',
          hintStyle: TextStyle(
            fontSize: 15,
            color: AppTheme.gray400,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          suffixIcon: Icon(
            Icons.edit_location_alt_outlined,
            color: AppTheme.gray400,
            size: 20,
          ),
        ),
        style: const TextStyle(
          fontSize: 15,
          color: AppTheme.gray800,
        ),
      ),
    );
  }

  /// 네이티브용 주소 검색 버튼
  Widget _buildNativeAddressInput() {
    final bool hasAddress = _selectedLocation.isNotEmpty;

    return GestureDetector(
      onTap: _openAddressSearch,
      child: Container(
        width: double.infinity,
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: hasAddress ? AppTheme.mintLight : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasAddress ? AppTheme.mintPrimary : AppTheme.gray200,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                hasAddress ? _selectedLocation : '주소를 검색해주세요',
                style: TextStyle(
                  fontSize: 15,
                  color: hasAddress ? AppTheme.gray800 : AppTheme.gray400,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.search,
              color: hasAddress ? AppTheme.mintPrimary : AppTheme.gray400,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemperatureSlider() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.gray200, width: 2),
      ),
      child: Column(
        children: [
          Text(
            '${_selectedTemperature.toInt()}°C',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppTheme.mintPrimary,
            ),
          ),
          Slider(
            value: _selectedTemperature,
            min: 15,
            max: 30,
            divisions: 15,
            activeColor: AppTheme.mintPrimary,
            inactiveColor: AppTheme.gray200,
            onChanged: (value) {
              setState(() {
                _selectedTemperature = value;
              });
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('15°C',
                  style: TextStyle(fontSize: 12, color: AppTheme.gray400)),
              Text('30°C',
                  style: TextStyle(fontSize: 12, color: AppTheme.gray400)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHumiditySlider() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.gray200, width: 2),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${_selectedHumidity.toInt()}%',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.mintPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getHumidityColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getHumidityStatus(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _getHumidityColor(),
                  ),
                ),
              ),
            ],
          ),
          Slider(
            value: _selectedHumidity,
            min: 20,
            max: 80,
            divisions: 60,
            activeColor: AppTheme.mintPrimary,
            inactiveColor: AppTheme.gray200,
            onChanged: (value) {
              setState(() {
                _selectedHumidity = value;
              });
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('20%',
                  style: TextStyle(fontSize: 12, color: AppTheme.gray400)),
              Text('80%',
                  style: TextStyle(fontSize: 12, color: AppTheme.gray400)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '모르시면 50%로 두셔도 괜찮아요',
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.gray400,
            ),
          ),
        ],
      ),
    );
  }

  String _getHumidityStatus() {
    if (_selectedHumidity < 40) return '건조';
    if (_selectedHumidity < 60) return '적정';
    return '습함';
  }

  Color _getHumidityColor() {
    if (_selectedHumidity < 40) return Colors.orange;
    if (_selectedHumidity < 60) return AppTheme.mintPrimary;
    return AppTheme.pinkPrimary;
  }

  Widget _buildDirectionSelector() {
    return Row(
      children: List.generate(
        AppConstants.houseDirections.length,
        (index) => Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedDirectionIndex = index;
              });
            },
            child: Container(
              height: 52,
              margin: EdgeInsets.only(
                right: index < AppConstants.houseDirections.length - 1 ? 12 : 0,
              ),
              decoration: BoxDecoration(
                color: _selectedDirectionIndex == index
                    ? AppTheme.mintLight
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _selectedDirectionIndex == index
                      ? AppTheme.mintPrimary
                      : AppTheme.gray200,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  AppConstants.houseDirections[index],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _selectedDirectionIndex == index
                        ? AppTheme.mintDark
                        : AppTheme.gray500,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
