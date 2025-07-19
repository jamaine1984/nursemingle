import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:livekit_client/livekit_client.dart';
import 'dart:async';
import '../utils/app_colors.dart';
import '../services/livekit_service.dart';
import '../models/gift_model.dart';
import '../data/gift_catalog.dart';

class LiveRoomScreen extends StatefulWidget {
  final String title;
  final bool isHost;
  final String? streamId;

  const LiveRoomScreen({
    Key? key,
    required this.title,
    required this.isHost,
    this.streamId,
  }) : super(key: key);

  @override
  State<LiveRoomScreen> createState() => _LiveRoomScreenState();
}

class _LiveRoomScreenState extends State<LiveRoomScreen> {
  final LiveKitService _liveKitService = LiveKitService();
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();
  
  final List<ChatMessage> _chatMessages = [];
  List<ParticipantTrack> _participantTracks = [];
  bool _isCameraEnabled = true;
  bool _isMicEnabled = true;
  int _viewerCount = 0;
  int _giftCount = 0;
  Timer? _durationTimer;
  Duration _streamDuration = Duration.zero;
  
  @override
  void initState() {
    super.initState();
    _initializeLiveRoom();
    _startDurationTimer();
  }

  void _startDurationTimer() {
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _streamDuration = _streamDuration + const Duration(seconds: 1);
      });
    });
  }

  Future<void> _initializeLiveRoom() async {
    try {
      if (!widget.isHost && widget.streamId != null) {
        // Join existing stream
        await _liveKitService.joinLiveStream(widget.streamId!);
      }
      
      // Set up room listeners
      _setupRoomListeners();
      
      // Enable camera and microphone for host
      if (widget.isHost) {
        await _liveKitService.enableCamera();
        await _liveKitService.enableMicrophone();
      }
      
      // Update viewer count
      _updateViewerCount();
    } catch (e) {
      print('Error initializing live room: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to initialize live room: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _setupRoomListeners() {
    final room = _liveKitService.room;
    if (room != null) {
      room.addListener(_onRoomUpdate);
    }
  }

  void _onRoomUpdate() {
    _updateParticipantTracks();
    _updateViewerCount();
  }

  void _updateParticipantTracks() {
    final room = _liveKitService.room;
    if (room == null) return;

    List<ParticipantTrack> tracks = [];
    
    // Add local participant video if host
    if (widget.isHost && room.localParticipant != null) {
      for (final trackPublication in room.localParticipant!.videoTrackPublications) {
        if (trackPublication.track != null) {
          tracks.add(ParticipantTrack(
            participant: room.localParticipant!,
            videoTrack: trackPublication.track as VideoTrack,
            isLocal: true,
          ));
        }
      }
    }
    
    // Add remote participants
    for (final participant in room.remoteParticipants.values) {
      for (final trackPublication in participant.videoTrackPublications) {
        if (trackPublication.track != null && trackPublication.subscribed) {
          tracks.add(ParticipantTrack(
            participant: participant,
            videoTrack: trackPublication.track as VideoTrack,
            isLocal: false,
          ));
        }
      }
    }
    
    setState(() {
      _participantTracks = tracks;
    });
  }

  void _updateViewerCount() {
    setState(() {
      _viewerCount = _liveKitService.viewerCount;
    });
  }

  Future<void> _toggleCamera() async {
    if (_isCameraEnabled) {
      await _liveKitService.disableCamera();
    } else {
      await _liveKitService.enableCamera();
    }
    setState(() {
      _isCameraEnabled = !_isCameraEnabled;
    });
  }

  Future<void> _toggleMic() async {
    if (_isMicEnabled) {
      await _liveKitService.disableMicrophone();
    } else {
      await _liveKitService.enableMicrophone();
    }
    setState(() {
      _isMicEnabled = !_isMicEnabled;
    });
  }

  Future<void> _switchCamera() async {
    await _liveKitService.switchCamera();
  }

  void _sendMessage() {
    final message = _chatController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _chatMessages.add(ChatMessage(
        userName: widget.isHost ? 'Host' : 'Viewer',
        message: message,
        timestamp: DateTime.now(),
        isHost: widget.isHost,
      ));
    });

    _chatController.clear();
    
    // Scroll to bottom
    _chatScrollController.animateTo(
      _chatScrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _showGiftDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Send a Gift',
              style: GoogleFonts.urbanist(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 10,
                itemBuilder: (context, index) {
                  final gifts = GiftCatalog.getAllGifts();
                  if (index >= gifts.length) return const SizedBox();
                  
                  final gift = gifts[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _sendGift(gift);
                    },
                    child: Container(
                      width: 80,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                gift.icon ?? '🎁',
                                style: const TextStyle(fontSize: 30),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            gift.name,
                            style: GoogleFonts.urbanist(fontSize: 12),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendGift(Gift gift) {
    setState(() {
      _giftCount++;
      _chatMessages.add(ChatMessage(
        userName: 'Viewer',
        message: 'sent a ${gift.name} ${gift.icon ?? '🎁'}',
        timestamp: DateTime.now(),
        isHost: false,
        isGift: true,
      ));
    });
  }

  Future<void> _endStream() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Stream?'),
        content: const Text('Are you sure you want to end the live stream?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('End Stream'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _liveKitService.disconnect();
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Video view
          _buildVideoView(),
          
          // Top bar
          _buildTopBar(),
          
          // Chat overlay
          Positioned(
            left: 0,
            right: 0,
            bottom: widget.isHost ? 100 : 80,
            height: 250,
            child: _buildChat(),
          ),
          
          // Bottom controls
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: widget.isHost ? _buildHostControls() : _buildViewerControls(),
          ),
          
          // Gift animation area
          if (_giftCount > 0)
            Positioned(
              top: 100,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Text('🎁', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Text(
                      _giftCount.toString(),
                      style: GoogleFonts.urbanist(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVideoView() {
    if (_participantTracks.isEmpty) {
      return Container(
        color: AppColors.surface,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.isHost ? Icons.videocam_off : Icons.hourglass_empty,
                size: 64,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 16),
              Text(
                widget.isHost ? 'Camera is off' : 'Waiting for host...',
                style: GoogleFonts.urbanist(
                  color: AppColors.textSecondary,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Show the first video track (usually the host)
    final track = _participantTracks.first;
    return VideoTrackRenderer(
      track.videoTrack,
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 10,
          left: 20,
          right: 20,
          bottom: 10,
        ),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black87,
              Colors.transparent,
            ],
          ),
        ),
        child: Row(
          children: [
            // Live badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.circle,
                    size: 8,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'LIVE',
                    style: GoogleFonts.urbanist(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            
            // Viewer count
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.visibility,
                    size: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _viewerCount.toString(),
                    style: GoogleFonts.urbanist(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            
            // Duration
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _formatDuration(_streamDuration),
                style: GoogleFonts.urbanist(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            const Spacer(),
            
            // Close button
            IconButton(
              onPressed: widget.isHost ? _endStream : () => Navigator.pop(context),
              icon: const Icon(Icons.close, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChat() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _chatScrollController,
              itemCount: _chatMessages.length,
              itemBuilder: (context, index) {
                final message = _chatMessages[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: message.isGift
                        ? AppColors.warning.withValues(alpha: 0.3)
                        : Colors.black54,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (message.isHost)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'HOST',
                            style: GoogleFonts.urbanist(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (message.isHost) const SizedBox(width: 6),
                      Text(
                        '${message.userName}: ',
                        style: GoogleFonts.urbanist(
                          color: message.isHost ? AppColors.primary : AppColors.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          message.message,
                          style: GoogleFonts.urbanist(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHostControls() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Camera toggle
            _buildControlButton(
              icon: _isCameraEnabled ? Icons.videocam : Icons.videocam_off,
              onPressed: _toggleCamera,
              isActive: _isCameraEnabled,
            ),
            
            // Mic toggle
            _buildControlButton(
              icon: _isMicEnabled ? Icons.mic : Icons.mic_off,
              onPressed: _toggleMic,
              isActive: _isMicEnabled,
            ),
            
            // Switch camera
            _buildControlButton(
              icon: Icons.flip_camera_ios,
              onPressed: _switchCamera,
            ),
            
            // End stream
            _buildControlButton(
              icon: Icons.call_end,
              onPressed: _endStream,
              backgroundColor: AppColors.error,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewerControls() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Chat input
            Expanded(
              child: TextField(
                controller: _chatController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 12),
            
            // Send gift button
            _buildControlButton(
              icon: Icons.card_giftcard,
              onPressed: _showGiftDialog,
              backgroundColor: AppColors.secondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    bool isActive = true,
    Color? backgroundColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? (isActive ? Colors.white : Colors.white.withValues(alpha: 0.3)),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: backgroundColor != null ? Colors.white : (isActive ? Colors.black : Colors.white),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _durationTimer?.cancel();
    _chatController.dispose();
    _chatScrollController.dispose();
    _liveKitService.disconnect();
    super.dispose();
  }
}

class ParticipantTrack {
  final Participant participant;
  final VideoTrack videoTrack;
  final bool isLocal;

  ParticipantTrack({
    required this.participant,
    required this.videoTrack,
    required this.isLocal,
  });
}

class ChatMessage {
  final String userName;
  final String message;
  final DateTime timestamp;
  final bool isHost;
  final bool isGift;

  ChatMessage({
    required this.userName,
    required this.message,
    required this.timestamp,
    required this.isHost,
    this.isGift = false,
  });
} 