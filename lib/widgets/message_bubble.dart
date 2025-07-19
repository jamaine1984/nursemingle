import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isFromMe;
  final DateTime timestamp;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isFromMe,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isFromMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          left: isFromMe ? 50 : 0,
          right: isFromMe ? 0 : 50,
          bottom: 8,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isFromMe ? AppColors.primary : Colors.grey[200],
          borderRadius: BorderRadius.circular(20).copyWith(
            bottomLeft: isFromMe ? const Radius.circular(20) : const Radius.circular(5),
            bottomRight: isFromMe ? const Radius.circular(5) : const Radius.circular(20),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: isFromMe ? Colors.white : Colors.grey[700],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(timestamp),
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: isFromMe ? Colors.white70 : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
} 
