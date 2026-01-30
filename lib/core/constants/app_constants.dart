class AppConstants {
  // App Info
  static const String appName = 'LAN Chat';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String storageKeyProfile = 'user_profile';
  static const String storageKeyTheme = 'theme_mode';
  static const String storageKeyConversations = 'conversations';

  // Database
  static const String storageKeyMessages = 'messages_store';
  static const String storageKeyPeers = 'peers_store';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 10);
  static const Duration messageTimeout = Duration(seconds: 5);
  static const Duration scanInterval = Duration(seconds: 3);

  // File limits
  static const int maxFileSize = 50 * 1024 * 1024; // 50MB
  static const int maxImageSize = 10 * 1024 * 1024; // 10MB
}
