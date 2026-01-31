import 'package:get/get.dart';
import 'package:lan_chat_app/features/discovery/presentation/pages/conversations_page.dart';
import 'package:lan_chat_app/features/profile/presentation/pages/profile_setup_page.dart';

import '../features/chat/presentation/controllers/chat_controller.dart';
import '../features/chat/presentation/controllers/conversation_controller.dart';
import '../features/chat/presentation/pages/chat_page.dart';
import '../features/discovery/presentation/controllers/discovery_controller.dart';
import '../features/discovery/presentation/pages/discovery_page.dart';
import '../features/profile/presentation/controllers/profile_controller.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.initial,
      page: () => const ProfileSetupPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ProfileController>(() => ProfileController());
      }),
    ),
    GetPage(
      name: AppRoutes.profileSetup,
      page: () => const ProfileSetupPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ProfileController>(() => ProfileController());
      }),
    ),
    GetPage(
      name: AppRoutes.discovery,
      page: () => const DiscoveryPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<DiscoveryController>(() => DiscoveryController());
      }),
    ),
    GetPage(
      name: AppRoutes.conversations,
      page: () => const ConversationsPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ConversationController>(() => ConversationController());
      }),
    ),
    GetPage(
      name: AppRoutes.chat,
      page: () => const ChatPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ChatController>(() => ChatController());
      }),
    ),
  ];
}
