import 'package:flutter/material.dart';
import 'package:vet_biotics_shared/shared.dart';

class SocialLoginButtons extends StatelessWidget {
  final VoidCallback? onGooglePressed;
  final VoidCallback? onFacebookPressed;
  final VoidCallback? onApplePressed;
  final bool isLoading;

  const SocialLoginButtons({
    super.key,
    this.onGooglePressed,
    this.onFacebookPressed,
    this.onApplePressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildDivider(),
        const SizedBox(height: 16),
        if (onGooglePressed != null) ...[
          _buildSocialButton(
            onPressed: isLoading ? null : onGooglePressed,
            icon: Image.asset(
              'assets/images/google_logo.png',
              height: 24,
              width: 24,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.g_mobiledata, size: 24);
              },
            ),
            label: 'Continue with Google',
            backgroundColor: Colors.white,
            textColor: Colors.black87,
          ),
          const SizedBox(height: 12),
        ],
        if (onFacebookPressed != null) ...[
          _buildSocialButton(
            onPressed: isLoading ? null : onFacebookPressed,
            icon: const Icon(Icons.facebook, color: Colors.white, size: 24),
            label: 'Continue with Facebook',
            backgroundColor: const Color(0xFF1877F2),
            textColor: Colors.white,
          ),
          const SizedBox(height: 12),
        ],
        if (onApplePressed != null) ...[
          _buildSocialButton(
            onPressed: isLoading ? null : onApplePressed,
            icon: const Icon(Icons.apple, color: Colors.white, size: 24),
            label: 'Continue with Apple',
            backgroundColor: Colors.black,
            textColor: Colors.white,
          ),
        ],
      ],
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: AppTheme.dividerColor, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('or', style: AppTheme.bodyText2.copyWith(color: AppTheme.textSecondaryColor)),
        ),
        Expanded(child: Divider(color: AppTheme.dividerColor, thickness: 1)),
      ],
    );
  }

  Widget _buildSocialButton({
    required VoidCallback? onPressed,
    required Widget icon,
    required String label,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            side: BorderSide(color: AppTheme.borderColor),
          ),
          shadowColor: Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 12),
            Text(label, style: AppTheme.button.copyWith(color: textColor)),
          ],
        ),
      ),
    );
  }
}
