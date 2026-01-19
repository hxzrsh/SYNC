import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(const VoidApp());
}

class VoidApp extends StatelessWidget {
  const VoidApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(brightness: Brightness.dark),
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
    
    // Start the fade-in breath
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) setState(() => _opacity = 1.0);
    });

    // 60FPS Refresh Loop
    _atomicClock = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (mounted) {
        setState(() {
          _progress = _calculateYearProgress();
          _handleHaptics();
        });
      }
    });
  }

  double _calculateYearProgress() {
    final DateTime now = DateTime.now();
    final DateTime start = DateTime(2026, 1, 1);
    final DateTime end = DateTime(2027, 1, 1);
    
    final int total = end.difference(start).inMilliseconds;
    final int elapsed = now.difference(start).inMilliseconds;
    
    return (elapsed / total).clamp(0.0, 1.0);
  }

  void _handleHaptics() {
    // Feel the passage of time on the 4th decimal
    String current = (_progress * 100).toStringAsFixed(4).split('.').last.substring(2, 4);
    if (current != _lastSync) {
      HapticFeedback.selectionClick();
      _lastSync = current;
    }
  }

  String _getDisplayValue() {
    if (_showPercentage) {
      return "${(_progress * 100).toStringAsFixed(6)}%";
    } else {
      // Direct Days Left calculation
      final double daysLeft = 365.25 - (365.25 * _progress);
      return "${daysLeft.toStringAsFixed(2)} DAYS LEFT";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, 
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.mediumImpact();
          setState(() => _showPercentage = !_showPercentage);
        },
        child: Center(
          child: AnimatedOpacity(
            duration: const Duration(seconds: 2),
            curve: Curves.easeIn,
            opacity: _opacity,
            child: Text(
              _getDisplayValue(),
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
  void dispose() {
    _atomicClock?.cancel();
    super.dispose();
  }
}