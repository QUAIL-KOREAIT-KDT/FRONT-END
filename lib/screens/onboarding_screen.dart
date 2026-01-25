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
  String _selectedLocation = '서울특별시 강남구';
  double _selectedTemperature = 22.0;
  int _selectedDirectionIndex = 0;

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

              // 캐릭터
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
                child: Column(
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

                      // 거주지 위치
                      _buildLabel('📍 거주지 위치'),
                      const SizedBox(height: 8),
                      _buildFilledInput(_selectedLocation),
                      const SizedBox(height: 20),

                      // 평균 실내 온도
                      _buildLabel('🌡️ 평균 실내 온도'),
                      const SizedBox(height: 8),
                      _buildTemperatureSlider(),
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
