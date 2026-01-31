import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/file_utils.dart';
import '../../../chat/domain/entities/message.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final String currentUserId;

  const MessageBubble({
    super.key,
    required this.message,
    required this.currentUserId,
  });

  bool get isSentByMe => message.senderId == currentUserId;

  String _formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  Widget _buildStatusIcon(BuildContext context) {
    switch (message.status) {
      case MessageStatus.sending:
        return const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 1.5));
      case MessageStatus.sent:
        return const Icon(Icons.check, size: 14, color: Colors.white70);
      case MessageStatus.delivered:
        return const Icon(Icons.done_all, size: 14, color: Colors.white70);
      case MessageStatus.read:
        return const Icon(Icons.done_all, size: 14, color: Colors.lightBlueAccent);
      case MessageStatus.failed:
        return Icon(Icons.error_outline, size: 14, color: Theme.of(context).colorScheme.error);
    }
  }

  Widget _buildMessageContent(BuildContext context) {
    final textColor = isSentByMe ? Colors.white : AppColors.textPrimary;

    switch (message.type) {
      case MessageType.text:
        return Text(
          message.content,
          style: TextStyle(
            color: textColor,
            fontSize: 15,
            height: 1.3,
          ),
        );

      case MessageType.image:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              constraints: const BoxConstraints(maxWidth: 250),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Icon(Icons.image, size: 48, color: isSentByMe ? Colors.white70 : AppColors.primary),
                  const Gap(8),
                  Text(
                    message.attachmentName ?? 'Image',
                    style: TextStyle(fontSize: 13, color: textColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (message.attachmentSize != null)
                    Text(
                      FileUtils.formatFileSize(message.attachmentSize!),
                      style: TextStyle(fontSize: 11, color: textColor.withValues(alpha: 0.7)),
                    ),
                ],
              ),
            ),
          ],
        );

      case MessageType.file:
        return Container(
          constraints: const BoxConstraints(maxWidth: 280),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSentByMe ? Colors.white24 : AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.insert_drive_file,
                  size: 28,
                  color: isSentByMe ? Colors.white : AppColors.primary,
                ),
              ),
              const Gap(12),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.attachmentName ?? 'File',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: textColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (message.attachmentSize != null)
                      Text(
                        FileUtils.formatFileSize(message.attachmentSize!),
                        style: TextStyle(fontSize: 12, color: textColor.withValues(alpha: 0.7)),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );

      case MessageType.typing:
        return Text('Typing...', style: TextStyle(color: textColor, fontStyle: FontStyle.italic));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisAlignment: isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isSentByMe) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.person, size: 14, color: Colors.white),
            ),
            const Gap(8),
          ],
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 320),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isSentByMe ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isSentByMe ? 16 : 4),
                  bottomRight: Radius.circular(isSentByMe ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _buildMessageContent(context),
                  ),
                  const Gap(4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(message.timestamp),
                        style: TextStyle(
                          fontSize: 11,
                          color: isSentByMe ? Colors.white70 : AppColors.textSecondary,
                        ),
                      ),
                      if (isSentByMe) ...[
                        const Gap(4),
                        _buildStatusIcon(context),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isSentByMe) const Gap(8),
        ],
      ),
    );
  }
}
