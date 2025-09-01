import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:rafiqi/models/map_model.dart';

class MapScreen extends StatefulWidget {
  final int floorNumber;
  final ValueNotifier<Offset>? secondFloorDoorNotifier; // New optional parameter

  const MapScreen({
    super.key,
    required this.floorNumber,
    this.secondFloorDoorNotifier, // Initialize the new parameter
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late double cellSize;
  final int rows = 54;
  final int cols = 110;
  late List<Offset> walls;
  List<Offset> path = [];
  Rect? selectedRoomRect; // Renamed to avoid conflict with Room model
  List<MapButton> get floorButtons => widget.floorNumber == 1
      ? [
    // Ground Floor Buttons (17 total)
    MapButton(
      position: const Offset(59, 45), // Main Entrance
      dialogTitle: 'Main Entrance',
      dialogDescription: 'Welcome to the main entrance of the building.',
      icon: Icons.location_on,
    ),
    MapButton(
      position: const Offset(42, 35), // Room 42
      dialogTitle: 'Room 42',
      dialogDescription:
      'Main Artefacts \nStatue of Khafre \nStatue of Ka-aper \nStatue of a Scribe \nFalse-door stela of Ika',
    ),
    MapButton(
      position: const Offset(43, 40), // Room 47
      dialogTitle: 'Room 47',
      dialogDescription:
      'Main Artefacts \nStatue of Khafre \nStatue of Ka-aper \nStatue of a Scribe \nFalse-door stela of Ika',
    ),
    MapButton(
      position: const Offset(36, 40), // Room 46
      dialogTitle: 'Room 46',
      dialogDescription:
      'Main Artefacts \nSeated Statue of King Djoser \nScribe Statue \nHead of Userkaf',
    ),

    MapButton(
      position: const Offset(42, 31), // Room 37
      dialogTitle: 'Room 37',
      dialogDescription:
      'Main Artefacts \nStatuette of Khufu (Cheops) \nGrave goods of Queen Hetepheres \nSedan chair \nArmchair \nCasket with bracelets \nCanopy holder \nThe bed',
    ),
    MapButton(
      position: const Offset(42, 27.5), // Room 32
      dialogTitle: 'Room 32',
      dialogDescription:
      'Main Artefacts \nStatues of Rahotep and Nofret \nStatue of Seneb and his family \nMeidum geese \nFalse door of Iteti \nStatue of Pepi I',
    ),

    MapButton(
      position: const Offset(42, 20), // Room 22
      dialogTitle: 'Room 22',
      dialogDescription: '',
    ),

    MapButton(
      position: const Offset(42, 12), // Room 12
      dialogTitle: 'Gallery 12 ',
      dialogDescription:
      'Main Artefacts \nWall reliefs with scenes of an expedition to Punt \nShrine dedicated to Hathor by Thutmosis III \n Statue of the Goddess Hathor with Amenhotep II \n Statue of Thutmosis IV with his mother Tia \n Statue of Aset \n Statue of Senenmut with Neferura \n Statue of Thutmosis III seated \n Stela for Tetisheri \n Head of statue of Amenhotep III \n Statue of Amenhotep son of Hapu \n Statue of the God Khonsu as Tutankhamun \n Double statue of Sennefer and his wife Senay \n Sphinx of Thutmosis III',
    ),
    MapButton(
      position: const Offset(30, 12), // Room 11
      dialogTitle: 'Room 11',
      dialogDescription:
      'Main Artefacts \nHead of the Queen Hatshepsut \nSphinx of Hatshepsut \nStatue of Isis seated \nStanding statue of Thutmosis III',
    ),
    MapButton(
      position: const Offset(30, 16), // Room 16
      dialogTitle: 'Room 16',
      dialogDescription: 'Main Artefacts \nStatue of Amenemhat III',
    ),
    MapButton(
      position: const Offset(30, 23), // Room 26
      dialogTitle: 'Room 26',
      dialogDescription:
      'Main Artefacts \nStatue of Nebhepetre Mentuhotep (Mentuhotep II)',
    ),
    MapButton(
      position: const Offset(30, 27), // Room 31
      dialogTitle: 'Room 31',
      dialogDescription:
      'Main Artefacts \nStatue of Nebhepetre Mentuhotep (Mentuhotep II)',
    ),
    MapButton(
      position: const Offset(72, 27.5), // Room 34
      dialogTitle: 'Room 34',
      dialogDescription:
      'Main Artefacts \nHead of Alexander the Great \nPainting with mythological scenes of Oedipus \nBust of Zeus',
    ),

    MapButton(
      position: const Offset(72, 20), // Room 24
      dialogTitle: 'Room 24',
      dialogDescription: 'Room 24:',
    ),

    MapButton(
      position: const Offset(72, 12), // Room 14
      dialogTitle: 'Room 14',
      dialogDescription: '',
    ),
    MapButton(
      position: const Offset(77, 23), // Room 30
      dialogTitle: 'Room 30',
      dialogDescription: 'Main Artefacts \nStatue of Amenirdis',
    ),
    MapButton(
      position: const Offset(77, 9), // Room 10
      dialogTitle: 'Room 10',
      dialogDescription:
      'Main Artefacts \nStatue of Ramesses II as a child and the god Horun \nBust of Merenptah \nRamesses II massacring his enemies',
    ),
    MapButton(
      position: const Offset(53, 19), // Central Hall
      dialogTitle: 'Central Hall',
      dialogDescription:
      'Main Artefacts \nStatuary group of Amenhotep III',
    ),
    MapButton(
      position: const Offset(56, 26), // Central Hall
      dialogTitle: 'Central Hall',
      dialogDescription:
      'Main Artefacts \nStatuary group of Amenhotep III \nPyramidion of the pyramid of Amenemhat III \nFirst and Third Hatshepsut Sarcophagus \nSarcophagus of Merenptah reused by Psusennes I \nNaos of Ramses II',
    ),
    MapButton(
      position: const Offset(53, 6), // room 3
      dialogTitle: '3',
      dialogDescription:
      'Main Artefacts \nUnfinished head of Nefertiti \nSarcophagus in tomb 55 Valley of the Kings \nPortrait of Nefertiti \nColossus of Amenhotep IV- Akhenaten \nFragment of paving from Tell el-Amarna \nStatue of Akhenaten offering \nHead of Akhenaten \nAmarna period canonic vase \nSlab showing a scene of worship of the Aten \nHeads of princesses',
    ),
    MapButton(
      position: const Offset(53, 33), // room 43
      dialogTitle: '43',
      dialogDescription:
      'Main Artefacts \nNarmer Palette \nStatue of Hetepdief \nPanels of Hesire \nJubilee vase \nLibyan tribute tablet \nLabel of Hor-Aha (Menes) \nLotus flower vase \nVase with names of pharaohs \nVase with painted decoration \nStatue of King Khasekhemwy',
    ),
    MapButton(
      position: const Offset(92.5, 41), // Restrooms
      dialogTitle: 'Restrooms',
      dialogDescription: 'Public restrooms.',
      icon: Icons.wc,
    ),
  ]
      : [
    // Second Floor Buttons (20 total)
    MapButton(
      position: const Offset(41, 35), // Room 42
      dialogTitle: 'Gallery  42',
      dialogDescription: '',
    ),
    MapButton(
      position: const Offset(41, 31.5), // Room 37
      dialogTitle: 'Gallery  37',
      dialogDescription: '',
    ),
    MapButton(
      position: const Offset(41, 27.5), // Room 32
      dialogTitle: 'Gallery  32 ',
      dialogDescription: '.',
    ),
    MapButton(
      position: const Offset(41, 24), // Room 27
      dialogTitle: 'Gallery  27',
      dialogDescription: '',
    ),
    MapButton(
      position: const Offset(41, 20), // Room 22
      dialogTitle: 'Gallery  22',
      dialogDescription: '',
    ),
    MapButton(
      position: const Offset(41, 16), // Room 17
      dialogTitle: 'Gallery  17',
      dialogDescription: '',
    ),
    MapButton(
      position: const Offset(41, 12), // Room 12
      dialogTitle: 'Gallery  12',
      dialogDescription: '',
    ),
    MapButton(
      position: const Offset(71, 35.5),
      dialogTitle: 'Gallery  44',
      dialogDescription: 'Tiles and Statuettes'
      ,
    ),
    MapButton(
      position: const Offset(71, 31.5),
      dialogTitle: 'Gallery 39',
      dialogDescription: ' Vases and Statuettes',
    ),
    MapButton(
      position: const Offset(71, 28),
      dialogTitle: 'Gallery 34',
      dialogDescription: 'Daily Life',
    ),
    MapButton(
      position: const Offset(71, 24),
      dialogTitle: 'Gallery 29',
      dialogDescription: 'Manuscripts and Papyri',
    ),
    MapButton(
      position: const Offset(71, 20),
      dialogTitle: 'Gallery 24',
      dialogDescription: 'Papyri and Ostraca',
    ),
    MapButton(
      position: const Offset(71, 16.3),
      dialogTitle: 'Gallery 19',
      dialogDescription: ' Gods of Ancient Egypt',
    ),
    MapButton(
      position: const Offset(71, 12.5),
      dialogTitle: 'Gallery 14',
      dialogDescription:'Main Artefacts \nPortrait of a woman \nMask of a man \nMask of Ammonarin \nPortrait of a man \nPortrait of a young woman \nPortrait of two brothers \nPortrait of a boy'
      ,
    ),
    MapButton(
      position: const Offset(52.5, 6),
      dialogTitle: 'Gallery 3',
      dialogDescription: '',
    ),
    MapButton(
      position: const Offset(95, 41), // Restrooms
      dialogTitle: 'Restrooms',
      dialogDescription: 'Public restrooms.',
      icon: Icons.wc,
    ),
    MapButton(
      position: const Offset(66.5, 7.5),
      dialogTitle: 'Gallery 9',
      dialogDescription: 'Main Artefacts \nShrine for canopic vases \nAlabaster container for canopic vases \nPortable simulacrum of Anubis \nAlabaster basin with boat'
      ,
    ),
    MapButton(
      position: const Offset(38, 7.5),
      dialogTitle: 'Gallery 7',
      dialogDescription:'Main Artefacts \nThe first wooden shrine of Tutankhamun'
      ,
    ),
    MapButton(
      position: const Offset(38, 5),
      dialogTitle: 'Gallery 2',
      dialogDescription:'Main Artefacts \nFunerary mask of King Psusennes I \nFunerary mask of King Sheshonq II \nFunerary sandals of King Psusennes I \nPectoral of King Sheshonq I \nCanopic vases of King Psusennes I \nSarcophagus of King Sheshonq II \nSarcophagus of King Psusennes I \nFunerary mask of King Amenemope \nPectoral of King Amenemope \nFunerary mask of general Undebaunded \nPendant belonging to general Undebaunded \nCup belonging to general Undebaunded \nNecklaces belonging to King Psusennes I \nWater jug belonging to King Psusennes I \nAnklet belonging to King Psusennes I \nPlaque for the mummy of King Psusennes I'
      ,
    ),

    MapButton(
      position: const Offset(76.5, 8),
      dialogTitle: 'Gallery 10',
      dialogDescription: 'Main Artefacts \nStatue of the ka of Tutankhamun \nThrone of Tutankhamun \nCeremonial seat'
      ,
    ),
    MapButton(
      position: const Offset(76.5, 15),
      dialogTitle: 'Gallery 20',
      dialogDescription: 'Main Artefacts \nYuya and Tuya papyrus'
      ,
    ),
    MapButton(
      position: const Offset(76.5, 23),
      dialogTitle: 'Gallery 30',
      dialogDescription: 'Main Artefacts \nYuya mummy-shaped sarcophagus'
      ,
    ),
    MapButton(
      position: const Offset(76.5, 31),
      dialogTitle: 'Gallery 40',
      dialogDescription: 'Main Artefacts \nChair belonging to princess Satamun'
      ,
    ),
    MapButton(
      position: const Offset(76.5, 34),
      dialogTitle: 'Gallery 45',
      dialogDescription: 'Main Artefacts \nFunerary Mask of Tuya \nFunerary Mask of Yuya'
      ,
    ),
    MapButton(
      position: const Offset(80, 42),
      dialogTitle: 'Gallery 50',
      dialogDescription: 'Main Artefacts \nCoffin of the Queen Ahmose-Merytamun'

      ,
    ),
    MapButton(
      position: const Offset(90, 47),
      dialogTitle: 'Gallery 56',
      dialogDescription: 'Main Artefacts \nInner coffin and mummy board of Meritamun \nCoffins of Padiamun \nNedjmetmut Inner coffin \nTjnet Osorkon’s Funerary Papyrus'
      ,
    ),
    MapButton(
      position: const Offset(31, 45.5),
      dialogTitle: 'Gallery 53',
      dialogDescription: 'Main Artefacts \nRams Mummies \nMummy of a hunting dog \nMummies of the big Nile crocodile'
      ,
    ),
    MapButton(
      position: const Offset(29, 27), // Room 31
      dialogTitle: ' Gallery 31',
      dialogDescription:
      'Sarcophagi and Tombs Furniture',
    ),
  ];

  // Get the list of buttons based on the floor number
  List<Room> get roomsData => widget.floorNumber == 1
      ? [
    // Ground Floor Rooms
    Room(origin: Offset(35, 34.5), size: Size(11, 5), label: "Room 42"),
    Room(origin: Offset(35, 31.4), size: Size(11, 3.2), label: "Room 37"),
    Room(origin: Offset(35, 27), size: Size(11, 4.3), label: "Room 32"),
    Room(origin: Offset(35, 24), size: Size(11, 3), label: ""),
    Room(origin: Offset(35, 19), size: Size(11, 5), label: "Room 22"),
    Room(origin: Offset(35, 16), size: Size(11, 3), label: ""),
    Room(origin: Offset(35, 12), size: Size(11, 4), label: "Room 12"),

    Room(
        origin: Offset(64, 35),
        size: Size(12, 4.5),
        label: "Temporary Exhibitions"),
    Room(origin: Offset(64, 31.5), size: Size(12, 3), label: ""),
    Room(origin: Offset(64, 27.5), size: Size(12, 4), label: "room 34 "),
    Room(origin: Offset(64, 24), size: Size(12, 3.5), label: ""),
    Room(origin: Offset(64, 19.5), size: Size(12, 4), label: "Room 24"),
    Room(origin: Offset(64, 16.2), size: Size(12, 3), label: ""),
    Room(origin: Offset(64, 12), size: Size(12, 4), label: "Room 14"),

    Room(
        origin: Offset(53, 17), size: Size(5, 3), label: "Centeral Hall"),
    Room(origin: Offset(50, 4), size: Size(10, 5), label: "3"),
    Room(origin: Offset(29, 13), size: Size(2, 2), label: "11"),
    Room(origin: Offset(29, 17), size: Size(2, 2), label: "16"),
    Room(origin: Offset(29, 24), size: Size(2, 2), label: "26"),
    Room(origin: Offset(29, 28), size: Size(2, 2), label: "31"),
    Room(origin: Offset(35, 41), size: Size(2, 2), label: "46"),
    Room(origin: Offset(42, 41), size: Size(2, 2), label: "47"),
    Room(
        origin: Offset(53, 27), size: Size(4, 2), label: "Centeral Hall"),
    Room(origin: Offset(54, 36), size: Size(2, 2), label: "43"),

    //stairs
    Room(origin: Offset(29, 6), size: Size(6, 3), label: "Stairs"),
    Room(origin: Offset(75, 6), size: Size(7, 3), label: "Stairs"),
    Room(origin: Offset(17, 41), size: Size(8, 4), label: "Stairs"),
    Room(origin: Offset(87, 41), size: Size(6, 4), label: "Stairs"),
    Room(origin: Offset(80, 10), size: Size(2, 2), label: "10"),
    Room(origin: Offset(80, 24), size: Size(2, 2), label: "30"),
  ]
      : [
    // Second Floor Rooms
    // left
    Room(origin: Offset(34, 35), size: Size(11, 5), label: "Room 42"),
    Room(origin: Offset(34, 32), size: Size(11, 3), label: "Room 37"),
    Room(origin: Offset(34, 27.5), size: Size(11, 4), label: "Room 32"),
    Room(origin: Offset(34, 24.3), size: Size(11, 3), label: "Room 27"),
    Room(origin: Offset(34, 19.5), size: Size(11, 4.5), label: "Room 22"),
    Room(origin: Offset(34, 16.5), size: Size(11, 3), label: "Room 17"),
    Room(origin: Offset(34, 11.5), size: Size(11, 5), label: "Room 12"),
    //
    Room(origin: Offset(28, 28), size: Size(2, 2), label: "31"),

// right
    Room(origin: Offset(64, 35.4), size: Size(11, 4.2), label: "Room 44"),
    Room(origin: Offset(64, 32), size: Size(11, 3), label: "Room 39"),
    Room(origin: Offset(64, 27.8), size: Size(11, 4), label: "Room 34"),
    Room(origin: Offset(64, 24.3), size: Size(11, 3), label: "Room 29"),
    Room(origin: Offset(64, 19.5), size: Size(11, 4.5), label: "Room 24"),
    Room(origin: Offset(64, 16.3), size: Size(11, 3), label: "Room 19"),
    Room(origin: Offset(64, 12), size: Size(11, 4.5), label: "Room 14"),
    //
    Room(origin: Offset(80, 9), size: Size(2, 2), label: "10"),
    Room(origin: Offset(80, 16), size: Size(2, 2), label: "20"),
    Room(origin: Offset(80, 24), size: Size(2, 2), label: "30"),
    Room(origin: Offset(80, 32), size: Size(2, 2), label: "40"),
    Room(origin: Offset(80, 35), size: Size(2, 2), label: "45"),

    Room(origin: Offset(49.5, 4), size: Size(10, 5), label: "3"),
    Room(origin: Offset(37, 6), size: Size(2, 2), label: "2"),
    Room(origin: Offset(37, 8.5), size: Size(2, 2), label: "7"),
    Room(origin: Offset(30, 46.5), size: Size(2, 2), label: "53"),
    Room(origin: Offset(88, 48), size: Size(2, 2), label: "56"),
    Room(origin: Offset(84, 43), size: Size(2, 2), label: "50"),

    Room(origin: Offset(70, 8.5), size: Size(2, 2), label: "9"),
  ];

  Offset get door {
    if (widget.floorNumber == 1) {
      return const Offset(59, 46);
    } else {
      return widget.secondFloorDoorNotifier!.value;
    }
  }

  String get backgroundImage =>
      widget.floorNumber == 1 ? 'assets/images/groundf.png' : 'assets/images/floor.png';

  @override
  void initState() {
    super.initState();
    walls = widget.floorNumber == 1
        ? _generateFirstFloorWalls()
        : _generateSecondFloorWalls();

    // Add a listener to the notifier for the second floor door
    widget.secondFloorDoorNotifier?.addListener(_onSecondFloorDoorChanged);
  }

  @override
  void dispose() {
    widget.secondFloorDoorNotifier?.removeListener(_onSecondFloorDoorChanged);
    super.dispose();
  }

  void _onSecondFloorDoorChanged() {
    // When the second floor door changes, clear the path and selected room
    // This forces a recalculation of the path if a room was previously selected
    setState(() {
      path = [];
      selectedRoomRect = null;
    });
  }

  List<Offset> _generateFirstFloorWalls() {
    List<Offset> wallList = [];
    //colomns
    //left
    for (int i = 11; i < 39; i++) wallList.add(Offset(46, i.toDouble()));
    for (int i = 11; i < 40; i++) {
      if (![14, 18, 21, 25, 29, 32, 37].contains(i))
        wallList.add(Offset(34, i.toDouble()));
    }
    //right
    for (int i = 11; i < 39; i++) wallList.add(Offset(64, i.toDouble()));
    for (int i = 11; i < 40; i++) {
      if (![14, 18, 21, 25, 29, 32, 37].contains(i))
        wallList.add(Offset(76, i.toDouble()));
    }
    //center
    for (int i = 16; i < 35; i++) wallList.add(Offset(60, i.toDouble()));
    for (int i = 16; i < 35; i++) wallList.add(Offset(49, i.toDouble()));

    //rows
    for (int i = 35; i < 51; i++) wallList.add(Offset(i.toDouble(), 39));
    for (int i = 60; i < 78; i++) wallList.add(Offset(i.toDouble(), 39));
    for (int i = 14; i < 96; i++) {
      if (i != 54 && i != 55) {
        wallList.add(Offset(i.toDouble(), 45));
        wallList.add(Offset(i.toDouble(), 44));
      }
    }
    //left
    for (int i = 35; i < 46; i++) {
      wallList.add(Offset(i.toDouble(), 34));
      wallList.add(Offset(i.toDouble(), 31));
      wallList.add(Offset(i.toDouble(), 27));
      wallList.add(Offset(i.toDouble(), 23));
      wallList.add(Offset(i.toDouble(), 19));
      wallList.add(Offset(i.toDouble(), 16));
      wallList.add(Offset(i.toDouble(), 11));
    }
    for (int i = 29; i < 32; i++) {
      wallList.add(Offset(i.toDouble(), 30));
      wallList.add(Offset(i.toDouble(), 26));
      wallList.add(Offset(i.toDouble(), 19));
      wallList.add(Offset(i.toDouble(), 15));
    }
    //right
    for (int i = 65; i < 76; i++) {
      wallList.add(Offset(i.toDouble(), 34));
      wallList.add(Offset(i.toDouble(), 31));
      wallList.add(Offset(i.toDouble(), 27));
      wallList.add(Offset(i.toDouble(), 23));
      wallList.add(Offset(i.toDouble(), 19));
      wallList.add(Offset(i.toDouble(), 16));
      wallList.add(Offset(i.toDouble(), 11));
    }
    for (int i = 79; i < 82; i++) {
      wallList.add(Offset(i.toDouble(), 26));
      wallList.add(Offset(i.toDouble(), 12));
    }
    //center
    for (int i = 50; i < 60; i++) {
      wallList.add(Offset(i.toDouble(), 16));
    }
    for (int i = 50; i < 60; i++) {
      wallList.add(Offset(i.toDouble(), 3));
    }
    for (int i = 53; i < 57; i++) {
      wallList.add(Offset(i.toDouble(), 26));

      wallList.add(Offset(i.toDouble(), 29));
      wallList.add(Offset(i.toDouble(), 38));
    }

    return wallList;
  }

  List<Offset> _generateSecondFloorWalls() {
    List<Offset> wallList = [];
    //colomns
    //left rooms
    // left
    for (int i = 4; i < 41; i++) {
      wallList.add(Offset(27, i.toDouble()));
    }
    for (int i = 41; i < 45; i++) {
      wallList.add(Offset(23, i.toDouble()));
      wallList.add(Offset(87, i.toDouble()));
    }
    for (int i = 0; i < 40; i++) {
      if (![9, 10, 14, 18, 21, 25, 29, 33, 37].contains(i))
        wallList.add(Offset(34, i.toDouble()));
    }
    //  right

    for (int i = 11; i < 39; i++) {
      wallList.add(Offset(46, i.toDouble()));
    }
    //right rooms
    //  left
    for (int i = 11; i < 39; i++) {
      wallList.add(Offset(64, i.toDouble()));
    }
    //  right
    for (int i = 4; i < 41; i++) {
      wallList.add(Offset(82, i.toDouble()));
    }
    for (int i = 47; i < 55; i++) {
      wallList.add(Offset(87, i.toDouble()));
    }

    for (int i = 11; i < 40; i++) {
      if (![14, 17, 21, 25, 29, 33, 37].contains(i))
        wallList.add(Offset(76, i.toDouble()));
    }
    //center
    for (int i = 16; i < 36; i++) {
      wallList.add(Offset(60, i.toDouble()));
      wallList.add(Offset(49, i.toDouble()));
    }

    for (int i = 3; i < 9; i++) {
      wallList.add(Offset(49, i.toDouble()));
      wallList.add(Offset(60, i.toDouble()));
    }

    //horizontal
    // down rooms
    // left
    for (int i = 35; i < 51; i++) wallList.add(Offset(i.toDouble(), 39));
    // right
    for (int i = 60; i < 78; i++) wallList.add(Offset(i.toDouble(), 39));
    // up rooms
    // left
    for (int i = 35; i < 50; i++) wallList.add(Offset(i.toDouble(), 11));
    // right
    for (int i = 58; i < 77; i++) wallList.add(Offset(i.toDouble(), 11));
    // center down entrance
    for (int i = 0; i < 95; i++) {
      if (i != 42 && i != 43) {
        wallList.add(Offset(i.toDouble(), 46));
      }
    }
    // center up

    for (int i = 34; i < 76; i++) {
      if (i != 41 &&
          i != 42 &&
          i != 53 &&
          i != 54 &&
          i != 55 &&
          i != 56 &&
          i != 57) {
        wallList.add(Offset(i.toDouble(), 8));
      }
    }
    //left
    for (int i = 35; i < 46; i++) {
      wallList.add(Offset(i.toDouble(), 34));
      wallList.add(Offset(i.toDouble(), 31));
      wallList.add(Offset(i.toDouble(), 27));
      wallList.add(Offset(i.toDouble(), 23));
      wallList.add(Offset(i.toDouble(), 19));
      wallList.add(Offset(i.toDouble(), 16));
    }
    for (int i = 28; i < 31; i++) {
      wallList.add(Offset(i.toDouble(), 30));
    }
    for (int i = 23; i < 28; i++) {
      wallList.add(Offset(i.toDouble(), 40));
    }
    for (int i = 17; i < 23; i++) {
      wallList.add(Offset(i.toDouble(), 44));
    }
    //right
    for (int i = 65; i < 76; i++) {
      wallList.add(Offset(i.toDouble(), 34));
      wallList.add(Offset(i.toDouble(), 31));
      wallList.add(Offset(i.toDouble(), 27));
      wallList.add(Offset(i.toDouble(), 23));
      wallList.add(Offset(i.toDouble(), 19));
      wallList.add(Offset(i.toDouble(), 16));
    }
    for (int i = 79; i < 82; i++) {
      wallList.add(Offset(i.toDouble(), 40));

      wallList.add(Offset(i.toDouble(), 37));

      wallList.add(Offset(i.toDouble(), 34));

      wallList.add(Offset(i.toDouble(), 26));

      wallList.add(Offset(i.toDouble(), 18));

      wallList.add(Offset(i.toDouble(), 11));
    }
    for (int i = 83; i < 88; i++) {
      wallList.add(Offset(i.toDouble(), 40));
    }
    for (int i = 87; i < 94; i++) {
      wallList.add(Offset(i.toDouble(), 44));
    }
    //center
    for (int i = 50; i < 60; i++) {
      wallList.add(Offset(i.toDouble(), 16));
      wallList.add(Offset(i.toDouble(), 35));
    }
    for (int i = 50; i < 60; i++) {
      wallList.add(Offset(i.toDouble(), 3));
    }

    return wallList;
  }

  Offset _findClosestPointToRoom(Offset origin, Size size) {
    final double centerX = origin.dx + size.width / 2;
    final double centerY = origin.dy + size.height / 2;
    return Offset(centerX.floorToDouble(), centerY.floorToDouble());
  }

  List<Offset> _findPathBFS(Offset start, Offset end) {
    Queue<List<Offset>> queue = Queue();
    Set<Offset> visited = {};
    Set<Offset> wallSet = walls.toSet();

    queue.add([start]);
    visited.add(start);

    while (queue.isNotEmpty) {
      List<Offset> currentPath = queue.removeFirst();
      Offset current = currentPath.last;

      if (current == end) return currentPath;

      for (Offset direction in [
        const Offset(1, 0),
        const Offset(-1, 0),
        const Offset(0, 1),
        const Offset(0, -1)
      ]) {
        Offset next =
        Offset(current.dx + direction.dx, current.dy + direction.dy);
        if (next.dx >= 0 &&
            next.dy >= 0 &&
            next.dx < cols &&
            next.dy < rows &&
            !visited.contains(next) &&
            !wallSet.contains(next)) {
          visited.add(next);
          queue.add([...currentPath, next]);
        }
      }
    }
    return [];
  }

  void _showFloorInfoDialog(
      BuildContext context, String title, String description) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.info,
      animType: AnimType.rightSlide,
      title: title,
      desc: description,
      btnOkOnPress: () {},
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    cellSize = screenSize.width / cols;
    final double gridWidth = cols * cellSize;
    final double gridHeight = rows * cellSize;

    final List<Rect> pixelRooms = List.generate(
      roomsData.length,
          (i) => Rect.fromLTWH(
        roomsData[i].origin.dx * cellSize,
        roomsData[i].origin.dy * cellSize,
        roomsData[i].size.width * cellSize,
        roomsData[i].size.height * cellSize,
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: InteractiveViewer(
          maxScale: 5,
          minScale: 1,
          child: GestureDetector(
            onTapDown: (details) {
              final localPos = details.localPosition;
              final x = (localPos.dx / cellSize).floor();
              final y = (localPos.dy / cellSize).floor();
              final pixel = Offset(x * cellSize, y * cellSize);

              for (int i = 0; i < roomsData.length; i++) {
                final roomRect = pixelRooms[i];
                if (roomRect.contains(pixel)) {
                  final target = _findClosestPointToRoom(
                      roomsData[i].origin, roomsData[i].size);
                  final newPath = _findPathBFS(door, target);
                  setState(() {
                    selectedRoomRect = roomRect;
                    path = newPath;
                  });
                  break;
                }
              }
            },
            child: Stack(
              children: [
                Image.asset(
                  backgroundImage,
                  width: gridWidth,
                  height: gridHeight,
                  fit: BoxFit.fill,
                ),
                // Use ValueListenableBuilder to rebuild only when the door changes
                ValueListenableBuilder<Offset>(
                  valueListenable:
                  widget.secondFloorDoorNotifier ?? ValueNotifier(door),
                  builder: (context, currentDoor, child) {
                    // Update the door for GridPainter when the notifier changes
                    return CustomPaint(
                      size: Size(gridWidth, gridHeight),
                      painter: GridPainter(
                        cellSize: cellSize,
                        rows: rows,
                        cols: cols,
                        walls: walls,
                        door: currentDoor, // Use the currentDoor from notifier
                        selectedRoomRect: selectedRoomRect,
                        path: path,
                        pixelRooms: pixelRooms,
                        roomLabels: roomsData.map((room) => room.label).toList(),
                      ),
                    );
                  },
                ),
                ...floorButtons.map((buttonData) {
                  return Positioned(
                    // Adjust position slightly to center the icon within its grid cell if needed,
                    // or to offset it for better visibility near the actual point of interest.
                    left: buttonData.position.dx * cellSize,
                    top: buttonData.position.dy * cellSize,
                    child: IconButton(
                      icon: Icon(buttonData.icon),
                      iconSize:
                      cellSize * 2, // Adjust icon size relative to cell
                      color: Colors.blue.shade800, // Customize icon color
                      onPressed: () {
                        _showFloorInfoDialog(
                          context,
                          buttonData.dialogTitle,
                          buttonData.dialogDescription,
                        );
                      },
                      // style: IconButton.styleFrom(
                      //   backgroundColor: Colors.white.withOpacity(0.6),
                      //   shape: const CircleBorder(),
                      //   padding: EdgeInsets.all(cellSize * 0.1),
                      // ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}