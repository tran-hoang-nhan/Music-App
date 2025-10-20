import 'package:flutter/material.dart';

class ProfileSettings extends StatelessWidget {
  final VoidCallback onSignOut;

  const ProfileSettings({
    super.key,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSettingItem(
          'Cài đặt tài khoản',
          Icons.settings,
          () {
            // Navigate to account settings
          },
        ),
        _buildSettingItem(
          'Đăng xuất',
          Icons.logout,
          () => _showLogoutDialog(context),
        ),
      ],
    );
  }

  Widget _buildSettingItem(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text(
            'Đăng xuất',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Bạn có chắc chắn muốn đăng xuất?',
            style: TextStyle(color: Colors.grey),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Hủy',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onSignOut();
              },
              child: const Text(
                'Đăng xuất',
                style: TextStyle(color: Color(0xFFE53E3E)),
              ),
            ),
          ],
        );
      },
    );
  }
}

