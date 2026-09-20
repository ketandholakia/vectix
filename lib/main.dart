import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ui/editor_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: VectixApp(),
    ),
  );
}

class VectixApp extends StatelessWidget {
  const VectixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vectix',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const EditorScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
