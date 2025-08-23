import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:lottie/lottie.dart';
import 'package:pkm_lucky_draw/cards/xy7.dart';
import 'package:pkm_lucky_draw/common/route_drawer.dart';
import 'package:pkm_lucky_draw/cards/pokemon_card.dart';

class PokemonDrawing extends StatefulWidget {
  const PokemonDrawing({super.key});

  @override
  State<PokemonDrawing> createState() => _PokemonDrawingState();
}

class _PokemonDrawingState extends State<PokemonDrawing>
    with TickerProviderStateMixin {
  late final AnimationController _chestController;

  var isDrew = false;
  var wallet = 1000.0;

  final rareProbs = {
    // 'Common': 0,
    // 'Uncommon': 0,
    'Rare': 10,
    'Rare Holo': 5,
    'Rare Holo EX': 3,
    'Rare Ultra': 1.5,
    'Rare Secret': 0.5,
  };

  final translations = {
    'Common': '●',
    'Uncommon': '◆',
    'Rare': '★',
    'Rare Holo': '★ Holo',
    'Rare Holo EX': 'EX',
    'Rare Ultra': '★ Rainbow',
    'Rare Secret': '★ Secret',
  };

  final sellingPriceList = {
    'Common': 2,
    'Uncommon': 5,
    'Rare': 20,
    'Rare Holo': 50,
    'Rare Holo EX': 100,
    'Rare Ultra': 250,
    'Rare Secret': 1000,
  };

  @override
  void initState() {
    super.initState();

    _chestController = AnimationController(vsync: this);

    // Loop the shaking animation
    // * Triggered whenever animation controller value changes
    _chestController.addListener(() {
      if (isDrew) {
        _chestController.forward();
        return;
      }

      if (_chestController.value >= 0.31) {
        _chestController.reverse();
      }
      if (_chestController.value <= 0) {
        _chestController.forward();
      }
    });
  }

  @override
  void dispose() {
    _chestController.dispose();
    super.dispose();
  }

  void _playChestAnimation() {
    setState(() {
      isDrew = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        title: Text("\$: $wallet"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text("Information"),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: [
                      Text(
                        "You begin with 1000 coins. Each chest costs \$100 and each has 5 cards inside. "
                        "Every card has its own value, and if you're lucky, you could either earn money or lose money "
                        "depending on the rarity of the cards. Earn as much money as possible! Good luck!",
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    child: Text("Close"),
                  ),
                ],
              ),
            ),
            icon: Icon(Icons.help),
          ),
        ],
      ),
      drawer: RouteDrawer(),
      floatingActionButton: isDrew
          ? null
          : FloatingActionButton.extended(
              icon: Icon(Icons.casino),
              label: Text("Draw"),
              onPressed: () {
                if (wallet - 100 < 0) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      content:
                          Text('You do not have enough money to continue.'),
                    ),
                  );
                  return;
                }

                setState(() {
                  wallet -= 100;
                });

                _playChestAnimation(); // Call the function to play the animation
                drawCards();
              }),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Use PageView for swiping between card slots
          if (isDrew) cardStack() else Expanded(child: Container()),
          SizedBox(
            height: 250, // Fixed height for the treasure chest
            child: Lottie.asset(
              'images/treasure-chest.json',
              controller: _chestController,
              onLoaded: (composition) {
                _chestController.duration = composition.duration;
                _chestController.forward();
              },
            ),
          ),
        ],
      ),
    );
  }

  List<PokemonCard> drawCards() {
    final allCards = <PokemonCard>[];

    allCards.addAll(xy7.map((e) => PokemonCard.fromJson(e)));
    allCards.shuffle();

    final availableRares = allCards
        .map((e) => e.rarity)
        .toSet()
        .where((e) => e != null && e.startsWith('Rare'));

    final rarities = <String, num>{};
    var remaining = 100.0;
    for (final r in availableRares) {
      rarities[r!] = rareProbs[r]!;
      remaining -= rareProbs[r]!;
    }
    rarities['Uncommon'] = remaining * 0.375;
    rarities['Common'] = remaining * 0.625;

    final cards = <PokemonCard>[];
    for (var i = 0; i < 5; i++) {
      final random = Random().nextDouble() * 100;
      var cumulative = 0.0;
      var rarity = '';

      for (final entry in rarities.entries) {
        final prob = entry.value;

        cumulative += prob;
        if (random <= cumulative) {
          rarity = entry.key;
          break;
        }
      }

      final filtered = allCards.where((e) => e.rarity == rarity).toList();

      filtered.shuffle();
      cards.addAll(filtered.take(1));
    }

    return cards;
  }

  Widget cardStack() {
    var cards = <PokemonCard>[];
    cards = drawCards();
    print(cards.length);
    return Expanded(
      child: CardSwiper(
        backCardOffset: const Offset(19, 24),
        padding: const EdgeInsets.symmetric(horizontal: 125, vertical: 55.5),
        cardsCount: 6,
        isLoop: false,
        onEnd: () {
          var total = 0.0;
          for (final card in cards) {
            total += sellingPriceList[card.rarity] ?? 0;
          }
          var profit = total - 100;

          setState(() {
            isDrew = false;
            _chestController.animateTo(0);
          });

          showAdaptiveDialog(
              context: context,
              builder: (context) => AlertDialog(
                    icon: Icon(Icons.monetization_on),
                    title: Text('Pack Summary'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final card in cards)
                          ListTile(
                            leading: Text('(${translations[card.rarity]})'),
                            title: Text(card.name ?? '???'),
                            trailing: Text(
                              '\$${sellingPriceList[card.rarity] ?? 0}',
                            ),
                          ),
                        ListTile(
                            title: Text('Total Value'),
                            trailing: Text('\$$total')),
                        ListTile(
                            title: Text('Total Profit'),
                            trailing: Text('\$$profit')),
                      ],
                    ),
                  ));

          setState(() {
            wallet += total;
          });
        },
        cardBuilder: (
          context,
          index,
          horizontalOffsetPercentage,
          verticalOffsetPercentage,
        ) =>
            ClipRRect(
          //borderRadius:
          //BorderRadius.circular(50.0), // Adjust the radius as needed
          child: Card(
            elevation: 4,
            child: Container(
              alignment: Alignment.center,
              child: index == 0
                  ? Image.asset('images/xy7-cover.png', fit: BoxFit.cover)
                  : Image.network(
                      cards[index - 1].images?.small ?? 'images/xy7-cover.png',
                      fit: BoxFit.cover,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
