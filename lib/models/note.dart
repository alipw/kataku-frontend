import 'package:flutter_quill/flutter_quill.dart';
import 'dart:convert';

import 'package:flutter_quill/quill_delta.dart';

class Note {
  final String id;
  String title;
  Delta content;

  Note({
    required this.id,
    required this.title,
    required this.content,
  });

  // Helper to create an empty note
  factory Note.empty() {
    return Note(
      id: DateTime.now().toIso8601String(), // Simple unique ID for now
      title: 'New Note',
      content: Delta()..insert('\n'), // Start with an empty line
    );
  }

  // Optional: Methods for serialization if needed later (e.g., saving to disk)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': jsonEncode(content.toJson()), // Store Delta as JSON string
    };
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      title: json['title'],
      content: Delta.fromJson(jsonDecode(json['content'])), // Decode JSON string to Delta
    );
  }
} 