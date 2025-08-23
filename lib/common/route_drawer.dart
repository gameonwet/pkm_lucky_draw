import 'package:flutter/material.dart';

class RouteDrawer extends StatelessWidget {
  const RouteDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          ListTile(
            title: Text('Pokemon Display'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/pkm_display');
            },
          ),
          ListTile(
            title: Text('Pokemon Drawing'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/pkm_drawing');
            },
          ),
        ],
      ),
    );
  }
}
