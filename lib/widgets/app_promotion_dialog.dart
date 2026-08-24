import 'dart:ui';

import 'package:flutter/material.dart';

import '../services/promo_dialog_service.dart';

/// Elegant in-app cross promotion dialog (App Promotion Dialog).
///
/// Shows a centered rounded card with:
///  * a circular app icon at the top center with a gradient ring,
///  * the app name and a small "recommended" badge,
///  * the key features as a tidy bullet list,
///  * a primary gradient install button that opens Google Play,
///  * an (X) close button in the top corner and a "لاحقاً" button below.
class AppPromotionDialog extends StatelessWidget {
  const AppPromotionDialog({super.key, required this.app, this.onClose});

  final PromoAppInfo app;
  final VoidCallback? onClose;

  void _close(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
    onClose?.call();
  }

  Future<void> _install(BuildContext context) async {
    await PromoDialogService.openStorePage(app);
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color cardColor = isDark ? const Color(0xFF1E1E2E) : Colors.white;
    final Color textColor = isDark ? const Color(0xFFF3F4F6) : const Color(0xFF111827);
    final Color subtitleColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF374151);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // ── Card ──────────────────────────────────────────────
              Material(
                color: Colors.transparent,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: app.primary.withOpacity(0.14),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.30),
                        blurRadius: 38,
                        offset: const Offset(0, 18),
                        spreadRadius: -8,
                      ),
                      BoxShadow(
                        color: app.primary.withOpacity(0.16),
                        blurRadius: 60,
                        offset: const Offset(0, 26),
                        spreadRadius: -14,
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Soft tinted header area behind the icon.
                        Container(
                          width: double.infinity,
                          height: 64,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                app.softTint.withOpacity(isDark ? 0.10 : 1.0),
                                cardColor.withOpacity(0.0),
                              ],
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(28),
                              topRight: Radius.circular(28),
                            ),
                          ),
                        ),
                        const SizedBox(height: 44), // icon overlap space
                        // ── App name ──
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            app.name,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: textColor,
                              height: 1.3,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // ── Recommended badge ──
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: app.softTint.withOpacity(isDark ? 0.16 : 1.0),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: app.primary.withOpacity(0.35),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified_outlined,
                                  size: 15, color: app.primary),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  'تطبيق موصى به لك',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: app.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        // ── Divider ──
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                app.primary.withOpacity(0.28),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // ── Features ──
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              for (int i = 0; i < app.features.length; i++)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 11),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        margin:
                                            const EdgeInsets.only(top: 1.5),
                                        decoration: BoxDecoration(
                                          color: app.softTint.withOpacity(
                                              isDark ? 0.20 : 1.0),
                                          shape: BoxShape.circle,
                                        ),
                                        padding: const EdgeInsets.all(3),
                                        child: Icon(
                                          Icons.check_rounded,
                                          size: 14,
                                          color: app.primary,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          app.features[i],
                                          style: TextStyle(
                                            fontSize: 13.2,
                                            height: 1.45,
                                            color: subtitleColor,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        // ── Install button ──
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 22),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [app.primary, app.primaryDark],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: app.primary.withOpacity(0.38),
                                  blurRadius: 18,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () => _install(context),
                                child: SizedBox(
                                  height: 52,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.download_rounded,
                                          color: Colors.white, size: 22),
                                      const SizedBox(width: 9),
                                      Flexible(
                                        child: Text(
                                          app.ctaText,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // ── Later button ──
                        TextButton(
                          onPressed: () => _close(context),
                          style: TextButton.styleFrom(
                            foregroundColor: subtitleColor.withOpacity(0.8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                          ),
                          child: const Text(
                            'لاحقاً',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
              // ── Circular app icon (top center, overlapping the card) ──
              Positioned(
                top: -44,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [app.primary, app.primaryDark],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: app.primary.withOpacity(0.45),
                          blurRadius: 26,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: ClipOval(
                        child: SizedBox(
                          width: 78,
                          height: 78,
                          child: Image.asset(
                            app.iconAsset,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: app.softTint,
                              child: Icon(Icons.apps_rounded,
                                  size: 40, color: app.primary),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // ── X close button (top corner) ──
              PositionedDirectional(
                top: 10,
                end: 10,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: () => _close(context),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (isDark ? Colors.white : Colors.black)
                            .withOpacity(0.06),
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 19,
                        color: subtitleColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
