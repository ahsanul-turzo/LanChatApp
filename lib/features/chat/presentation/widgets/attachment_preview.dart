import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/utils/file_utils.dart';
import '../../../chat/domain/entities/attachment.dart';

class AttachmentPreview extends StatelessWidget {
  final Attachment attachment;
  final VoidCallback? onRemove;

  const AttachmentPreview({super.key, required this.attachment, this.onRemove});

  IconData _getFileIcon() {
    switch (attachment.type) {
      case AttachmentType.image:
        return Icons.image;
      case AttachmentType.video:
        return Icons.video_file;
      case AttachmentType.document:
        return Icons.description;
      case AttachmentType.other:
        return Icons.insert_drive_file;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          Icon(_getFileIcon(), size: 32, color: Theme.of(context).primaryColor),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  attachment.fileName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Gap(2),
                Text(FileUtils.formatFileSize(attachment.fileSize), style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          if (onRemove != null) ...[
            const Gap(8),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: onRemove,
              iconSize: 20,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ],
      ),
    );
  }
}
