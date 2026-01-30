import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '../controllers/chat_controller.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ChatController controller = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(controller.currentPeerName ?? 'Chat', style: const TextStyle(fontSize: 18)),
              const Text('Online', style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () {
              Get.snackbar(
                'Coming Soon',
                'Video call feature will be available soon',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            tooltip: 'Video Call',
          ),
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () {
              Get.snackbar(
                'Coming Soon',
                'Voice call feature will be available soon',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            tooltip: 'Voice Call',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'clear') {
                Get.defaultDialog(
                  title: 'Clear Chat',
                  middleText: 'Are you sure you want to clear this chat?',
                  textConfirm: 'Clear',
                  textCancel: 'Cancel',
                  confirmTextColor: Colors.white,
                  onConfirm: () {
                    Get.back();
                    Get.snackbar('Success', 'Chat cleared', snackPosition: SnackPosition.BOTTOM);
                  },
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear',
                child: Row(children: [Icon(Icons.delete_outline), Gap(8), Text('Clear Chat')]),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Obx(() {
            if (controller.error.isNotEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error, size: 20),
                    const Gap(8),
                    Expanded(
                      child: Text(
                        controller.error,
                        style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: controller.clearError,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          Expanded(
            child: Obx(() {
              if (controller.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.messages.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.chat_bubble_outline, size: 64, color: Theme.of(context).disabledColor),
                      const Gap(16),
                      Text('No messages yet', style: Theme.of(context).textTheme.titleMedium),
                      const Gap(8),
                      Text(
                        'Send a message to start the conversation',
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                reverse: false,
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  final message = controller.messages[index];
                  return MessageBubble(message: message);
                },
              );
            }),
          ),
          MessageInput(
            onSendText: controller.sendTextMessage,
            onSendImage: controller.sendImageMessage,
            onSendFile: controller.sendFileMessage,
          ),
        ],
      ),
    );
  }
}
