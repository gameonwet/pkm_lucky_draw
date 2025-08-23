import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'screens/pokemon_display.dart';
import 'screens/pokemon_drawing.dart';

void main() {
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(onGenerateRoute: (settings) {
      if (settings.name == "/pkm_drawing") {
        return CupertinoPageRoute(
          builder: (context) => PokemonDrawing(),
        );
      }

      return CupertinoPageRoute(
        builder: (context) => PokemonDisplay(),
      );
    });
  }
}
