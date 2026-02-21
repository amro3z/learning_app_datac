import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:training/helper/base.dart';

class OfflineOverlay extends StatelessWidget {
  final VoidCallback onRetry;

  const OfflineOverlay({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          color: Colors.black.withOpacity(0.6),
          child: Center(
            child: Container(
              width: 300,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E1E2E), Color(0xFF2A2A40)],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.wifi_off, color: Colors.redAccent, size: 48),
                  const SizedBox(height: 12),
                  defaultText(
                                            context: context,
                    text: 'No Internet Connection',
                    size: 18,
                    color: Colors.white,
                    bold: true,
                  ),
                  const SizedBox(height: 8),
                  defaultText(
                                            context: context,
                    text: 'Please check your connection',
                    size: 22,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C6CFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
