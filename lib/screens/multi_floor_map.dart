import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:rafiqi/constants/colors.dart';
import 'map_screen.dart';

class MultiFloorMap extends StatefulWidget {
  const MultiFloorMap({super.key});

  @override
  State<MultiFloorMap> createState() => _MultiFloorMapState();
}

class _MultiFloorMapState extends State<MultiFloorMap> {
  // Use a ValueNotifier to hold the currently selected door for the second floor
  // Initialize with a default second floor door, e.g., the top-left stairs
  final ValueNotifier<Offset> _secondFloorDoorNotifier =
      ValueNotifier<Offset>(const Offset(30, 8)); // Default for second floor

  @override
  void dispose() {
    _secondFloorDoorNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: MyColor.myBrown,
          foregroundColor: MyColor.offWhite,
          title: const Text(
            "Building Map",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: const TabBar(
            unselectedLabelColor: MyColor.accentBrown,
            labelStyle: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: 'Ground'),
              Tab(text: 'Second Floor'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            const MapScreen(floorNumber: 1),
            // Pass the ValueNotifier to the Second Floor MapScreen
            MapScreen(
              floorNumber: 2,
              secondFloorDoorNotifier: _secondFloorDoorNotifier,
            ),
          ],
        ),
        // Add a FloatingActionButton to let the user choose the start point
        floatingActionButton: SizedBox(
          width: 175,
          child: FloatingActionButton.extended(
            backgroundColor: MyColor.myBrown,
            onPressed: () {
              _showSecondFloorDoorSelection(context);
            },
            label: const Text('Choose Start \nPoint(2nd Floor)',style: TextStyle(
              fontSize: 12,
              color: Colors.white
            ),),
            icon: const Icon(Icons.elevator,color: Colors.white,),
          ),
        ),
      ),
    );
  }

  // Function to show the dialog for selecting the second floor door
  void _showSecondFloorDoorSelection(BuildContext context) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.info,
      animType: AnimType.rightSlide,
      title: 'Select Second Floor Start Point',
      desc: 'Choose which staircase you are starting from on the second floor.',
      btnOkText: 'Done',
      btnOkOnPress: () {}, // Simply dismisses the dialog
      body: Column(
        children: [
          RadioListTile<Offset>(
            title: const Text('Stairs Top Left (30, 8)'),
            value: const Offset(30, 8),
            groupValue: _secondFloorDoorNotifier.value,
            onChanged: (Offset? value) {
              if (value != null) {
                _secondFloorDoorNotifier.value = value;
                Navigator.of(context).pop(); // Close dialog after selection
              }
            },
          ),
          RadioListTile<Offset>(
            title: const Text('Stairs Top Right (78, 7)'),
            value: const Offset(78, 7),
            groupValue: _secondFloorDoorNotifier.value,
            onChanged: (Offset? value) {
              if (value != null) {
                _secondFloorDoorNotifier.value = value;
                Navigator.of(context).pop();
              }
            },
          ),
          RadioListTile<Offset>(
            title: const Text('Stairs Bottom Left (15, 43)'),
            value: const Offset(15, 43),
            groupValue: _secondFloorDoorNotifier.value,
            onChanged: (Offset? value) {
              if (value != null) {
                _secondFloorDoorNotifier.value = value;
                Navigator.of(context).pop();
              }
            },
          ),
          RadioListTile<Offset>(
            title: const Text('Stairs Bottom Right (93, 43)'),
            value: const Offset(93, 43),
            groupValue: _secondFloorDoorNotifier.value,
            onChanged: (Offset? value) {
              if (value != null) {
                _secondFloorDoorNotifier.value = value;
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    ).show();
  }
}
