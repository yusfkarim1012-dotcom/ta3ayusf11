import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/app_promotion_dialog.dart';

/// Data model describing a promoted (recommended) app shown in the
/// in-app cross promotion dialog.
class PromoAppInfo {
  const PromoAppInfo({
    required this.name,
    required this.iconAsset,
    required this.features,
    required this.storeUrl,
    required this.marketUrl,
    required this.ctaText,
    required this.primary,
    required this.primaryDark,
    required this.softTint,
  });

  final String name;
  final String iconAsset;
  final List<String> features;
  final String storeUrl;
  final String marketUrl;
  final String ctaText;
  final Color primary;
  final Color primaryDark;
  final Color softTint;
}

/// Service that owns the rotation logic of the promotion dialog.
///
/// The dialog alternates between the promoted apps on every app launch:
/// first launch shows the first app, next launch shows the second app,
/// and so on (the rotation index is persisted via [SharedPreferences]).
class PromoDialogService {
  PromoDialogService._();

  static const String _rotationKey = 'app_promo_rotation_index';

  /// The promoted apps, in rotation order.
  static const List<PromoAppInfo> promotedApps = [
    PromoAppInfo(
      name: 'My Prayers - صلاتي وأذكاري',
      iconAsset: 'assets/images/promo_my_prayers_icon.jpg',
      features: [
        'مواقيت صلاة دقيقة حسب موقعك مع تنبيهات الأذان',
        'بوصلة دقيقة لتحديد اتجاه القبلة أينما كنت',
        'المسبحة الإلكترونية وأذكار الصباح والمساء والورد اليومي',
        'واجهة عصرية وسريعة خفيفة على موارد الجهاز',
      ],
      storeUrl:
          'https://play.google.com/store/apps/details?id=com.yusuf.alkurdi',
      marketUrl: 'market://details?id=com.yusuf.alkurdi',
      ctaText: 'تثبيت التطبيق الآن مجاناً',
      primary: const Color(0xFF10B981),
      primaryDark: const Color(0xFF0D9488),
      softTint: const Color(0xFFECFDF5),
    ),
    PromoAppInfo(
      name: 'UltraBlock X by LaAbRah',
      iconAsset: 'assets/images/promo_ultrablock_icon.jpg',
      features: [
        'حجب المواقع غير اللائقة والإباحية والضارة',
        'حظر التطبيقات وتحديد أوقات الاستخدام للحد من التشتت',
        'حماية فورية على مستوى الجهاز وتصفية الكلمات الحساسة',
        'تطبيق آمن، سريع، وخفيف على البطارية',
      ],
      storeUrl:
          'https://play.google.com/store/apps/details?id=com.familyshield.protection',
      marketUrl: 'market://details?id=com.familyshield.protection',
      ctaText: 'تثبيت التطبيق الآن مجاناً',
      primary: const Color(0xFF4F46E5),
      primaryDark: const Color(0xFF3730A3),
      softTint: const Color(0xFFEEF2FF),
    ),
  ];

  /// Returns the app that should be shown on the current launch and
  /// persists the next rotation index.
  static Future<PromoAppInfo> getNextPromoApp() async {
    final prefs = await SharedPreferences.getInstance();
    final int index = prefs.getInt(_rotationKey) ?? 0;
    final PromoAppInfo app = promotedApps[index % promotedApps.length];
    await prefs.setInt(_rotationKey, index + 1);
    return app;
  }

  /// Shows the promotion dialog for the app in turn. Intended to be
  /// called once per app launch. Never throws: any failure (for example
  /// storage unavailable) is swallowed so the app flow is never broken.
  static Future<void> showOnAppOpen(BuildContext context) async {
    try {
      final PromoAppInfo app = await getNextPromoApp();
      if (!context.mounted) return;
      await showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: ' promo',
        barrierColor: Colors.black.withOpacity(0.55),
        transitionDuration: const Duration(milliseconds: 320),
        transitionBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.90, end: 1.0).animate(curved),
              child: child,
            ),
          );
        },
        pageBuilder: (context, animation, secondaryAnimation) {
          return AppPromotionDialog(app: app);
        },
      );
    } catch (e) {
      debugPrint('Promo dialog skipped: $e');
    }
  }

  /// Opens the store page of [app], preferring the native Play Store
  /// app (market:// intent) and falling back to the browser URL.
  static Future<void> openStorePage(PromoAppInfo app) async {
    final Uri marketUri = Uri.parse(app.marketUrl);
    try {
      if (await canLaunchUrl(marketUri)) {
        await launchUrl(marketUri, mode: LaunchMode.externalApplication);
        return;
      }
    } catch (_) {
      // Fall through to the https fallback below.
    }
    try {
      await launchUrl(
        Uri.parse(app.storeUrl),
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      debugPrint('Could not open store page: $e');
    }
  }
}
