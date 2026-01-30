import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:lan_chat_app/features/chat/presentation/controllers/conversation_controller.dart';
import 'package:lan_chat_app/features/chat/presentation/widgets/conversation_item.dart';

import '../../../../routes/app_routes.dart';

class ConversationsPage extends StatelessWidget {
  const ConversationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ConversationController controller = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.devices),
            onPressed: () => Get.offAllNamed(AppRoutes.discovery),
            tooltip: 'Discover Devices',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.error.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 64, color: Theme.of(context).colorScheme.error),
                const Gap(16),
                Text(
                  controller.error,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                  textAlign: TextAlign.center,
                ),
                const Gap(16),
                ElevatedButton(onPressed: controller.refresh, child: const Text('Retry')),
              ],
            ),
          );
        }

        if (controller.conversations.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.chat_bubble_outline, size: 64, color: Theme.of(context).disabledColor),
                const Gap(16),
                Text('No conversations yet', style: Theme.of(context).textTheme.titleMedium),
                const Gap(8),
                Text(
                  'Start chatting with devices on your network',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const Gap(16),
                ElevatedButton.icon(
                  onPressed: () => Get.offAllNamed(AppRoutes.discovery),
                  icon: const Icon(Icons.devices),
                  label: const Text('Find Devices'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refresh,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: controller.conversations.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final conversation = controller.conversations[index];
              return ConversationItem(conversation: conversation, onTap: () => controller.openChat(conversation));
            },
          ),
        );
      }),
    );
  }
}
