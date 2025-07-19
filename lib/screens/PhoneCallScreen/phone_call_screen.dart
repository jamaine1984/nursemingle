import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/livekit_service.dart';
import '../../utils/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

class PhoneCallScreen extends StatefulWidget {
  final String roomName;
  final String participantId;
  final String participantName;
  final bool isIncoming;

  const PhoneCallScreen({
    super.key,
    required this.roomName,
    required this.participantId,
    required this.participantName,
    this.isIncoming = false,
  });

  @override
  State<PhoneCallScreen> createState() => _PhoneCallScreenState();
}

class _PhoneCallScreenState extends State<PhoneCallScreen> {
  final LiveKitService _liveKitService = LiveKitService();
  bool _isConnecting = true;
  bool _isConnected = false;
  bool _isMuted = false;
  bool _isSpeakerOn = false;
  String _connectionStatus = 'Connecting...';
  Timer? _callTimer;
  Duration _callDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    if (widget.isIncoming) {
      _showIncomingCallUI();
    } else {
      _initializeCall();
    }
  }

  void _showIncomingCallUI() {
    setState(() {
      _isConnecting = false;
      _connectionStatus = 'Incoming call...';
    });
  }

  Future<void> _initializeCall() async {
    try {
      setState(() {
        _connectionStatus = 'Connecting...';
        _isConnecting = true;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;
      
      if (user == null) {
        _showError('User not authenticated');
        return;
      }

      // Connect to LiveKit room for audio-only call
      final connected = await _liveKitService.connect(
        roomName: widget.roomName,
        participantName: user.fullName,
        participantId: user.id,
      );

      if (connected) {
        setState(() {
          _isConnected = true;
          _isConnecting = false;
        });
        
        // Mock room listeners - in a real implementation this would set up LiveKit room listeners
        // _liveKitService.room?.addListener(_onRoomUpdate);
        print('Setting up room listeners for ${widget.roomName}');
        
        // Enable microphone
        await _liveKitService.enableMicrophone();
        
        setState(() {
          _isMuted = false;
        });
      } else {
        setState(() {
          _isConnecting = false;
        });
      }
    } catch (e) {
      setState(() {
        _isConnecting = false;
      });
      print('Error connecting to call: $e');
    }
  }

  Future<void> _acceptCall() async {
    await _initializeCall();
  }

  Future<void> _declineCall() async {
    Navigator.of(context).pop();
  }

  void _onRoomUpdate() {
    if (!mounted) return;
    setState(() {});
  }

  void _startCallTimer() {
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _callDuration = Duration(seconds: _callDuration.inSeconds + 1);
        });
      }
    });
  }

  Future<void> _toggleMute() async {
    try {
      if (_isMuted) {
        await _liveKitService.enableMicrophone();
      } else {
        await _liveKitService.disableMicrophone();
      }
      setState(() {
        _isMuted = !_isMuted;
      });
    } catch (e) {
      _showError('Failed to toggle microphone: $e');
    }
  }

  void _toggleSpeaker() {
    setState(() {
      _isSpeakerOn = !_isSpeakerOn;
    });
    // In a real implementation, you would configure audio routing here
  }

  Future<void> _endCall() async {
    try {
      _callTimer?.cancel();
      await _liveKitService.disconnect();
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint('Error ending call: $e');
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  void dispose() {
    // _liveKitService.room?.removeListener(_onRoomUpdate);
    _liveKitService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: widget.isIncoming && !_isConnected
            ? _buildIncomingCallScreen()
            : _isConnecting
                ? _buildConnectingScreen()
                : _buildActiveCallScreen(),
      ),
    );
  }

  Widget _buildIncomingCallScreen() {
    return Column(
      children: [
        const SizedBox(height: 60),
        
        // Incoming call label
        Text(
          'Incoming Call',
          style: GoogleFonts.urbanist(
            color: AppColors.onPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        
        const SizedBox(height: 40),
        
        // Caller avatar
        CircleAvatar(
          radius: 80,
          backgroundColor: AppColors.onPrimary.withValues(alpha: 0.2),
          child: const Icon(
            Icons.person,
            size: 100,
            color: AppColors.onPrimary,
          ),
        ),
        
        const SizedBox(height: 30),
        
        // Caller name
        Text(
          widget.participantName,
          style: GoogleFonts.urbanist(
            color: AppColors.onPrimary,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 10),
        
        Text(
          'Nurse Mingle Voice Call',
          style: GoogleFonts.urbanist(
            color: AppColors.onPrimary.withValues(alpha: 0.8),
            fontSize: 16,
          ),
        ),
        
        const Spacer(),
        
        // Answer/Decline buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 40),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Decline button
              GestureDetector(
                onTap: _declineCall,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.call_end,
                    color: Colors.white,
                    size: 35,
                  ),
                ),
              ),
              
              // Accept button
              GestureDetector(
                onTap: _acceptCall,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.call,
                    color: Colors.white,
                    size: 35,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConnectingScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 80,
          backgroundColor: AppColors.onPrimary.withValues(alpha: 0.2),
          child: const Icon(
            Icons.person,
            size: 100,
            color: AppColors.onPrimary,
          ),
        ),
        
        const SizedBox(height: 30),
        
        Text(
          widget.participantName,
          style: GoogleFonts.urbanist(
            color: AppColors.onPrimary,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 20),
        
        Text(
          _connectionStatus,
          style: GoogleFonts.urbanist(
            color: AppColors.onPrimary.withValues(alpha: 0.8),
            fontSize: 18,
          ),
        ),
        
        const SizedBox(height: 30),
        
        const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ],
    );
  }

  Widget _buildActiveCallScreen() {
    return Column(
      children: [
        const SizedBox(height: 60),
        
        // Call status
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.onPrimary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _connectionStatus,
            style: GoogleFonts.urbanist(
              color: AppColors.onPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        
        const SizedBox(height: 40),
        
        // Participant avatar
        CircleAvatar(
          radius: 80,
          backgroundColor: AppColors.onPrimary.withValues(alpha: 0.2),
          child: const Icon(
            Icons.person,
            size: 100,
            color: AppColors.onPrimary,
          ),
        ),
        
        const SizedBox(height: 30),
        
        // Participant name
        Text(
          widget.participantName,
          style: GoogleFonts.urbanist(
            color: AppColors.onPrimary,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 10),
        
        // Call duration
        Text(
          _formatDuration(_callDuration),
          style: GoogleFonts.urbanist(
            color: AppColors.onPrimary.withValues(alpha: 0.8),
            fontSize: 18,
          ),
        ),
        
        const Spacer(),
        
        // Control buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Mute button
              _buildControlButton(
                icon: _isMuted ? Icons.mic_off : Icons.mic,
                onPressed: _toggleMute,
                isActive: !_isMuted,
              ),
              
              // Speaker button
              _buildControlButton(
                icon: _isSpeakerOn ? Icons.volume_up : Icons.volume_down,
                onPressed: _toggleSpeaker,
                isActive: _isSpeakerOn,
              ),
              
              // End call button
              _buildControlButton(
                icon: Icons.call_end,
                onPressed: _endCall,
                isActive: false,
                backgroundColor: Colors.red,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required bool isActive,
    Color? backgroundColor,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: backgroundColor ?? (isActive 
              ? AppColors.onPrimary.withValues(alpha: 0.2)
              : AppColors.onPrimary.withValues(alpha: 0.1)),
          shape: BoxShape.circle,
          border: Border.all(
            color: isActive ? AppColors.onPrimary : AppColors.onPrimary.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: backgroundColor == Colors.red ? Colors.white : 
                 (isActive ? AppColors.onPrimary : AppColors.onPrimary.withValues(alpha: 0.7)),
          size: 28,
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
} 
