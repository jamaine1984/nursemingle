import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:livekit_client/livekit_client.dart';
import '../../providers/auth_provider.dart';
import '../../services/livekit_service.dart';
import '../../utils/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

class VideoCallScreen extends StatefulWidget {
  final String roomName;
  final String participantId;
  final bool isIncoming;

  const VideoCallScreen({
    super.key,
    required this.roomName,
    required this.participantId,
    this.isIncoming = false,
  });

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  final LiveKitService _liveKitService = LiveKitService();
  bool _isConnecting = true;
  bool _isConnected = false;
  bool _isMuted = false;
  bool _isVideoEnabled = true;
  bool _isFrontCamera = true;
  String _connectionStatus = 'Connecting...';
  
  final List<TrackPublication> _remoteVideoTracks = [];
  LocalVideoTrack? _localVideoTrack;
  LocalAudioTrack? _localAudioTrack;

  @override
  void initState() {
    super.initState();
    _initializeCall();
  }

  Future<void> _initializeCall() async {
    try {
      setState(() {
        _connectionStatus = 'Connecting to call...';
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;
      
      if (user == null) {
        _showError('User not authenticated');
        return;
      }

      // Connect to LiveKit room
      await _liveKitService.connect(
        roomName: widget.roomName,
        participantName: user.fullName,
        participantId: user.id,
      );

      // Set up event listeners
      _setupRoomListeners();
      
      // Enable camera and microphone
      await _enableCameraAndMicrophone();
      
      setState(() {
        _isConnecting = false;
        _isConnected = true;
        _connectionStatus = 'Connected';
      });

    } catch (e) {
      setState(() {
        _isConnecting = false;
        _connectionStatus = 'Connection failed';
      });
      _showError('Failed to connect: $e');
    }
  }

  void _setupRoomListeners() {
    // Mock room listeners - in a real implementation this would set up LiveKit room listeners
    // _liveKitService.room?.addListener(_onRoomUpdate);
    print('Setting up room listeners for ${widget.roomName}');
  }

  void _onRoomUpdate() {
    if (!mounted) return;
    
    setState(() {
      // Mock room update - in a real implementation this would update from LiveKit room state
      // _localVideoTrack = _liveKitService.room?.localParticipant?.videoTrackPublications
      //     .where((pub) => pub.track != null)
      //     .map((pub) => pub.track!)
      //     .first;
      // _remoteVideoTrack = _liveKitService.room?.remoteParticipants.values
      //     .expand((p) => p.videoTrackPublications)
      //     .where((pub) => pub.track != null)
      //     .map((pub) => pub.track!)
      //     .first;
    });
  }

  Future<void> _enableCameraAndMicrophone() async {
    try {
      final cameraEnabled = await _liveKitService.enableCamera();
      final micEnabled = await _liveKitService.enableMicrophone();
      
      if (cameraEnabled && micEnabled) {
        // Mock track setup - in a real implementation this would get tracks from LiveKit
        // _localVideoTrack = _liveKitService.room?.localParticipant?.videoTrackPublications
        //     .where((pub) => pub.track is LocalVideoTrack)
        //     .map((pub) => pub.track as LocalVideoTrack)
        //     .firstOrNull;
        //     
        // _localAudioTrack = _liveKitService.room?.localParticipant?.audioTrackPublications
        //     .where((pub) => pub.track is LocalAudioTrack)
        //     .map((pub) => pub.track as LocalAudioTrack)
        //     .firstOrNull;
      }
    } catch (e) {
      print('Error enabling camera/microphone: $e');
    }
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

  Future<void> _toggleVideo() async {
    try {
      if (_isVideoEnabled) {
        await _liveKitService.disableCamera();
      } else {
        await _liveKitService.enableCamera();
      }
      setState(() {
        _isVideoEnabled = !_isVideoEnabled;
      });
    } catch (e) {
      _showError('Failed to toggle camera: $e');
    }
  }

  Future<void> _switchCamera() async {
    try {
      await _liveKitService.switchCamera();
      setState(() {
        _isFrontCamera = !_isFrontCamera;
      });
    } catch (e) {
      _showError('Failed to switch camera: $e');
    }
  }

  Future<void> _endCall() async {
    try {
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
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _isConnecting 
            ? _buildConnectingScreen()
            : _buildCallScreen(),
      ),
    );
  }

  Widget _buildConnectingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
          const SizedBox(height: 20),
          Text(
            _connectionStatus,
            style: GoogleFonts.urbanist(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallScreen() {
    return Stack(
      children: [
        // Remote video (full screen)
        if (_remoteVideoTracks.isNotEmpty)
          Positioned.fill(
            child: VideoTrackRenderer(
              _remoteVideoTracks.first.track! as VideoTrack,
              fit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
            ),
          )
        else
          // Default background when no remote video
          Container(
            color: AppColors.primary.withValues(alpha: 0.8),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    child: const Icon(
                      Icons.person,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Waiting for participant...',
                    style: GoogleFonts.urbanist(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Local video (picture-in-picture)
        if (_localVideoTrack != null && _isVideoEnabled)
          Positioned(
            top: 60,
            right: 20,
            child: Container(
              width: 120,
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: VideoTrackRenderer(
                  _localVideoTrack!,
                  fit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                ),
              ),
            ),
          ),

        // Top bar with status
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.7),
                  Colors.transparent,
                ],
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _isConnected ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _connectionStatus,
                    style: GoogleFonts.urbanist(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  _formatCallDuration(),
                  style: GoogleFonts.urbanist(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Bottom controls
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.8),
                  Colors.transparent,
                ],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Mute button
                _buildControlButton(
                  icon: _isMuted ? Icons.mic_off : Icons.mic,
                  onPressed: _toggleMute,
                  isActive: !_isMuted,
                ),
                
                // Video button
                _buildControlButton(
                  icon: _isVideoEnabled ? Icons.videocam : Icons.videocam_off,
                  onPressed: _toggleVideo,
                  isActive: _isVideoEnabled,
                ),
                
                // Switch camera button
                _buildControlButton(
                  icon: Icons.flip_camera_ios,
                  onPressed: _switchCamera,
                  isActive: true,
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
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.1)),
          shape: BoxShape.circle,
          border: Border.all(
            color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: backgroundColor == Colors.red ? Colors.white : 
                 (isActive ? Colors.white : Colors.white.withValues(alpha: 0.7)),
          size: 28,
        ),
      ),
    );
  }

  String _formatCallDuration() {
    // This would typically track actual call duration
    // For now, return a placeholder
    return '00:00';
  }
}

// Custom VideoTrackRenderer widget to handle LiveKit video rendering
class VideoTrackRenderer extends StatefulWidget {
  final VideoTrack track;
  final RTCVideoViewObjectFit fit;

  const VideoTrackRenderer(
    this.track, {
    super.key,
    this.fit = RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
  });

  @override
  State<VideoTrackRenderer> createState() => _VideoTrackRendererState();
}

class _VideoTrackRendererState extends State<VideoTrackRenderer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Text(
          'Video Track: ${widget.track.sid}',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

// RTCVideoViewObjectFit enum for compatibility
enum RTCVideoViewObjectFit {
  RTCVideoViewObjectFitContain,
  RTCVideoViewObjectFitCover,
  RTCVideoViewObjectFitFill,
}

// Updated VideoTrackWidget to use a simple container
class VideoTrackWidget extends StatelessWidget {
  final VideoTrack track;
  final RTCVideoViewObjectFit fit;

  const VideoTrackWidget(
    this.track, {
    super.key,
    this.fit = RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Text(
          'Video: ${track.sid}',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
} 
