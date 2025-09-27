// Uygulamadaki tüm sayfalar için standart bir yapı ve arka plan sunan widget.
import 'package:alisveris_sepeti/widgets/app_background.dart';
import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  final AppBar? appBar;
  final Widget body;
  final FloatingActionButton? floatingActionButton;
  final String imagePath;

  const AppScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: appBar,
      body: AppBackground(
        imagePath: imagePath,
        child: body,
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}
