class Journal {
  String? documnetID;
  String? date;
  String? mood;
  String? note;
  String? uid;

  Journal({this.documnetID, this.date, this.mood, this.note, this.uid});

  //Method responsible for converting and mapping a Cloud Firestore database document record
  //to an individual Journal entry
  factory Journal.fromDoc(dynamic doc) => Journal(
    documnetID: doc.documnetID,
    date: doc["date"],
    mood: doc["mood"],
    note: doc["note"],
    uid: doc["uid"]
  );
}