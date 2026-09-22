import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/storage_service.dart';
import '../home/home_screen.dart';
import 'login_sheet.dart';
import 'register_sheet.dart';
import 'google_profile_sheet.dart';

/// 2-Step Official OBIN Player Onboarding & Authentication Screen
/// Identically implements the user-designed reference visuals:
/// Step 0: Welcome Screen (media_1790045597275.png -> assets/images/welcome_bg_clean.png)
/// Step 1: Login & Auth Selection (media_1790045597176.png -> assets/images/auth_bg_clean.png)
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
      body: SafeArea(
        top: true,
        bottom: true,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double screenAspect = constraints.maxWidth / constraints.maxHeight;
            final BoxFit fit = (screenAspect > 0.55) ? BoxFit.contain : BoxFit.cover;

            return GestureDetector(
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity != null) {
                  if (details.primaryVelocity! < -200 && _currentStep == 0) {
                    setState(() => _currentStep = 1);
                  } else if (details.primaryVelocity! > 200 && _currentStep == 1) {
                    setState(() => _currentStep = 0);
                  }
                }
              },
              child: Center(
                child: FittedBox(
                  fit: fit,
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 460,
                    height: 942,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 320),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
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
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Screen 1: Welcome Step (100% Identical to media_1790045597275.png)
  Widget _buildWelcomeStep() {
    return Stack(
      key: const ValueKey('welcome_step'),
      children: [
        // Exact user-designed high-res clean background visual
        Positioned.fill(
          child: Image.asset(
            'assets/images/welcome_bg_clean.png',
            width: 460,
            height: 942,
            fit: BoxFit.fill,
          ),
        ),

        // Interactive Tap Target: "Let's Get Started" Button
        Positioned(
          left: 20,
          top: 810,
          width: 420,
          height: 62,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              splashColor: const Color(0xFF00E5FF).withValues(alpha: 0.35),
              highlightColor: const Color(0xFF00E5FF).withValues(alpha: 0.18),
              onTap: () {
                setState(() {
                  _currentStep = 1;
                });
              },
              child: const SizedBox.expand(),
            ),
          ),
        ),
      ],
    );
  }

  /// Screen 2: Authentication Step (100% Identical to media_1790045597176.png)
  Widget _buildAuthSelectionStep() {
    return Stack(
      key: const ValueKey('auth_step'),
      children: [
        // Exact user-designed high-res clean background visual
        Positioned.fill(
          child: Image.asset(
            'assets/images/auth_bg_clean.png',
            width: 460,
            height: 942,
            fit: BoxFit.fill,
          ),
        ),

        // 1. Interactive Tap Target: Top-Left Glass Back Button (<)
        Positioned(
          left: 18,
          top: 8,
          width: 58,
          height: 58,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              splashColor: const Color(0xFF38BDF8).withValues(alpha: 0.3),
              highlightColor: const Color(0xFF38BDF8).withValues(alpha: 0.15),
              onTap: () {
                setState(() {
                  _currentStep = 0;
                });
              },
              child: const SizedBox.expand(),
            ),
          ),
        ),

        // 2. Interactive Tap Target: "Continue with Google" Button
        Positioned(
          left: 20,
          top: 460,
          width: 420,
          height: 78,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(26),
              splashColor: const Color(0xFF0284C7).withValues(alpha: 0.25),
              highlightColor: const Color(0xFF0284C7).withValues(alpha: 0.12),
              onTap: _isGoogleLoading ? null : _handleGoogleSignIn,
              child: _isGoogleLoading
                  ? Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(26),
                      ),
                      child: const Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2.8, color: Color(0xFF0284C7)),
                            ),
                            SizedBox(width: 14),
                            Text(
                              'Signing in with Google...',
                              style: TextStyle(
                                color: Color(0xFF0F172A),
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox.expand(),
            ),
          ),
        ),

        // 3. Interactive Tap Target: "Manual Login" Button
        Positioned(
          left: 20,
          top: 560,
          width: 420,
          height: 75,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(26),
              splashColor: const Color(0xFF00E5FF).withValues(alpha: 0.25),
              highlightColor: const Color(0xFF00E5FF).withValues(alpha: 0.12),
              onTap: _openLoginSheet,
              child: const SizedBox.expand(),
            ),
          ),
        ),

        // 4. Interactive Tap Target: 100% Verified Gaming Account Badge
        Positioned(
          left: 90,
          top: 660,
          width: 280,
          height: 48,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              splashColor: const Color(0xFF10B981).withValues(alpha: 0.25),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🛡️ OBIN 100% Verified Secure Gaming Account'),
                    backgroundColor: Color(0xFF065F46),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const SizedBox.expand(),
            ),
          ),
        ),

        // 5. Interactive Tap Target: Terms of Service & Privacy Policy
        Positioned(
          left: 30,
          top: 895,
          width: 400,
          height: 38,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              splashColor: const Color(0xFF00E5FF).withValues(alpha: 0.15),
              onTap: () => _openLegalUrl(AppConstants.termsOfServiceUrl),
              child: const SizedBox.expand(),
            ),
          ),
        ),
      ],
    );
  }
}
