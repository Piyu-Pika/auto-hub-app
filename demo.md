I cannot access your local Autohub codebase or generate a screenshot of your emulator. To get that screenshot for your team, you can drop this native Flutter widget directly into one of your existing screens, capture the device screen, and then immediately remove the code.

### 1. Add the Dependency

Ensure the URL launcher is in your `pubspec.yaml` to handle the external routing:

```yaml
dependencies:
  url_launcher: ^6.3.0

```

### 2. Add the Widget Code

Create a temporary file (e.g., `hitech_widget.dart`) and paste this pure Dart implementation. The tracking tag has been automatically updated to track Autohub:

```dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HiTechInsuranceWidget extends StatelessWidget {
  final String utmSource;
  final bool isDark;

  const HiTechInsuranceWidget({
    Key? key,
    this.utmSource = 'autohub_mobile_app',
    this.isDark = true,
  }) : super(key: key);

  Future<void> _launchHiTech() async {
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
            width: 1,
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
              child: Image.network(
                'https://hitechinsurance.ai/widget-mark.png',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
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
                      Text(
                        'HiTech Insurance',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                  Icon(Icons.arrow_forward_rounded, size: 14, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

```

### 3. Render it in Autohub

Import the widget into whatever screen you want to test and drop it inside a layout block like a `Column` or `ListView`:

```dart
// Drop this into your layout
HiTechInsuranceWidget(
  utmSource: 'autohub_mobile_app',
  isDark: true, // Set to false if Autohub has a white background
),

```

Once you run this code, the widget will render at 60 FPS without relying on a web view. You can then capture the screenshot and revert the changes to clear it out.