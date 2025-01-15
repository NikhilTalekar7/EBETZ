import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'game_wise_tournaments.dart';
import 'notification_provider.dart';

class NotificationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Start listening for notifications
    Provider.of<NotificationProvider>(context, listen: false)
        .fetchNotifications();

    return Scaffold(
       appBar: AppBar(
        backgroundColor:const Color.fromRGBO(0, 0, 41, 1),
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Alerts",
          style: GoogleFonts.breeSerif(
            fontWeight: FontWeight.w700,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromRGBO(0, 0, 41, 1),
              Color.fromRGBO(53, 52, 92, 1),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // AppBar-like custom widget
              SizedBox(height: 20,),
              Expanded(
                child: Consumer<NotificationProvider>(
                  builder: (context, notificationProvider, _) {
                    // Sort notifications by recency (assumes notifications have a 'timestamp' field)
                    final notifications = notificationProvider.notifications;
                    notifications.sort((a, b) => b['timestamp']
                        .compareTo(a['timestamp'])); // Recent on top

                    return notifications.isEmpty
                        ? Center(
                            child: Text(
                              'No notifications yet!',
                              style: GoogleFonts.cairo(
                                fontSize: 18,
                                color: Colors.grey[300],
                              ),
                            ),
                          )
                        : AnimatedList(
                            key: notificationProvider.listKey,
                            initialItemCount: notifications.length,
                            itemBuilder: (context, index, animation) {
                              final notification = notifications[index];
                              final tournament =
                                  notification['tournament'] ?? 'No Tournament';
                              final title = notification['title'] ?? 'No title';
                              final description = notification['description'] ?? 
                                  'No description';
                              final isRead = notification['isRead'] ?? false;

                              return SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(1, 0),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8.0,
                                    horizontal: 16.0,
                                  ),
                                  child: GestureDetector(
                                    onTap: () {
                                      // Navigate to the tournaments page for the selected game
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => TournamentsPage(
                                            gameName: tournament,
                                            tournamentName: '',
                                          ),
                                        ),
                                      );
                                      // Mark notification as read-******----error---*****///
                                      notificationProvider.markAsRead(
                                          index as String);
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: isRead
                                              ? [
                                                  const Color.fromRGBO(
                                                      44, 62, 80, 0.8),
                                                  const Color.fromRGBO(
                                                      52, 73, 94, 0.8),
                                                ]
                                              : [
                                                  const Color.fromRGBO(
                                                      44, 62, 80, 1),
                                                  const Color.fromRGBO(
                                                      52, 73, 94, 1),
                                                ],
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.2),
                                            blurRadius: 10.0,
                                            offset: const Offset(0, 5),
                                          ),
                                        ],
                                        border: Border.all(
                                          color:
                                              Colors.white.withOpacity(0.3),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: ListTile(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          vertical: 12.0,
                                          horizontal: 16.0,
                                        ),
                                        leading: Container(
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: LinearGradient(
                                              colors: [
                                                Color.fromRGBO(255, 170, 86, 1),
                                                Color.fromRGBO(255, 94, 58, 1),
                                              ],
                                            ),
                                          ),
                                          padding: const EdgeInsets.all(8.0),
                                          child: const Icon(
                                            Icons.notifications,
                                            color: Colors.white,
                                            size: 36,
                                          ),
                                        ),
                                        title: Text(
                                          tournament,
                                          style: GoogleFonts.roboto(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18.0,
                                            color: Colors.white,
                                          ),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 6.0),
                                            Text(
                                              title,
                                              style: GoogleFonts.roboto(
                                                fontSize: 14.0,
                                                color: Colors.white70,
                                              ),
                                            ),
                                            const SizedBox(height: 6.0),
                                            Text(
                                              description,
                                              style: GoogleFonts.roboto(
                                                fontSize: 12.0,
                                                color: Colors.white60,
                                              ),
                                            ),
                                          ],
                                        ),
                                        trailing: const Icon(
                                          Icons.arrow_forward_ios,
                                          color: Colors.white70,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}