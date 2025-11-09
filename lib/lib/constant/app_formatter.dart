import 'package:intl/intl.dart';

class AppFormatter {
  static String dateFormater({required String date}) {
    if (date == 'N/A') {
      return 'N/A';
    } else {
      DateTime parsedDate = DateTime.parse(date);
      String formattedDate = DateFormat('dd-MM-yyyy').format(parsedDate);
      return formattedDate;
    }
  }
}
