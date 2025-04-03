import 'package:flutter/material.dart';
import 'package:flutter_quill/quill_delta.dart';
import '../models/note.dart';
import '../models/note_list.dart'; // Import NoteList
import 'package:flutter_quill/flutter_quill.dart';

class NoteProvider with ChangeNotifier {
  // List of Note Lists
  final List<NoteList> _noteLists = [
    // Start with a sample list and note
    NoteList(
      id: 'default_list',
      name: 'My Notes',
      notes: [
        Note(
            id: 'initial',
            title: 'My First Note',
            content: Delta()..insert('Hello Flutter Quill!\n')
        ),
      ]
    ),
     NoteList(
      id: 'second_list',
      name: 'Work',
      notes: []
    ),
  ];

  NoteList? _selectedNoteList;
  Note? _selectedNote;

  // Getters
  List<NoteList> get noteLists => _noteLists;
  NoteList? get selectedNoteList => _selectedNoteList;
  // Get notes from the selected list
  List<Note> get notes => _selectedNoteList?.notes ?? [];
  Note? get selectedNote => _selectedNote;

  NoteProvider() {
    // Select the first list and its first note initially if available
    if (_noteLists.isNotEmpty) {
      _selectedNoteList = _noteLists.first;
      if (_selectedNoteList!.notes.isNotEmpty) {
        _selectedNote = _selectedNoteList!.notes.first;
      }
    }
  }

  // --- List Management ---

  void selectNoteList(NoteList list) {
    if (_selectedNoteList?.id != list.id) {
       _selectedNoteList = list;
       // Select the first note in the new list, or null if empty
       _selectedNote = list.notes.isNotEmpty ? list.notes.first : null;
       notifyListeners();
    }
  }

  void addNoteList(String name) {
    final newList = NoteList.empty(name.isEmpty ? 'New List' : name);
    _noteLists.add(newList);
    _selectedNoteList = newList; // Select the newly added list
    _selectedNote = null; // No note selected in a new list
    notifyListeners();
  }

  void deleteNoteList(NoteList list) {
     final index = _noteLists.indexWhere((l) => l.id == list.id);
     if (index != -1) {
       _noteLists.removeAt(index);
       // If the deleted list was selected, select the first available list or null
       if (_selectedNoteList == list) {
         _selectedNoteList = _noteLists.isNotEmpty ? _noteLists.first : null;
         _selectedNote = _selectedNoteList?.notes.isNotEmpty ?? false
             ? _selectedNoteList!.notes.first
             : null;
       }
       notifyListeners();
     }
   }

  void renameNoteList(NoteList list, String newName) {
    final index = _noteLists.indexWhere((l) => l.id == list.id);
    if (index != -1 && newName.isNotEmpty) {
      _noteLists[index].name = newName;
      notifyListeners();
    }
  }

  // --- Note Management (within selected list) ---

  void selectNote(Note note) {
    // Ensure the note belongs to the currently selected list
    if (_selectedNoteList != null && _selectedNoteList!.notes.any((n) => n.id == note.id)) {
      _selectedNote = note;
      notifyListeners();
    } else {
      // Handle cases where note might be from a different list (optional)
      print("Error: Attempted to select a note not in the current list.");
    }
  }

  void addNote() {
    if (_selectedNoteList == null) return; // Cannot add note without a selected list

    final newNote = Note.empty();
    _selectedNoteList!.notes.add(newNote);
    _selectedNote = newNote; // Select the newly added note
    notifyListeners();
  }

  void updateSelectedNoteContent(Delta newContent) {
    if (_selectedNote != null) {
      _selectedNote!.content = newContent;
      // Find the note in the list and update it (needed if using copies)
       // No notifyListeners needed usually, editor handles its state
    }
  }

  void updateSelectedNoteTitle(String newTitle) {
    if (_selectedNote != null && _selectedNoteList != null) {
      _selectedNote!.title = newTitle;
      // Make sure the title updates in the list view
      notifyListeners();
    }
  }

  void deleteNote(Note note) {
     if (_selectedNoteList == null) return;

     final listIndex = _noteLists.indexWhere((l) => l.id == _selectedNoteList!.id);
     if (listIndex == -1) return;

     final noteIndex = _noteLists[listIndex].notes.indexWhere((n) => n.id == note.id);
     if (noteIndex != -1) {
       _noteLists[listIndex].notes.removeAt(noteIndex);
       if (_selectedNote == note) {
         // Select the first note in the current list or null if empty
         _selectedNote = _noteLists[listIndex].notes.isNotEmpty
             ? _noteLists[listIndex].notes.first
             : null;
       }
       notifyListeners();
     }
   }
} 