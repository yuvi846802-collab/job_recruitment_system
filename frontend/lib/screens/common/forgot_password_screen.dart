import 'package:flutter/material.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/constants/app_colors.dart';
import '../../services/api_service.dart';
import '../../widgets/common/app_snackbar.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/app_back_button.dart';


class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _newPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _codeSent = false;

  void _handleSendCode() async {
    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      AppSnackbar.showError(context, 'Please enter a valid email address');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final res = await ApiService.post(ApiEndpoints.forgotPassword, {
        'email': _emailController.text.trim(),
      });
      setState(() {
        _isLoading = false;
        _codeSent = true;
      });
      if (!mounted) return;
      AppSnackbar.showSuccess(context, res['message'] ?? 'Reset instructions sent.');
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      AppSnackbar.showError(context, e.toString().replaceAll('Exception: ', ''));
    }
  }

  void _handleResetPassword() async {
    if (_newPasswordController.text.length < 6) {
      AppSnackbar.showError(context, 'New password must be at least 6 characters');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final res = await ApiService.post(ApiEndpoints.resetPassword, {
        'email': _emailController.text.trim(),
        'new_password': _newPasswordController.text.trim(),
      });
      setState(() => _isLoading = false);
      if (!mounted) return;
      AppSnackbar.showSuccess(context, res['message'] ?? 'Password reset successfully!');
      Navigator.pop(context);
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      AppSnackbar.showError(context, e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Reset Password'),
      ),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.lock_reset_rounded, size: 48, color: AppColors.accent),
                      const SizedBox(height: 16),
                      const Text(
                        'Forgot Your Password?',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Enter your account email address below to reset your password.',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 24),
                      CustomTextField(
                        controller: _emailController,
                        label: 'Account Email',
                        hint: 'Enter your email',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      if (_codeSent) ...[
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _newPasswordController,
                          label: 'New Password',
                          hint: 'Enter new password',
                          prefixIcon: Icons.lock_outline,
                          obscureText: true,
                        ),
                      ],
                      const SizedBox(height: 24),
                      CustomButton(
                        text: _codeSent ? 'Update Password' : 'Send Reset Link',
                        isLoading: _isLoading,
                        onPressed: _codeSent ? _handleResetPassword : _handleSendCode,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
