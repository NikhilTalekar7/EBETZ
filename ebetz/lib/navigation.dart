import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:ebetz/notification.dart';
import 'package:ebetz/user_my_matches.dart';
import 'package:flutter/material.dart';
import 'package:ebetz/home.dart';
import 'package:ebetz/profile.dart';
import 'package:provider/provider.dart';

import 'notification_provider.dart';

class NavigatorScreen extends StatefulWidget {
  const NavigatorScreen(
    int i, {
    super.key,
  });

  @override
  State<NavigatorScreen> createState() => _NavigatorScreenState();
}

class _NavigatorScreenState extends State<NavigatorScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 2) {
        // If "Alerts" tab is selected, mark all notifications as read
        Provider.of<NotificationProvider>(context, listen: false)
            .markAllAsRead();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = Provider.of<NotificationProvider>(context).unreadCount;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          const HomeScreen(),
          const UserMyMatches(),
          NotificationPage(), // Placeholder for Matches screen
          const ProfilePage(),
        ],
      ),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.black,
        onTap: _onItemTapped, // Add navigation logic here
        items: [
          const CurvedNavigationBarItem(
            child: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          const CurvedNavigationBarItem(
            child: Icon(Icons.stadium_outlined),
            label: 'Matches',
          ),
          CurvedNavigationBarItem(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_none), // Base icon
                if (unreadCount >
                    0) // Show badge only if there are unread notifications
                  Positioned(
                    top: -5, // Adjust to move the badge upward
                    right: -5, // Adjust to move the badge to the right
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$unreadCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Alerts',
          ),
          const CurvedNavigationBarItem(
            child: Icon(Icons.person_2_outlined),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}