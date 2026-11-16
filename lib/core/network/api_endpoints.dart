/// All API endpoint paths for AutoHub Customer API (/v1).
abstract final class ApiEndpoints {
  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String social = '/auth/social';
  static const String session = '/auth/session';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';

  // Account
  static const String userMe = '/users/me';
  static const String userAvatar = '/users/me/avatar';
  static const String userPassword = '/users/me/password';
  static const String userDeletion = '/users/me/deletion-request';
  static const String userSearchHistory = '/users/me/search-history';
  static const String userVehicles = '/users/me/vehicles';

  // Settings
  static const String settings = '/settings';
  static const String settingsLanguages = '/settings/languages';

  // Addresses
  static const String addresses = '/addresses';
  static String addressById(String id) => '/addresses/$id';
  static String addressDefault(String id) => '/addresses/$id/default';

  // Payment Methods
  static const String paymentMethods = '/payment-methods';
  static String paymentMethodById(String id) => '/payment-methods/$id';
  static String paymentMethodDefault(String id) => '/payment-methods/$id/default';

  // Parts Catalog
  static const String parts = '/parts';
  static const String partsFilterOptions = '/parts/filter-options';
  static const String partsFitments = '/parts/fitments';
  static String partById(String id) => '/parts/$id';
  static String partSimilar(String id) => '/parts/$id/similar';
  static String partFavorite(String id) => '/parts/$id/favorite';

  // Saved Parts (Wishlist)
  static const String savedParts = '/saved-parts';
  static String savedPartById(String partId) => '/saved-parts/$partId';

  // Home Feed
  static const String homeFeed = '/home/feed';
  static const String homeHeroBanner = '/home/hero-banner';
  static const String homeStats = '/home/stats';
  static const String categories = '/categories';
  static const String homeJunkBanner = '/home/junk-banner';
  static const String homeTrustStrip = '/home/trust-strip';

  // VIN
  static const String vinDecode = '/vin/decode';

  // Cart & Checkout
  static const String cart = '/cart';
  static const String cartItems = '/cart/items';
  static String cartItemById(String cartItemId) => '/cart/items/$cartItemId';
  static const String checkoutOrders = '/checkout/orders';

  // Orders
  static const String orders = '/orders';
  static String orderById(String id) => '/orders/$id';
  static String orderCancel(String id) => '/orders/$id/cancel';
  static String orderTracking(String id) => '/orders/$id/tracking';
  static String orderReorder(String id) => '/orders/$id/reorder';
  static String orderRate(String id) => '/orders/$id/rate';
  static String orderReturn(String id) => '/orders/$id/return';

  // Junk Requests
  static const String junkQuote = '/junk-requests/quote';
  static const String junkRequests = '/junk-requests';
  static String junkRequestById(String id) => '/junk-requests/$id';
  static String junkRequestAcceptOffer(String id) => '/junk-requests/$id/accept-offer';
  static String junkRequestPickupSchedule(String id) =>
      '/junk-requests/$id/pickup-schedule';
  static String junkRequestCancel(String id) => '/junk-requests/$id/cancel';
  static const String uploadVehicleImages = '/uploads/vehicle-images';

  // Chat & Messaging
  static const String chatRooms = '/chats/rooms';
  static String chatRoomById(String roomId) => '/chats/rooms/$roomId';
  static String chatMessages(String roomId) => '/chats/rooms/$roomId/messages';
  static String chatRead(String roomId) => '/chats/rooms/$roomId/read';
  static const String chatUnreadCount = '/chats/unread-count';
  static String chatAttachments(String roomId) =>
      '/chats/rooms/$roomId/attachments';

  // Help & Support
  static const String helpCategories = '/help/categories';
  static const String helpArticles = '/help/articles';
  static String helpArticleById(String id) => '/help/articles/$id';
  static const String supportTickets = '/support/tickets';
  static String supportTicketById(String id) => '/support/tickets/$id';
  static const String supportAttachments = '/support/attachments';
  static const String supportCallback = '/support/callback-request';

  // Meta & Analytics
  static const String analyticsEvents = '/analytics/events';
  static const String referralsTrack = '/referrals/track';
  static const String appConfig = '/app/config';
}
