import 'package:flutter/material.dart';

class Piece {
  final String type;
  final int rotation;
  const Piece({required this.type, this.rotation = 0});
}

class Position {
  final int row;
  final int col;
  const Position({required this.row, required this.col});
}

const Map<String, List<List<List<int>>>> tetrominoShapes = {
  'I': [
    [
      [0, 0, 0, 0],
      [1, 1, 1, 1],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
    ], // 0°
    [
      [0, 1, 0, 0],
      [0, 1, 0, 0],
      [0, 1, 0, 0],
      [0, 1, 0, 0],
    ], // 90°
    [
      [0, 0, 0, 0],
      [0, 0, 0, 0],
      [1, 1, 1, 1],
      [0, 0, 0, 0],
    ], // 180°
    [
      [0, 0, 1, 0],
      [0, 0, 1, 0],
      [0, 0, 1, 0],
      [0, 0, 1, 0],
    ], // 270°
  ],
  'O': [
    [
      [1, 1],
      [1, 1],
    ], // All rotations are the same
    [
      [1, 1],
      [1, 1],
    ],
    [
      [1, 1],
      [1, 1],
    ],
    [
      [1, 1],
      [1, 1],
    ],
  ],
  'T': [
    [
      [0, 1, 0],
      [1, 1, 1],
      [0, 0, 0],
    ], // 0°
    [
      [0, 1, 0],
      [0, 1, 1],
      [0, 1, 0],
    ], // 90°
    [
      [0, 0, 0],
      [1, 1, 1],
      [0, 1, 0],
    ], // 180°
    [
      [0, 1, 0],
      [1, 1, 0],
      [0, 1, 0],
    ], // 270°
  ],
  'S': [
    [
      [0, 1, 1],
      [1, 1, 0],
      [0, 0, 0],
    ], // 0°
    [
      [0, 1, 0],
      [0, 1, 1],
      [0, 0, 1],
    ], // 90°
    [
      [0, 0, 0],
      [0, 1, 1],
      [1, 1, 0],
    ], // 180°
    [
      [1, 0, 0],
      [1, 1, 0],
      [0, 1, 0],
    ], // 270°
  ],
  'Z': [
    [
      [1, 1, 0],
      [0, 1, 1],
      [0, 0, 0],
    ], // 0°
    [
      [0, 0, 1],
      [0, 1, 1],
      [0, 1, 0],
    ], // 90°
    [
      [0, 0, 0],
      [1, 1, 0],
      [0, 1, 1],
    ], // 180°
    [
      [0, 1, 0],
      [1, 1, 0],
      [1, 0, 0],
    ], // 270°
  ],
  'J': [
    [
      [1, 0, 0],
      [1, 1, 1],
      [0, 0, 0],
    ], // 0°
    [
      [0, 1, 1],
      [0, 1, 0],
      [0, 1, 0],
    ], // 90°
    [
      [0, 0, 0],
      [1, 1, 1],
      [0, 0, 1],
    ], // 180°
    [
      [0, 1, 0],
      [0, 1, 0],
      [1, 1, 0],
    ], // 270°
  ],
  'L': [
    [
      [0, 0, 1],
      [1, 1, 1],
      [0, 0, 0],
    ], // 0°
    [
      [0, 1, 0],
      [0, 1, 0],
      [0, 1, 1],
    ], // 90°
    [
      [0, 0, 0],
      [1, 1, 1],
      [1, 0, 0],
    ], // 180°
    [
      [1, 1, 0],
      [0, 1, 0],
      [0, 1, 0],
    ], // 270°
  ],
};

class TetrisBoard extends StatelessWidget {
  final List<List<int>> gameBoard;
  final Piece? currentPiece;
  final Position? piecePosition;

  // --- CONFIG ---
  final int rows;
  final int cols;

  const TetrisBoard({
    super.key,
    required this.gameBoard,
    this.currentPiece,
    this.piecePosition,
    this.rows = 20,
    this.cols = 10,
  });

  static const Map<int, Color> pieceColors = {
    1: Color(0xFF00FFFF),
    2: Color(0xFFFDD835),
    3: Color(0xFFBE18FB),
    4: Color(0xFF00FF00),
    5: Color(0xFFFF0000),
    6: Color(0xFF0000FF),
    7: Color(0xFFFFA500),
    8: Color(0xFF7F7F7F),
  };

  int _pieceTypeToInt(String type) {
    switch (type) {
      case 'I':
        return 1;
      case 'O':
        return 2;
      case 'T':
        return 3;
      case 'S':
        return 4;
      case 'Z':
        return 5;
      case 'J':
        return 6;
      case 'L':
        return 7;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: cols / rows,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: rows * cols,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cols,
        ),
        itemBuilder: (context, index) {
          int row = index ~/ cols;
          int col = index % cols;
          int blockType = gameBoard[row][col];

          if (currentPiece != null && piecePosition != null) {
            final shapeMatrix =
                tetrominoShapes[currentPiece!.type]![currentPiece!.rotation];
            int relativeRow = row - piecePosition!.row;
            int relativeCol = col - piecePosition!.col;

            if (relativeRow >= 0 &&
                relativeRow < shapeMatrix.length &&
                relativeCol >= 0 &&
                relativeCol < shapeMatrix[relativeRow].length &&
                shapeMatrix[relativeRow][relativeCol] == 1) {
              blockType = _pieceTypeToInt(currentPiece!.type);
            }
          }
          return _TetrisBlock(blockType: blockType);
        },
      ),
    );
  }
}

class _TetrisBlock extends StatelessWidget {
  final int blockType;
  const _TetrisBlock({required this.blockType});

  @override
  Widget build(BuildContext context) {
    final color = TetrisBoard.pieceColors[blockType] ?? Colors.transparent;
    if (color == Colors.transparent) {
      return Container();
    }

    return Container(
      margin: const EdgeInsets.all(1.0),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: color, width: 1),
        borderRadius: BorderRadius.circular(1.5),
        boxShadow: [
          BoxShadow(color: color, blurRadius: 3, spreadRadius: 1),
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black.withValues(alpha: 0.8)
                : Colors.white54.withValues(alpha: 0.8),
            blurRadius: 2.0,
            spreadRadius: -1.0,
            blurStyle: BlurStyle.inner,
          ),
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.transparent.withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.3),
            blurRadius: 2.0,
            spreadRadius: 1.0,
            blurStyle: BlurStyle.inner,
          ),
        ],
      ),
    );
  }
}
