import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:secondflutter/services/cloud/cloud_note.dart';
import 'package:secondflutter/services/cloud/cloud_storage_constants.dart';
import 'package:secondflutter/services/cloud/cloud_storage_exceptions.dart';

class FirebaseCloudStorage {
  //acces to notes collection in cloud firestire

  //firestore(documents) <-> CloudNote
  final notes = FirebaseFirestore.instance.collection('notes');

  Future<void> updateNote(
      {required String documentId, required String text}) async {
    try {
      await notes.doc(documentId).update({textFieldName: text});
    } catch (e) {
      throw CouldNotUpdateNote();
    }
  }

  Future<void> deleteNote({required String documentId}) async {
    try {
      await notes.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteNote();
    }
  }

  Stream<Iterable<CloudNote>> allNotes({required String ownerUserId}) =>
      notes.snapshots().map(((event) => event.docs
          .map((doc) => CloudNote.fromSnapshot(doc))
          .where((note) => note.ownerUserId == ownerUserId)));

  Future<Iterable<CloudNote>> getNotes({required String ownewUserId}) async {
    try {
      return await notes
          .where(ownerUserIdFieldName, isEqualTo: ownewUserId)
          .get()
          .then(
            (value) => value.docs.map(
              (doc) => CloudNote.fromSnapshot(doc),
            ),
          );
    } catch (e) {
      throw CouldNotGetAllNotes();
    }
  }

  Future<CloudNote> createNewNote({required String ownewUserId}) async {
    final document =
        await notes.add({ownerUserIdFieldName: ownewUserId, textFieldName: ''});
    final fetchedNote = await document.get();
    return CloudNote(
        documentId: fetchedNote.id, ownerUserId: ownewUserId, text: '');
  }

  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;
}
