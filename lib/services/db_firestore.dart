// ignore_for_file: avoid_print

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:journal/models/journal.dart';
import 'package:journal/services/db_firestore_api.dart';

class DbFirestoreService implements DbApi {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionJournals = 'journals';

  DbFirestoreService() {
    _firestore.settings = const Settings(persistenceEnabled: true);
  }

  //Method responsible of retrieving journal entries.
  @override
  Stream<List<Journal>> getJournalList (String uid) {
    //uid is the logged-in user ID
    return _firestore.collection(_collectionJournals)
    .where('uid', isEqualTo: uid)
    .snapshots()
    .map((QuerySnapshot snapshots) {
      List<Journal> journalDocs = snapshots.docs.map((doc) => Journal.fromDoc(doc)).toList();

      journalDocs.sort((comp1, comp2) => comp2.date!.compareTo(comp1.date!));
      return journalDocs;
    });
  }

  //Method responsible for adding a new journal entry
  @override
  Future<bool> addJournal (Journal journal) async {
    DocumentReference documentReference = await _firestore.collection(_collectionJournals).add({
      'date' : journal.date,
      'mood' : journal.mood,
      'note': journal.note,
      'uid' : journal.uid,
    });

    return documentReference.id.isNotEmpty;
  }

  @override
  void updateJournal (Journal journal) async {
    await _firestore
      .collection(_collectionJournals)
      .doc(journal.documnetID)
      .update({
        'date': journal.date,
        'mood' : journal.mood,
        'note' : journal.note,
      })
      .catchError((onError) => print('Error updating : $onError'));
  }

  @override
  void deleteJournal (Journal journal) async {
    await _firestore
    .collection(_collectionJournals)
    .doc(journal.documnetID)
    .delete()
    .catchError((onError) => print('Error on deleting : $onError'));
  }

  @override
  Future<Journal> getJournal (String documentID) async {
   try {
     final DocumentSnapshot<Map<String, dynamic>> documentSnapshot = 
      await _firestore.collection(_collectionJournals).doc(documentID).get();

    if(documentSnapshot.exists){
      return Journal.fromDoc(documentSnapshot);
    }
    else {
      //Gérer le cas où le journal n'est pas trouvé.
      return Future.error('No journal found for the given documentID.');
    }
   } catch (e) {
     print('Error getting journal: $e');
     return Future.error('Error getting journal : $e');
   }
  }
}