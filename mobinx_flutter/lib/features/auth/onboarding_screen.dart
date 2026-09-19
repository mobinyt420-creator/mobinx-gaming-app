import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/auth_service.dart';
import '../home/home_screen.dart';
import 'login_sheet.dart';
import 'register_sheet.dart';
import 'google_profile_sheet.dart';

/// Official 4-Color Google Vector Mark
class GoogleGLogo extends StatelessWidget {
  final double size;
  const GoogleGLogo({super.key, this.size = 22});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _GoogleGLogoPainter(),
    );
  }
}

class _GoogleGLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double s = size.width / 48.0;
    final paint = Paint()..style = PaintingStyle.fill;

    // 1. Blue (#4285F4)
    paint.color = const Color(0xFF4285F4);
    final bluePath = Path()
      ..moveTo(46.98 * s, 24.55 * s)
      ..cubicTo(46.98 * s, 22.89 * s, 46.83 * s, 21.28 * s, 46.56 * s, 19.73 * s)
      ..lineTo(24.0 * s, 19.73 * s)
      ..lineTo(24.0 * s, 28.77 * s)
      ..lineTo(36.94 * s, 28.77 * s)
      ..cubicTo(36.38 * s, 31.78 * s, 34.69 * s, 34.33 * s, 32.14 * s, 36.03 * s)
      ..lineTo(32.14 * s, 42.12 * s)
      ..lineTo(39.88 * s, 42.12 * s)
      ..cubicTo(44.41 * s, 37.95 * s, 46.98 * s, 31.83 * s, 46.98 * s, 24.55 * s)
      ..close();
    canvas.drawPath(bluePath, paint);

    // 2. Green (#34A853)
    paint.color = const Color(0xFF34A853);
    final greenPath = Path()
      ..moveTo(24.0 * s, 48.0 * s)
      ..cubicTo(30.48 * s, 48.0 * s, 35.91 * s, 45.85 * s, 39.88 * s, 42.12 * s)
      ..lineTo(32.14 * s, 36.03 * s)
      ..cubicTo(29.99 * s, 37.47 * s, 27.24 * s, 38.33 * s, 24.0 * s, 38.33 * s)
      ..cubicTo(17.76 * s, 38.33 * s, 12.48 * s, 34.11 * s, 10.59 * s, 28.43 * s)
      ..lineTo(2.61 * s, 28.43 * s)
      ..lineTo(2.61 * s, 34.62 * s)
      ..cubicTo(6.58 * s, 42.5 * s, 14.73 * s, 48.0 * s, 24.0 * s, 48.0 * s)
      ..close();
    canvas.drawPath(greenPath, paint);

    // 3. Yellow (#FBBC05)
    paint.color = const Color(0xFFFBBC05);
    final yellowPath = Path()
      ..moveTo(10.59 * s, 28.43 * s)
      ..cubicTo(10.11 * s, 27.0 * s, 9.84 * s, 25.48 * s, 9.84 * s, 23.9 * s)
      ..cubicTo(9.84 * s, 22.32 * s, 10.11 * s, 20.8 * s, 10.59 * s, 19.37 * s)
      ..lineTo(10.59 * s, 13.18 * s)
      ..lineTo(2.61 * s, 13.18 * s)
      ..cubicTo(0.95 * s, 16.48 * s, 0.0 * s, 20.09 * s, 0.0 * s, 23.9 * s)
      ..cubicTo(0.0 * s, 27.71 * s, 0.95 * s, 31.32 * s, 2.61 * s, 34.62 * s)
      ..lineTo(10.59 * s, 28.43 * s)
      ..close();
    canvas.drawPath(yellowPath, paint);

    // 4. Red (#EA4335)
    paint.color = const Color(0xFFEA4335);
    final redPath = Path()
      ..moveTo(24.0 * s, 9.47 * s)
      ..cubicTo(27.52 * s, 9.47 * s, 30.69 * s, 10.68 * s, 33.17 * s, 13.06 * s)
      ..lineTo(40.06 * s, 6.17 * s)
      ..cubicTo(35.9 * s, 2.3 * s, 30.47 * s, 0.0 * s, 24.0 * s, 0.0 * s)
      ..cubicTo(14.73 * s, 0.0 * s, 6.58 * s, 5.5 * s, 2.61 * s, 13.18 * s)
      ..lineTo(10.59 * s, 19.37 * s)
      ..cubicTo(12.48 * s, 13.69 * s, 17.76 * s, 9.47 * s, 24.0 * s, 9.47 * s)
      ..close();
    canvas.drawPath(redPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Modernized Player Authentication & Onboarding Screen (Big-Brand Tier)
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  bool _isGoogleLoading = false;

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 250),
      ),
    );
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isGoogleLoading = true);
    try {
      final googleUser = await AuthService.instance.pickGoogleAccount();
      if (!mounted) return;

      if (googleUser != null) {
        // 1. Check if user already exists in Cloud Firestore
        final existing = await AuthService.instance.findCloudUser(googleUser.email);
        if (existing != null && existing.phone.isNotEmpty) {
          // Returning user: Instant direct login!
          await AuthService.instance.completeGoogleSignIn(
            googleUser: googleUser,
            customName: existing.fullName.isNotEmpty ? existing.fullName : (googleUser.displayName ?? ''),
            phone: existing.phone,
            ffUid: existing.ffUid,
          );
          if (mounted) _navigateToHome();
          return;
        }

        // 2. First-time user: Open Complete Profile Sheet
        if (mounted) {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => GoogleProfileSheet(
              googleUser: googleUser,
              onLoginSuccess: _navigateToHome,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google Sign-In notice: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.textMain,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  void _openLoginSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LoginSheet(
        onRegisterTap: _openRegisterSheet,
        onLoginSuccess: _navigateToHome,
      ),
    );
  }

  void _openRegisterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RegisterSheet(
        onLoginTap: _openLoginSheet,
        onRegisterSuccess: _navigateToHome,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // Background ambient soft blue glow (top centered)
          Positioned(
            top: -100,
            left: MediaQuery.of(context).size.width / 2 - 160,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF0284C7).withValues(alpha: 0.14),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: ValueListenableBuilder<Map<String, dynamic>>(
              valueListenable: AuthService.instance.authSettingsNotifier,
              builder: (context, settings, _) {
                final bool isGoogleEnabled = settings['googleLoginEnabled'] != false;
                final bool isManualLoginEnabled = settings['manualLoginEnabled'] != false;
                final bool isManualRegEnabled = settings['manualRegistrationEnabled'] != false;
                final bool hasAnyManualOption = isManualLoginEnabled || isManualRegEnabled;

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 36),

                      // Brand Emblem (Hero 'M' with refined lighting & depth)
                      Center(
                        child: Container(
                          width: 82,
                          height: 82,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0284C7), Color(0xFF1D4ED8)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0284C7).withValues(alpha: 0.38),
                                blurRadius: 28,
                                offset: const Offset(0, 10),
                              ),
                              BoxShadow(
                                color: const Color(0xFF2563EB).withValues(alpha: 0.15),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                              width: 1.5,
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'M',
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -1.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // App Name
                      Text(
                        AppConstants.appName,
                        style: GoogleFonts.outfit(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF0F172A),
                          letterSpacing: -0.6,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Sub-Badge Caption
                      Text(
                        'CREATE PLAYER ACCOUNT',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0284C7),
                          letterSpacing: 1.6,
                        ),
                      ),
                      const SizedBox(height: 38),

                      // 1. Star CTA: Official "Continue with Google"
                      if (isGoogleEnabled) ...[
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _isGoogleLoading ? null : _handleGoogleSignIn,
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              width: double.infinity,
                              height: 56,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                  width: 1.4,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: _isGoogleLoading
                                  ? const Center(
                                      child: SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
                                        ),
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 34,
                                          height: 34,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF8FAFC),
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(
                                              color: const Color(0xFFF1F5F9),
                                              width: 1,
                                            ),
                                          ),
                                          child: const Center(
                                            child: GoogleGLogo(size: 20),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Continue with Google',
                                          style: GoogleFonts.outfit(
                                            fontSize: 15.5,
                                            fontWeight: FontWeight.w800,
                                            color: const Color(0xFF0F172A),
                                            letterSpacing: -0.2,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      ],

                      // 2. Manual Options (Controlled live by Admin Panel switches)
                      if (hasAnyManualOption) ...[
                        const SizedBox(height: 20),

                        // Sleek "OR" Divider
                        Row(
                          children: [
                            const Expanded(child: Divider(color: Color(0xFFE2E8F0), thickness: 1)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              child: Text(
                                'OR',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF94A3B8),
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                            const Expanded(child: Divider(color: Color(0xFFE2E8F0), thickness: 1)),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Manual Registration Button
                        if (isManualRegEnabled) ...[
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _openRegisterSheet,
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                width: double.infinity,
                                height: 54,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF2563EB).withValues(alpha: 0.32),
                                      blurRadius: 16,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.person_add_rounded, color: Colors.white, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Create New Player Account',
                                      style: GoogleFonts.outfit(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        letterSpacing: -0.1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Manual Login Option
                        if (isManualLoginEnabled) ...[
                          InkWell(
                            onTap: _openLoginSheet,
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    isManualRegEnabled ? 'Already have an account? ' : 'Sign in to existing account: ',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                  Text(
                                    'Log In',
                                    style: GoogleFonts.outfit(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w900,
                                      color: const Color(0xFF2563EB),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],

                      const SizedBox(height: 36),

                      // Legal Terms & Privacy Footer
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'By continuing, you agree to our Terms & Privacy Policy',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF94A3B8),
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
