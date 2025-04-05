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

  // Getters
  List<NoteList> get noteLists => _noteLists;
  NoteList? get selectedNoteList => _selectedNoteList;
  List<Note> get notes => _selectedNoteList?.notes ?? [];
  Note? get selectedNote => _selectedNote;

  NoteProvider() {
    _loadLists();
  }

  Future<void> _loadLists() async {
    try {
      _noteLists = await _api.getLists();
      if (_noteLists.isNotEmpty) {
        await selectNoteList(_noteLists.first);
      }
      notifyListeners();
    } catch (e) {
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
      } catch (e) {
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
      notifyListeners();
    } catch (e) {
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
      notifyListeners();
    } catch (e) {
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
      notifyListeners();
      return newNote;
    } catch (e) {
      debugPrint('Error creating note: $e');
      return null;
    }
  }

  Future<void> updateSelectedNoteContent(Delta newContent) async {
    if (_selectedNote != null) {
      try {
        final updatedNote = await _api.updateNote(
          _selectedNote!.id,
          title: _selectedNote!.title,
          content: newContent,
        );
        _selectedNote!.content = updatedNote.content;
        notifyListeners();
      } catch (e) {
        debugPrint('Error updating note content: $e');
      }
    }
  }

  Future<void> updateSelectedNoteTitle(String newTitle) async {
    if (_selectedNote != null) {
      try {
        final updatedNote = await _api.updateNote(
          _selectedNote!.id,
          title: newTitle,
          content: _selectedNote!.content,
        );
        _selectedNote!.title = updatedNote.title;
        notifyListeners();
      } catch (e) {
        debugPrint('Error updating note title: $e');
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
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error deleting note: $e');
    }
  }
} 