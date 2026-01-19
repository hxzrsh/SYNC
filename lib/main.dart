import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
  ));
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(const VoidApp());
}

class VoidApp extends StatelessWidget {
  const VoidApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Void Year',
    theme: ThemeData(brightness: Brightness.dark, useMaterial3: true),
    home: const VoidTerminal(),
  );
}

class VoidTerminal extends StatefulWidget {
  const VoidTerminal({super.key});
  @override
  State<VoidTerminal> createState() => _VoidTerminalState();
}

class _VoidTerminalState extends State<VoidTerminal> {
  Timer? _atomicClock;
  double _progress = 0.0;
  bool _showPercentage = true;
  double _opacity = 0.0;
  String _lastSync = "";

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _opacity = 1.0);
    });
    _atomicClock = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (mounted) setState(() { _progress = _calculateProgress(); _handleHaptics(); });
    });
  }

  double _calculateProgress() {
    final now = DateTime.now();
    final start = DateTime(2026, 1, 1);
    final end = DateTime(2027, 1, 1);
    return (now.difference(start).inMilliseconds / end.difference(start).inMilliseconds).clamp(0.0, 1.0);
  }

  void _handleHaptics() {
    String current = (_progress * 100).toStringAsFixed(4).split('.').last.substring(2, 4);
    if (current != _lastSync) { HapticFeedback.selectionClick(); _lastSync = current; }
  }

  @override
  Widget build(BuildContext context) {
    final daysLeft = 365.25 - (365.25 * _progress);
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () { HapticFeedback.mediumImpact(); setState(() => _showPercentage = !_showPercentage); },
        child: Center(
          child: AnimatedOpacity(
            duration: const Duration(seconds: 2),
            opacity: _opacity,
            child: Text(
              _showPercentage ? "${(_progress * 100).toStringAsFixed(6)}%" : "${daysLeft.toStringAsFixed(2)} DAYS LEFT",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Deutschlander',
                fontSize: _showPercentage ? 100 : 45,
                fontWeight: FontWeight.w100,
                color: Colors.white,
                letterSpacing: _showPercentage ? 2 : 6,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() { _atomicClock?.cancel(); super.dispose(); }
}