import 'dart:async';
import 'dart:io';

class NetworkService {
  static final StreamController<bool> _controller =
      StreamController<bool>.broadcast();

  static Stream<bool> get connectionStream => _controller.stream;

  static Timer? _timer;

  static void startListening() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      final hasNet = await _checkInternet();
      _controller.add(hasNet);
    });
  }

  static Future<bool> _checkInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  static void dispose() {
    _timer?.cancel();
    _controller.close();
  }
}
