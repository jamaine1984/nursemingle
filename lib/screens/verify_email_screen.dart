import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class VerifyEmailScreen extends StatefulWidget {
  static const routeName = '/verify-email';

  const VerifyEmailScreen({super.key});
  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _isLoading = false;
  bool _isVerified = false;
  String? _email;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _email = args?['email'];
    _checkVerification();
  }

  Future<void> _checkVerification() async {
    if (_email == null) return;
    setState(() => _isLoading = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final verified = await authProvider.checkVerificationStatus(_email!);
    setState(() {
      _isVerified = verified;
      _isLoading = false;
    });
    if (verified && mounted) {
      Navigator.pushReplacementNamed(context, '/profile-setup');
    }
  }

  Future<void> _resendEmail() async {
    if (_email == null) return;
    setState(() => _isLoading = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.sendVerificationEmail(_email!);
    setState(() => _isLoading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification email resent.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Email')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isVerified ? Icons.check_circle : Icons.email,
              size: 64,
              color: _isVerified ? Colors.green : Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              _isVerified
                  ? 'Email verified! Redirecting...'
                  : 'Check your email for a verification link.',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 12),
            if (!_isVerified)
              const Text('Didn\'t get it? Check spam or resend below.'),
            const SizedBox(height: 32),
            if (_isLoading)
              const CircularProgressIndicator()
            else if (!_isVerified) ...[
              ElevatedButton(
                onPressed: _resendEmail,
                child: const Text('Resend Verification Email'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _checkVerification,
                child: const Text('I\'ve Verified My Email'),
              ),
            ]
          ],
        ),
      ),
    );
  }
} 
