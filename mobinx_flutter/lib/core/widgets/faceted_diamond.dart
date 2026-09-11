import 'dart:math' as math;
import 'package:flutter/material.dart';

/// 3D Faceted Sparkling Diamond Widget with floating pulse animation (gemFloat) and star sparkles (✦, ✨)
class FacetedDiamond3D extends StatefulWidget {
  final double size;
  final bool enableFloat;
  final bool enableSparkles;
  final List<Color>? gradientColors;

  const FacetedDiamond3D({
    super.key,
    this.size = 46.0,
    this.enableFloat = true,
    this.enableSparkles = true,
    this.gradientColors,
  });

  @override
  State<FacetedDiamond3D> createState() => _FacetedDiamond3DState();
}

class _FacetedDiamond3DState extends State<FacetedDiamond3D>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _floatAnim;
  late Animation<double> _sparkleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _floatAnim = Tween<double>(begin: -2.5, end: 2.5).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOutSine),
    );

    _sparkleAnim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, widget.enableFloat ? _floatAnim.value : 0),
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // Soft radial glow behind gem
                Container(
                  width: widget.size * 0.9,
                  height: widget.size * 0.9,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00E5FF).withValues(
                          alpha: 0.35 * _sparkleAnim.value,
                        ),
                        blurRadius: widget.size * 0.4,
                        spreadRadius: widget.size * 0.1,
                      ),
                    ],
                  ),
                ),

                // 3D Faceted Diamond Custom Paint
                CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: _Diamond3DPainter(
                    glowFactor: _sparkleAnim.value,
                  ),
                ),

                // Twinkling Star Sparkle (Top-Right)
                if (widget.enableSparkles)
                  Positioned(
                    top: -widget.size * 0.12,
                    right: -widget.size * 0.08,
                    child: Opacity(
                      opacity: _sparkleAnim.value.clamp(0.0, 1.0),
                      child: Transform.scale(
                        scale: 0.7 + 0.4 * _sparkleAnim.value,
                        child: Text(
                          '✦',
                          style: TextStyle(
                            fontSize: widget.size * 0.38,
                            color: const Color(0xFFE0F7FF),
                            shadows: const [
                              Shadow(
                                color: Color(0xFF00E5FF),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                // Twinkling Star Sparkle (Bottom-Left)
                if (widget.enableSparkles)
                  Positioned(
                    bottom: -widget.size * 0.06,
                    left: -widget.size * 0.08,
                    child: Opacity(
                      opacity: (1.2 - _sparkleAnim.value).clamp(0.0, 1.0),
                      child: Transform.scale(
                        scale: 0.6 + 0.3 * (1.0 - _sparkleAnim.value),
                        child: Text(
                          '✨',
                          style: TextStyle(
                            fontSize: widget.size * 0.28,
                          ),
                        ),
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

class _Diamond3DPainter extends CustomPainter {
  final double glowFactor;

  _Diamond3DPainter({required this.glowFactor});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Diamond key coordinate vertices (classic brilliant gem proportions)
    final pTopLeft = Offset(w * 0.22, h * 0.28);
    final pTopCenterLeft = Offset(w * 0.38, h * 0.28);
    final pTopCenterRight = Offset(w * 0.62, h * 0.28);
    final pTopRight = Offset(w * 0.78, h * 0.28);

    final pMidLeft = Offset(w * 0.08, h * 0.48);
    final pMidCenterLeft = Offset(w * 0.32, h * 0.48);
    final pMidCenterRight = Offset(w * 0.68, h * 0.48);
    final pMidRight = Offset(w * 0.92, h * 0.48);

    final pBottomTip = Offset(w * 0.50, h * 0.88);

    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9;

    void drawFacet(List<Offset> points, List<Color> colors, [Alignment begin = Alignment.topCenter, Alignment end = Alignment.bottomCenter]) {
      final path = Path()..moveTo(points[0].dx, points[0].dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      path.close();

      final bounds = path.getBounds();
      final paint = Paint()
        ..shader = LinearGradient(colors: colors, begin: begin, end: end).createShader(bounds)
        ..style = PaintingStyle.fill;

      canvas.drawPath(path, paint);
      canvas.drawPath(path, linePaint);
    }

    // 1. Crown Top Table Facets (Bright specular highlights)
    // Center Table
    drawFacet(
      [pTopCenterLeft, pTopCenterRight, pMidCenterRight, pMidCenterLeft],
      [const Color(0xFFE0F7FE), const Color(0xFF38BDF8), const Color(0xFF0284C7)],
      Alignment.topLeft,
      Alignment.bottomRight,
    );

    // Left Upper Crown
    drawFacet(
      [pTopLeft, pTopCenterLeft, pMidCenterLeft, pMidLeft],
      [const Color(0xFFBAE6FD), const Color(0xFF0284C7), const Color(0xFF0369A1)],
      Alignment.topRight,
      Alignment.bottomLeft,
    );

    // Right Upper Crown
    drawFacet(
      [pTopCenterRight, pTopRight, pMidRight, pMidCenterRight],
      [const Color(0xFFE0F2FE), const Color(0xFF0EA5E9), const Color(0xFF0284C7)],
      Alignment.topLeft,
      Alignment.bottomRight,
    );

    // 2. Pavilion Lower Facets (Deep 3D reflective cones)
    // Left Lower Triangle
    drawFacet(
      [pMidLeft, pMidCenterLeft, pBottomTip],
      [const Color(0xFF0284C7), const Color(0xFF0369A1), const Color(0xFF0C4A6E)],
      Alignment.topCenter,
      Alignment.bottomRight,
    );

    // Center Lower Kite / Triangle
    drawFacet(
      [pMidCenterLeft, pMidCenterRight, pBottomTip],
      [const Color(0xFF38BDF8), const Color(0xFF0284C7), const Color(0xFF075985)],
      Alignment.topCenter,
      Alignment.bottomCenter,
    );

    // Right Lower Triangle
    drawFacet(
      [pMidCenterRight, pMidRight, pBottomTip],
      [const Color(0xFF0EA5E9), const Color(0xFF0369A1), const Color(0xFF082F49)],
      Alignment.topCenter,
      Alignment.bottomLeft,
    );

    // 3. Specular Glint Highlight on Top Table (Mirror Reflection)
    final glintPath = Path()
      ..moveTo(pTopCenterLeft.dx + 2, pTopCenterLeft.dy + 1)
      ..lineTo(pTopCenterRight.dx - 2, pTopCenterRight.dy + 1)
      ..lineTo(pMidCenterLeft.dx + (pMidCenterRight.dx - pMidCenterLeft.dx) * 0.4, pMidCenterLeft.dy - 2)
      ..close();

    final glintPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.65 * glowFactor)
      ..style = PaintingStyle.fill;
    canvas.drawPath(glintPath, glintPaint);
  }

  @override
  bool shouldRepaint(covariant _Diamond3DPainter oldDelegate) {
    return oldDelegate.glowFactor != glowFactor;
  }
}
