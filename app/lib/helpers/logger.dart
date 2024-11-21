import 'package:logger/logger.dart';

var logger = Logger(
    printer: PrettyPrinter(
  methodCount: 2, // Number of method calls to be displayed
  errorMethodCount: 8, // Number of method calls if stacktrace is provided
  lineLength: 120, // Width of the output
  colors: true, // Colorful log messages
  printEmojis: true, // Print an emoji for each log message
  // Should each log print contain a timestamp
  dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
));
