import 'package:flutter/material.dart';
import 'package:secondflutter/services/auth/auth_service.dart';
import 'package:secondflutter/services/crud/notes_service.dart';
import 'package:secondflutter/utilities/dialogs/generics/get_arguments.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({super.key});

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
  DatabaseNotes? _note;
  late final NotesService _notesService;
  late final TextEditingController _textConttroller;
  Future<DatabaseNotes> createOrGetExistingNote(BuildContext context) async {
    final widgetNote = context.getArgument<DatabaseNotes>();
    if (widgetNote != null) {
      _note = widgetNote;
      _textConttroller.text = widgetNote.text;
      return widgetNote;
    }

    final existingNote = _note;
    if (existingNote != null) {
      return existingNote;
    }
    final currentUser = AuthService.firebase().currentUser!;
    final email = currentUser.email;
    final owner = await _notesService.getUser(email: email);
    final newNote = await _notesService.createnote(owner: owner);
    _note = newNote;
    return newNote;
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
        future: createOrGetExistingNote(context),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
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
