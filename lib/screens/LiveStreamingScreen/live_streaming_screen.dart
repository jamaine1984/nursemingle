import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'package:nursemingle/services/livekit_service.dart';
import 'package:provider/provider.dart';
import 'package:nursemingle/providers/auth_provider.dart';
import 'package:nursemingle/services/ad_service.dart';

class LiveStreamingScreen extends StatefulWidget {
  static const routeName = '/live_streaming';
  const LiveStreamingScreen({super.key});
  @override
  State<LiveStreamingScreen> createState() => _LiveStreamingScreenState();
}

class _LiveStreamingScreenState extends State<LiveStreamingScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _tokenController = TextEditingController();
  final LiveKitService _liveKitService = LiveKitService();
  
  List<Map<String, dynamic>> streams = [];
  bool isStartingStream = false;
  bool showPipAd = false;
  Timer? pipTimer;

  @override
  void initState() {
    super.initState();
    // Start automatic interstitial ads every 15 minutes during live streams
    AdService.startLiveStreamAds();
    _loadStoredToken();
    _loadStreams();
  }

  Future<void> _loadStoredToken() async {
    final token = await _liveKitService.getToken();
    setState(() {
      _tokenController.text = token ?? '';
    });
  }

  Future<void> _loadStreams() async {
    // TODO: Implement real API call to load streams
    setState(() {
      streams = [];
    });
  }

  Future<void> _startLiveStream() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a stream title')),
      );
      return;
    }

    setState(() {
      isStartingStream = true;
    });

    try {
      await _liveKitService.startLiveStream();
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Live stream started successfully')),
      );
      
      // Add the new stream to the list
      setState(() {
        streams.insert(0, {
          'thumbnail': 'https://images.unsplash.com/photo-1519125323398-675f0ddb6308',
          'avatar': 'https://randomuser.me/api/portraits/men/1.jpg',
          'name': 'You',
          'viewers': 0,
          'timer': '00:00:00',
          'isLive': true,
          'streamedHours': 0.0,
          'isMyStream': true,
        });
      });

      // Clear the form
      _titleController.clear();
      _descriptionController.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error starting stream: $e')),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        isStartingStream = false;
      });
    }
  }

  @override
  void dispose() {
    // Stop automatic interstitial ads when leaving the screen
    AdService.stopLiveStreamAds();
    _titleController.dispose();
    _descriptionController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Live Streaming', style: GoogleFonts.urbanist(fontWeight: FontWeight.bold)),
        actions: [
          if (authProvider.isPaidUser)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _showStartStreamDialog,
            ),
        ],
      ),
      body: Stack(
        children: [
          streams.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: streams.length,
                  itemBuilder: (context, index) {
                    final stream = streams[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                stream['thumbnail'],
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundImage: NetworkImage(stream['avatar']),
                                        radius: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        stream['name'],
                                        style: GoogleFonts.urbanist(fontWeight: FontWeight.bold),
                                      ),
                                      if (stream['isMyStream'] == true)
                                        Container(
                                          margin: const EdgeInsets.only(left: 8),
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.green,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            'You',
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.remove_red_eye, size: 16, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      Text('${stream['viewers']}', style: GoogleFonts.poppins(fontSize: 14)),
                                      const SizedBox(width: 16),
                                      Icon(Icons.timer, size: 16, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      Text(stream['timer'], style: GoogleFonts.poppins(fontSize: 14)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${stream['streamedHours']} hours streamed',
                                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.play_circle_fill, color: Colors.red, size: 32),
                              onPressed: () {
                                // TODO: Implement join stream functionality
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Joining stream...')),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
          
          // PIP Ad Overlay
          if (showPipAd)
            Positioned(
              bottom: 20,
              right: 20,
              child: Container(
                width: 120,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.ondemand_video, color: Colors.white, size: 24),
                      const SizedBox(height: 4),
                      Text('Ad', style: GoogleFonts.inter(fontSize: 13, color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.live_tv_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          Text(
            'No live streams',
            style: GoogleFonts.urbanist(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Be the first to start streaming!',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: _showStartStreamDialog,
            icon: const Icon(Icons.live_tv),
            label: const Text('Start Streaming'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showStartStreamDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start Live Stream'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Stream Title',
                  hintText: 'Enter stream title...',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'Enter stream description...',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _tokenController,
                decoration: const InputDecoration(
                  labelText: 'LiveKit Token (Optional)',
                  hintText: 'Enter LiveKit token...',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your LiveKit token for streaming',
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: isStartingStream ? null : () {
              Navigator.pop(context);
              _startLiveStream();
            },
            child: isStartingStream
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Start Stream'),
          ),
        ],
      ),
    );
  }
} 
