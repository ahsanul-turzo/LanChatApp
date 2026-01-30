import 'package:get/get.dart';

import '../../domain/entities/conversation.dart';
import '../../domain/usecases/get_conversations.dart';

class ConversationController extends GetxController {
  final GetConversations _getConversations = Get.find();

  final RxList<Conversation> _conversations = <Conversation>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;

  List<Conversation> get conversations => _conversations;
  bool get isLoading => _isLoading.value;
  String get error => _error.value;

  @override
  void onInit() {
    super.onInit();
    loadConversations();
  }

  Future<void> loadConversations() async {
    _isLoading.value = true;
    _error.value = '';

    final result = await _getConversations();

    result.fold(
      (failure) {
        _error.value = failure.message;
        _isLoading.value = false;
      },
      (conversations) {
        _conversations.value = conversations;
        _isLoading.value = false;
      },
    );
  }

  Future<void> refresh() async {
    await loadConversations();
  }

  void openChat(Conversation conversation) {
    Get.toNamed('/chat', arguments: conversation);
  }

  void clearError() {
    _error.value = '';
  }
}
