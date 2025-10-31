import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const FlipClockApp());

/// 🌙 Fliqlo-style Flip Clock
class FlipClockApp extends StatelessWidget {
  const FlipClockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'FlipO-Cock',
      debugShowCheckedModeBanner: false,
      home: FlipClockScreen(),
    );
  }
}

class FlipClockScreen extends StatefulWidget {
  const FlipClockScreen({super.key});

  @override
  State<FlipClockScreen> createState() => _FlipClockScreenState();
}

class _FlipClockScreenState extends State<FlipClockScreen> {
  late Timer _timer;
  late DateTime _time;

  @override
  void initState() {
    super.initState();
    _time = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _time = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final hour = _twoDigits(_time.hour);
    final minute = _twoDigits(_time.minute);
    final second = _twoDigits(_time.second);

    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 1000;
    final isTablet = size.width > 700 && size.width <= 1000;

    final fontSize = isDesktop
        ? size.width * 0.14
        : isTablet
            ? size.width * 0.16
            : size.width * 0.18;

    final spacing = isDesktop ? 40.0 : isTablet ? 25.0 : 12.0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 700),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
            child: child,
          ),
          child: Container(
            key: ValueKey('$hour:$minute:$second'),
            padding: EdgeInsets.symmetric(horizontal: spacing),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDigit(hour[0], fontSize),
                _buildDigit(hour[1], fontSize),
                SizedBox(width: spacing),
                _buildColon(fontSize),
                SizedBox(width: spacing),
                _buildDigit(minute[0], fontSize),
                _buildDigit(minute[1], fontSize),
                SizedBox(width: spacing),
                _buildColon(fontSize),
                SizedBox(width: spacing),
                _buildDigit(second[0], fontSize * 0.8, Colors.grey[400]),
                _buildDigit(second[1], fontSize * 0.8, Colors.grey[400]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDigit(String value, double fontSize, [Color? color]) {
    return FlipDigit(value: value, fontSize: fontSize, color: color);
  }

  Widget _buildColon(double fontSize) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _dot(fontSize),
        SizedBox(height: fontSize * 0.25),
        _dot(fontSize),
      ],
    );
  }

  Widget _dot(double fontSize) {
    return Container(
      width: fontSize * 0.15,
      height: fontSize * 0.15,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }
}

class FlipDigit extends StatelessWidget {
  final String value;
  final double fontSize;
  final Color? color;

  const FlipDigit({
    super.key,
    required this.value,
    required this.fontSize,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      transitionBuilder: (child, animation) {
        final flipAnim = Tween(begin: pi, end: 0.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeInOut),
        );

        return AnimatedBuilder(
          animation: flipAnim,
          builder: (context, child) {
            final isUnder = flipAnim.value > pi / 2;
            final displayValue = isUnder ? "" : value;

            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationX(flipAnim.value),
              child: Opacity(
                opacity: isUnder ? 0.2 : 1.0,
                child: Text(
                  displayValue,
                  style: TextStyle(
                    color: color ?? Colors.white,
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Courier',
                    letterSpacing: 2,
                    shadows: [
                      Shadow(
                        offset: const Offset(0, 2),
                        blurRadius: 10,
                        color: Colors.white.withOpacity(0.15),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
          child: child,
        );
      },
      child: Text(
        value,
        key: ValueKey(value),
        style: TextStyle(
          color: color ?? Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          fontFamily: 'Courier',
          letterSpacing: 2,
        ),
      ),
    );
  }
}
