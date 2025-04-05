import 'note.dart';

class NoteList {
  final String id;
  String title;
  final String userOwnerId;
  final List<Note> notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  NoteList({
    required this.id,
    required this.title,
    required this.userOwnerId,
    List<Note>? notes,
    required this.createdAt,
    required this.updatedAt,
  }) : notes = notes ?? [];

  // Helper to create an empty list
  factory NoteList.empty(String title) {
    final now = DateTime.now();
    return NoteList(
      id: now.toIso8601String(), // Temporary ID until saved
      title: title,
      userOwnerId: 'temp_user', // Will be set by the server
      notes: [],
      createdAt: now,
      updatedAt: now,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'user_owner_id': userOwnerId,
      'notes': notes.map((note) => note.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory NoteList.fromJson(Map<String, dynamic> json) {
    return NoteList(
      id: json['id'],
      title: json['title'],
      userOwnerId: json['user_owner_id'],
      notes: (json['notes'] as List)
          .map((noteJson) => Note.fromJson(noteJson))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
} 