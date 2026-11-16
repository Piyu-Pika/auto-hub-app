import 'package:auto_hub_app/core/network/api_endpoints.dart';
import 'package:auto_hub_app/injection.dart';
import 'package:dio/dio.dart';
import 'package:auto_hub_app/core/widgets/app_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Native Flutter HiTech Insurance widget demo for AutoHub.
class HiTechInsuranceWidget extends StatelessWidget {
  const HiTechInsuranceWidget({
    super.key,
    this.utmSource = 'autohub_mobile_app',
    this.isDark = true,
  });

  final String utmSource;
  final bool isDark;

  Future<void> _launchHiTech() async {
    // Send partner referral tracking to AutoHub Customer API
    try {
      if (getIt.isRegistered<Dio>()) {
        await getIt<Dio>().post<dynamic>(
          ApiEndpoints.referralsTrack,
          data: {
            'partner': 'hitech',
            'utmSource': utmSource,
            'utmMedium': 'flutter_widget',
            'utmCampaign': 'partner_referral',
          },
        );
      }
    } catch (_) {}

    final uri = Uri.parse(
      'https://hitechinsurance.ai/'
      '?utm_source=$utmSource'
      '&utm_medium=flutter_widget'
      '&utm_campaign=partner_referral',
    );
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $uri');
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _launchHiTech,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF0B1120), const Color(0xFF0F172A)]
                : [const Color(0xFFFFFFFF), const Color(0xFFF8FAFC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: isDark
                ? const Color(0x20FFFFFF)
                : const Color(0x30CBD5E1),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? const Color(0x40000000)
                  : const Color(0x10000000),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark
                      ? const Color(0x25FFFFFF)
                      : const Color(0x15000000),
                ),
              ),
              child: AppImage(
                imagePath: 'https://hitechinsurance.ai/widget-mark.png',
                fit: BoxFit.contain,
                errorWidget: const Icon(
                  Icons.shield,
                  color: Color(0xFFFF763C),
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          'HiTech Insurance',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0x25FF763C),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0x50FF763C)),
                        ),
                        child: const Text(
                          'VERIFIED',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFFF763C),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Smart Coverage for Every Need • Auto, Commercial & Life',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF763C), Color(0xFFFF5722)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x40FF763C),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Get Quote',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
