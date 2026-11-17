import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final AuthController _auth = Get.find<AuthController>();
  bool _hidePassword = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    final email = _email.text.trim();
    final password = _password.text;
    if (email.isEmpty || password.isEmpty) {
      showMsg('Missing details', 'Enter your email and password.', error: true);
      return;
    }
    _auth.login(email, password);
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BrandLogo(),
          const SizedBox(height: 32),
          const Text(
            'Welcome back',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          const Text(
            'Log in to keep shopping or selling.',
            style: TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 28),
          AppTextField(
            controller: _email,
            label: 'Email',
            icon: Icons.mail_outline,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 14),
          AppTextField(
            controller: _password,
            label: 'Password',
            icon: Icons.lock_outline,
            obscure: _hidePassword,
            onSubmitted: (_) => _submit(),
            suffix: IconButton(
              tooltip: _hidePassword ? 'Show password' : 'Hide password',
              icon: Icon(
                _hidePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppColors.muted,
              ),
              onPressed: () => setState(() => _hidePassword = !_hidePassword),
            ),
          ),
          const SizedBox(height: 24),
          Obx(
            () => PrimaryButton(
              label: 'Log in',
              loading: _auth.isLoading.value,
              onPressed: _submit,
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text(
                  'New here? ',
                  style: TextStyle(color: AppColors.muted),
                ),
                GestureDetector(
                  onTap: () => Get.to(() => RegisterScreen()),
                  child: const Text(
                    'Create an account',
                    style: TextStyle(
                      color: AppColors.teal,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
