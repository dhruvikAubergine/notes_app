import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:notes_app/feature/add_note/modals/note.dart';

class NoteProvider with ChangeNotifier {
  List<Note> _notes = [];
  final noteBox = Hive.box('Note Box');

  List<Note> get getNotes {
    return _notes;
  }

  Future<void> fetchNotes() async {
    _notes = noteBox.values.toList().cast<Note>();
    notifyListeners();
  }

  Future<void> removeItem(String noteId) async {
    if (noteId.isNotEmpty) {
      await noteBox.delete(noteId);
      _notes.removeWhere((notes) => notes.id == noteId);
    }
    notifyListeners();
  }

  Future<void> clear() async {
    await noteBox.clear();
    _notes = [];
    notifyListeners();
  }

  Future<void> reorderedNotes() async {
    await noteBox.clear();
    await noteBox.addAll(_notes);
    notifyListeners();
  }

  Future<void> addNote({required Note note, bool isForEdit = false}) async {
    if (isForEdit) {
      await noteBox.put(note.id, note);
      final index = _notes.indexWhere((element) => element.id == note.id);
      _notes[index] = note;
    } else {
      await noteBox.put(note.id, note);
      _notes.add(note);
      log(noteBox.values.toList().toString());
    }

    notifyListeners();
    log(noteBox.keys.toString());
    log(noteBox.values.toString());
  }
}
