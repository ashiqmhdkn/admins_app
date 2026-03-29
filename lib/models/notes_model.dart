class Note {
  final String noteId;
  final String unitId;
  final String title;
  final String? filePath;
  final String? mimeType;
  final int? fileSize;
  final String? createdAt;

  const Note({
    required this.noteId,
    required this.unitId,
    required this.title,
    this.filePath,
    this.mimeType,
    this.fileSize,
    this.createdAt,
  });

  factory Note.fromJson(Map<String, dynamic> json) => Note(
        noteId: json["note_id"].toString(),
        unitId: json["unit_id"].toString(),
        title: json["title"] as String,
        filePath: json["file_path"] as String?,
        mimeType: json["mime_type"] as String?,
        fileSize: json["file_size"] as int?,
        createdAt: json["created_at"] as String?,
      );

  Map<String, dynamic> toJson() => {
        "note_id": noteId,
        "unit_id": unitId,
        "title": title,
        "file_path": filePath,
        "mime_type": mimeType,
        "file_size": fileSize,
        "created_at": createdAt,
      };
}