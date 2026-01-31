import 'dart:convert';
import 'dart:typed_data';

import '../../domain/entities/attachment.dart';

class AttachmentModel extends Attachment {
  AttachmentModel({
    required super.id,
    required super.fileName,
    super.filePath,
    super.fileBytes,
    required super.fileSize,
    required super.mimeType,
    required super.type,
    super.thumbnailPath,
    required super.createdAt,
  });

  factory AttachmentModel.fromJson(Map<String, dynamic> json) {
    Uint8List? bytes;
    if (json['fileData'] != null) {
      bytes = base64Decode(json['fileData'] as String);
    }

    return AttachmentModel(
      id: json['id'] as String,
      fileName: json['fileName'] as String,
      filePath: json['filePath'] as String?,
      fileBytes: bytes,
      fileSize: json['fileSize'] as int,
      mimeType: json['mimeType'] as String,
      type: AttachmentType.values.firstWhere((e) => e.name == json['type'], orElse: () => AttachmentType.other),
      thumbnailPath: json['thumbnailPath'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'id': id,
      'fileName': fileName,
      'fileSize': fileSize,
      'mimeType': mimeType,
      'type': type.name,
      'thumbnailPath': thumbnailPath,
      'createdAt': createdAt.toIso8601String(),
    };

    if (filePath != null) {
      json['filePath'] = filePath;
    }

    if (fileBytes != null) {
      json['fileData'] = base64Encode(fileBytes!);
    }

    return json;
  }

  factory AttachmentModel.fromEntity(Attachment entity) {
    return AttachmentModel(
      id: entity.id,
      fileName: entity.fileName,
      filePath: entity.filePath,
      fileBytes: entity.fileBytes,
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
      fileBytes: fileBytes,
      fileSize: fileSize,
      mimeType: mimeType,
      type: type,
      thumbnailPath: thumbnailPath,
      createdAt: createdAt,
    );
  }
}
