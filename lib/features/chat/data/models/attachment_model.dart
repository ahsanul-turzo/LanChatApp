import '../../domain/entities/attachment.dart';

class AttachmentModel extends Attachment {
  AttachmentModel({
    required super.id,
    required super.fileName,
    required super.filePath,
    required super.fileSize,
    required super.mimeType,
    required super.type,
    super.thumbnailPath,
    required super.createdAt,
  });

  factory AttachmentModel.fromJson(Map<String, dynamic> json) {
    return AttachmentModel(
      id: json['id'] as String,
      fileName: json['fileName'] as String,
      filePath: json['filePath'] as String,
      fileSize: json['fileSize'] as int,
      mimeType: json['mimeType'] as String,
      type: AttachmentType.values.firstWhere((e) => e.name == json['type'], orElse: () => AttachmentType.other),
      thumbnailPath: json['thumbnailPath'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileName': fileName,
      'filePath': filePath,
      'fileSize': fileSize,
      'mimeType': mimeType,
      'type': type.name,
      'thumbnailPath': thumbnailPath,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AttachmentModel.fromEntity(Attachment entity) {
    return AttachmentModel(
      id: entity.id,
      fileName: entity.fileName,
      filePath: entity.filePath,
      fileSize: entity.fileSize,
      mimeType: entity.mimeType,
      type: entity.type,
      thumbnailPath: entity.thumbnailPath,
      createdAt: entity.createdAt,
    );
  }

  Attachment toEntity() {
    return Attachment(
      id: id,
      fileName: fileName,
      filePath: filePath,
      fileSize: fileSize,
      mimeType: mimeType,
      type: type,
      thumbnailPath: thumbnailPath,
      createdAt: createdAt,
    );
  }
}
