import 'dart:developer' as dev;

class AppLogger {
  static final List<String> _logs = [];

  static void log(String message) {
    final formatted = "[LOG] $message";
    _logs.add(formatted);
    dev.log(formatted);
  }

  static List<String> get logs => _logs;

  static void clear() => _logs.clear();
}
