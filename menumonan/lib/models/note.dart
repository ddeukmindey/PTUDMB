import 'dart:convert';

class Note {
  String id;
  String title;
  String content;
  DateTime updatedAt;
  List<String> imagePaths;
  List<String> filePaths;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.updatedAt,
    this.imagePaths = const [],
    this.filePaths = const [],
  });

  factory Note.createEmpty() {
    final now = DateTime.now();
    return Note(id: now.millisecondsSinceEpoch.toString(), title: '', content: '', updatedAt: now, imagePaths: [], filePaths: []);
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      imagePaths: List<String>.from(json['imagePaths'] as List<dynamic>? ?? []),
      filePaths: List<String>.from(json['filePaths'] as List<dynamic>? ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'updatedAt': updatedAt.toIso8601String(),
        'imagePaths': imagePaths,
        'filePaths': filePaths,
      };

  static List<Note> listFromJson(String jsonString) {
    final List<dynamic> list = json.decode(jsonString) as List<dynamic>;
    return list.map((e) => Note.fromJson(e as Map<String, dynamic>)).toList();
  }

  static String listToJson(List<Note> notes) {
    final list = notes.map((e) => e.toJson()).toList();
    return json.encode(list);
  }
}
