import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_service.dart';

class DynamicBackground extends StatelessWidget {
  final Widget child;
  final bool usePlayerGradient;

  const DynamicBackground({
    super.key,
    required this.child,
    this.usePlayerGradient = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, _) {
        if (usePlayerGradient) {
          return themeService.createPlayerGradient(child: child);
        }
        return themeService.createGradientContainer(child: child);
      },
    );
  }
}

class DynamicCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;

  const DynamicCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, _) {
        return Container(
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: themeService.primaryColor.withValues(alpha: 0.1),
            borderRadius: borderRadius ?? BorderRadius.circular(12),
            border: Border.all(
              color: themeService.primaryColor.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: child,
        );
      },
    );
  }
}

class DynamicButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final bool isOutlined;

  const DynamicButton({
    super.key,
    required this.child,
    this.onPressed,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, _) {
        if (isOutlined) {
          return OutlinedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: themeService.primaryColor),
              foregroundColor: themeService.primaryColor,
            ),
            child: child,
          );
        }
        return ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: themeService.primaryColor,
            foregroundColor: Colors.white,
          ),
          child: child,
        );
      },
    );
  }
}