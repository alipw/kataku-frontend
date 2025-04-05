import 'package:flutter_quill/flutter_quill.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';

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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content.toJson().toString(),
      'user_owner_id': userOwnerId,
      'notesListsId': notesListsId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static Delta _parseContent(dynamic content) {
    try {
      if (content is String) {
        // Try to parse as Delta JSON first
        try {
          final deltaJson = jsonDecode(content);
          if (deltaJson is List) {
            return Delta.fromJson(deltaJson);
          }
          // If not a valid Delta JSON, treat as plain text
          return Delta()
            ..insert(content)
            ..insert('\n'); // Ensure it ends with newline
        } catch (_) {
          // If not a Delta JSON, treat as plain text
          return Delta()
            ..insert(content)
            ..insert('\n'); // Ensure it ends with newline
        }
      } else if (content is List) {
        // If it's already a list, try to parse as Delta
        return Delta.fromJson(content);
      } else {
        // Default to empty Delta with newline
        return Delta()..insert('\n');
      }
    } catch (e) {
      debugPrint('Error parsing note content: $e');
      // Return empty Delta with newline as fallback
      return Delta()..insert('\n');
    }
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      title: json['title'],
      content: _parseContent(json['content']),
      userOwnerId: json['user_owner_id'],
      notesListsId: json['notesListsId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
} 