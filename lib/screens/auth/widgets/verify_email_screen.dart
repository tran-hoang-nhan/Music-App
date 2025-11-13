import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/firebase/firebase_controller.dart';
import '../../../main.dart';
import '../auth_screen.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _isLoading = false;
  int _cooldown = 0; // giây

  @override
  Widget build(BuildContext context) {
    final firebase = Provider.of<FirebaseController>(context, listen: false);
    final user = firebase.currentUser;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _goToLogin();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF121212),
        appBar: AppBar(
          backgroundColor: const Color(0xFF121212),
          title: const Text('Xác minh email'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              await _goToLogin();
            },
          ),
        ),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                  const Icon(Icons.mark_email_unread, size: 72, color: Color(0xFFE53E3E)),
                  const SizedBox(height: 16),
                  const Text(
                    'Vui lòng xác minh email của bạn',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user?.email ?? '',
                    style: const TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Chúng tôi đã gửi email xác minh. Hãy kiểm tra hộp thư và nhấn vào liên kết để hoàn tất.',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Nút kiểm tra lại trạng thái
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () async {
                              setState(() => _isLoading = true);
                              final verified = await firebase.auth.reloadAndCheckEmailVerified();
                              if (!mounted || !context.mounted) return;
                              setState(() => _isLoading = false);
                              if (verified) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Xác minh thành công!'),
                                    backgroundColor: Color(0xFFE53E3E),
                                  ),
                                );
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(builder: (_) => const MainScreen()),
                                  (route) => false,
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Email của bạn chưa được xác minh.'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE53E3E)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_isLoading)
                            const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                          if (_isLoading) const SizedBox(width: 10),
                          Text(_isLoading ? 'Đang kiểm tra…' : 'Tôi đã xác minh'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Nút gửi lại email
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: (_cooldown > 0 || _isLoading)
                          ? null
                          : () async {
                              setState(() => _isLoading = true);
                              final ok = await firebase.auth.sendEmailVerification();
                              if (!mounted || !context.mounted) return;
                              setState(() {
                                _isLoading = false;
                                _cooldown = 30; // cooldown 30s
                              });
                              if (ok) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Đã gửi lại email xác minh.'),
                                    backgroundColor: Color(0xFFE53E3E),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Không thể gửi email. Vui lòng thử lại.'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                              _startCooldownTimer();
                            },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFE53E3E)),
                      ),
                      child: Text(
                        _cooldown > 0 ? 'Gửi lại (${_cooldown}s)' : 'Gửi lại email xác minh',
                        style: const TextStyle(color: Color(0xFFE53E3E)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  TextButton(
                    onPressed: () async {
                      await _goToLogin();
                    },
                    child: const Text('Quay lại', style: TextStyle(color: Colors.grey)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
  }

  void _startCooldownTimer() {
    if (_cooldown <= 0) return;
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() {
        _cooldown = _cooldown - 1;
      });
      return _cooldown > 0;
    });
  }

  Future<void> _goToLogin() async {
    try {
      final firebase = Provider.of<FirebaseController>(context, listen: false);
      await firebase.auth.signOut();
    } catch (_) {}
    if (!mounted || !context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthScreen()),
      (route) => false,
    );
  }
}
