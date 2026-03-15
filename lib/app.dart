import 'package:flutter/material.dart';

import 'screens/upload_screen.dart';
import 'theme/app_theme.dart';

class UltrasoundApp extends StatelessWidget {
  const UltrasoundApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SonoBowel',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const UploadScreen(),
    );
  }
}
