import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_icons.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../services/user_service.dart';
import '../../providers/user_provider.dart';
// 조건부 import: 웹에서는 stub, 네이티브에서는 kpostal 사용
import '../address_search_stub.dart'
    if (dart.library.io) '../address_search_native.dart' as address_search;

class HomeInfoScreen extends StatefulWidget {
  const HomeInfoScreen({super.key});

  @override
  State<HomeInfoScreen> createState() => _HomeInfoScreenState();
}

class _HomeInfoScreenState extends State<HomeInfoScreen> {
  final TextEditingController _addressController = TextEditingController();
  final UserService _userService = UserService();
  String _selectedLocation = '';
  double _selectedTemperature = 22.0;
  double _selectedHumidity = 50.0;
  int _selectedDirectionIndex = 0;
  bool _isBasement = false;
  bool _isLoading = false;
  bool _isInitLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserInfo();
    });
  }

  void _loadUserInfo() {
    final user = context.read<UserProvider>().user;
    setState(() {
      if (user != null) {
        _selectedLocation = user.location ?? '';
        _addressController.text = _selectedLocation;
        _selectedTemperature =
            (user.indoorTemperature ?? 22.0).clamp(15.0, 30.0);
        _selectedHumidity = (user.indoorHumidity ?? 50.0).clamp(20.0, 80.0);
        _isBasement = user.underground == 'semi-basement';
        _selectedDirectionIndex =
            _apiValueToDirectionIndex(user.houseDirection);
      }
      _isInitLoading = false;
    });
  }

  /// 백엔드 API 값을 방향 인덱스로 변환
  int _apiValueToDirectionIndex(String? direction) {
    switch (direction) {
      case 'N':
        return 0; // 북향
      case 'S':
        return 1; // 남향
      default:
        return 2; // 기타
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
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

            // 폼
            Expanded(
              child: _isInitLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: AppTheme.mintPrimary),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),

                          // 거주지 위치
                          _buildLabel(AppIcons.location, '거주지 위치'),
                          const SizedBox(height: 8),
                          _buildAddressInput(),
                          const SizedBox(height: 20),

                          // 반지하 여부
                          _buildLabel(AppIcons.home, '반지하 여부'),
                          const SizedBox(height: 8),
                          _buildBasementSelector(),
                          const SizedBox(height: 20),

                          // 평균 실내 온도
                          _buildLabel(AppIcons.temperature, '평균 실내 온도'),
                          const SizedBox(height: 8),
                          _buildTemperatureSlider(),
                          const SizedBox(height: 20),

                          // 평균 실내 습도
                          _buildLabel(AppIcons.humidity, '평균 실내 습도'),
                          const SizedBox(height: 8),
                          _buildHumiditySlider(),
                          const SizedBox(height: 20),

                          // 집 방향
                          _buildLabel(AppIcons.direction, '집 방향'),
                          const SizedBox(height: 8),
                          _buildDirectionSelector(),

                          const SizedBox(height: 32),

                          // 저장 버튼
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _saveInfo,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.mintPrimary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              child: const Text(
                                '저장하기',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppTheme.gray700,
              size: 22,
            ),
          ),
          const SizedBox(width: 8),
          const Row(
            children: [
              Icon(AppIcons.homeInfo, size: 24, color: AppTheme.mintPrimary),
              SizedBox(width: 8),
              Text(
                '집 정보 수정',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.gray800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppTheme.mintPrimary),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.gray700,
          ),
        ),
      ],
    );
  }

  // 주소 입력 (웹/네이티브 분기)
  Widget _buildAddressInput() {
    if (kIsWeb) {
      return _buildWebAddressInput();
    } else {
      return _buildNativeAddressInput();
    }
  }

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

  Future<void> _openAddressSearch() async {
    final result = await address_search.openAddressSearch(context);
    if (result != null && result.isNotEmpty) {
      setState(() {
        _selectedLocation = result;
      });
    }
  }

  // 반지하 여부 선택
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
                child: Text(
                  '반지하',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color:
                        _isBasement ? AppTheme.pinkPrimary : AppTheme.gray500,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 온도 슬라이더
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

  // 습도 슬라이더
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

  // 집 방향 선택
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

  /// 방향 인덱스를 백엔드 API 값으로 변환
  String _directionToApiValue(int index) {
    // houseDirections: ['북향', '남향', '기타']
    // API: 'N' (북), 'S' (남), 'O' (기타)
    switch (index) {
      case 0:
        return 'N'; // 북향
      case 1:
        return 'S'; // 남향
      default:
        return 'O'; // 기타
    }
  }

  /// 반지하 여부를 백엔드 API 값으로 변환
  String _basementToApiValue(bool isBasement) {
    return isBasement ? 'semi-basement' : 'others';
  }

  Future<void> _saveInfo() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final updateData = UserProfilePartialUpdate(
        address: _selectedLocation,
        underground: _basementToApiValue(_isBasement),
        windowDirection: _directionToApiValue(_selectedDirectionIndex),
        indoorTemp: _selectedTemperature,
        indoorHumidity: _selectedHumidity,
      );

      final success = await _userService.updateProfilePartial(updateData);

      if (mounted) {
        if (success) {
          // Provider 로컬 상태도 갱신 (서버 재요청 없이)
          context.read<UserProvider>().updateHomeInfo(
                location: _selectedLocation,
                indoorTemperature: _selectedTemperature,
                indoorHumidity: _selectedHumidity,
                houseDirection: _directionToApiValue(_selectedDirectionIndex),
                underground: _basementToApiValue(_isBasement),
              );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('집 정보가 저장되었습니다'),
              backgroundColor: AppTheme.mintPrimary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('저장에 실패했습니다. 다시 시도해주세요.'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('[HomeInfoScreen] 저장 오류: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('오류가 발생했습니다. 다시 시도해주세요.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
