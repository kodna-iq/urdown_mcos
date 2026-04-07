import 'package:flutter/material.dart';

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// UrDownIcon  — the ORIGINAL cyan icon, unchanged geometry, just renamed
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class UrDownIcon extends StatelessWidget {
  const UrDownIcon({super.key, this.size = 48});
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(
        width:  size,
        height: size,
        child:  CustomPaint(painter: _UrDownIconPainter()),
      );
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// UrDownLogo  — icon + "UrDown" wordmark + optional translated tagline
//
// IMPORTANT: pass `tagline: s.appTagline` from the widget that has access
// to the strings provider so the tagline respects the selected language.
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class UrDownLogo extends StatelessWidget {
  const UrDownLogo({
    super.key,
    this.iconSize    = 80,
    this.showTagline = true,
    this.tagline,          // ← pass s.appTagline from outside
  });
  final double  iconSize;
  final bool    showTagline;
  final String? tagline;   // null = use English fallback

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Icon ──────────────────────────────────────────────────────────
        UrDownIcon(size: iconSize),
        SizedBox(height: iconSize * 0.14),

        // ── "UrDown" wordmark ─────────────────────────────────────────────
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF4FC3F7), Color(0xFF5C6BC0), Color(0xFF8B2FC9)],
          ).createShader(bounds),
          child: Text(
            'UrDown',
            style: TextStyle(
              fontSize:      iconSize * 0.42,
              fontWeight:    FontWeight.w900,
              letterSpacing: 3,
              color:         Colors.white,
            ),
          ),
        ),

        // ── Translated tagline ────────────────────────────────────────────
        if (showTagline) ...[
          SizedBox(height: iconSize * 0.06),
          Text(
            tagline ?? 'Download the World, Rooted in Ur.',
            style: TextStyle(
              fontSize:      iconSize * 0.118,
              color:         const Color(0xFF00E5FF).withValues(alpha: 0.75),
              letterSpacing: 1.2,
              fontWeight:    FontWeight.w300,
              fontStyle:     FontStyle.normal,
              height:        1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

// ── Backward-compat aliases ───────────────────────────────────────────────────
// Old files that still import vidox_logo.dart and use VidoxIcon / VidoxLogo
// will continue to compile without any changes.
typedef VidoxIcon = UrDownIcon;
typedef VidoxLogo = UrDownLogo;

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// _UrDownIconPainter  — EXACT COPY of the original _VidoxIconPainter
//
// Geometry (1024×1024 canvas):
//   1. Cyan #00E5FF rounded-rect background  (rx = 210)
//   2. Black vertical stem   x=477 y=190 w=70 h=450 rx=35
//   3. Black chevron         M330,450 L512,632 L694,450  sw=80 round
//   4. Black baseline bar    x=262 y=740 w=500 h=80 rx=40
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _UrDownIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final sc = size.width / 1024.0; // uniform scale factor

    // ── 1. Cyan background ────────────────────────────────────────────────
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(210 * sc),
      ),
      Paint()..color = const Color(0xFF00E5FF),
    );

    final black = Paint()..color = Colors.black;

    // ── 2. Vertical stem ──────────────────────────────────────────────────
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(477 * sc, 190 * sc, 70 * sc, 450 * sc),
        Radius.circular(35 * sc),
      ),
      black,
    );

    // ── 3. Chevron M330,450 L512,632 L694,450 ────────────────────────────
    canvas.drawPath(
      Path()
        ..moveTo(330 * sc, 450 * sc)
        ..lineTo(512 * sc, 632 * sc)
        ..lineTo(694 * sc, 450 * sc),
      Paint()
        ..color       = Colors.black
        ..style       = PaintingStyle.stroke
        ..strokeWidth = 80 * sc
        ..strokeCap   = StrokeCap.round
        ..strokeJoin  = StrokeJoin.round,
    );

    // ── 4. Baseline bar ───────────────────────────────────────────────────
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(262 * sc, 740 * sc, 500 * sc, 80 * sc),
        Radius.circular(40 * sc),
      ),
      black,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
