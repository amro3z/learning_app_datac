import 'package:flutter/material.dart';
import 'package:training/services/network_service.dart';
import 'offline_overlay.dart';

class NetworkGuard extends StatelessWidget {
  final Widget child;
  final VoidCallback onRetry;

  const NetworkGuard({super.key, required this.child, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: NetworkService.connectionStream,
      initialData: true,
      builder: (context, snapshot) {
        final connected = snapshot.data ?? true;
        return Stack(
          children: [
            child,
            if (!connected) OfflineOverlay(onRetry: onRetry),
          ],
        );
      },
    );
  }
}
