import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/connectivity_service.dart';

class OfflineBanner extends StatefulWidget {
  const OfflineBanner({super.key});

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: -1.0, end: 0.0).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityService>(
      builder: (context, connectivityService, child) {
        if (connectivityService.isConnected) {
          _slideController.reverse();
          _fadeController.reverse();
          return const SizedBox.shrink();
        } else {
          _slideController.forward();
          _fadeController.forward();
          return AnimatedBuilder(
            animation: _slideAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _slideAnimation.value * 50),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.orange.withValues(alpha: 0.9),
                          Colors.deepOrange.withValues(alpha: 0.8),
                        ],
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.wifi_off,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Không có kết nối internet. Một số tính năng có thể bị hạn chế.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => connectivityService.checkConnectivity(),
                          child: const Text(
                            'Thử lại',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }
}