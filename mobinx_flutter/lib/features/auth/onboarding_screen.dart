import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/storage_service.dart';
import '../home/home_screen.dart';
import 'login_sheet.dart';
import 'register_sheet.dart';
import 'google_profile_sheet.dart';

/// Official 4-Color Google Vector Logo (Ultra-Sharp Vector Drawing)
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
      ..cubicTo(30.48 * s, 48.0 * s, 35.91 * s, 45.86 * s, 39.88 * s, 42.12 * s)
      ..lineTo(32.14 * s, 36.03 * s)
      ..cubicTo(30.01 * s, 37.47 * s, 27.24 * s, 38.37 * s, 24.0 * s, 38.37 * s)
      ..cubicTo(17.75 * s, 38.37 * s, 12.44 * s, 34.13 * s, 10.53 * s, 28.45 * s)
      ..lineTo(2.55 * s, 28.45 * s)
      ..lineTo(2.55 * s, 34.64 * s)
      ..cubicTo(6.49 * s, 42.47 * s, 14.61 * s, 48.0 * s, 24.0 * s, 48.0 * s)
      ..close();
    canvas.drawPath(greenPath, paint);

    // 3. Yellow (#FBBC05)
    paint.color = const Color(0xFFFBBC05);
    final yellowPath = Path()
      ..moveTo(10.53 * s, 28.45 * s)
      ..cubicTo(10.05 * s, 27.01 * s, 9.77 * s, 25.48 * s, 9.77 * s, 23.9 * s)
      ..cubicTo(9.77 * s, 22.32 * s, 10.05 * s, 20.79 * s, 10.53 * s, 19.35 * s)
      ..lineTo(10.53 * s, 13.16 * s)
      ..lineTo(2.55 * s, 13.16 * s)
      ..cubicTo(0.92 * s, 16.41 * s, 0.0 * s, 20.06 * s, 0.0 * s, 23.9 * s)
      ..cubicTo(0.0 * s, 27.74 * s, 0.92 * s, 31.39 * s, 2.55 * s, 34.64 * s)
      ..lineTo(10.53 * s, 28.45 * s)
      ..close();
    canvas.drawPath(yellowPath, paint);

    // 4. Red (#EA4335)
    paint.color = const Color(0xFFEA4335);
    final redPath = Path()
      ..moveTo(24.0 * s, 9.43 * s)
      ..cubicTo(27.53 * s, 9.43 * s, 30.69 * s, 10.65 * s, 33.19 * s, 13.03 * s)
      ..lineTo(40.05 * s, 6.17 * s)
      ..cubicTo(35.9 * s, 2.31 * s, 30.47 * s, 0.0 * s, 24.0 * s, 0.0 * s)
      ..cubicTo(14.61 * s, 0.0 * s, 6.49 * s, 5.53 * s, 2.55 * s, 13.16 * s)
      ..lineTo(10.53 * s, 19.35 * s)
      ..cubicTo(12.44 * s, 13.67 * s, 17.75 * s, 9.43 * s, 24.0 * s, 9.43 * s)
      ..close();
    canvas.drawPath(redPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 2-Step Official OBIN Player Onboarding & Authentication Screen
/// 100% Native Vector UI - Crystal Clear 4K Quality, Zero Blurriness
/// Step 0: Welcome Screen
/// Step 1: Login & Auth Selection Screen
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with SingleTickerProviderStateMixin {
  int _currentStep = 0; // 0 = Welcome Step, 1 = Auth Selection Step
  bool _isGoogleLoading = false;

  void _navigateToHome() {
    try {
      StorageService.setOnboardingDone(true);
    } catch (_) {}
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
        final existing = await AuthService.instance.findCloudUser(googleUser.email);
        if (existing != null && existing.phone.isNotEmpty) {
          await AuthService.instance.completeGoogleSignIn(
            googleUser: googleUser,
            customName: existing.fullName.isNotEmpty ? existing.fullName : (googleUser.displayName ?? ''),
            phone: existing.phone,
            ffUid: existing.ffUid,
          );
          if (mounted) _navigateToHome();
          return;
        }

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
      } else {
        if (mounted) _openLoginSheet();
      }
    } catch (e) {
      if (mounted) _openLoginSheet();
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

  void _openLegalUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Color(0xFF030712),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF030712),
        body: Stack(
          children: [
            // 1. Full-bleed Edge-to-Edge High-Res Gaming Background (No black top bar)
            Positioned.fill(
              child: Image.asset(
                'assets/images/auth_bg.jpg',
                fit: BoxFit.cover,
              ),
            ),

            // Subtle dark gradient overlay for optimal readability & contrast
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF030712).withValues(alpha: 0.5),
                      Colors.transparent,
                      const Color(0xFF030712).withValues(alpha: 0.5),
                      const Color(0xFF030712).withValues(alpha: 0.5),
                    ],
                    stops: const [0.0, 0.25, 0.75, 1.0],
                  ),
                ),
              ),
            ),

            // 2. Safe Edge-to-Edge Responsive Content
            SafeArea(
              top: true,
              bottom: true,
              child: GestureDetector(
                onHorizontalDragEnd: (details) {
                  if (details.primaryVelocity != null) {
                    if (details.primaryVelocity! < -200 && _currentStep == 0) {
                      setState(() => _currentStep = 1);
                    } else if (details.primaryVelocity! > 200 && _currentStep == 1) {
                      setState(() => _currentStep = 0);
                    }
                  }
                },
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 320),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.06, 0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: _currentStep == 0
                      ? _buildWelcomeStep(context)
                      : _buildAuthSelectionStep(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Screen 1: Welcome Step (100% Native Vector Widgets - Zero Blurriness)
  Widget _buildWelcomeStep(BuildContext context) {
    return LayoutBuilder(
      key: const ValueKey('welcome_step_native'),
      builder: (context, constraints) {
        final double maxW = constraints.maxWidth;
        final double contentWidth = maxW > 440 ? 400 : (maxW - 36);

        return Center(
          child: SizedBox(
            width: contentWidth,
            child: Column(
              children: [
                const SizedBox(height: 6),

                // Top Glowing App Icon
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00E5FF).withValues(alpha: 0.5),
                        blurRadius: 18,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/images/obin_icon_512.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Welcome to
                Text(
                  'Welcome to',
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF94A3B8),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),

                // — OBIN —
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFF00E5FF), Color(0xFF38BDF8), Color(0xFF00E5FF)],
                  ).createShader(bounds),
                  child: Text(
                    '— OBIN —',
                    style: GoogleFonts.outfit(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 2.5,
                    ),
                  ),
                ),
                const SizedBox(height: 2),

                // The Ultimate Super App
                Text(
                  'The Ultimate Super App',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 12),

                // Center 3D Gaming Stage Illustration (Ultra-High-Res Asset)
                Flexible(
                  flex: 3,
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 200, maxWidth: 280),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xFF00E5FF).withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00E5FF).withValues(alpha: 0.5),
                          blurRadius: 22,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: Image.asset(
                        'assets/images/welcome_stage.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // 3 Service Feature Cards (100% Crisp Native Vector Layout)
                _buildFeatureCard(
                  iconBg: const Color(0xFF0284C7).withValues(alpha: 0.5),
                  iconBorder: const Color(0xFF38BDF8).withValues(alpha: 0.5),
                  icon: const Icon(Icons.diamond_rounded, color: Color(0xFF00E5FF), size: 22),
                  title: 'Top Up & Diamonds',
                  subtitle: 'Fast & secure instant top up',
                ),
                const SizedBox(height: 10),

                _buildFeatureCard(
                  iconBg: const Color(0xFFD97706).withValues(alpha: 0.5),
                  iconBorder: const Color(0xFFF59E0B).withValues(alpha: 0.5),
                  icon: const Icon(Icons.emoji_events_rounded, color: Color(0xFFFBBF24), size: 22),
                  title: 'Tournaments',
                  subtitle: 'Join daily exciting battles',
                ),
                const SizedBox(height: 10),

                _buildFeatureCard(
                  iconBg: const Color(0xFF9333EA).withValues(alpha: 0.5),
                  iconBorder: const Color(0xFFA855F7).withValues(alpha: 0.5),
                  icon: const Icon(Icons.card_giftcard_rounded, color: Color(0xFFE879F9), size: 22),
                  title: 'Rewards & Pro Tools',
                  subtitle: 'Custom sensitivity & downloads',
                ),

                const Spacer(),

                // "Let's Get Started" Action Button
                Container(
                  width: double.infinity,
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0072FF), Color(0xFF00E5FF)],
                    ),
                    borderRadius: BorderRadius.circular(27),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00D2FF).withValues(alpha: 0.5),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(27),
                      splashColor: Colors.white.withValues(alpha: 0.5),
                      highlightColor: Colors.white.withValues(alpha: 0.5),
                      onTap: () => setState(() => _currentStep = 1),
                      child: Center(
                        child: Text(
                          "Let's Get Started",
                          style: GoogleFonts.outfit(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeatureCard({
    required Color iconBg,
    required Color iconBorder,
    required Widget icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFF08142A).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF1E3A6E).withValues(alpha: 0.5),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: iconBorder, width: 1.1),
            ),
            child: Center(child: icon),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Screen 2: Authentication Step (100% Native Vector Widgets - Zero Blurriness)
  Widget _buildAuthSelectionStep(BuildContext context) {
    return LayoutBuilder(
      key: const ValueKey('auth_step_native'),
      builder: (context, constraints) {
        final double maxW = constraints.maxWidth;
        final double contentWidth = maxW > 440 ? 400 : (maxW - 36);

        return Center(
          child: SizedBox(
            width: contentWidth,
            child: Column(
              children: [
                const SizedBox(height: 6),

                // Top Left Glass Back Button (<)
                Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B172E).withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFF1E3A6E).withValues(alpha: 0.5),
                        width: 1.2,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        splashColor: const Color(0xFF00E5FF).withValues(alpha: 0.5),
                        onTap: () => setState(() => _currentStep = 0),
                        child: const Center(
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const Spacer(flex: 2),

                // App Brand Logo with Soft Cyan Glow
                Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00E5FF).withValues(alpha: 0.5),
                        blurRadius: 28,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(26),
                    child: Image.asset(
                      'assets/images/obin_icon_512.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // OBIN Brand Title
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFF00E5FF), Color(0xFF38BDF8), Color(0xFF00E5FF)],
                  ).createShader(bounds),
                  child: Text(
                    'OBIN',
                    style: GoogleFonts.outfit(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 3.0,
                    ),
                  ),
                ),
                const SizedBox(height: 4),

                // Your All-in-One Gaming Companion
                Text(
                  'Your All-in-One\nGaming Companion',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF93C5FD),
                    height: 1.35,
                  ),
                ),

                const Spacer(flex: 3),

                // 1. "Continue with Google" Action Button
                Container(
                  width: double.infinity,
                  height: 58,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(29),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.5),
                        blurRadius: 18,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(29),
                      onTap: _isGoogleLoading ? null : _handleGoogleSignIn,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _isGoogleLoading
                            ? const Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Color(0xFF0284C7),
                                  ),
                                ),
                              )
                            : Row(
                                children: [
                                  const GoogleGLogo(size: 24),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      'Continue with Google',
                                      style: GoogleFonts.outfit(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF0F172A),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 34,
                                    height: 34,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFE2E8F0),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 18,
                                      color: Color(0xFF0284C7),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // 2. "Manual Login" Action Button (Reacts live to Admin Panel Toggle)
                ValueListenableBuilder<Map<String, dynamic>>(
                  valueListenable: AuthService.instance.authSettingsNotifier,
                  builder: (context, authSettings, _) {
                    final isManualLoginEnabled = AuthService.instance.isManualLoginEnabled;
                    if (!isManualLoginEnabled) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: Container(
                        width: double.infinity,
                        height: 66,
                        decoration: BoxDecoration(
                          color: const Color(0xFF08142A).withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(29),
                          border: Border.all(
                            color: const Color(0xFF1E3A6E),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(29),
                            splashColor: const Color(0xFF00E5FF).withValues(alpha: 0.5),
                            onTap: _openLoginSheet,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0284C7).withValues(alpha: 0.5),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: const Color(0xFF00E5FF).withValues(alpha: 0.5),
                                        width: 1.1,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.lock_outline_rounded,
                                      color: Color(0xFF00E5FF),
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Manual Login',
                                          style: GoogleFonts.outfit(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Email & Password Sign In',
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: const Color(0xFF64748B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0E2247),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xFF00E5FF).withValues(alpha: 0.5),
                                        width: 1,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 18,
                                      color: Color(0xFF00E5FF),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // 3. 100% Verified Gaming Account Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF063326).withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF059669).withValues(alpha: 0.5),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.verified_user_rounded,
                        color: Color(0xFF34D399),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '100% Verified Gaming Account',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFA7F3D0),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 2),

                // 4. Terms of Service & Privacy Policy Footer
                GestureDetector(
                  onTap: () => _openLegalUrl(AppConstants.termsOfServiceUrl),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text.rich(
                      TextSpan(
                        text: 'By continuing, you agree to our ',
                        children: [
                          TextSpan(
                            text: 'Terms of Service & Privacy Policy',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF38BDF8),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: const Color(0xFF64748B),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
