import 'dart:io';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../../app/theme.dart';
import 'urdown_logo.dart';

class UrDownTitleBar extends StatelessWidget {
  const UrDownTitleBar({super.key});

  @override
  Widget build(BuildContext context) {
    // Only render on macOS — safety guard for other platforms.
    if (!Platform.isMacOS) return const SizedBox.shrink();

    // TitleBarStyle.normal is used for VirtualBox compatibility (Metal-less
    // environments). When the native title bar is active, we hide this custom
    // bar to avoid having two title bars stacked.
    // We detect this by checking if we're using the normal title bar style:
    // the native bar shows the window title "UrDown", so no custom bar needed.
    //
    // To restore the custom title bar on real Mac hardware, change
    // TitleBarStyle in main.dart back to TitleBarStyle.hidden and
    // remove the SizedBox.shrink() early return below.
    return const SizedBox.shrink();
  }
}

// ── Full custom title bar (used when TitleBarStyle.hidden is active) ─────────
// Kept here for reference — re-enable by removing the early return above.

class UrDownTitleBarFull extends StatelessWidget {
  const UrDownTitleBarFull({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Platform.isMacOS) return const SizedBox.shrink();

    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final barBg    = isDark ? AppColors.darkSurface : AppColors.lightCard;
    final divColor = isDark
        ? AppColors.brand.withValues(alpha: 0.7)
        : AppColors.brand.withValues(alpha: 0.5);

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(height: 1, color: divColor),
          Container(
            height: 38,
            color:  barBg,
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14),
                  child:   _Brand(),
                ),
                const Expanded(
                  child: DragToMoveArea(child: SizedBox.expand()),
                ),
                _WindowControls(isDark: isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const UrDownIcon(size: 22),
        const SizedBox(width: 9),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF00E5FF), Color(0xFF33ECFF)],
          ).createShader(bounds),
          child: const Text(
            'UrDown',
            style: TextStyle(
              color:        Colors.white,
              fontSize:     13,
              fontWeight:   FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _WindowControls extends StatelessWidget {
  const _WindowControls({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _WinBtn(isDark: isDark, icon: Icons.remove_rounded,      tooltip: 'Minimize', onTap: windowManager.minimize),
        _WinBtn(isDark: isDark, icon: Icons.crop_square_rounded,  tooltip: 'Maximize', onTap: _toggleMaximize, iconSize: 14),
        _WinBtn(isDark: isDark, icon: Icons.close_rounded,        tooltip: 'Close',    onTap: windowManager.close, isClose: true),
      ],
    );
  }

  Future<void> _toggleMaximize() async {
    if (await windowManager.isMaximized()) {
      await windowManager.restore();
    } else {
      await windowManager.maximize();
    }
  }
}

class _WinBtn extends StatefulWidget {
  const _WinBtn({
    required this.isDark,
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.iconSize = 16,
    this.isClose  = false,
  });
  final bool     isDark;
  final IconData icon;
  final String   tooltip;
  final Future<void> Function() onTap;
  final double   iconSize;
  final bool     isClose;

  @override
  State<_WinBtn> createState() => _WinBtnState();
}

class _WinBtnState extends State<_WinBtn> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final hoverBg = widget.isClose
        ? const Color(0xFFE81123)
        : (widget.isDark
            ? AppColors.darkBorder.withValues(alpha: 0.8)
            : AppColors.lightBorder.withValues(alpha: 0.9));

    final bg = _hover ? hoverBg : Colors.transparent;

    final iconColor = _hover && widget.isClose
        ? Colors.white
        : (widget.isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary);

    return Tooltip(
      message:     widget.tooltip,
      preferBelow: false,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit:  (_) => setState(() => _hover = false),
        cursor:  SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 80),
            width:  46,
            height: 38,
            color:  bg,
            child: Center(
              child: Icon(widget.icon, size: widget.iconSize, color: iconColor),
            ),
          ),
        ),
      ),
    );
  }
}
