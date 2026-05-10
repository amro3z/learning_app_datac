import 'package:flutter/material.dart';

class SecureWrapper extends StatefulWidget {
  final Widget child;

  const SecureWrapper({super.key, required this.child});

  @override
  State<SecureWrapper> createState() => _SecureWrapperState();
}

class _SecureWrapperState extends State<SecureWrapper>
    with WidgetsBindingObserver {
  bool _isHidden = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      setState(() => _isHidden = true);
    } else if (state == AppLifecycleState.resumed) {
      setState(() => _isHidden = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,

        // 🔒 overlay
        if (_isHidden) Container(color: Colors.black),
      ],
    );
  }
}
