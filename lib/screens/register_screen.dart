import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final AuthController _auth = Get.find<AuthController>();

  String _role = 'Customer';
  bool _hidePassword = true;
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _name.text.trim();
    final email = _email.text.trim();
    final password = _password.text;

    if (name.length < 3) {
      showMsg(
        'Check your name',
        'Your name needs at least 3 characters.',
        error: true,
      );
      return;
    }
    if (!email.contains('@') || !email.contains('.')) {
      showMsg('Check your email', 'Enter a valid email address.', error: true);
      return;
    }
    if (password.length < 6) {
      showMsg('Check your password', 'Use at least 6 characters.', error: true);
      return;
    }

    setState(() => _busy = true);
    await _auth.register(name, email, password, _role);
    if (mounted) setState(() => _busy = false);
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
            'Create your account',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          const Text(
            'It takes less than a minute.',
            style: TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 28),
          AppTextField(
            controller: _name,
            label: 'Full name',
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 14),
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
            helper: 'At least 6 characters',
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
          const SizedBox(height: 20),
          const Text(
            'I want to',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _RoleOption(
                  title: 'Buy',
                  subtitle: 'Shop as a customer',
                  icon: Icons.shopping_bag_outlined,
                  selected: _role == 'Customer',
                  onTap: () => setState(() => _role = 'Customer'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _RoleOption(
                  title: 'Sell',
                  subtitle: 'Sell as a vendor',
                  icon: Icons.storefront_outlined,
                  selected: _role == 'Vendor',
                  onTap: () => setState(() => _role = 'Vendor'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Create account',
            loading: _busy,
            onPressed: _submit,
          ),
          const SizedBox(height: 20),
          Center(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text(
                  'Already have an account? ',
                  style: TextStyle(color: AppColors.muted),
                ),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: const Text(
                    'Log in',
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

class _RoleOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _RoleOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.teal.withValues(alpha: 0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.teal : Colors.transparent,
            width: 1.6,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: selected ? AppColors.teal : AppColors.muted),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(color: AppColors.muted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
