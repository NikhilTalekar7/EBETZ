import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NotificationProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _notifications = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _unreadCount = 0;

  List<Map<String, dynamic>> get notifications => _notifications;
  int get unreadCount => _unreadCount;

  /// Key for AnimatedList to enable animations
  final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();

  /// Fetch notifications in real-time
  void fetchNotifications() {
    _firestore.collection('notifications').snapshots().listen((snapshot) {
      _notifications.clear();
      _unreadCount = 0;

      for (var doc in snapshot.docs) {
        final notification = doc.data();
        _notifications.add({
          ...notification,
          'id': doc.id, // Include document ID for individual updates
        });
        if (!(notification['read'] ?? false)) {
          _unreadCount++;
        }
      }

      // Sort notifications to display recent first
      _notifications.sort((a, b) => (b['timestamp'] as Timestamp)
          .compareTo(a['timestamp'] as Timestamp));
      notifyListeners(); // Notify UI of changes
    });
  }

  /// Add a notification to Firestore
  Future<void> addNotification({
    required String gameName,
    required String title,
    required String description,
  }) async {
    await _firestore.collection('notifications').add({
      'tournament': gameName,
      'title': title,
      'description': description,
      'timestamp': FieldValue.serverTimestamp(),
      'read': false, // New notifications are unread by default
    });
  }

  /// Mark a specific notification as read
  Future<void> markAsRead(String notificationId) async {
    await _firestore
        .collection('notifications')
        .doc(notificationId)
        .update({'read': true});

    // Update locally
    final index = _notifications.indexWhere((n) => n['id'] == notificationId);
    if (index != -1) {
      _notifications[index]['read'] = true;
      _unreadCount--;
      notifyListeners();
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    final batch = _firestore.batch();
    final snapshot = await _firestore.collection('notifications').get();

    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {'read': true});
    }

    await batch.commit();
    _unreadCount = 0;
    notifyListeners();
  }

  /// Remove all notifications with animation
  Future<void> clearAllNotifications() async {
    final batch = _firestore.batch();
    final snapshot = await _firestore.collection('notifications').get();

    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    // Perform the deletion in Firestore
    await batch.commit();

    // Clear notifications locally with animation
    for (int i = _notifications.length - 1; i >= 0; i--) {
      listKey.currentState?.removeItem(
        i,
        (context, animation) => SlideTransition(
          position: Tween<Offset>(
            begin: Offset.zero,
            end: const Offset(1, 0),
          ).animate(animation),
          child: Container(), // Placeholder during removal animation
        ),
        duration: const Duration(milliseconds: 300),
      );
    }
    _notifications.clear();
    _unreadCount = 0;

    notifyListeners();
  }
}