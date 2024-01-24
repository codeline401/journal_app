import 'dart:async';
import 'package:journal/services/authentication_api.dart';
import 'package:journal/services/db_firestore_api.dart';
import 'package:journal/models/journal.dart';

class HomeBloc {
  late final DbApi dbApi;
  late final AuthenticationApi authenticationApi;

  //A stream controller responsible of adding journal
  final StreamController<List<Journal>> journalController = StreamController<List<Journal>>.broadcast();
  Sink<List<Journal>> get addListJournal => journalController.sink;
  Stream<List<Journal>> get listJournal => journalController.stream;

  //A stream controller responsible for deleting journals,
  //no need a list of deleted journals streams
  final StreamController<Journal> journalDeleteController = StreamController<Journal>.broadcast();
  Sink<Journal> get deleteJournal => journalDeleteController.sink;

  HomeBloc(this.dbApi, this.authenticationApi){
    startListeners();
  }

  void dispose() {
    journalController.close();
    journalDeleteController.close();
  }

  void startListeners() async {
    //Retrieve Firestore Journal Records as List<Journnal> not DocumentSnapshot
    try {
      var user = await authenticationApi.getFirebaseAuth().currentUser();

      if(user != null){
        var journalStream = dbApi.getJournalList(user.uid);

        //Ecouter les changements dans le stream et ajouter à _addListJournal
        journalStream.listen((journalDocs) { 
          addListJournal.add(journalDocs);
        });

        //Ecouter les suppressions dans journalDeleteController
        journalDeleteController.stream.listen((journal) async{ 
          dbApi.deleteJournal(journal);
        });
      }
    } catch (e) {
      //Gestion des erreurs ici
      //Instructions....
    }
  }
}