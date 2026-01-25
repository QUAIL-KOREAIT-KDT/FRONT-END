import 'package:flutter/material.dart';
import '../../config/theme.dart';

class IotSettingsScreen extends StatefulWidget {
  const IotSettingsScreen({super.key});

  @override
  State<IotSettingsScreen> createState() => _IotSettingsScreenState();
}

class _IotSettingsScreenState extends State<IotSettingsScreen> {
  // 더미 연결된 기기 목록
  final List<Map<String, dynamic>> _connectedDevices = [
    {
      'name': '거실 온습도계',
      'type': 'sensor',
      'status': 'connected',
      'battery': 85,
    },
    {
      'name': '침실 제습기',
      'type': 'dehumidifier',
      'status': 'connected',
      'battery': null,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 헤더
            _buildHeader(context),

            // 컨텐츠
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 연결된 기기
                    _buildSectionTitle('연결된 기기'),
                    if (_connectedDevices.isEmpty)
                      _buildEmptyState()
                    else
                      ..._connectedDevices
                          .map((device) => _buildDeviceCard(device)),

                    const SizedBox(height: 32),

                    // 새 기기 추가
                    _buildAddDeviceButton(),

                    const SizedBox(height: 32),

                    // 지원 기기 안내
                    _buildSupportedDevices(),
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
          Row(
            children: [
              const Text(
                '📡',
                style: TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 8),
              const Text(
                '스마트홈 연동',
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
      child: Column(
        children: [
          Icon(
            Icons.devices_outlined,
            size: 48,
            color: AppTheme.gray400,
          ),
          const SizedBox(height: 16),
          Text(
            '연결된 기기가 없어요',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.gray600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '스마트홈 기기를 연결하면\n더 정확한 곰팡이 위험도를 측정할 수 있어요',
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

  Widget _buildDeviceCard(Map<String, dynamic> device) {
    final isConnected = device['status'] == 'connected';

    IconData iconData;
    switch (device['type']) {
      case 'sensor':
        iconData = Icons.sensors_rounded;
        break;
      case 'dehumidifier':
        iconData = Icons.air_rounded;
        break;
      default:
        iconData = Icons.devices_other_rounded;
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
            color: Colors.black.withOpacity(0.04),
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
              color: isConnected ? AppTheme.mintLight : AppTheme.gray100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              iconData,
              color: isConnected ? AppTheme.mintPrimary : AppTheme.gray400,
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
                  device['name'],
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
                        color: isConnected ? AppTheme.safe : AppTheme.gray400,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isConnected ? '연결됨' : '연결 끊김',
                      style: TextStyle(
                        fontSize: 13,
                        color: isConnected ? AppTheme.safe : AppTheme.gray400,
                      ),
                    ),
                    if (device['battery'] != null) ...[
                      const SizedBox(width: 12),
                      Icon(
                        Icons.battery_std_rounded,
                        size: 14,
                        color: AppTheme.gray400,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${device['battery']}%',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.gray400,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          // 더보기 버튼
          IconButton(
            onPressed: () => _showDeviceOptions(device),
            icon: Icon(
              Icons.more_vert_rounded,
              color: AppTheme.gray400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddDeviceButton() {
    return GestureDetector(
      onTap: _showAddDeviceDialog,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.mintLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.mintPrimary.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline_rounded,
              color: AppTheme.mintPrimary,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              '새 기기 추가',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.mintPrimary,
              ),
            ),
          ],
        ),
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
          _buildSupportItem('🌡️', '온습도 센서', 'Xiaomi, Aqara 등'),
          _buildSupportItem('💨', '제습기', 'LG, 삼성, 위닉스 등'),
          _buildSupportItem('🌬️', '환기 시스템', 'Samsung SmartThings'),
          _buildSupportItem('📡', '공기질 측정기', 'Awair, Qingping 등'),
        ],
      ),
    );
  }

  Widget _buildSupportItem(String emoji, String title, String brands) {
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
                  brands,
                  style: TextStyle(
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

  void _showDeviceOptions(Map<String, dynamic> device) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.gray300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              device['name'],
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.gray800,
              ),
            ),
            const SizedBox(height: 24),
            _buildOptionItem(
              icon: Icons.sync_rounded,
              title: '다시 연결',
              onTap: () => Navigator.pop(context),
            ),
            _buildOptionItem(
              icon: Icons.edit_outlined,
              title: '이름 변경',
              onTap: () => Navigator.pop(context),
            ),
            _buildOptionItem(
              icon: Icons.delete_outline_rounded,
              title: '기기 삭제',
              color: AppTheme.danger,
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String title,
    Color? color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppTheme.gray600),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: color ?? AppTheme.gray800,
        ),
      ),
      onTap: onTap,
    );
  }

  void _showAddDeviceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('기기 추가'),
        content: const Text('블루투스와 Wi-Fi를 켜고 기기를 검색합니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('기기를 검색중입니다...'),
                  backgroundColor: AppTheme.mintPrimary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            child: const Text('검색'),
          ),
        ],
      ),
    );
  }
}
