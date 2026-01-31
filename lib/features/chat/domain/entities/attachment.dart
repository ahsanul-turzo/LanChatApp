import 'dart:typed_data';

class Attachment {
  final String id;
  final String fileName;
  final String? filePath;
  final Uint8List? fileBytes;
  final int fileSize;
  final String mimeType;
  final AttachmentType type;
  final String? thumbnailPath;
  final DateTime createdAt;

  Attachment({
    required this.id,
    required this.fileName,
    this.filePath,
    this.fileBytes,
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
    Uint8List? fileBytes,
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
      fileBytes: fileBytes ?? this.fileBytes,
      fileSize: fileSize ?? this.fileSize,
      mimeType: mimeType ?? this.mimeType,
      type: type ?? this.type,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

enum AttachmentType { image, video, document, other }
