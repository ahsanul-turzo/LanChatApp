import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/file_utils.dart';
import '../../../chat/domain/entities/message.dart';

class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({super.key, required this.message});

  bool get isSentByMe {
    // This is a simplified check - in real app, compare with current user ID
    return message.status != MessageStatus.delivered && message.status != MessageStatus.read;
  }

  String _formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  Widget _buildStatusIcon(BuildContext context) {
    switch (message.status) {
      case MessageStatus.sending:
        return const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 1.5));
      case MessageStatus.sent:
        return const Icon(Icons.check, size: 16);
      case MessageStatus.delivered:
        return const Icon(Icons.done_all, size: 16);
      case MessageStatus.read:
        return Icon(Icons.done_all, size: 16, color: Theme.of(context).primaryColor);
      case MessageStatus.failed:
        return Icon(Icons.error_outline, size: 16, color: Theme.of(context).colorScheme.error);
    }
  }

  Widget _buildMessageContent(BuildContext context) {
    switch (message.type) {
      case MessageType.text:
        return Text(
          message.content,
          style: TextStyle(
            color: isSentByMe
                ? Colors.black87
                : Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black87,
          ),
        );

      case MessageType.image:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              constraints: const BoxConstraints(maxWidth: 250),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Icon(Icons.image, size: 64, color: Theme.of(context).primaryColor),
                  const Gap(8),
                  Text(message.attachmentName ?? 'Image', style: const TextStyle(fontSize: 12)),
                  if (message.attachmentSize != null)
                    Text(FileUtils.formatFileSize(message.attachmentSize!), style: const TextStyle(fontSize: 10)),
                ],
              ),
            ),
          ],
        );

      case MessageType.file:
        return Container(
          constraints: const BoxConstraints(maxWidth: 250),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
          child: Row(
            children: [
              Icon(Icons.insert_drive_file, size: 32, color: Theme.of(context).primaryColor),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.attachmentName ?? 'File',
                      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (message.attachmentSize != null)
                      Text(FileUtils.formatFileSize(message.attachmentSize!), style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        );

      case MessageType.typing:
        return const Text('Typing...');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isSentByMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.person, size: 16, color: Colors.white),
            ),
            const Gap(8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSentByMe
                    ? (isDark ? AppColors.messageSentDark : AppColors.messageSent)
                    : (isDark ? AppColors.messageReceivedDark : AppColors.messageReceived),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(12),
                  topRight: const Radius.circular(12),
                  bottomLeft: Radius.circular(isSentByMe ? 12 : 4),
                  bottomRight: Radius.circular(isSentByMe ? 4 : 12),
                ),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 2, offset: const Offset(0, 1)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMessageContent(context),
                  const Gap(4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(message.timestamp),
                        style: TextStyle(
                          fontSize: 10,
                          color: isSentByMe
                              ? Colors.black54
                              : Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                        ),
                      ),
                      if (isSentByMe) ...[const Gap(4), _buildStatusIcon(context)],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
