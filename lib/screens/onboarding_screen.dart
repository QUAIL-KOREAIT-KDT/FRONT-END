import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../config/routes.dart';
import '../config/constants.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final TextEditingController _nicknameController = TextEditingController();
  String _selectedLocation = '서울특별시 강남구';
  double _selectedTemperature = 22.0;
  double _selectedHumidity = 50.0; // 평균 실내 습도
  int _selectedDirectionIndex = 0;
  bool _isBasement = false; // 반지하 여부

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
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
          child: Column(
            children: [
              // 헤더
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 20),
                child: Column(
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [AppTheme.mintPrimary, AppTheme.pinkPrimary],
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

              // 로고 이미지
              Container(
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
                      'assets/images/character/pangpangpang_logo_small.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('🧚', style: TextStyle(fontSize: 48)),
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

              const SizedBox(height: 24),

              // 폼
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                      _buildFilledInput(_selectedLocation),
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
                    ],
                  ),
                ),
              ),

              // 버튼
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(
                              context, AppRoutes.home);
                        },
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
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, AppRoutes.home);
                      },
                      child: Text(
                        '나중에 설정하기',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.gray400,
                        ),
                      ),
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
                      Text(
                        '⚠️',
                        style: TextStyle(fontSize: 12),
                      ),
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

  Widget _buildFilledInput(String value) {
    return Container(
      width: double.infinity,
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.mintLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.mintPrimary, width: 2),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            color: AppTheme.gray800,
          ),
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
