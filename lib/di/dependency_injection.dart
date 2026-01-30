import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:lan_chat_app/features/discovery/data/datasources/discovery_local_datasource.dart';
import 'package:lan_chat_app/features/discovery/data/datasources/discovery_remote_datasource.dart';
import 'package:lan_chat_app/features/discovery/data/repositories/discovery_repository_impl.dart';

import '../core/network/network_discovery.dart';
import '../core/network/network_manager.dart';
import '../core/network/socket_service.dart';
import '../features/chat/data/datasources/chat_local_datasource.dart';
import '../features/chat/data/datasources/chat_remote_datasource.dart';
import '../features/chat/data/repositories/chat_repository_impl.dart';
import '../features/chat/domain/repositories/chat_repository.dart';
import '../features/chat/domain/usecases/get_conversations.dart';
import '../features/chat/domain/usecases/receive_message.dart';
import '../features/chat/domain/usecases/send_file.dart';
import '../features/chat/domain/usecases/send_message.dart';
import '../features/discovery/domain/repositories/discovery_repository.dart';
import '../features/discovery/domain/usecases/broadcast_presence.dart';
import '../features/discovery/domain/usecases/scan_network.dart';
import '../features/profile/data/datasources/profile_local_datasource.dart';
import '../features/profile/data/repositories/profile_repository_impl.dart';
import '../features/profile/domain/repositories/profile_repository.dart';
import '../features/profile/domain/usecases/get_profile.dart';
import '../features/profile/domain/usecases/update_profile.dart';
import '../features/profile/presentation/controllers/profile_controller.dart';

class DependencyInjection {
  static Future<void> init() async {
    // Core - Immediate initialization
    Get.put(GetStorage(), permanent: true);
    Get.put(NetworkManager(), permanent: true);
    Get.put(SocketService(), permanent: true);
    Get.put(NetworkDiscovery(), permanent: true);

    // Profile Feature
    _initProfile();

    // Discovery Feature
    _initDiscovery();

    // Chat Feature
    _initChat();
  }

  static void _initProfile() {
    // Data sources
    Get.lazyPut<ProfileLocalDataSource>(() => ProfileLocalDataSourceImpl(Get.find<GetStorage>()));

    // Repositories
    Get.lazyPut<ProfileRepository>(() => ProfileRepositoryImpl(Get.find()));

    // Use cases
    Get.lazyPut(() => GetProfile(Get.find()));
    Get.lazyPut(() => UpdateProfile(Get.find()));

    // Controller
    Get.put(ProfileController(), permanent: true);
  }

  static void _initDiscovery() {
    // Data sources
    Get.lazyPut<DiscoveryLocalDataSource>(() => DiscoveryLocalDataSourceImpl(Get.find<GetStorage>()));
    Get.lazyPut<DiscoveryRemoteDataSource>(
      () => DiscoveryRemoteDataSourceImpl(Get.find<NetworkDiscovery>(), Get.find<NetworkManager>()),
    );

    // Repositories
    Get.lazyPut<DiscoveryRepository>(
      () => DiscoveryRepositoryImpl(localDataSource: Get.find(), remoteDataSource: Get.find()),
    );

    // Use cases
    Get.lazyPut(() => ScanNetwork(Get.find()));
    Get.lazyPut(() => BroadcastPresence(Get.find()));
  }

  static void _initChat() {
    // Data sources
    Get.lazyPut<ChatLocalDataSource>(() => ChatLocalDataSourceImpl(Get.find<GetStorage>()));
    Get.lazyPut<ChatRemoteDataSource>(() => ChatRemoteDataSourceImpl(Get.find<SocketService>()));

    // Repositories
    Get.lazyPut<ChatRepository>(() => ChatRepositoryImpl(localDataSource: Get.find(), remoteDataSource: Get.find()));

    // Use cases
    Get.lazyPut(() => SendMessage(Get.find()));
    Get.lazyPut(() => ReceiveMessage(Get.find()));
    Get.lazyPut(() => SendFile(Get.find()));
    Get.lazyPut(() => GetConversations(Get.find()));
  }
}
