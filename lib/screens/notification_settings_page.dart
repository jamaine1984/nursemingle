import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool pushEnabled = true;
  bool emailEnabled = false;
  bool smsEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notification Settings', style: GoogleFonts.urbanist(fontWeight: FontWeight.bold))),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Push Notifications'),
            value: pushEnabled,
            onChanged: (val) => setState(() => pushEnabled = val),
          ),
          SwitchListTile(
            title: const Text('Email Notifications'),
            value: emailEnabled,
            onChanged: (val) => setState(() => emailEnabled = val),
          ),
          SwitchListTile(
            title: const Text('SMS Notifications'),
            value: smsEnabled,
            onChanged: (val) => setState(() => smsEnabled = val),
          ),
        ],
      ),
    );
  }
} 
