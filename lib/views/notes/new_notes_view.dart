import 'package:flutter/material.dart';
import 'package:secondflutter/services/auth/auth_service.dart';
import 'package:secondflutter/services/crud/notes_service.dart';

class NewNoteView extends StatefulWidget {
  const NewNoteView({super.key});

  @override
  State<NewNoteView> createState() => _NewNoteViewState();
}

class _NewNoteViewState extends State<NewNoteView> {
  DatabaseNotes? _note;
  late final NotesService _notesService;
  late final TextEditingController _textConttroller;
  Future<DatabaseNotes> createNewNote() async {
    final existingNote = _note;
    if (existingNote != null) {
      return existingNote;
    }
    final currentUser = AuthService.firebase().currentUser!;
    final email = currentUser.email!;
    final owner = await _notesService.getUser(email: email);
    return await _notesService.createnote(owner: owner);
  }

  void _textConttrollerListener() async {
    final note = _note;
    if (note == null) {
      return;
    }
    final text = _textConttroller.text;
    await _notesService.updateNote(note: note, text: text);
  }

  void _setUpTextConttrollerListener() async {
    _textConttroller.removeListener(_textConttrollerListener);
    _textConttroller.addListener(_textConttrollerListener);
  }

  void _deleteNoteIfItIsEmpty() {
    final note = _note;
    if (_textConttroller.text.isEmpty && note != null) {
      _notesService.deleteNote(id: note.id);
    }
  }

  void _saveNoteIfItIsNoyEmpty() async {
    final note = _note;
    final text = _textConttroller.text;
    if (text.isNotEmpty && note != null) {
      await _notesService.updateNote(note: note, text: text);
    }
  }

  @override
  void dispose() {
    _deleteNoteIfItIsEmpty();
    _saveNoteIfItIsNoyEmpty();
    _textConttroller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _notesService = NotesService();
    _textConttroller = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New note'),
      ),
      body: FutureBuilder(
        future: createNewNote(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              _note = snapshot.data as DatabaseNotes;
              _setUpTextConttrollerListener();
              return TextField(
                controller: _textConttroller,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration:
                    const InputDecoration(hintText: 'Start typing your note'),
              );
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
