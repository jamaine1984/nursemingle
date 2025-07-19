import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class LiveLoungeScreen extends StatelessWidget {
  const LiveLoungeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Live Lounge'),
        centerTitle: true,
        elevation: 0,
      ),
      body: const Center(
        child: Text(
          'Group livestream events will appear here!',
          style: TextStyle(fontSize: 18, color: Colors.deepPurple),
        ),
      ),
    );
  }
} 
