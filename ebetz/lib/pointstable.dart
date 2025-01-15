import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PointsTablePage extends StatefulWidget {
  final String tournamentName;
  final String tournamentId;

  const PointsTablePage({super.key, required this.tournamentName,required this.tournamentId,});

  @override
  _PointsTablePageState createState() => _PointsTablePageState();
}

class _PointsTablePageState extends State<PointsTablePage> {
  final TextEditingController _teamNameController = TextEditingController();
  final TextEditingController _pointsController = TextEditingController();

  Future<void> _addPoints() async {
    if (_teamNameController.text.isEmpty || _pointsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    try {
      final teamName = _teamNameController.text.trim();
      final points = int.tryParse(_pointsController.text.trim());

      if (points == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid points value")),
        );
        return;
      }

      await FirebaseFirestore.instance.collection('points_table').add({
        'tournamentName': widget.tournamentName,
        'tournamentId': widget.tournamentId,
        'teamName': teamName,
        'points': points,
      });

      _teamNameController.clear();
      _pointsController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Points added successfully")),
      );
    } catch (e) {
      print("Error adding points: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to add points")),
      );
    }
  }

  Stream<List<Map<String, dynamic>>> _getPointsTable() {
    return FirebaseFirestore.instance
        .collection('points_table')
        .where('tournamentId', isEqualTo: widget.tournamentId)
        //.where('tournamentName', isEqualTo: widget.tournamentName)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  void _savePointsTable() {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Points table saved successfully")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "${widget.tournamentName} - Points Table",
          style: GoogleFonts.breeSerif(
            fontWeight: FontWeight.w700,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_sharp, color: Colors.white),
          onPressed: () {
          Navigator.pop(context);
          },
        ),
      ),
      
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _teamNameController,
                  decoration:  InputDecoration(
                    labelText: "Team Name",
                    labelStyle:GoogleFonts.cairo(color: Colors.white) ,
                    border:const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _pointsController,
                  keyboardType: TextInputType.number,
                  decoration:  InputDecoration(
                    labelText: "Points",
                    labelStyle:GoogleFonts.cairo(color: Colors.white) ,
                    border:const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _addPoints,
                  child:  Text("Add Points",style: GoogleFonts.cairo(color: Colors.white),),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _getPointsTable(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return  Center(child: Text("No points added yet.",style: GoogleFonts.cairo(color: Colors.white)));
                }

                final pointsTable = snapshot.data!;

                return ListView.builder(
                  itemCount: pointsTable.length,
                  itemBuilder: (context, index) {
                    final entry = pointsTable[index];
                    return ListTile(
                      title: Text(entry['teamName']),
                      trailing: Text("${entry['points']} pts"),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right:16 ,left:16 ,top:16 ,bottom: 28),
            child: ElevatedButton(
              onPressed: _savePointsTable,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(0, 122, 255, 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Save Points Table",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}