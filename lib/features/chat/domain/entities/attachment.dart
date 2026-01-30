class Attachment {
  final String id;
  final String fileName;
  final String filePath;
  final int fileSize;
  final String mimeType;
  final AttachmentType type;
  final String? thumbnailPath;
  final DateTime createdAt;

  Attachment({
    required this.id,
    required this.fileName,
    required this.filePath,
    required this.fileSize,
    required this.mimeType,
    required this.type,
    this.thumbnailPath,
    required this.createdAt,
  });

  Attachment copyWith({
    String? id,
    String? fileName,
    String? filePath,
    int? fileSize,
    String? mimeType,
    AttachmentType? type,
    String? thumbnailPath,
    DateTime? createdAt,
  }) {
    return Attachment(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      fileSize: fileSize ?? this.fileSize,
      mimeType: mimeType ?? this.mimeType,
      type: type ?? this.type,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

enum AttachmentType { image, video, document, other }
