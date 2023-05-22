import 'package:flutter/material.dart';
import 'package:secondflutter/services/crud/notes_service.dart';
import 'package:secondflutter/utilities/dialogs/delete_dialog.dart';

typedef NoteCallBack = void Function(DatabaseNotes note);

class NotesListView extends StatelessWidget {
  final List<DatabaseNotes> notes;
  final NoteCallBack oneDeleteNote;
  final NoteCallBack onTap;
  const NotesListView(
      {super.key,
      required this.notes,
      required this.oneDeleteNote,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return ListTile(
          onTap: () {
            onTap(note);
          },
          title: Text(
            note.text,
            maxLines: 1,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: IconButton(
              onPressed: () async {
                final shouldDelete = await showDeleteDialog(context);
                if (shouldDelete) {
                  oneDeleteNote(note);
                }
              },
              icon: const Icon(Icons.delete)),
        );
      },
    );
  }
}
