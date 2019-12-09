import 'package:intl/intl.dart';

class LoggingService {
  bool debug = true;
  bool writeToFile = false;

  void log(Object s, [Object o, Object o2]) {
    if (debug) {
      print("[" + getDateTime() + "]: " + s.toString() + ((o != null) ? ", " + o.toString() : "") + ((o2 != null) ? ", " + o2.toString() : ""));
    }

    if (writeToFile) {
      // Write logging to file.
    }
  }

  String getDateTime() {
    var now = new DateTime.now();
    var formatter = new DateFormat('yyyy-MM-dd hh:mm:ss');
    String formatted = formatter.format(now);

    return formatted;
  }

  void shareLogToTelegram() {
    // Functionality to share your debug information with us.
  }
}
