import 'dart:io';

import 'package:flutter/material.dart';

class PreviewScreen extends StatelessWidget {
  const PreviewScreen({super.key, required this.imageFile});

  final File imageFile;

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
