import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class AppBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? color;
  final Color? backgroundColor;

  const AppBackButton({
    super.key,
    this.onPressed,
    this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        color: backgroundColor ?? AppColors.primary.withValues(alpha: 0.08),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed ??
              () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  // Return to home or splash screen if on root page
                  Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                }
              },
          child: Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16,
              color: color ?? AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
