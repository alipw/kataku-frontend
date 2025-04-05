import 'package:flutter_quill/flutter_quill.dart';
import 'dart:convert';

import 'package:flutter_quill/quill_delta.dart';

class Note {
  final String id;
  String title;
  Delta content;
  final String userOwnerId;
  final String notesListsId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.userOwnerId,
    required this.notesListsId,
    required this.createdAt,
    required this.updatedAt,
  });

  // Helper to create an empty note
  factory Note.empty(String listId) {
    final now = DateTime.now();
    return Note(
      id: now.toIso8601String(), // Temporary ID until saved
      title: '',
      content: Delta()..insert('\n'),
      userOwnerId: 'temp_user', // Will be set by the server
      notesListsId: listId,
      createdAt: now,
      updatedAt: now,
    );
  }

  // Optional: Methods for serialization if needed later (e.g., saving to disk)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': jsonEncode(content.toJson()),
      'user_owner_id': userOwnerId,
      'notesListsId': notesListsId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      title: json['title'],
      content: Delta.fromJson(jsonDecode(json['content'])),
      userOwnerId: json['user_owner_id'],
      notesListsId: json['notesListsId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
} 