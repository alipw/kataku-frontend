import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_quill/quill_delta.dart';
import '../models/note.dart';
import '../models/note_list.dart';
import 'package:flutter_quill/flutter_quill.dart';

class ApiService {
  static const String baseUrl = 'https://kataku-worker.alifwide.workers.dev';
  
  // Lists API
  Future<List<NoteList>> getLists() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/lists'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => NoteList.fromJson(json)).toList();
      }
      throw Exception('Failed to load lists: ${response.body}');
    } catch (e) {
      throw Exception('Failed to load lists: $e');
    }
  }

  Future<NoteList> createList(String title) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/lists'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'title': title}),
      );
      if (response.statusCode == 201) {
        return NoteList.fromJson(json.decode(response.body));
      }
      throw Exception('Failed to create list: ${response.body}');
    } catch (e) {
      throw Exception('Failed to create list: $e');
    }
  }

  Future<NoteList> getList(String listId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/lists/$listId'));
      if (response.statusCode == 200) {
        return NoteList.fromJson(json.decode(response.body));
      }
      throw Exception('Failed to load list: ${response.body}');
    } catch (e) {
      throw Exception('Failed to load list: $e');
    }
  }

  Future<void> deleteList(String listId) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/lists/$listId'));
      if (response.statusCode != 204) {
        throw Exception('Failed to delete list: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to delete list: $e');
    }
  }

  // Notes API
  Future<List<Note>> getNotes({String? listId}) async {
    try {
      final uri = Uri.parse('$baseUrl/notes').replace(
        queryParameters: listId != null ? {'listId': listId} : null,
      );
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Note.fromJson(json)).toList();
      }
      throw Exception('Failed to load notes: ${response.body}');
    } catch (e) {
      throw Exception('Failed to load notes: $e');
    }
  }

  Future<Note> createNote({
    required String title,
    required Delta content,
    required String listId,
  }) async {
    try {
      // Ensure content ends with newline
      String plainText = Document.fromDelta(content).toPlainText();
      if (!plainText.endsWith('\n')) {
        plainText += '\n';
      }

      final response = await http.post(
        Uri.parse('$baseUrl/notes'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'title': title,
          'content': plainText,
          'notesListsId': listId,
        }),
      );
      if (response.statusCode == 201) {
        return Note.fromJson(json.decode(response.body));
      }
      throw Exception('Failed to create note: ${response.body}');
    } catch (e) {
      throw Exception('Failed to create note: $e');
    }
  }

  Future<Note> getNote(String noteId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/notes/$noteId'));
      if (response.statusCode == 200) {
        return Note.fromJson(json.decode(response.body));
      }
      throw Exception('Failed to load note: ${response.body}');
    } catch (e) {
      throw Exception('Failed to load note: $e');
    }
  }

  Future<void> deleteNote(String noteId) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/notes/$noteId'));
      if (response.statusCode != 204) {
        throw Exception('Failed to delete note: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to delete note: $e');
    }
  }

  Future<Note> updateNote(String noteId, {
    required String title,
    required Delta content,
  }) async {
    try {
      // Ensure content ends with newline
      String plainText = Document.fromDelta(content).toPlainText();
      if (!plainText.endsWith('\n')) {
        plainText += '\n';
      }

      final response = await http.put(
        Uri.parse('$baseUrl/notes/$noteId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'title': title,
          'content': plainText,
        }),
      );
      if (response.statusCode == 200) {
        return Note.fromJson(json.decode(response.body));
      }
      throw Exception('Failed to update note: ${response.body}');
    } catch (e) {
      throw Exception('Failed to update note: $e');
    }
  }
} 