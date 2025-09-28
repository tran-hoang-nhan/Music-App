import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../main.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();
  
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
              Text(
                'Ứng dụng Âm nhạc',
                style: const TextStyle(
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
              
              // Form đăng nhập/đăng ký
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    if (!_isLogin)
                      TextFormField(
                        controller: _nameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Họ tên',
                          labelStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: const Color(0xFF1E1E1E),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(Icons.person, color: Colors.grey),
                        ),
                        validator: (value) {
                          if (!_isLogin && (value == null || value.isEmpty)) {
                            return 'Vui lòng nhập họ tên';
                          }
                          return null;
                        },
                      ),
                    if (!_isLogin) const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _emailController,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: const Color(0xFF1E1E1E),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.email, color: Colors.grey),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập email';
                        }
                        if (!value.contains('@')) {
                          return 'Email không hợp lệ';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _passwordController,
                      style: const TextStyle(color: Colors.white),
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Mật khẩu',
                        labelStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: const Color(0xFF1E1E1E),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập mật khẩu';
                        }
                        if (value.length < 6) {
                          return 'Mật khẩu phải có ít nhất 6 ký tự';
                        }
                        return null;
                      },
                    ),
                    if (!_isLogin) const SizedBox(height: 16),
                    
                    if (!_isLogin)
                      TextFormField(
                        controller: _confirmPasswordController,
                        style: const TextStyle(color: Colors.white),
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Nhập lại mật khẩu',
                          labelStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: const Color(0xFF1E1E1E),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                        ),
                        validator: (value) {
                          if (!_isLogin) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng nhập lại mật khẩu';
                            }
                            if (value != _passwordController.text) {
                              return 'Mật khẩu không khớp';
                            }
                          }
                          return null;
                        },
                      ),
                    const SizedBox(height: 24),
                    
                    // Nút đăng nhập/đăng ký
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleAuth,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE53E3E),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                                _isLogin ? 'Đăng nhập' : 'Đăng ký',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Quên mật khẩu (chỉ hiển thị khi đăng nhập)
                    if (_isLogin)
                      TextButton(
                        onPressed: _showForgotPasswordDialog,
                        child: const Text(
                          'Quên mật khẩu?',
                          style: TextStyle(
                            color: Color(0xFFE53E3E),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    
                    // Chuyển đổi giữa đăng nhập và đăng ký
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isLogin = !_isLogin;
                        });
                      },
                      child: Text(
                        _isLogin
                            ? 'Chưa có tài khoản? Đăng ký ngay'
                            : 'Đã có tài khoản? Đăng nhập',
                        style: const TextStyle(
                          color: Color(0xFFE53E3E),
                          fontSize: 14,
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
      ),
    );
  }

  Future<void> _handleAuth() async {
    if (!_formKey.currentState!.validate()) return;

    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isLogin) {
        final user = await _firebaseService.signIn(
          _emailController.text.trim(),
          _passwordController.text,
        );
        
        if (user != null) {
          if (mounted) {
            navigator.pushReplacement(
              MaterialPageRoute(builder: (context) => const MainScreen()),
            );
          }
        } else {
          if (mounted) {
            scaffoldMessenger.showSnackBar(
              const SnackBar(
                content: Text('Đăng nhập thất bại. Vui lòng kiểm tra lại thông tin.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        final user = await _firebaseService.signUp(
          _emailController.text.trim(),
          _passwordController.text,
          _nameController.text.trim(),
        );
        
        if (user != null) {
          if (mounted) {
            navigator.pushReplacement(
              MaterialPageRoute(builder: (context) => const MainScreen()),
            );
          }
        } else {
          if (mounted) {
            scaffoldMessenger.showSnackBar(
              const SnackBar(
                content: Text('Đăng ký thất bại. Vui lòng thử lại.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Có lỗi xảy ra: $e'),
            backgroundColor: Colors.red,
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
                
                final success = await _firebaseService.resetPassword(email);
                if (mounted) {
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
                }
              },
              child: const Text('Gửi', style: TextStyle(color: Color(0xFFE53E3E))),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }
}