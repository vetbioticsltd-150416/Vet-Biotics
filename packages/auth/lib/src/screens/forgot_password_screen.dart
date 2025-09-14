import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vet_biotics_shared/shared.dart';

import '../providers/auth_provider.dart';
import '../utils/auth_validators.dart';
import '../widgets/auth_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 48),
                  _buildHeader(),
                  const SizedBox(height: 32),
                  if (!_emailSent) ...[_buildForm(authProvider)] else ...[_buildSuccessMessage()],
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
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_emailSent ? 'Check Your Email' : 'Reset Password', style: AppTheme.headline1),
        const SizedBox(height: 8),
        Text(
          _emailSent
              ? 'We\'ve sent password reset instructions to your email'
              : 'Enter your email address and we\'ll send you a link to reset your password',
          style: AppTheme.bodyText2.copyWith(color: AppTheme.textSecondaryColor),
        ),
      ],
    );
  }

  Widget _buildForm(AuthProvider authProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AuthTextField(
          controller: _emailController,
          labelText: 'Email',
          hintText: 'Enter your email address',
          keyboardType: TextInputType.emailAddress,
          validator: AuthValidators.validateEmail,
          prefixIcon: const Icon(Icons.email_outlined),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: authProvider.status == AuthStatus.loading ? null : _handleResetPassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.borderRadius)),
              elevation: 2,
              shadowColor: AppTheme.primaryColor.withOpacity(0.3),
            ),
            child: authProvider.status == AuthStatus.loading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text('Send Reset Link', style: AppTheme.button.copyWith(color: Colors.white)),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessMessage() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: AppTheme.successColor.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(Icons.check_circle, color: AppTheme.successColor, size: 48),
        ),
        const SizedBox(height: 24),
        Text(
          'Password reset email sent!',
          style: AppTheme.headline2.copyWith(color: AppTheme.successColor),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'Please check your email and follow the instructions to reset your password.',
          style: AppTheme.bodyText2.copyWith(color: AppTheme.textSecondaryColor),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppTheme.primaryColor),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.borderRadius)),
            ),
            child: Text('Back to Sign In', style: AppTheme.button.copyWith(color: AppTheme.primaryColor)),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: _handleResendEmail,
          child: Text(
            'Didn\'t receive the email? Send again',
            style: AppTheme.bodyText2.copyWith(color: AppTheme.primaryColor, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage(String message) {
    return Container(
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
  }

  void _handleResetPassword() {
    if (_formKey.currentState?.validate() ?? false) {
      final authProvider = context.read<AuthProvider>();
      authProvider.sendPasswordResetEmail(_emailController.text.trim()).then((_) {
        if (authProvider.errorMessage == null) {
          setState(() {
            _emailSent = true;
          });
        }
      });
    }
  }

  void _handleResendEmail() {
    final authProvider = context.read<AuthProvider>();
    authProvider.sendPasswordResetEmail(_emailController.text.trim());
  }
}
