import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vet_biotics_shared/shared.dart';

import '../providers/auth_provider.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isResending = false;
  bool _isChecking = false;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.backgroundColor,
    appBar: AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: AppTheme.textPrimaryColor),
        onPressed: () => Navigator.of(context).pop(),
      ),
    ),
    body: SafeArea(
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          var user = authProvider.currentUser;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 48),
                _buildHeader(),
                const SizedBox(height: 32),
                _buildEmailIcon(),
                const SizedBox(height: 24),
                _buildMessage(user?.email ?? 'your email'),
                const SizedBox(height: 32),
                _buildActionButtons(),
                const SizedBox(height: 24),
                _buildCheckVerificationButton(),
                if (authProvider.errorMessage != null) ...[
                  const SizedBox(height: 16),
                  _buildErrorMessage(authProvider.errorMessage!),
                ],
              ],
            ),
          );
        },
      ),
    ),
  );

  Widget _buildHeader() => Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Text('Verify Your Email', style: AppTheme.headline1, textAlign: TextAlign.center),
      const SizedBox(height: 8),
      Text(
        'We\'ve sent a verification link to your email address',
        style: AppTheme.bodyText2.copyWith(color: AppTheme.textSecondaryColor),
        textAlign: TextAlign.center,
      ),
    ],
  );

  Widget _buildEmailIcon() => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.1), shape: BoxShape.circle),
    child: Icon(Icons.email, color: AppTheme.primaryColor, size: 48),
  );

  Widget _buildMessage(String email) => Column(
    children: [
      Text(
        'Please check your email and click on the verification link to activate your account.',
        style: AppTheme.bodyText1,
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.email_outlined, color: AppTheme.textSecondaryColor, size: 20),
            const SizedBox(width: 8),
            Text(email, style: AppTheme.bodyText2.copyWith(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    ],
  );

  Widget _buildActionButtons() => Column(
    children: [
      SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: _isResending ? null : _handleResendVerification,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.borderRadius)),
            elevation: 2,
            shadowColor: AppTheme.primaryColor.withOpacity(0.3),
          ),
          child: _isResending
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text('Resend Verification Email', style: AppTheme.button.copyWith(color: Colors.white)),
        ),
      ),
      const SizedBox(height: 12),
      TextButton(
        onPressed: () {
          // Navigate back to login
          Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
        },
        child: Text(
          'Back to Sign In',
          style: AppTheme.bodyText2.copyWith(color: AppTheme.primaryColor, fontWeight: FontWeight.w500),
        ),
      ),
    ],
  );

  Widget _buildCheckVerificationButton() => Column(
    children: [
      Text('Already verified your email?', style: AppTheme.bodyText2.copyWith(color: AppTheme.textSecondaryColor)),
      const SizedBox(height: 8),
      SizedBox(
        width: double.infinity,
        height: 48,
        child: OutlinedButton(
          onPressed: _isChecking ? null : _handleCheckVerification,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: AppTheme.primaryColor),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.borderRadius)),
          ),
          child: _isChecking
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                  ),
                )
              : Text('Check Verification Status', style: AppTheme.button.copyWith(color: AppTheme.primaryColor)),
        ),
      ),
    ],
  );

  Widget _buildErrorMessage(String message) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppTheme.errorColor.withOpacity(0.1),
      borderRadius: BorderRadius.circular(AppTheme.borderRadius),
      border: Border.all(color: AppTheme.errorColor.withOpacity(0.3)),
    ),
    child: Row(
      children: [
        Icon(Icons.error_outline, color: AppTheme.errorColor, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(message, style: AppTheme.bodyText2.copyWith(color: AppTheme.errorColor)),
        ),
      ],
    ),
  );

  void _handleResendVerification() async {
    setState(() {
      _isResending = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      await authProvider.sendEmailVerification();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verification email sent successfully!', style: TextStyle(color: AppTheme.surfaceColor)),
            backgroundColor: AppTheme.successColor,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Error is handled by the provider
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  void _handleCheckVerification() async {
    setState(() {
      _isChecking = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      await authProvider.reloadUser();

      final user = authProvider.currentUser;
      if (user != null && user.emailVerified) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Email verified successfully!', style: TextStyle(color: AppTheme.surfaceColor)),
              backgroundColor: AppTheme.successColor,
              duration: const Duration(seconds: 2),
            ),
          );

          // Navigate to main app
          Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Email not yet verified. Please check your email and click the verification link.',
                style: TextStyle(color: AppTheme.surfaceColor),
              ),
              backgroundColor: AppTheme.warningColor,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to check verification status. Please try again.',
              style: TextStyle(color: AppTheme.surfaceColor),
            ),
            backgroundColor: AppTheme.errorColor,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
      }
    }
  }
}
