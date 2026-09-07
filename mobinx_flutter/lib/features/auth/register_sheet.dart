import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/gamer_components.dart';
import '../../core/services/auth_service.dart';

class RegisterSheet extends StatefulWidget {
  final VoidCallback onLoginTap;
  final VoidCallback onRegisterSuccess;

  const RegisterSheet({
    super.key,
    required this.onLoginTap,
    required this.onRegisterSuccess,
  });

  @override
  State<RegisterSheet> createState() => _RegisterSheetState();
}

class _RegisterSheetState extends State<RegisterSheet> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _cpassCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _isLoading = false;
  String? _errorMsg;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _cpassCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final pass = _passCtrl.text;
    final cpass = _cpassCtrl.text;

    setState(() => _errorMsg = null);

    if (name.length < 2) {
      setState(() => _errorMsg = 'Please enter your full in-game name.');
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _errorMsg = 'Please enter a valid email address.');
      return;
    }
    if (phone.length < 11) {
      setState(() => _errorMsg = 'Please enter a valid 11-digit phone number.');
      return;
    }
    if (pass.length < 6) {
      setState(() => _errorMsg = 'Password must be at least 6 characters long.');
      return;
    }
    if (pass != cpass) {
      setState(() => _errorMsg = 'Passwords do not match.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await AuthService.instance.registerWithEmailPassword(
        fullName: name,
        email: email,
        phone: phone,
        password: pass,
      );
      if (mounted) {
        Navigator.pop(context);
        widget.onRegisterSuccess();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMsg = e.toString().replaceAll('Exception:', '').trim();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: AppColors.borderLight, width: 1.5)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 18),

            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.cyan.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cyan.withValues(alpha: 0.35)),
                  ),
                  child: const Icon(Icons.person_add_alt_1_rounded, color: AppColors.cyanLight, size: 20),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create Player Account',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Join Mobin X official esports ecosystem',
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 18),

            if (_errorMsg != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.danger.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: AppColors.danger, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMsg!,
                        style: GoogleFonts.inter(fontSize: 12, color: AppColors.danger, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

            // Player Full Name
            Text('Player Name / In-Game Name *', style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textBody)),
            const SizedBox(height: 5),
            TextField(
              controller: _nameCtrl,
              style: const TextStyle(color: Colors.white, fontSize: 13.5),
              decoration: const InputDecoration(
                hintText: 'e.g. Tanvir FF',
                prefixIcon: Icon(Icons.badge_outlined, color: AppColors.textMuted, size: 18),
              ),
            ),
            const SizedBox(height: 12),

            // Email
            Text('Email Address *', style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textBody)),
            const SizedBox(height: 5),
            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white, fontSize: 13.5),
              decoration: const InputDecoration(
                hintText: 'player@gmail.com',
                prefixIcon: Icon(Icons.email_outlined, color: AppColors.textMuted, size: 18),
              ),
            ),
            const SizedBox(height: 12),

            // Phone
            Text('Phone Number (11 digits) *', style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textBody)),
            const SizedBox(height: 5),
            TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              maxLength: 14,
              buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
              style: const TextStyle(color: Colors.white, fontSize: 13.5),
              decoration: const InputDecoration(
                hintText: '01XXXXXXXXX',
                prefixIcon: Icon(Icons.phone_iphone_rounded, color: AppColors.textMuted, size: 18),
              ),
            ),
            const SizedBox(height: 12),

            // Password
            Text('Password (Min 6 chars) *', style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textBody)),
            const SizedBox(height: 5),
            TextField(
              controller: _passCtrl,
              obscureText: _obscurePass,
              style: const TextStyle(color: Colors.white, fontSize: 13.5),
              decoration: InputDecoration(
                hintText: 'Create strong password',
                prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.textMuted, size: 18),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePass ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.textMuted, size: 18),
                  onPressed: () => setState(() => _obscurePass = !_obscurePass),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Confirm Password
            Text('Confirm Password *', style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textBody)),
            const SizedBox(height: 5),
            TextField(
              controller: _cpassCtrl,
              obscureText: _obscurePass,
              style: const TextStyle(color: Colors.white, fontSize: 13.5),
              decoration: const InputDecoration(
                hintText: 'Re-enter password',
                prefixIcon: Icon(Icons.lock_reset_rounded, color: AppColors.textMuted, size: 18),
              ),
            ),
            const SizedBox(height: 22),

            // Submit Button
            GamerButton(
              label: 'Complete Registration 🚀',
              isLoading: _isLoading,
              onPressed: _handleRegister,
              gradient: AppColors.gamerGlowGradient,
            ),
            const SizedBox(height: 16),

            // Switch to Sign In
            Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  widget.onLoginTap();
                },
                child: RichText(
                  text: TextSpan(
                    text: "Already have an account? ",
                    style: GoogleFonts.inter(fontSize: 12.5, color: AppColors.textMuted),
                    children: [
                      TextSpan(
                        text: 'Sign In',
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.cyanLight,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
