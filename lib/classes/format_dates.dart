import 'package:intl/intl.dart';

class FormatDates {
  String dateFormatShortMonthDayYear (String date) {
    return DateFormat.yMMMEd().format(DateTime.parse(date));
  }

  String dateFormatDayNumber(String date){
    return DateFormat.d().format(DateTime.parse(date));
  }

  String dateFormatShortDayName(String date){
    return DateFormat.E().format(DateTime.parse(date));
  }
}