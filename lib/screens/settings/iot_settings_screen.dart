import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_icons.dart';
import '../../config/theme.dart';
import '../../providers/iot_provider.dart';
import '../../models/iot_device.dart';

class IotSettingsScreen extends StatefulWidget {
  const IotSettingsScreen({super.key});

  @override
  State<IotSettingsScreen> createState() => _IotSettingsScreenState();
}

class _IotSettingsScreenState extends State<IotSettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IotProvider>().loadDevices();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Consumer<IotProvider>(
                builder: (context, iotProvider, child) {
                  if (iotProvider.isLoading) {
                    return _buildLoading();
                  }

                  if (!iotProvider.isMaster) {
                    return _buildComingSoon();
                  }

                  if (iotProvider.errorMessage != null) {
                    return _buildError(iotProvider.errorMessage!);
                  }

                  return _buildDeviceList(iotProvider);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
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
          const Icon(AppIcons.iotSettings,
              size: 24, color: AppTheme.mintPrimary),
          const SizedBox(width: 8),
          const Text(
            '스마트홈 연동',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppTheme.gray800,
            ),
          ),
          const Spacer(),
          Consumer<IotProvider>(
            builder: (context, iotProvider, child) {
              if (!iotProvider.isMaster || iotProvider.isLoading) {
                return const SizedBox.shrink();
              }
              return IconButton(
                onPressed: () => _onRefresh(context),
                icon: const Icon(
                  Icons.refresh_rounded,
                  color: AppTheme.gray600,
                  size: 24,
                ),
                tooltip: '기기 새로고침',
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _onRefresh(BuildContext context) async {
    final provider = context.read<IotProvider>();
    final messenger = ScaffoldMessenger.of(context);
    await provider.loadDevices();
    if (!mounted) return;
    messenger.showSnackBar(
      SnackBar(
        content: const Text('기기 정보를 새로고침했습니다.'),
        backgroundColor: AppTheme.mintPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppTheme.mintPrimary,
          ),
          SizedBox(height: 16),
          Text(
            '기기 정보를 불러오는 중...',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.gray400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComingSoon() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.mintLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.construction_rounded,
                size: 40,
                color: AppTheme.mintPrimary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '개발중',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.gray800,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '스마트홈 연동 기능은 현재 개발중입니다.\n추후 업데이트 예정입니다.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: AppTheme.gray400,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppTheme.gray400,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.gray600,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<IotProvider>().loadDevices();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('다시 시도'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.mintPrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceList(IotProvider iotProvider) {
    return RefreshIndicator(
      onRefresh: () => _onRefresh(context),
      color: AppTheme.mintPrimary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('연결된 기기'),
            if (iotProvider.devices.isEmpty)
              _buildEmptyState()
            else
              ...iotProvider.devices.map((device) => _buildDeviceCard(device)),
            const SizedBox(height: 32),
            _buildSupportedDevices(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppTheme.gray800,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.gray100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.devices_outlined,
            size: 48,
            color: AppTheme.gray400,
          ),
          SizedBox(height: 16),
          Text(
            '연결된 기기가 없어요',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.gray600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Smart Life 앱에 기기를 등록하면\n여기에서 제어할 수 있어요',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.gray400,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceCard(IotDeviceModel device) {
    IconData iconData;
    switch (device.type) {
      case 'dehumidifier':
        iconData = Icons.air_rounded;
        break;
      case 'air_conditioner':
        iconData = Icons.ac_unit_rounded;
        break;
      case 'fan':
        iconData = Icons.wind_power_rounded;
        break;
      case 'plug':
      default:
        iconData = Icons.power_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.gray200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 아이콘
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: device.isOnline ? AppTheme.mintLight : AppTheme.gray100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              iconData,
              color: device.isOnline ? AppTheme.mintPrimary : AppTheme.gray400,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          // 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.gray800,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color:
                            device.isOnline ? AppTheme.safe : AppTheme.gray400,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      device.isOnline ? '온라인' : '오프라인',
                      style: TextStyle(
                        fontSize: 13,
                        color:
                            device.isOnline ? AppTheme.safe : AppTheme.gray400,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      device.typeName,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.gray400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // ON/OFF 스위치
          Switch(
            value: device.isOn,
            onChanged: device.isOnline
                ? (value) => _onToggleDevice(device, value)
                : null,
            activeThumbColor: AppTheme.mintPrimary,
            activeTrackColor: AppTheme.mintLight2,
            inactiveThumbColor: AppTheme.gray300,
            inactiveTrackColor: AppTheme.gray200,
          ),
        ],
      ),
    );
  }

  void _onToggleDevice(IotDeviceModel device, bool turnOn) async {
    final iotProvider = context.read<IotProvider>();
    final success = await iotProvider.controlDevice(device.id, turnOn);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? '${device.name}이(가) ${turnOn ? "켜졌" : "꺼졌"}습니다.'
              : '기기 제어에 실패했습니다.',
        ),
        backgroundColor: success ? AppTheme.mintPrimary : AppTheme.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildSupportedDevices() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.gray100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '지원하는 기기',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.gray800,
            ),
          ),
          const SizedBox(height: 16),
          _buildSupportItem('🔌', '스마트 플러그', 'Tuya 호환 플러그'),
          _buildSupportItem('💨', '제습기', '스마트 플러그로 제어'),
          _buildSupportItem('🌀', '선풍기', '스마트 플러그로 제어'),
        ],
      ),
    );
  }

  Widget _buildSupportItem(String emoji, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.gray700,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.gray400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
