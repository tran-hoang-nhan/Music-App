import 'package:flutter/material.dart';
import '../../services/firebase/firebase_controller.dart';
import '../../main.dart';
import 'widgets/login_form.dart';
import 'widgets/register_form.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final FirebaseController _firebaseService = FirebaseController();

  bool _isLogin = true;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom - 48,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo và tiêu đề
                const Icon(
                  Icons.music_note,
                  size: 80,
                  color: Color(0xFFE53E3E),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Ứng dụng Âm nhạc',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isLogin ? 'Đăng nhập để tiếp tục' : 'Tạo tài khoản mới',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 48),

                // Loading indicator
                if (_isLoading)
                  const CircularProgressIndicator(color: Color(0xFFE53E3E))
                else
                // Form đăng nhập/đăng ký
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _isLogin
                        ? LoginForm(
                      key: const ValueKey('login'),
                      onSwitchToRegister: () => setState(() => _isLogin = false),
                      onLogin: _handleLogin,
                      onForgotPassword: _showForgotPasswordDialog,
                    )
                        : RegisterForm(
                      key: const ValueKey('register'),
                      onSwitchToLogin: () => setState(() => _isLogin = true),
                      onRegister: _handleRegister,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin(String email, String password) async {
    setState(() => _isLoading = true);
    try {
      final user = await _firebaseService.auth.signIn(email, password);
      if (mounted) {
        if (user != null) {
          final navigator = Navigator.of(context);
          navigator.pushReplacement(
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        } else {
          final scaffoldMessenger = ScaffoldMessenger.of(context);
          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text('Email hoặc mật khẩu không đúng'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        final scaffoldMessenger = ScaffoldMessenger.of(context);
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Đăng nhập thất bại: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleRegister(String name, String email, String password) async {
    setState(() => _isLoading = true);
    try {
      final user = await _firebaseService.auth.signUp(email, password, name);
      if (mounted) {
        if (user != null) {
          final navigator = Navigator.of(context);
          navigator.pushReplacement(
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        } else {
          final scaffoldMessenger = ScaffoldMessenger.of(context);
          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text('Đăng ký thất bại, vui lòng thử lại'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        final scaffoldMessenger = ScaffoldMessenger.of(context);
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Đăng ký thất bại: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showForgotPasswordDialog() {
    final resetEmailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text('Quên mật khẩu', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Nhập email để nhận liên kết đặt lại mật khẩu',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: resetEmailController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFF121212),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.email, color: Colors.grey),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                final email = resetEmailController.text.trim();
                if (!context.mounted) return;
                final navigator = Navigator.of(context);
                final scaffoldMessenger = ScaffoldMessenger.of(context);

                if (email.isEmpty || !email.contains('@')) {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('Vui lòng nhập email hợp lệ'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final success = await _firebaseService.auth.resetPassword(email);
                if (!context.mounted) return;
                navigator.pop();

                if (success) {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('Đã gửi email đặt lại mật khẩu. Vui lòng kiểm tra hộp thư.'),
                      backgroundColor: Color(0xFFE53E3E),
                    ),
                  );
                } else {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('Không thể gửi email. Vui lòng thử lại.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Gửi', style: TextStyle(color: Color(0xFFE53E3E))),
            ),
          ],
        );
      },
    );
  }
}