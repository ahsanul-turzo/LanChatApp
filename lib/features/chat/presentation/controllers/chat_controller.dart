import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';

import '../../../../core/utils/encryption_utils.dart';
import '../../../../core/utils/file_utils.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';
import '../../domain/entities/attachment.dart';
import '../../domain/entities/message.dart';
import '../../domain/usecases/receive_message.dart';
import '../../domain/usecases/send_file.dart';
import '../../domain/usecases/send_message.dart';

class ChatController extends GetxController {
  final SendMessage _sendMessage = Get.find();
  final ReceiveMessage _receiveMessage = Get.find();
  final SendFile _sendFile = Get.find();
  final ProfileController _profileController = Get.find();

  final RxList<Message> _messages = <Message>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _isSending = false.obs;
  final RxString _error = ''.obs;
  final Rx<String?> _currentPeerId = Rx<String?>(null);
  final Rx<String?> _currentPeerName = Rx<String?>(null);

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading.value;
  bool get isSending => _isSending.value;
  String get error => _error.value;
  String? get currentPeerName => _currentPeerName.value;

  StreamSubscription<Message>? _messageSubscription;

  @override
  void onInit() {
    super.onInit();
    _setupMessageListener();
    _loadArgumentsFromRoute();
  }

  @override
  void onClose() {
    _messageSubscription?.cancel();
    super.onClose();
  }

  void _loadArgumentsFromRoute() {
    final args = Get.arguments;
    if (args != null) {
      if (args is Map<String, dynamic>) {
        _currentPeerId.value = args['peerId'] as String?;
        _currentPeerName.value = args['peerName'] as String?;
      } else {
        _currentPeerId.value = args.id as String?;
        _currentPeerName.value = args.userName as String?;
      }
    }
  }

  void _setupMessageListener() {
    _messageSubscription = _receiveMessage().listen(
      (message) {
        if (message.senderId == _currentPeerId.value) {
          _messages.add(message);
          _sortMessages();
        }
      },
      onError: (error) {
        _error.value = 'Error receiving message: $error';
      },
    );
  }

  Future<void> sendTextMessage(String content) async {
    if (content.trim().isEmpty) return;
    if (_currentPeerId.value == null) {
      _error.value = 'No peer selected';
      return;
    }

    _isSending.value = true;
    _error.value = '';

    final message = Message(
      id: EncryptionUtils.generateMessageId(),
      senderId: _profileController.profile?.id ?? 'unknown',
      receiverId: _currentPeerId.value!,
      content: content,
      type: MessageType.text,
      timestamp: DateTime.now(),
      status: MessageStatus.sending,
    );

    _messages.add(message);
    _sortMessages();

    final result = await _sendMessage(message);

    result.fold(
      (failure) {
        _error.value = failure.message;
        _updateMessageStatus(message.id, MessageStatus.failed);
      },
      (sentMessage) {
        _updateMessageStatus(message.id, MessageStatus.sent);
      },
    );

    _isSending.value = false;
  }

  Future<void> sendImageMessage() async {
    if (_currentPeerId.value == null) {
      _error.value = 'No peer selected';
      return;
    }

    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.image, allowMultiple: false);

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      await _sendFileMessage(file, MessageType.image);
    } catch (e) {
      _error.value = 'Failed to pick image: $e';
    }
  }

  Future<void> sendFileMessage() async {
    if (_currentPeerId.value == null) {
      _error.value = 'No peer selected';
      return;
    }

    try {
      final result = await FilePicker.platform.pickFiles(allowMultiple: false);

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      await _sendFileMessage(file, MessageType.file);
    } catch (e) {
      _error.value = 'Failed to pick file: $e';
    }
  }

  Future<void> _sendFileMessage(PlatformFile file, MessageType type) async {
    _isSending.value = true;
    _error.value = '';

    final message = Message(
      id: EncryptionUtils.generateMessageId(),
      senderId: _profileController.profile?.id ?? 'unknown',
      receiverId: _currentPeerId.value!,
      content: file.name,
      type: type,
      timestamp: DateTime.now(),
      status: MessageStatus.sending,
      attachmentName: file.name,
      attachmentSize: file.size,
    );

    final attachment = Attachment(
      id: EncryptionUtils.generateMessageId(),
      fileName: file.name,
      filePath: file.path ?? '',
      fileSize: file.size,
      mimeType: FileUtils.getMimeType(file.name),
      type: type == MessageType.image ? AttachmentType.image : AttachmentType.document,
      createdAt: DateTime.now(),
    );

    _messages.add(message);
    _sortMessages();

    final result = await _sendFile(message, attachment);

    result.fold(
      (failure) {
        _error.value = failure.message;
        _updateMessageStatus(message.id, MessageStatus.failed);
      },
      (sentMessage) {
        _updateMessageStatus(message.id, MessageStatus.sent);
      },
    );

    _isSending.value = false;
  }

  void _updateMessageStatus(String messageId, MessageStatus status) {
    final index = _messages.indexWhere((msg) => msg.id == messageId);
    if (index >= 0) {
      _messages[index] = _messages[index].copyWith(status: status);
      _messages.refresh();
    }
  }

  void _sortMessages() {
    _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  void clearError() {
    _error.value = '';
  }
}
