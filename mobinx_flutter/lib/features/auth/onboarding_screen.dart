import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

/// 2-Step Modernized Player Authentication & Onboarding Screen
/// Step 0: Welcome Screen with "Let's Get Started" / "Continue" button
/// Step 1: Authentication Screen with Google Login, Manual Login & Referral Code
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with SingleTickerProviderStateMixin {
  int _currentStep = 0; // 0 = Welcome Step, 1 = Auth Selection Step
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
    _glowAnimation = Tween<double>(begin: 0.90, end: 1.10).animate(
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
        // If Google Sign-In didn't return an account, offer resilient direct login
        if (mounted) {
          _showQuickLoginDialog();
        }
      }
    } catch (e) {
      if (mounted) {
        _showQuickLoginDialog();
      }
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  void _showQuickLoginDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            const Icon(Icons.sports_esports_rounded, color: Color(0xFF38BDF8), size: 24),
            const SizedBox(width: 10),
            Text(
              'Quick Player Access',
              style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
            ),
          ],
        ),
        content: Text(
          'Would you like to enter as a Player immediately or use Manual Login?',
          style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 13.5),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _openLoginSheet();
            },
            child: Text('Manual Login', style: GoogleFonts.inter(color: const Color(0xFF38BDF8), fontWeight: FontWeight.w700)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0284C7),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.pop(context);
              await AuthService.instance.signInWithGoogle();
              if (mounted) _navigateToHome();
            },
            child: Text('Enter Now', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
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
      backgroundColor: const Color(0xFF060B18),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.05, 0),
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

  /// Screen 1: Welcome / Intro Flow ("Let's Get Started" / "Continue  /// Screen 1: Welcome / Intro Flow ("Let's Get Started" / "Continue")
  Widget _buildWelcomeStep() {
    return Container(
      key: const ValueKey('welcome_step'),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF132A54), // Lighter, richer navy-sapphire tone
            Color(0xFF0B1936),
            Color(0xFF061026),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top Branding
              Column(
                children: [
                  const SizedBox(height: 6),
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFF00F0FF).withValues(alpha: 0.55), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0284C7).withValues(alpha: 0.55),
                          blurRadius: 28,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(
                      'assets/images/obin_icon_512.png',
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        color: const Color(0xFF0284C7),
                        child: const Center(
                          child: Text('M', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Welcome to',
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFCBD5E1),
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 2),

                  // Stylized Gaming OBIN Brand Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 22,
                        height: 2,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.transparent, const Color(0xFF00F0FF).withValues(alpha: 0.8)],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFF00F0FF), Color(0xFF38BDF8), Color(0xFF2563EB)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds),
                        child: Text(
                          'OBIN',
                          style: GoogleFonts.orbitron(
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 4.5,
                            shadows: [
                              Shadow(
                                color: const Color(0xFF00F0FF).withValues(alpha: 0.6),
                                blurRadius: 22,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 22,
                        height: 2,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [const Color(0xFF00F0FF).withValues(alpha: 0.8), Colors.transparent],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'The Ultimate Super App',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF94A3B8),
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),

              // Center Pedestal Artwork (with ambient breathing glow animation)
              AnimatedBuilder(
                animation: _glowAnimation,
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Ambient pulsing outer glow ring
                      Transform.scale(
                        scale: _glowAnimation.value,
                        child: Container(
                          width: 230,
                          height: 230,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                const Color(0xFF0284C7).withValues(alpha: 0.45 * _glowAnimation.value),
                                const Color(0xFF00F0FF).withValues(alpha: 0.18 * _glowAnimation.value),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Pedestal frame
                      Container(
                        width: 176,
                        height: 176,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: const Color(0xFF00F0FF).withValues(alpha: 0.5), width: 1.8),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0284C7).withValues(alpha: 0.5 * _glowAnimation.value),
                              blurRadius: 38 * _glowAnimation.value,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.asset(
                          'assets/images/onboarding_controller.jpg',
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            color: const Color(0xFF0F172A),
                            child: const Icon(Icons.sports_esports_rounded, size: 70, color: Color(0xFF38BDF8)),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),

              // 3 Feature Highlight Cards (Rich Glassmorphism)
              Column(
                children: [
                  _buildFeatureRow(
                    icon: '💎',
                    title: 'Top Up & Diamonds',
                    desc: 'Fast & secure instant top up',
                    borderColor: const Color(0xFF00F0FF),
                  ),
                  const SizedBox(height: 8),
                  _buildFeatureRow(
                    icon: '🏆',
                    title: 'Tournaments',
                    desc: 'Join daily exciting battles',
                    borderColor: const Color(0xFFF59E0B),
                  ),
                  const SizedBox(height: 8),
                  _buildFeatureRow(
                    icon: '🎁',
                    title: 'Rewards & Pro Tools',
                    desc: 'Custom sensitivity & downloads',
                    borderColor: const Color(0xFFA855F7),
                  ),
                ],
              ),

              // Bottom "Let's Get Started" Button with gradient & pulse
              AnimatedBuilder(
                animation: _glowAnimation,
                builder: (context, child) {
                  return Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0066FF), Color(0xFF0284C7), Color(0xFF00C6FF)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0284C7).withValues(alpha: 0.55 * _glowAnimation.value),
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Let's Get Started",
                            style: GoogleFonts.outfit(fontSize: 16.5, fontWeight: FontWeight.w800, letterSpacing: 0.4),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, size: 20),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow({
    required String icon,
    required String title,
    required String desc,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF102042).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor.withValues(alpha: 0.35)),
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
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: borderColor.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderColor.withValues(alpha: 0.35)),
            ),
            child: Center(
              child: Text(icon, style: const TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
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

  /// Screen 2: Authentication Screen (Streamlined Google Login & Manual Login)
  Widget _buildAuthSelectionStep() {
    return Container(
      key: const ValueKey('auth_step'),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF132A54),
            Color(0xFF0B1936),
            Color(0xFF061026),
          ],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top Bar with Back Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        _currentStep = 0;
                      });
                    },
                  ),
                  const Spacer(),
                  const SizedBox(width: 48), // Balance spacing
                ],
              ),
              const SizedBox(height: 12),

              // Header Branding
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFF00F0FF).withValues(alpha: 0.55), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0284C7).withValues(alpha: 0.5),
                      blurRadius: 26,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  'assets/images/obin_icon_512.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color: const Color(0xFF0284C7),
                    child: const Center(
                      child: Text('M', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Stylized Gaming OBIN Typography
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF00F0FF), Color(0xFF38BDF8), Color(0xFF2563EB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                child: Text(
                  'OBIN',
                  style: GoogleFonts.orbitron(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 3.8,
                    shadows: [
                      Shadow(
                        color: const Color(0xFF00F0FF).withValues(alpha: 0.6),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'SIGN IN TO CONTINUE',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF38BDF8),
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 28),

              // 1. Google Sign-In Card
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _isGoogleLoading ? null : _handleGoogleSignIn,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF38BDF8).withValues(alpha: 0.35),
                          blurRadius: 22,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: _isGoogleLoading
                        ? const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFF2563EB)),
                            ),
                          )
                        : Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                  child: GoogleGLogo(size: 22),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Continue with Google',
                                      style: GoogleFonts.outfit(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF0F172A),
                                      ),
                                    ),
                                    Text(
                                      'Fast & Direct One-Tap Login',
                                      style: GoogleFonts.inter(
                                        fontSize: 11.5,
                                        color: const Color(0xFF64748B),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.arrow_forward_rounded, color: Color(0xFF2563EB), size: 18),
                              ),
                            ],
                          ),
                  ),
                ),
              ),

              // 2. Manual Login Card (Controlled live by Admin Panel auth_settings)
              ValueListenableBuilder<Map<String, dynamic>>(
                valueListenable: AuthService.instance.authSettingsNotifier,
                builder: (context, authSettings, _) {
                  final isManualEnabled = authSettings['manualLoginEnabled'] != false;
                  if (!isManualEnabled) return const SizedBox.shrink();
                  return Column(
                    children: [
                      const SizedBox(height: 14),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _openLoginSheet,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF102042).withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.4), width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.35),
                                  blurRadius: 18,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.3)),
                                  ),
                                  child: const Center(
                                    child: Icon(Icons.lock_outline_rounded, color: Color(0xFF38BDF8), size: 22),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Manual Login',
                                        style: GoogleFonts.outfit(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        'Email & Password Sign In',
                                        style: GoogleFonts.inter(
                                          fontSize: 11.5,
                                          color: const Color(0xFF94A3B8),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E293B),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.arrow_forward_rounded, color: Color(0xFF38BDF8), size: 18),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 32),

              // Trust & Security Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF102042).withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.shield_rounded, color: Color(0xFF34D399), size: 15),
                    const SizedBox(width: 6),
                    Text(
                      '100% Secure & Verified Gaming Account',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: const Color(0xFF94A3B8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Terms & Privacy Policy
              Text(
                'By continuing, you agree to our Terms of Service & Privacy Policy',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
