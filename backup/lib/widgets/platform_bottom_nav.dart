import 'package:flutter/material.dart';
import 'dart:io';

class PlatformBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const PlatformBottomNav({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoBottomNav(
        currentIndex: currentIndex,
        onTap: onTap,
      );
    } else {
      return MaterialBottomNav(
        currentIndex: currentIndex,
        onTap: onTap,
      );
    }
  }
}

class CupertinoBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CupertinoBottomNav({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey[300]!,
            width: 0.5,
          ),
        ),
      ),
      child: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(context, 0, 'Home', Icons.home),
            _buildNavItem(context, 1, 'Favorites', Icons.favorite),
            _buildNavItem(context, 2, 'Settings', Icons.settings),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, String label, IconData icon) {
    final isActive = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? Colors.blue : Colors.grey),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.blue : Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class MaterialBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const MaterialBottomNav({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorites'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
      ],
    );
  }
}