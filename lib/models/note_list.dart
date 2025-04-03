import 'note.dart';

class NoteList {
  final String id;
  String name;
  final List<Note> notes;

  NoteList({
    required this.id,
    required this.name,
    List<Note>? notes,
  }) : notes = notes ?? []; // Initialize with empty list if null

  // Helper to create an empty list
  factory NoteList.empty(String name) {
    return NoteList(
      id: DateTime.now().toIso8601String(), // Simple unique ID
      name: name,
    );
  }

   // Optional: Methods for serialization if needed later
   Map<String, dynamic> toJson() {
     return {
       'id': id,
       'name': name,
       'notes': notes.map((note) => note.toJson()).toList(),
     };
   }

   factory NoteList.fromJson(Map<String, dynamic> json) {
     return NoteList(
       id: json['id'],
       name: json['name'],
       notes: (json['notes'] as List)
           .map((noteJson) => Note.fromJson(noteJson))
           .toList(),
     );
   }
} 