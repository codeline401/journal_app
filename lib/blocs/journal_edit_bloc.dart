import 'dart:async';

import 'package:journal/models/journal.dart';
import 'package:journal/services/db_firestore_api.dart';

class JournalEditBloc{
  final DbApi dbApi;
  final bool add;
  Journal selectedJournal;

  final StreamController<String> dateController = StreamController<String>.broadcast();
  Sink<String?> get dateEditChanged => dateController.sink;
  Stream<String> get dateEdit => dateController.stream;

  final StreamController<String> moodController = StreamController<String>.broadcast();
  Sink<String?> get moodEditChanged => moodController.sink;
  Stream<String> get moodEdit => moodController.stream;

  final StreamController<String> noteController = StreamController<String>.broadcast();
  Sink<String?> get noteEditChanged => noteController.sink;
  Stream<String> get noteEdit => noteController.stream;

  final StreamController<String> saveJournalController = StreamController<String>.broadcast();
  Sink<String?> get saveJournalChanged => saveJournalController.sink;
  Stream<String> get saveJournal => saveJournalController.stream;

  JournalEditBloc(this.dbApi, {required this.add, required this.selectedJournal}){
    startListeners();
    getJournal();
  }

  void dispose() {
    dateController.close();
    moodController.close();
    noteController.close();
    saveJournalController.close();
  }

  void startListeners() {
    dateController.stream.listen((date) { 
      selectedJournal.date = date;
    });

    moodController.stream.listen((mood) { 
      selectedJournal.mood = mood;
    });

    noteController.stream.listen((note) { 
      selectedJournal.note = note;
    });

    saveJournalController.stream.listen((action) { 
      if(action == 'Save'){
        _saveJournal();
      }
    });
  }

  void getJournal() {
    if (add) {
      selectedJournal = Journal(
        date: DateTime.now().toString(),
        mood: 'Very Satisfied',
        note: '',
        uid: '',
      );
    }
    dateEditChanged.add(selectedJournal.date);
    moodEditChanged.add(selectedJournal.mood);
    noteEditChanged.add(selectedJournal.note);

    print('Date in getjournal(): ${selectedJournal.date}');
  }

  void _saveJournal(){
    Journal journal = Journal(
      documnetID: selectedJournal.documnetID,
      date: DateTime.parse(selectedJournal.date!).toIso8601String(),
      mood: selectedJournal.mood,
      note: selectedJournal.note,
      uid: selectedJournal.uid
    );
    add ? dbApi.addJournal(journal) : dbApi.updateJournal(journal);
  }
}