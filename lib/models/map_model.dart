import 'package:flutter/material.dart';

class MapButton {
  final Offset position;
  final String dialogTitle;
  final String dialogDescription;
  final IconData icon;

  MapButton({
    required this.position,
    required this.dialogTitle,
    required this.dialogDescription,
    this.icon = Icons.info_outline, // Default icon
  });
}

// New Room Model
class Room {
  final Offset origin;
  final Size size;
  final String label;

  Room({
    required this.origin,
    required this.size,
    required this.label,
  });
}

class GridPainter extends CustomPainter {
  final double cellSize;
  final int rows;
  final int cols;
  final List<Offset> walls;
  final Offset door;
  final Rect? selectedRoomRect; // Renamed
  final List<Offset> path;
  final List<Rect>
      pixelRooms; // Renamed for clarity that these are the calculated pixel Reacts
  final List<String> roomLabels;

  GridPainter({
    required this.cellSize,
    required this.rows,
    required this.cols,
    required this.walls,
    required this.door,
    required this.selectedRoomRect, // Updated parameter name
    required this.path,
    required this.pixelRooms, // Updated parameter name
    required this.roomLabels,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint gridPaint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 1;

    final Paint wallPaint = Paint()..color = Colors.black;
    final Paint roomFillPaint = Paint()
      ..color = Colors.yellow.withValues(alpha: 0.15);
    final Paint roomOutlinePaint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final Paint pathPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2;

    final Paint doorPaint = Paint()..color = Colors.green;
    final Paint selectedRoomPaint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.2);

    final textStyle = TextStyle(color: Colors.black, fontSize: 12);

    // Draw rooms background and outlines
    for (final r in pixelRooms) {
      canvas.drawRect(r, roomFillPaint);
      canvas.drawRect(r, roomOutlinePaint);
    }

    // Draw door
    canvas.drawRect(
      Rect.fromLTWH(door.dx * cellSize, door.dy * cellSize, 1.5 * cellSize,
          1.5 * cellSize),
      doorPaint,
    );

    // Draw path lines
    for (int i = 0; i < path.length - 1; i++) {
      final p1 = Offset(path[i].dx * cellSize + cellSize / 2,
          path[i].dy * cellSize + cellSize / 2);
      final p2 = Offset(path[i + 1].dx * cellSize + cellSize / 2,
          path[i + 1].dy * cellSize + cellSize / 2);
      canvas.drawLine(p1, p2, pathPaint);
    }

    // Draw room labels
    for (int i = 0; i < pixelRooms.length; i++) {
      final rect = pixelRooms[i];
      final textSpan = TextSpan(
        text: roomLabels[i],
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: rect.width);
      textPainter.paint(
        canvas,
        Offset(rect.center.dx - textPainter.width / 2,
            rect.center.dy - textPainter.height / 2),
      );
    }

    // Highlight selected room
    if (selectedRoomRect != null) {
      canvas.drawRect(selectedRoomRect!, selectedRoomPaint);
    }
  }

  @override
  bool shouldRepaint(covariant GridPainter oldDelegate) {
    return oldDelegate.path != path ||
        oldDelegate.selectedRoomRect != selectedRoomRect ||
        oldDelegate.door != door; // Repaint if the door changes
  }
}
