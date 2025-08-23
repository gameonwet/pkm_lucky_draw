import 'package:pkm_lucky_draw/cards/pokedex.dart';
import 'package:pkm_lucky_draw/common/route_drawer.dart';
import 'package:flutter/material.dart';

class PokemonDisplay extends StatelessWidget {
  const PokemonDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      drawer: RouteDrawer(),
      body: ListView.builder(
        itemCount: pokedex.length,
        itemBuilder: (context, index) {
          final pkm = Pokemon.fromJson(pokedex[index]);
          final id = pkm.id;
          final name = pkm.name;
          final type = pkm.type;

          return ListTile(
            leading: Text('#$id'),
            title: Text(name.english),
            subtitle: Text("$type"),
            trailing: Image.asset(pkm.image.hires ?? pkm.image.sprite),
          );
        },
      ),
    );
  }
}
