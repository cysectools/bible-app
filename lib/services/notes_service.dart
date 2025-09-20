import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class Note {
  final String id;
  final String verseReference;
  final String verseText;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  Note({
    required this.id,
    required this.verseReference,
    required this.verseText,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'verseReference': verseReference,
      'verseText': verseText,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      verseReference: json['verseReference'],
      verseText: json['verseText'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Note copyWith({
    String? content,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id,
      verseReference: verseReference,
      verseText: verseText,
      content: content ?? this.content,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class NotesService {
  static const String _notesKey = 'bible_notes';
  static const _uuid = Uuid();

  static Future<List<Note>> getAllNotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notesJson = prefs.getStringList(_notesKey) ?? [];
      
      return notesJson
          .map((json) => Note.fromJson(jsonDecode(json)))
          .toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    } catch (e) {
      print('Error loading notes: $e');
      return [];
    }
  }

  static Future<Note?> getNoteById(String id) async {
    try {
      final notes = await getAllNotes();
      return notes.firstWhere((note) => note.id == id);
    } catch (e) {
      print('Error getting note by id: $e');
      return null;
    }
  }

  static Future<String> saveNote({
    String? id,
    required String verseReference,
    required String verseText,
    required String content,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notes = await getAllNotes();
      
      final now = DateTime.now();
      final noteId = id ?? _uuid.v4();
      
      final note = Note(
        id: noteId,
        verseReference: verseReference,
        verseText: verseText,
        content: content,
        createdAt: id != null ? notes.firstWhere((n) => n.id == id).createdAt : now,
        updatedAt: now,
      );

      // Remove existing note if updating
      if (id != null) {
        notes.removeWhere((n) => n.id == id);
      }
      
      notes.add(note);
      
      final notesJson = notes.map((note) => jsonEncode(note.toJson())).toList();
      await prefs.setStringList(_notesKey, notesJson);
      
      return noteId;
    } catch (e) {
      print('Error saving note: $e');
      rethrow;
    }
  }

  static Future<bool> deleteNote(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notes = await getAllNotes();
      
      notes.removeWhere((note) => note.id == id);
      
      final notesJson = notes.map((note) => jsonEncode(note.toJson())).toList();
      await prefs.setStringList(_notesKey, notesJson);
      
      return true;
    } catch (e) {
      print('Error deleting note: $e');
      return false;
    }
  }

  static Future<List<Note>> searchNotes(String query) async {
    try {
      final notes = await getAllNotes();
      final lowercaseQuery = query.toLowerCase();
      
      return notes.where((note) {
        return note.verseReference.toLowerCase().contains(lowercaseQuery) ||
               note.verseText.toLowerCase().contains(lowercaseQuery) ||
               note.content.toLowerCase().contains(lowercaseQuery);
      }).toList();
    } catch (e) {
      print('Error searching notes: $e');
      return [];
    }
  }
}
