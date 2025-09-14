import 'package:flutter/material.dart';
import 'package:vet_biotics_shared/shared.dart';
import 'auth_text_field.dart';
import '../utils/auth_validators.dart';

class AuthForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController? confirmPasswordController;
  final TextEditingController? nameController;
  final TextEditingController? phoneController;
  final bool isLogin;
  final bool isLoading;
  final VoidCallback onSubmit;

  const AuthForm({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    this.confirmPasswordController,
    this.nameController,
    this.phoneController,
    this.isLogin = true,
    this.isLoading = false,
    required this.onSubmit,
  });

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!widget.isLogin && widget.nameController != null) ...[
            AuthTextField(
              controller: widget.nameController!,
              labelText: 'Full Name',
              hintText: 'Enter your full name',
              keyboardType: TextInputType.name,
              validator: AuthValidators.validateName,
              prefixIcon: const Icon(Icons.person_outline),
            ),
            const SizedBox(height: 16),
          ],
          AuthTextField(
            controller: widget.emailController,
            labelText: 'Email',
            hintText: 'Enter your email address',
            keyboardType: TextInputType.emailAddress,
            validator: AuthValidators.validateEmail,
            prefixIcon: const Icon(Icons.email_outlined),
          ),
          const SizedBox(height: 16),
          if (!widget.isLogin && widget.phoneController != null) ...[
            AuthTextField(
              controller: widget.phoneController!,
              labelText: 'Phone Number',
              hintText: 'Enter your phone number',
              keyboardType: TextInputType.phone,
              validator: AuthValidators.validatePhoneNumber,
              prefixIcon: const Icon(Icons.phone_outlined),
            ),
            const SizedBox(height: 16),
          ],
          AuthTextField(
            controller: widget.passwordController,
            labelText: 'Password',
            hintText: 'Enter your password',
            obscureText: true,
            validator: AuthValidators.validatePassword,
            prefixIcon: const Icon(Icons.lock_outline),
          ),
          const SizedBox(height: 16),
          if (!widget.isLogin && widget.confirmPasswordController != null) ...[
            AuthTextField(
              controller: widget.confirmPasswordController!,
              labelText: 'Confirm Password',
              hintText: 'Re-enter your password',
              obscureText: true,
              validator: (value) => AuthValidators.validateConfirmPassword(value, widget.passwordController.text),
              prefixIcon: const Icon(Icons.lock_outline),
            ),
            const SizedBox(height: 24),
          ],
          if (widget.isLogin) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: widget.isLoading
                    ? null
                    : () {
                        // Navigate to forgot password screen
                        Navigator.of(context).pushNamed('/forgot-password');
                      },
                child: Text(
                  'Forgot Password?',
                  style: AppTheme.bodyText2.copyWith(color: AppTheme.primaryColor, fontWeight: FontWeight.w500),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: widget.isLoading ? null : widget.onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.borderRadius)),
                elevation: 2,
                shadowColor: AppTheme.primaryColor.withOpacity(0.3),
              ),
              child: widget.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(widget.isLogin ? 'Sign In' : 'Sign Up', style: AppTheme.button.copyWith(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
