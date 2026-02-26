import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:training/helper/base.dart';
import 'package:training/helper/custom_glow_buttom.dart';

class OfflineOverlay extends StatefulWidget {
  final VoidCallback onRetry;

  const OfflineOverlay({super.key, required this.onRetry});

  @override
  State<OfflineOverlay> createState() => _OfflineOverlayState();
}

class _OfflineOverlayState extends State<OfflineOverlay> {
  double _scale = 1.0;
  bool _locked = false;

  Future<void> _tapRetry() async {
    if (_locked) return;
    _locked = true;

    // bounce صغير
    setState(() => _scale = 0.96);
    await Future.delayed(const Duration(milliseconds: 90));
    if (!mounted) return;
    setState(() => _scale = 1.0);
    await Future.delayed(const Duration(milliseconds: 90));

    widget.onRetry();

    // منع سبام سريع
    await Future.delayed(const Duration(milliseconds: 400));
    _locked = false;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
        child: Container(
          color: Colors.black.withOpacity(0.6),
          child: Center(
            child: AnimatedScale(
              scale: _scale,
              duration: const Duration(milliseconds: 120),
              curve: Curves.easeOut,
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
                    const Icon(
                      Icons.wifi_off,
                      color: Colors.redAccent,
                      size: 48,
                    ),
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
                      bold: false,
                    ),
                    const SizedBox(height: 16),

                    // سيبنا الزرار زي ما هو، بس غلفناه عشان نعمل bounce للـ card
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: _tapRetry,
                      child: AbsorbPointer(
                        // يمنع تنفيذ onPressed مرتين (من GestureDetector ومن الزرار)
                        absorbing: true,
                        child: CustomGlowButton(
                          title: 'Retry',
                          onPressed:
                              widget.onRetry, // مش هيتنادى بسبب AbsorbPointer
                          width: 120,
                          textSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
