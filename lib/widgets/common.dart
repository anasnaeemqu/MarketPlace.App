import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';

// ---------- small helpers ----------

String _group(String digits) {
  final b = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) b.write(',');
    b.write(digits[i]);
  }
  return b.toString();
}

/// 999.99 -> $999.99   1299 -> $1,299
String money(num v) {
  final d = v.toDouble();
  final whole = d == d.roundToDouble();
  final fixed = d.toStringAsFixed(whole ? 0 : 2);
  final parts = fixed.split('.');
  final grouped = _group(parts[0]);
  return parts.length > 1 ? '\$$grouped.${parts[1]}' : '\$$grouped';
}

/// 1299.0 -> "1299"   12.5 -> "12.5"  (for filling text fields)
String plainNumber(num v) {
  final d = v.toDouble();
  return d == d.roundToDouble() ? d.toInt().toString() : d.toString();
}

/// One consistent look for every message.
void showMsg(String title, String message, {bool error = false}) {
  Get.snackbar(
    title,
    message,
    snackPosition: SnackPosition.BOTTOM,
    margin: const EdgeInsets.all(16),
    maxWidth: 420,
    borderRadius: 14,
    backgroundColor: error ? AppColors.danger : AppColors.teal,
    colorText: Colors.white,
    duration: const Duration(seconds: 3),
  );
}

// ---------- layout ----------

/// Keeps content from stretching edge to edge on a laptop.
class PageWidth extends StatelessWidget {
  final double maxWidth;
  final Widget child;
  const PageWidth({super.key, this.maxWidth = 560, required this.child});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

PreferredSizeWidget subAppBar(String title, {List<Widget>? actions}) {
  return AppBar(
    title: Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
    ),
    backgroundColor: AppColors.mist,
    foregroundColor: AppColors.ink,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: false,
    actions: actions,
  );
}

class BrandLogo extends StatelessWidget {
  final bool onDark;
  const BrandLogo({super.key, this.onDark = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: onDark ? Colors.white : AppColors.teal,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.storefront_outlined,
            size: 20,
            color: onDark ? AppColors.teal : Colors.white,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'Marketplace',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: onDark ? Colors.white : AppColors.teal,
          ),
        ),
      ],
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: const BoxDecoration(
                color: AppColors.tint,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 38, color: AppColors.teal),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted, height: 1.4),
            ),
            if (action != null) ...[const SizedBox(height: 20), action!],
          ],
        ),
      ),
    );
  }
}

// ---------- inputs and buttons ----------

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscure;
  final int maxLines;
  final Widget? suffix;
  final String? helper;
  final FocusNode? focusNode;
  final ValueChanged<String>? onSubmitted;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.obscure = false,
    this.maxLines = 1,
    this.suffix,
    this.helper,
    this.focusNode,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: width),
    );

    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      obscureText: obscure,
      maxLines: obscure ? 1 : maxLines,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        labelText: label,
        helperText: helper,
        prefixIcon: Icon(icon, color: AppColors.teal),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white,
        border: border(Colors.transparent, 0),
        enabledBorder: border(Colors.transparent, 0),
        focusedBorder: border(AppColors.teal, 1.6),
      ),
    );
  }
}

/// The orange button. Orange is used for actions only.
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.orange,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.orange.withValues(alpha: 0.5),
          disabledForegroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        child: loading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(label),
                ],
              ),
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  final String status;
  const StatusChip({super.key, required this.status});

  Color get _color {
    switch (status) {
      case 'Shipped':
        return AppColors.teal;
      case 'Delivered':
        return AppColors.success;
      case 'Cancelled':
        return AppColors.danger;
      default:
        return const Color(0xFFB26A00);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: _color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

// ---------- product picture ----------

/// Shows the vendor's photo, or a tidy icon if there is no link
/// (or the link cannot be loaded). Give it a bounded size.
class ProductImage extends StatelessWidget {
  final String? url;
  final double radius;
  final double iconSize;

  const ProductImage({
    super.key,
    this.url,
    this.radius = 16,
    this.iconSize = 48,
  });

  Widget _placeholder() => Center(
    child: Icon(
      Icons.inventory_2_outlined,
      size: iconSize,
      color: AppColors.teal,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final link = url?.trim() ?? '';
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        color: AppColors.tint,
        width: double.infinity,
        height: double.infinity,
        child: link.isEmpty
            ? _placeholder()
            : Image.network(
                link,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholder(),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const Center(
                    child: SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(strokeWidth: 2.4),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

// ---------- login / register frame ----------

/// Wide screens: teal brand panel on the left, form on the right.
/// Narrow screens: just the centred form.
class AuthShell extends StatelessWidget {
  final Widget child;
  const AuthShell({super.key, required this.child});

  Widget _circle(double size, Color color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );

  Widget _brandPanel() {
    return Container(
      color: AppColors.teal,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(
            right: -70,
            top: -70,
            child: _circle(280, AppColors.tealMid),
          ),
          Positioned(
            left: -50,
            bottom: -50,
            child: _circle(200, AppColors.tealLight),
          ),
          Padding(
            padding: const EdgeInsets.all(56),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                BrandLogo(onDark: true),
                SizedBox(height: 40),
                Text(
                  'Buy and sell,\nsimply.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 44,
                    fontWeight: FontWeight.w700,
                    height: 1.15,
                  ),
                ),
                SizedBox(height: 14),
                Text(
                  'Discover products from vendors,\nor start selling your own.',
                  style: TextStyle(
                    color: AppColors.heroText,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width >= 860;
    final form = Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: child,
        ),
      ),
    );

    return Scaffold(
      body: wide
          ? Row(
              children: [
                Expanded(child: _brandPanel()),
                Expanded(
                  child: Container(color: AppColors.mist, child: form),
                ),
              ],
            )
          : Container(
              color: AppColors.mist,
              child: SafeArea(child: form),
            ),
    );
  }
}
