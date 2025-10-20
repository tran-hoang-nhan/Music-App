import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme/theme_controller.dart';

class DynamicBackground extends StatelessWidget {
  final Widget child;

  const DynamicBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeController>(
      builder: (context, themeService, _) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 800),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: themeService.gradientColors.isNotEmpty 
                  ? themeService.gradientColors
                  : [
                      const Color(0xFF121212),
                      const Color(0xFF1E1E1E),
                      const Color(0xFF121212),
                    ],
            ),
          ),
          child: child,
        );
      },
    );
  }
}

