import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/live_stream.dart';
import '../providers/app_state_provider.dart';
import '../providers/auth_provider.dart';
import 'go_live_screen.dart';
import 'live_room_screen.dart';

class LiveScreen extends StatefulWidget {
  const LiveScreen({super.key});

  @override
  State<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends State<LiveScreen> {
  bool isLoading = false;
  List<Map<String, dynamic>> liveStreams = [];
  final List<Map<String, dynamic>> lounges = [
    {
      'title': 'Nurse Hangout',
      'avatars': [
        'https://randomuser.me/api/portraits/women/44.jpg',
        'https://randomuser.me/api/portraits/men/32.jpg',
        'https://randomuser.me/api/portraits/women/68.jpg',
      ],
      'count': 12,
    },
    {
      'title': 'Night Shift Crew',
      'avatars': [
        'https://randomuser.me/api/portraits/men/45.jpg',
        'https://randomuser.me/api/portraits/women/65.jpg',
      ],
      'count': 7,
    },
    {
      'title': 'ER Stories',
      'avatars': [
        'https://randomuser.me/api/portraits/men/23.jpg',
        'https://randomuser.me/api/portraits/women/12.jpg',
      ],
      'count': 5,
    },
  ];

  // Comments and reactions for live events
  final Map<String, List<String>> liveComments = {};
  final Map<String, Map<String, int>> liveReactions = {};
  static const List<String> emojiOptions = ['❤️', '😂', '🔥', '👏', '😍'];
  final List<Map<String, String>> moderationFeedback = [];

  @override
  Widget build(BuildContext context) {
    try {
      final appState = Provider.of<AppStateProvider>(context);
      final liveStreams = appState.liveStreams;
      
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: Text(
            'All Live Streams',
            style: GoogleFonts.urbanist(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GoLiveScreen(),
                  ),
                );
              },
            ),
          ],
        ),
        body: liveStreams.isEmpty
            ? _buildEmptyState()
            : _buildLiveStreamsList(liveStreams),
      );
    } catch (e) {
      print('Error in LiveScreen build: $e');
      return Scaffold(
        appBar: AppBar(title: const Text('Live Streams')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Something went wrong'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    // Trigger rebuild
                  });
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildLiveStreamsList(List<LiveStream> liveStreams) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 18,
        mainAxisSpacing: 18,
        childAspectRatio: 0.85,
      ),
      itemCount: liveStreams.length,
      itemBuilder: (context, index) {
        final stream = liveStreams[index];
        return _buildStreamCard(stream);
      },
    );
  }

  Widget _buildStreamCard(LiveStream stream) {
    return GestureDetector(
      onTap: () => _joinStream(stream),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stream thumbnail
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[200],
                  ),
                  child: const Icon(
                    Icons.live_tv,
                    size: 40,
                    color: Colors.red,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                stream.title,
                style: GoogleFonts.urbanist(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                stream.streamerName,
                style: GoogleFonts.urbanist(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.visibility, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '${stream.viewers} viewers',
                    style: GoogleFonts.urbanist(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _joinStream(LiveStream stream) {
    if (!mounted) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LiveRoomScreen(
          title: stream.title,
          isHost: false,
          streamId: stream.id,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.live_tv_outlined,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'No Live Streams',
            style: GoogleFonts.urbanist(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to go live!',
            style: GoogleFonts.urbanist(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const GoLiveScreen(),
                ),
              );
            },
            child: const Text('Start Live Stream'),
          ),
        ],
      ),
    );
  }

  void _showStartStreamDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const GoLiveScreen(),
      ),
    );
  }

  void _showGiftDialog(BuildContext context, LiveStream stream, AppStateProvider appState) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Send Gift to ${stream.streamerName}',
              style: GoogleFonts.urbanist(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Your Gift Points: ${Provider.of<AuthProvider>(context, listen: false).giftPoints}',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1,
                ),
                itemCount: appState.gifts.length,
                itemBuilder: (context, index) {
                  final gift = appState.gifts[index];
                  return Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      border: Border.all(
                        color: gift.price > 0 ? Colors.amber : Colors.green,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Gift icon
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: gift.price > 0 
                                ? Colors.amber.withValues(alpha: 0.1)
                                : Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                                              child: Text(
                    gift.icon ?? '🎁',
                    style: const TextStyle(fontSize: 32),
                  ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        // Gift name
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            gift.name,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 4),
                        
                        // Price indicator
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              gift.price > 0 ? Icons.diamond : Icons.free_breakfast,
                              size: 12,
                              color: gift.price > 0 ? Colors.amber : Colors.green,
                            ),
                            const SizedBox(width: 2),
                                                          Text(
                                gift.price == 0 ? 'Free' : '${gift.price}',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: gift.price > 0 ? Colors.amber : Colors.green,
                                ),
                              ),
                          ],
                        ),
                      ],
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

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Future<void> _loadLiveStreams() async {
    setState(() {
      isLoading = true;
    });
    
    try {
      // TODO: Implement real API call
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
} 
