# Next Steps: Close Whole-App API Integration Gaps

Status: plan (architect review). Data layer is fully wired to live API;
remaining work is UI binding + cleanup. Overall readiness ~85% → target ~98%.

## 1. Bind static Home sections to API feed data (highest priority)
The feed model [`home_feed_model.dart`](lib/features/home/data/models/home_feed_model.dart)
already parses `categories`, `junkBanner`, and `trustItems`, but
[`home_page.dart`](lib/features/home/presentation/pages/home_page.dart) renders these
sections as `const` static widgets, ignoring the API payload.
- `HomeCategorySection` → accept `feed.categories`, render icon/name/partCount.
- `HomeJunkCarBanner` → accept `feed.junkBanner`, use title/subtitle/image/ctaUrl.
- `HomeTrustStrip` → accept `feed.trustItems`, render icon/label items.
- Keep graceful empty state when API returns no data for a section.
- Leave `HomeVinLookup`, `HiTechInsuranceWidget`, `HomeSearchBar`, `HomeAppBar`
  as-is (navigation/static UI, no API payload).

## 2. Remove orphaned mock files (dead code)
None are registered in [`injection.config.dart`](lib/injection.config.dart) nor
referenced by any page. Delete:
- `lib/features/browse/data/repositories/mock_browse_repository.dart`
- `lib/features/payment_methods/data/datasources/mock_payment_data.dart`
- `lib/features/my_order/data/mock_orders_data.dart`
- `lib/features/account_details/data/mock/mock_user_data.dart`
- `lib/features/contact_support/data/repositories/mock_chat_repository.dart`
- `lib/features/your_addresses/data/repositories/mock_address_repository.dart`

## 3. Settings language fallback
[`settings_remote_datasource.dart`](lib/features/settings/data/datasources/settings_remote_datasource.dart:63)
returns a hardcoded en/es list on failure. Change to throw/return empty and show a
UI empty state in `settings_page.dart` instead of silently faking data.

## 4. Verify VIN datasource DI
`VinRemoteDatasourceImpl` is a real external call (NHTSA). Confirm it is provided
consistently (factory/getIt) and not instantiated ad hoc per use site.

## 5. Loading/error/empty-state sweep
Audit every API-backed page (browse, payment, addresses, orders, junk, help, chat,
saved, settings, home, profile, account details) for all three states; fill gaps.

## 6. Tests
- Widget test: `profile_page.dart` renders API name/initials/verified + loading/error/empty.
- Widget test: `home_page.dart` renders feed-driven categories/junk/trust sections.

## 7. Verify
- `flutter analyze` → zero issues.
- `flutter build apk --debug` (or `flutter test`) → green.

## Definition of done
All sections render live API data, no mock/static fallback remains, analyzer clean,
build passes.
