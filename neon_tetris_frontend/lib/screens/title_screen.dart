import 'package:flutter/material.dart';

class TitleScreen extends StatelessWidget {
  const TitleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          SizedBox(height: 10,),
          ClipRRect(
            clipBehavior: Clip.antiAlias,
            borderRadius: BorderRadiusGeometry.circular(20),
            child: Image.asset('assets/neon-tetris.png', scale: 1.25,),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  SizedBox(height: 10),
                  Text(
                    "NEON TETRIS",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  CircularProgressIndicator(color: Colors.grey),
                  SizedBox(height: 20),
                  Text(
                    'Initializing app....',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
