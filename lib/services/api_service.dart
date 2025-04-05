import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_quill/quill_delta.dart';
import '../models/note.dart';
import '../models/note_list.dart';

class ApiService {
  static const String baseUrl = 'https://kataku-worker.alifwide.workers.dev';
  
  // Lists API
  Future<List<NoteList>> getLists() async {
    final response = await http.get(Uri.parse('$baseUrl/lists'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => NoteList.fromJson(json)).toList();
    }
    throw Exception('Failed to load lists');
  }

  Future<NoteList> createList(String title) async {
    final response = await http.post(
      Uri.parse('$baseUrl/lists'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'title': title}),
    );
    if (response.statusCode == 201) {
      return NoteList.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to create list');
  }

  Future<NoteList> getList(String listId) async {
    final response = await http.get(Uri.parse('$baseUrl/lists/$listId'));
    if (response.statusCode == 200) {
      return NoteList.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to load list');
  }

  Future<void> deleteList(String listId) async {
    final response = await http.delete(Uri.parse('$baseUrl/lists/$listId'));
    if (response.statusCode != 204) {
      throw Exception('Failed to delete list');
    }
  }

  // Notes API
  Future<List<Note>> getNotes({String? listId}) async {
    final uri = Uri.parse('$baseUrl/notes').replace(
      queryParameters: listId != null ? {'listId': listId} : null,
    );
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Note.fromJson(json)).toList();
    }
    throw Exception('Failed to load notes');
  }

  Future<Note> createNote({
    required String title,
    required Delta content,
    required String listId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/notes'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'title': title,
        'content': jsonEncode(content.toJson()),
        'notesListsId': listId,
      }),
    );
    if (response.statusCode == 201) {
      return Note.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to create note');
  }

  Future<Note> getNote(String noteId) async {
    final response = await http.get(Uri.parse('$baseUrl/notes/$noteId'));
    if (response.statusCode == 200) {
      return Note.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to load note');
  }

  Future<void> deleteNote(String noteId) async {
    final response = await http.delete(Uri.parse('$baseUrl/notes/$noteId'));
    if (response.statusCode != 204) {
      throw Exception('Failed to delete note');
    }
  }

  Future<Note> updateNote(String noteId, {
    required String title,
    required Delta content,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/notes/$noteId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'title': title,
        'content': jsonEncode(content.toJson()),
      }),
    );
    if (response.statusCode == 200) {
      return Note.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to update note');
  }
} 