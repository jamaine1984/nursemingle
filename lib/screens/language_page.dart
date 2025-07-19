import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class LanguagePage extends StatelessWidget {
  const LanguagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final languages = [
      'English', 'Spanish', 'French', 'German', 'Chinese', 'Japanese', 'Korean', 'Hindi', 'Arabic',
      'Portuguese', 'Russian', 'Italian', 'Turkish', 'Vietnamese', 'Polish', 'Dutch', 'Indonesian',
      'Thai', 'Swedish', 'Greek', 'Czech', 'Danish', 'Finnish', 'Hungarian', 'Norwegian', 'Romanian',
      'Slovak', 'Ukrainian', 'Hebrew', 'Malay',
    ];
    // Device language detection
    final deviceLocale = View.of(context).platformDispatcher.locale.languageCode;
    String? detectedLanguage = languages.firstWhere(
      (lang) => lang.toLowerCase().startsWith(deviceLocale),
      orElse: () => 'English',
    );
    return Scaffold(
      appBar: AppBar(title: Text('Select Language', style: GoogleFonts.urbanist(fontWeight: FontWeight.bold))),
      body: Column(
        children: [
          if (detectedLanguage != 'English')
            Container(
              width: double.infinity,
              color: Colors.yellow[100],
              padding: const EdgeInsets.all(12),
              child: Text(
                'Detected device language: $detectedLanguage',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.deepPurple),
              ),
            ),
          Expanded(
            child: ListView.separated(
              itemCount: languages.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final isDetected = languages[i] == detectedLanguage;
                return ListTile(
                  title: Text(
                    languages[i],
                    style: isDetected
                        ? GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.deepPurple)
                        : null,
                  ),
                  trailing: isDetected ? const Icon(Icons.check_circle, color: Colors.deepPurple) : null,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Language changed to ${languages[i]}')),
                    );
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 
