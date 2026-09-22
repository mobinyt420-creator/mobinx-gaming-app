import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
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

/// 2-Step Modernized Player Authentication & Onboarding Screen (Images 2 & 3)
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with SingleTickerProviderStateMixin {
  int _currentStep = 0; // 0 = Welcome Step (Image 3), 1 = Auth Selection Step (Image 2)
  bool _isGoogleLoading = false;

  late final AnimationController _pulseController;
  late final Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

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
    return Scaffold(
      backgroundColor: const Color(0xFF060B18),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.04, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: _currentStep == 0 ? _buildWelcomeStep() : _buildAuthSelectionStep(),
      ),
    );
  }

  /// Screen 1: Welcome Step (Image 3)
  Widget _buildWelcomeStep() {
    return Container(
      key: const ValueKey('welcome_step'),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0F1E3D),
            Color(0xFF0B172E),
            Color(0xFF060B18),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Background ambient gaming glow
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF0284C7).withValues(alpha: 0.28),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 60,
            left: -40,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF00E5FF).withValues(alpha: 0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 1. Top Branding Header (Image 3)
                  Column(
                    children: [
                      const SizedBox(height: 4),
                      // App Icon Squircle
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: const Color(0xFF00E5FF).withValues(alpha: 0.6),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00E5FF).withValues(alpha: 0.35),
                              blurRadius: 24,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.asset(
                          'assets/images/obin_icon_512.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Welcome to',
                        style: GoogleFonts.outfit(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF94A3B8),
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 1),

                      // — OBIN — Brand Title
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 24,
                            height: 2.2,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.transparent, const Color(0xFF00E5FF).withValues(alpha: 0.9)],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Color(0xFF00E5FF), Color(0xFF38BDF8), Color(0xFF60A5FA)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(bounds),
                            child: Text(
                              'OBIN',
                              style: GoogleFonts.outfit(
                                fontSize: 34,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 2.5,
                                shadows: [
                                  Shadow(
                                    color: const Color(0xFF00E5FF).withValues(alpha: 0.65),
                                    blurRadius: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 24,
                            height: 2.2,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [const Color(0xFF00E5FF).withValues(alpha: 0.9), Colors.transparent],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 1),
                      Text(
                        'The Ultimate Super App',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF94A3B8),
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),

                  // 2. Center Hero Card (Image 3)
                  AnimatedBuilder(
                    animation: _glowAnimation,
                    builder: (context, child) {
                      return Container(
                        width: 250,
                        height: 210,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(
                            color: const Color(0xFF00E5FF).withValues(alpha: 0.55),
                            width: 1.6,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00E5FF).withValues(alpha: 0.35 * _glowAnimation.value),
                              blurRadius: 32 * _glowAnimation.value,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.asset(
                          'assets/images/onboarding_controller.jpg',
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),

                  // 3. Three Feature Highlight Cards (Image 3)
                  Column(
                    children: [
                      _buildFeatureTile(
                        icon: Icons.diamond_rounded,
                        iconColor: const Color(0xFF00E5FF),
                        title: 'Top Up & Diamonds',
                        desc: 'Fast & secure instant top up',
                        borderColor: const Color(0xFF0284C7),
                      ),
                      const SizedBox(height: 9),
                      _buildFeatureTile(
                        icon: Icons.emoji_events_rounded,
                        iconColor: const Color(0xFFF59E0B),
                        title: 'Tournaments',
                        desc: 'Join daily exciting battles',
                        borderColor: const Color(0xFFD97706),
                      ),
                      const SizedBox(height: 9),
                      _buildFeatureTile(
                        icon: Icons.card_giftcard_rounded,
                        iconColor: const Color(0xFFA855F7),
                        title: 'Rewards & Pro Tools',
                        desc: 'Custom sensitivity & downloads',
                        borderColor: const Color(0xFF7C3AED),
                      ),
                    ],
                  ),

                  // 4. Bottom "Let's Get Started" Button (Image 3)
                  AnimatedBuilder(
                    animation: _glowAnimation,
                    builder: (context, child) {
                      return Container(
                        width: double.infinity,
                        height: 54,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0072FF), Color(0xFF00D2FF)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00D2FF).withValues(alpha: 0.45 * _glowAnimation.value),
                              blurRadius: 22 * _glowAnimation.value,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _currentStep = 1;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          ),
                          child: Text(
                            "Let's Get Started",
                            style: GoogleFonts.outfit(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String desc,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1832).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: iconColor.withValues(alpha: 0.35)),
            ),
            child: Icon(icon, color: iconColor, size: 21),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  desc,
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    color: const Color(0xFF94A3B8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Screen 2: Authentication Screen (Image 2)
  Widget _buildAuthSelectionStep() {
    return Container(
      key: const ValueKey('auth_step'),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0F1E3D),
            Color(0xFF0C1935),
            Color(0xFF060D1E),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Background ambient light curves
          Positioned(
            top: 40,
            left: -30,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF0284C7).withValues(alpha: 0.25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            right: -30,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF00E5FF).withValues(alpha: 0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // 1. Top Bar with Glass Back Button (Image 2)
                          Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF101C38).withValues(alpha: 0.8),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: const Color(0xFF38BDF8).withValues(alpha: 0.3),
                                    width: 1.2,
                                  ),
                                ),
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 28),
                                  onPressed: () {
                                    setState(() {
                                      _currentStep = 0;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),

                          // 2. Center Branding & Action Cards (Image 2)
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Glowing Brand Icon Container (Image 2)
                              Container(
                                width: 84,
                                height: 84,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: const Color(0xFF00E5FF).withValues(alpha: 0.75),
                                    width: 2.0,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF00E5FF).withValues(alpha: 0.45),
                                      blurRadius: 36,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Image.asset(
                                  'assets/images/obin_icon_512.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Stylized OBIN Title (Image 2)
                              RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'O',
                                      style: GoogleFonts.outfit(
                                        fontSize: 42,
                                        fontWeight: FontWeight.w900,
                                        color: const Color(0xFF00E5FF),
                                        letterSpacing: 2.0,
                                        shadows: [
                                          Shadow(
                                            color: const Color(0xFF00E5FF).withValues(alpha: 0.8),
                                            blurRadius: 28,
                                          ),
                                        ],
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'BIN',
                                      style: GoogleFonts.outfit(
                                        fontSize: 42,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        letterSpacing: 2.5,
                                        shadows: [
                                          Shadow(
                                            color: const Color(0xFF38BDF8).withValues(alpha: 0.6),
                                            blurRadius: 24,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Your All-in-One\nGaming Companion',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.outfit(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFCBD5E1),
                                  height: 1.3,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(height: 38),

                              // Button 1: "Continue with Google" (White Pill Card from Image 2)
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: _isGoogleLoading ? null : _handleGoogleSignIn,
                                  borderRadius: BorderRadius.circular(24),
                                  child: Container(
                                    width: double.infinity,
                                    height: 62,
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(24),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.white.withValues(alpha: 0.15),
                                          blurRadius: 20,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: _isGoogleLoading
                                        ? const Center(
                                            child: SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFF0284C7)),
                                            ),
                                          )
                                        : Row(
                                            children: [
                                              Container(
                                                width: 44,
                                                height: 44,
                                                decoration: const BoxDecoration(
                                                  color: Color(0xFFF1F5F9),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Center(
                                                  child: GoogleGLogo(size: 22),
                                                ),
                                              ),
                                              const SizedBox(width: 14),
                                              Expanded(
                                                child: Text(
                                                  'Continue with Google',
                                                  style: GoogleFonts.outfit(
                                                    fontSize: 16.5,
                                                    fontWeight: FontWeight.w800,
                                                    color: const Color(0xFF0F172A),
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                width: 38,
                                                height: 38,
                                                decoration: const BoxDecoration(
                                                  color: Color(0xFFE0F2FE),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(Icons.arrow_forward_rounded, color: Color(0xFF0284C7), size: 20),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Button 2: "Manual Login" (Dark Glass Pill Card from Image 2)
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: _openLoginSheet,
                                  borderRadius: BorderRadius.circular(24),
                                  child: Container(
                                    width: double.infinity,
                                    height: 68,
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF08142C).withValues(alpha: 0.75),
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(
                                        color: const Color(0xFF0284C7),
                                        width: 1.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF0284C7).withValues(alpha: 0.25),
                                          blurRadius: 18,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF0284C7),
                                            borderRadius: BorderRadius.circular(14),
                                          ),
                                          child: const Center(
                                            child: Icon(Icons.lock_rounded, color: Color(0xFF38BDF8), size: 22),
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Manual Login',
                                                style: GoogleFonts.outfit(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w800,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              Text(
                                                'Email & Password Sign In',
                                                style: GoogleFonts.inter(
                                                  fontSize: 12,
                                                  color: const Color(0xFF94A3B8),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: 38,
                                          height: 38,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF0D254C),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: const Color(0xFF0284C7).withValues(alpha: 0.5),
                                            ),
                                          ),
                                          child: const Icon(Icons.arrow_forward_rounded, color: Color(0xFF00D2FF), size: 18),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Button 3: 100% Verified Gaming Account Badge (Image 2)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF071830).withValues(alpha: 0.65),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: const Color(0xFF0284C7).withValues(alpha: 0.45),
                                    width: 1.2,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.verified_user_rounded, color: Color(0xFF10B981), size: 17),
                                    const SizedBox(width: 8),
                                    Text(
                                      '100% Verified Gaming Account',
                                      style: GoogleFonts.outfit(
                                        fontSize: 13,
                                        color: const Color(0xFFE2E8F0),
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          // 3. Bottom Terms & Privacy Policy (Image 2)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'By continuing, you agree to our ',
                                  style: GoogleFonts.inter(
                                    fontSize: 11.5,
                                    color: const Color(0xFF94A3B8),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => _openLegalUrl(AppConstants.privacyPolicyUrl),
                                  child: Text(
                                    'Terms of Service & Privacy Policy',
                                    style: GoogleFonts.inter(
                                      fontSize: 11.5,
                                      color: const Color(0xFF38BDF8),
                                      fontWeight: FontWeight.w700,
                                      decoration: TextDecoration.underline,
                                      decorationColor: const Color(0xFF38BDF8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
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
