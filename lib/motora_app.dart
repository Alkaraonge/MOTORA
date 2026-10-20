import 'package:flutter/material.dart';

import 'screens/home_shell.dart';
import 'theme/motora_theme.dart';

class MotoraApp extends StatefulWidget {
  const MotoraApp({super.key});

  @override
  State<MotoraApp> createState() => _MotoraAppState();
}

class _MotoraAppState extends State<MotoraApp> {
  int _themeIndex = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MOTORA',
      locale: const Locale('ar'),
      theme: motoraThemes[_themeIndex].theme,
      themeAnimationDuration: const Duration(milliseconds: 420),
      themeAnimationCurve: Curves.easeOutCubic,
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child ?? const SizedBox.shrink(),
      ),
      home: HomeShell(
        selectedThemeIndex: _themeIndex,
        onThemeChanged: (index) => setState(() => _themeIndex = index),
      ),
    );
  }
}
