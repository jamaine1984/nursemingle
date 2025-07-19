import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';

class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({Key? key}) : super(key: key);

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          'Privacy & Security',
          style: GoogleFonts.urbanist(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionCard(
            'Report & Block Users',
            'Report inappropriate behavior or block users',
            Icons.report,
            () => _showReportBlockDialog(),
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            'Privacy Policy',
            'Learn how we protect your privacy',
            Icons.privacy_tip,
            () => _showPrivacyPolicy(),
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            'Terms of Service',
            'Read our terms and conditions',
            Icons.description,
            () => _showTermsOfService(),
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            'Safety Guidelines',
            'Stay safe while using Nurse Mingle',
            Icons.security,
            () => _showSafetyGuidelines(),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary, size: 24),
        ),
        title: Text(
          title,
          style: GoogleFonts.urbanist(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.urbanist(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: AppColors.textSecondary, size: 16),
        onTap: onTap,
      ),
    );
  }

  void _showReportBlockDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report & Block Users'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('How to report a user:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('1. Go to their profile'),
            Text('2. Tap the three dots menu'),
            Text('3. Select "Report User"'),
            Text('4. Choose the reason and submit'),
            SizedBox(height: 16),
            Text('How to block a user:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('1. Go to their profile'),
            Text('2. Tap the three dots menu'),
            Text('3. Select "Block User"'),
            Text('4. Confirm your decision'),
            SizedBox(height: 16),
            Text('Blocked users cannot:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('• See your profile'),
            Text('• Send you messages'),
            Text('• Find you in discovery'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showBlockedUsersScreen();
            },
            child: const Text('Manage Blocked Users'),
          ),
        ],
      ),
    );
  }

  void _showBlockedUsersScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Blocked Users'),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.block, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'No Blocked Users',
                  style: GoogleFonts.urbanist(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Users you block will appear here',
                  style: GoogleFonts.urbanist(
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPrivacyPolicy() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Privacy Policy'),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Privacy Policy',
                  style: GoogleFonts.urbanist(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Last updated: ${DateTime.now().toString().split(' ')[0]}',
                  style: GoogleFonts.urbanist(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                _buildPolicySection(
                  'Information We Collect',
                  'We collect information you provide directly to us, such as when you create an account, update your profile, or contact us for support.',
                ),
                _buildPolicySection(
                  'How We Use Your Information',
                  'We use the information we collect to provide, maintain, and improve our services, process transactions, and communicate with you.',
                ),
                _buildPolicySection(
                  'Information Sharing',
                  'We do not sell, trade, or rent your personal information to third parties. We may share your information only in specific circumstances outlined in this policy.',
                ),
                _buildPolicySection(
                  'Data Security',
                  'We implement appropriate security measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction.',
                ),
                _buildPolicySection(
                  'Your Rights',
                  'You have the right to access, update, or delete your personal information. You can also opt out of certain communications from us.',
                ),
                _buildPolicySection(
                  'Contact Us',
                  'If you have any questions about this Privacy Policy, please contact us at privacy@nursemingle.com',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTermsOfService() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Terms of Service'),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Terms of Service',
                  style: GoogleFonts.urbanist(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Last updated: ${DateTime.now().toString().split(' ')[0]}',
                  style: GoogleFonts.urbanist(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                _buildPolicySection(
                  'Acceptance of Terms',
                  'By using Nurse Mingle, you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use our service.',
                ),
                _buildPolicySection(
                  'User Conduct',
                  'You agree to use our service responsibly and not to engage in any harmful, illegal, or inappropriate behavior.',
                ),
                _buildPolicySection(
                  'Account Responsibilities',
                  'You are responsible for maintaining the security of your account and for all activities that occur under your account.',
                ),
                _buildPolicySection(
                  'Prohibited Content',
                  'You may not post content that is illegal, harmful, threatening, abusive, defamatory, or otherwise objectionable.',
                ),
                _buildPolicySection(
                  'Termination',
                  'We may terminate or suspend your account at any time for violation of these terms or for any other reason.',
                ),
                _buildPolicySection(
                  'Changes to Terms',
                  'We reserve the right to modify these terms at any time. We will notify you of any changes by posting the new terms on this page.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSafetyGuidelines() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Safety Guidelines'),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Safety Guidelines',
                  style: GoogleFonts.urbanist(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 24),
                _buildSafetyTip(
                  'Meet in Public Places',
                  'Always meet new people in public, well-lit areas with other people around.',
                  Icons.public,
                ),
                _buildSafetyTip(
                  'Tell Someone Your Plans',
                  'Let a friend or family member know where you\'re going and who you\'re meeting.',
                  Icons.group,
                ),
                _buildSafetyTip(
                  'Trust Your Instincts',
                  'If something feels wrong, trust your gut feeling and remove yourself from the situation.',
                  Icons.psychology,
                ),
                _buildSafetyTip(
                  'Protect Personal Information',
                  'Don\'t share personal details like your address, workplace, or financial information.',
                  Icons.lock,
                ),
                _buildSafetyTip(
                  'Report Suspicious Behavior',
                  'Report any inappropriate or suspicious behavior to our support team immediately.',
                  Icons.report_problem,
                ),
                _buildSafetyTip(
                  'Video Chat First',
                  'Consider video chatting before meeting in person to verify the person\'s identity.',
                  Icons.video_call,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.emergency, color: AppColors.error),
                          const SizedBox(width: 8),
                          Text(
                            'Emergency Contacts',
                            style: GoogleFonts.urbanist(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text('Emergency: 911'),
                      const Text('Crisis Text Line: Text HOME to 741741'),
                      const Text('National Suicide Prevention Lifeline: 988'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPolicySection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.urbanist(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.urbanist(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyTip(String title, String content, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.urbanist(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: GoogleFonts.urbanist(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 