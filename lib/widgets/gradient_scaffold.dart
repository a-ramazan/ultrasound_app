import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class GradientScaffold extends StatelessWidget {
  const GradientScaffold({
    super.key,
    required this.child,
    this.bottomNavigationBar,
    this.safeTop = true,
  });

  final Widget child;
  final Widget? bottomNavigationBar;
  final bool safeTop;

  @override
  Widget build(BuildContext context) {
    final body = Container(
      decoration: const BoxDecoration(gradient: AppColors.pageGradient),
      child: child,
    );

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: safeTop ? SafeArea(child: body) : body,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
