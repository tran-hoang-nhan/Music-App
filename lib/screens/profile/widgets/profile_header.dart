import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileHeader extends StatelessWidget {
  final User? user;
  final Map<String, dynamic>? userProfile;

  const ProfileHeader({
    super.key,
    required this.user,
    required this.userProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4A148C), Color(0xFF6A1B9A)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: ClipOval(
              child: user?.photoURL != null
                  ? Image.network(
                      user!.photoURL!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    )
                  : const Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.white,
                    ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Name
          Text(
            userProfile?['name'] ?? user?.displayName ?? 'Nguyễn Văn A',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          
          // Email
          Text(
            user?.email ?? 'nguyenvana@example.com',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

