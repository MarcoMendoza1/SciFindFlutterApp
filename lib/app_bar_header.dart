import 'package:flutter/material.dart';

class AppBarHeader extends StatelessWidget implements PreferredSizeWidget{
  const AppBarHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.purple[800],
      title: Row(
        children: [
          Icon(Icons.search, color: Colors.white),
          SizedBox(width: 8),
          Text(
            'SciFind',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.brightness_5, color: Colors.white),
          onPressed: () {
            
          },
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: IconButton(
            icon: Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              
            },
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
