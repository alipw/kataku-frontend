import 'package:flutter/material.dart';
import 'package:flutter_quill/quill_delta.dart';
import '../models/note.dart';
import '../models/note_list.dart';
import '../services/api_service.dart';

class NoteProvider with ChangeNotifier {
  final ApiService _api = ApiService();
  
  List<NoteList> _noteLists = [];
  NoteList? _selectedNoteList;
  Note? _selectedNote;
  String? _error;

  // Getters
  List<NoteList> get noteLists => _noteLists;
  NoteList? get selectedNoteList => _selectedNoteList;
  List<Note> get notes => _selectedNoteList?.notes ?? [];
  Note? get selectedNote => _selectedNote;
  String? get error => _error;

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  NoteProvider() {
    loadLists();
  }

  Future<void> loadLists() async {
    try {
      _noteLists = await _api.getLists();
      if (_noteLists.isNotEmpty) {
        await selectNoteList(_noteLists.first);
      }
      _setError(null);
    } catch (e) {
      _setError(e.toString());
      debugPrint('Error loading lists: $e');
    }
  }

  Future<void> selectNoteList(NoteList? list) async {
    _selectedNoteList = list;
    _selectedNote = null;
    if (list != null) {
      try {
        final fullList = await _api.getList(list.id);
        final index = _noteLists.indexWhere((l) => l.id == list.id);
        if (index != -1) {
          _noteLists[index] = fullList;
          _selectedNoteList = fullList;
        }
        _setError(null);
      } catch (e) {
        _setError(e.toString());
        debugPrint('Error loading list details: $e');
      }
    }
    notifyListeners();
  }

  Future<void> addNoteList(String title) async {
    try {
      final newList = await _api.createList(title);
      _noteLists.add(newList);
      await selectNoteList(newList);
      _setError(null);
    } catch (e) {
      _setError(e.toString());
      debugPrint('Error creating list: $e');
    }
  }

  Future<void> deleteNoteList(NoteList list) async {
    try {
      await _api.deleteList(list.id);
      _noteLists.removeWhere((l) => l.id == list.id);
      if (_selectedNoteList?.id == list.id) {
        await selectNoteList(_noteLists.isNotEmpty ? _noteLists.first : null);
      }
      _setError(null);
    } catch (e) {
      _setError(e.toString());
      debugPrint('Error deleting list: $e');
    }
  }

  Future<Note?> addNote() async {
    if (_selectedNoteList == null) return null;

    try {
      final newNote = await _api.createNote(
        title: '',
        content: Delta()..insert('\n'),
        listId: _selectedNoteList!.id,
      );
      _selectedNoteList!.notes.add(newNote);
      _selectedNote = newNote;
      _setError(null);
      return newNote;
    } catch (e) {
      _setError(e.toString());
      debugPrint('Error creating note: $e');
      return null;
    }
  }

  Future<void> updateSelectedNote({
    required String title,
    required Delta content,
  }) async {
    if (_selectedNote != null) {
      try {
        final updatedNote = await _api.updateNote(
          _selectedNote!.id,
          title: title,
          content: content,
        );
        _selectedNote!.title = updatedNote.title;
        _selectedNote!.content = updatedNote.content;
        _setError(null);
      } catch (e) {
        _setError(e.toString());
        debugPrint('Error updating note: $e');
      }
    }
  }

  Future<void> deleteNote(Note note) async {
    try {
      await _api.deleteNote(note.id);
      if (_selectedNoteList != null) {
        _selectedNoteList!.notes.removeWhere((n) => n.id == note.id);
        if (_selectedNote?.id == note.id) {
          _selectedNote = _selectedNoteList!.notes.isNotEmpty
              ? _selectedNoteList!.notes.first
              : null;
        }
        _setError(null);
      }
    } catch (e) {
      _setError(e.toString());
      debugPrint('Error deleting note: $e');
    }
  }
} 