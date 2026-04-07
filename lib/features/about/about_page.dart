import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/widgets/urdown_logo.dart';

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// AboutPage
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class AboutPage extends ConsumerWidget {
  const AboutPage({super.key});

  static String _urNote(String code) {
    const map = <String, String>{
      'en': "Named after the ancient Mesopotamian city of Ur, one of the world's first great civilisations, located in what is now southern Iraq.",
      'ar': 'سُمِّي على اسم مدينة أور السومرية العريقة، إحدى أولى الحضارات العظيمة في التاريخ، الواقعة في جنوب العراق.',
      'zh': '以美索不达米亚古城吾尔命名，世界最早文明之一，位于今伊拉克南部。',
      'es': 'Nombrado por la antigua ciudad mesopotámica de Ur, una de las primeras grandes civilizaciones, ubicada en el sur de Irak.',
      'ru': 'Назван в честь древнего шумерского города Ур, одной из первых великих цивилизаций, расположенной на юге Ирака.',
      'ku': 'ناوی لە شاری کۆنی سومەری ئوور وەرگیراوە، یەکێک لە یەکەمین شارستانییە گەورەکانی جیهان، لە باشووری عێراق.',
    };
    return map[code] ?? map['en']!;
  }

  static String _contactLabel(String code) {
    const map = <String, String>{
      'en': 'Contact us',
      'ar': 'تواصل معنا',
      'zh': '联系我们',
      'es': 'Contáctanos',
      'ru': 'Связаться',
      'ku': 'پەیوەندی بکە',
    };
    return map[code] ?? map['en']!;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s      = ref.watch(stringsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text(s.aboutApp)),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(32, 24, 32, 60),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              // ── Logo + translated tagline ──────────────────────────────
              UrDownLogo(iconSize: 96, showTagline: true, tagline: s.appTagline),
              const SizedBox(height: 10),

              // ── Version badge ──────────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.brand.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.brand.withValues(alpha: 0.3)),
                ),
                child: Text(
                  '${s.version}  ${AppConstants.appVersion}',
                  style: const TextStyle(
                    color: AppColors.brand, fontSize: 13,
                    fontWeight: FontWeight.w600, letterSpacing: 0.3,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // ── Info card ──────────────────────────────────────────────
              // Row 1: Developer — "فريق كودنا"
              // Row 2: Website button → kodna.org
              // Row 3: Telegram button → @kodna_iq
              _InfoCard(isDark: isDark, children: [

                // Developer row (non-tappable label)
                _InfoRow(
                  icon:  Icons.group_outlined,
                  label: s.developer,
                  value: s.developerName,
                ),

                _Divider(isDark: isDark),

                // Website — styled as a tappable action button inside the card
                _LinkRow(
                  isDark:    isDark,
                  icon:      Icons.language_rounded,
                  label:     s.website,
                  buttonText: 'kodna.org',
                  accentColor: AppColors.brand,
                  onTap: () => launchUrl(
                    Uri.parse('https://kodna.org/'),
                    mode: LaunchMode.externalApplication,
                  ),
                ),

                _Divider(isDark: isDark),

                // Telegram — styled as a tappable action button inside the card
                _LinkRow(
                  isDark:     isDark,
                  icon:       Icons.send_rounded,
                  label:      _contactLabel(s.languageCode),
                  buttonText: '@kodna_iq',
                  accentColor: const Color(0xFF29B6F6), // Telegram blue
                  onTap: () => launchUrl(
                    Uri.parse('https://t.me/kodna_iq'),
                    mode: LaunchMode.externalApplication,
                  ),
                ),
              ]),

              const SizedBox(height: 28),

              // ── Ur heritage note ───────────────────────────────────────
              Container(
                constraints: const BoxConstraints(maxWidth: 440),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.brand.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.brand.withValues(alpha: 0.15)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(Icons.history_edu_rounded, size: 18, color: AppColors.brand),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _urNote(s.languageCode),
                        style: TextStyle(
                          fontSize: 12.5, height: 1.55,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // ── Footer ─────────────────────────────────────────────────
              Text(
                s.madeWith,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                '© 2025 Kodna — ${s.allRightsReserved}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                textAlign: TextAlign.center,
              ),
              // ── NO bottom button row — website & Telegram are in the card above
            ],
          ),
        ),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// _LinkRow  — card row with a styled button on the right
// Label on the right (RTL-friendly), button on the left
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _LinkRow extends StatelessWidget {
  const _LinkRow({
    required this.isDark,
    required this.icon,
    required this.label,
    required this.buttonText,
    required this.accentColor,
    required this.onTap,
  });
  final bool         isDark;
  final IconData     icon;
  final String       label;
  final String       buttonText;
  final Color        accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: accentColor),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ),
          // Tappable button-style chip
          InkWell(
            onTap:        onTap,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color:        accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border:       Border.all(color: accentColor.withValues(alpha: 0.35)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    buttonText,
                    style: TextStyle(
                      fontSize:   13,
                      fontWeight: FontWeight.w600,
                      color:      accentColor,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Icon(Icons.open_in_new_rounded, size: 12, color: accentColor),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Standard info row (non-tappable)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label, value;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      child: Row(children: [
        Icon(icon, size: 20, color: AppColors.brand),
        const SizedBox(width: 14),
        Expanded(child: Text(label, style: TextStyle(
            fontSize: 14,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary))),
        Text(value, style: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkText : AppColors.lightText)),
      ]),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Card + divider helpers
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.isDark, required this.children});
  final bool isDark;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 440),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder, width: 0.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(children: children),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider({required this.isDark});
  final bool isDark;
  @override
  Widget build(BuildContext context) => Divider(
      height: 1, indent: 16, endIndent: 16,
      color: isDark ? AppColors.darkBorder : AppColors.lightBorder);
}
