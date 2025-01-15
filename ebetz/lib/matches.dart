import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebetz/notification_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'admin_page.dart';
import 'match_details_page.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Map<String, dynamic>> games = [
    {"image": "assets/cutout/bgmi.png", "color": Colors.green, "name": "BGMI"},
    {"image": "assets/cutout/pubgw.png", "color": Colors.amber, "name": "PUBG"},
    {
      "image": "assets/cutout/raven.png",
      "color": Colors.blue,
      "name": "FORTNITE"
    },
    {
      "image": "assets/cutout/apex.png",
      "color": Colors.grey,
      "name": "APEX LEGENDS"
    },
    {
      "image": "assets/cutout/indus.png",
      "color": Colors.red,
      "name": "INDUS BATTLE ROYALE"
    },
    {
      "image": "assets/cutout/freefire.png",
      "color": Colors.pink,
      "name": "FREEFIRE"
    },
    {
      "image": "assets/cutout/cod.png",
      "color": Colors.purple,
      "name": "Call Of Duty"
    },
  ];

  List<Map<String, dynamic>> matchDetails = [];
  final TextEditingController _tournamentNameController =
      TextEditingController();
  final TextEditingController _numPlayersController = TextEditingController();
  final TextEditingController _matchFeeController = TextEditingController();
  final TextEditingController _prizePoolController = TextEditingController();

  DateTime? _selectedStartTime;

  void _pickStartTime(BuildContext context) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (selectedDate != null) {
      final selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (selectedTime != null) {
        setState(() {
          _selectedStartTime = DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            selectedTime.hour,
            selectedTime.minute,
          );
        });
      }
    }
  }

  String _formatStartTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd hh:mm:ss a').format(dateTime);
  }

  void _showTournamentBottomSheet(BuildContext context, String gameName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black.withOpacity(0.8),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        final deviceHeight = MediaQuery.of(context).size.height;
        final padding = MediaQuery.of(context).viewInsets.bottom;
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              top: 16.0,
              bottom: padding + deviceHeight * 0.02,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Enter Tournament Details',
                  style: GoogleFonts.breeSerif(
                      fontSize: deviceHeight * 0.03,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent),
                ),
                SizedBox(height: deviceHeight * 0.02),
                _buildNonEditableTextField('Game Name', gameName),
                SizedBox(height: deviceHeight * 0.02),
                _buildTextField('Tournament Name', _tournamentNameController),
                SizedBox(height: deviceHeight * 0.02),
                _buildTextField('Number of Players', _numPlayersController,
                    keyboardType: TextInputType.number),
                SizedBox(height: deviceHeight * 0.02),
                _buildTextField('Match Fee', _matchFeeController,
                    keyboardType: TextInputType.number),
                SizedBox(height: deviceHeight * 0.02),
                _buildTextField('Prize Pool', _prizePoolController,
                    keyboardType: TextInputType.number),
                SizedBox(height: deviceHeight * 0.02),
                _buildStartTimeButton(context),
                SizedBox(height: deviceHeight * 0.03),
                _buildSubmitButton(),
              ],
            ),
          ),
        );
      },
    );
  }

  String? gameName;

  TextField _buildNonEditableTextField(String label, String value) {
    gameName = value;
    return TextField(
      controller: TextEditingController(text: value),
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.cairo(color: Colors.grey.shade400),
        filled: true,
        fillColor: Colors.white10,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    );
  }

  TextField _buildTextField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.cairo(color: Colors.grey.shade400),
        filled: true,
        fillColor: Colors.white10,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    );
  }

  ElevatedButton _buildStartTimeButton(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    return ElevatedButton(
      onPressed: () => _pickStartTime(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      child: Text(
        _selectedStartTime != null
            ? "Start Time: ${_formatStartTime(_selectedStartTime!)}"
            : "Select Start Time",
        style: GoogleFonts.cairo(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: deviceHeight * 0.02,
        ),
      ),
    );
  }

  ElevatedButton _buildSubmitButton() {
    final deviceHeight = MediaQuery.of(context).size.height;
    return ElevatedButton(
      onPressed: () async {
        if (_selectedStartTime != null) {
          try {
            // Generate a random tournament ID
            final tournamentId =
                DateTime.now().millisecondsSinceEpoch.toString();

            // Prepare tournament data
            final tournamentData = {
              "tournamentId": tournamentId,
              "gameName": gameName,
              "tournamentName": _tournamentNameController.text,
              "numPlayers": int.parse(_numPlayersController.text),
              "matchFee": int.parse(_matchFeeController.text),
              "prizePool": int.parse(_prizePoolController.text),
              "startTime": _selectedStartTime,
              "status": "Upcoming",
            };

            // Save to Firestore
            await FirebaseFirestore.instance
                .collection('tournaments')
                .doc(tournamentId)
                .set(tournamentData);

            // Add the notification
            final DateTime? selectedStartTime = _selectedStartTime;
            String formattedStartTime = "Time not available";

            if (selectedStartTime != null) {
              formattedStartTime = DateFormat('yyyy-MM-dd | hh:mm a')
                  .format(selectedStartTime.toLocal());
            }
            Provider.of<NotificationProvider>(context, listen: false)
                .addNotification(
              gameName: "$gameName",
              title: "New Tournament: ${_tournamentNameController.text}",
              description: "Starts at $formattedStartTime",
            );

            // Clear fields after submission
            _clearFields();

            // Navigate to match details page
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MatchDetailsPage(
                  matchDetails: [tournamentData],
                  tournamentId: tournamentId,
                ),
              ),
            );
            _updateTournamentStatus(tournamentId, _selectedStartTime!);

            print("Tournament data successfully saved to Firestore.");
          } catch (e) {
            print("Error saving tournament data: $e");
          }
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      child: Text(
        'Submit',
        style:
            GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold,fontSize: deviceHeight * 0.02,),
      ),
    );
  }

  void _updateTournamentStatus(String tournamentId, DateTime startTime) async {
    final currentTime = DateTime.now();

    String newStatus;

    if (currentTime.isBefore(startTime)) {
      newStatus = "Upcoming";
    } else if (currentTime.isAfter(startTime) &&
        currentTime.isBefore(startTime.add(Duration(hours: 2)))) {
      // Tournament has started and is ongoing
      newStatus = "Live";
    } else {
      newStatus = "Completed";
    }

    // Update the tournament status in Firestore
    await FirebaseFirestore.instance
        .collection('tournaments')
        .doc(tournamentId)
        .update({"status": newStatus});

    print("Tournament status updated to: $newStatus");
  }

  void _clearFields() {
    _tournamentNameController.clear();
    _numPlayersController.clear();
    _matchFeeController.clear();
    _prizePoolController.clear();
    _selectedStartTime = null;
  }

  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Create Bet',
          style: GoogleFonts.breeSerif(
            fontSize: deviceHeight * 0.03,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_sharp, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AdminPage()),
            );
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(deviceWidth * 0.04),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: deviceWidth * 0.04,
            mainAxisSpacing: deviceWidth * 0.04,
          ),
          itemCount: games.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () =>
                  _showTournamentBottomSheet(context, games[index]["name"]),
              child: GameCard(
                imagePath: games[index]["image"]!,
                color: games[index]["color"],
                title: games[index]["name"]!,
              ),
            );
          },
        ),
      ),
    );
  }
}

class GameCard extends StatelessWidget {
  final String imagePath;
  final Color color;
  final String title;

  const GameCard({
    required this.imagePath,
    required this.color,
    required this.title,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Main card container
        Container(
          height: screenHeight * 0.18,
          width: screenWidth * 0.4,
          decoration: BoxDecoration(
            color: color.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16.0),
            border:
                Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: RotatedBox(
              quarterTurns: -1, // Rotates the text -90 degrees clockwise
              child: Text(
                title,
                style: GoogleFonts.ubuntu(
                  fontSize: screenHeight * 0.022,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),

        // Floating image
        Positioned(
          top: -screenHeight * 0.03,
          right: -screenWidth * 0.08,
          child: SizedBox(
            width: screenWidth * 0.45,
            height: screenHeight * 0.21,
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }
}
