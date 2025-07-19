import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'live_room_screen.dart';
import '../utils/api_service.dart';
import 'go_live_screen.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  List<FeedItem> _feedItems = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadFeedItems();
  }

  Future<void> _loadFeedItems() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get feed items from backend
      final response = await ApiService.get('/api/feed');
      
      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> feedData = response['data'] ?? [];
        
        setState(() {
          _feedItems = feedData.map((item) => FeedItem.fromJson(item)).toList();
          _isLoading = false;
        });
      } else {
        print('❌ FEED_SCREEN: No feed data available');
        setState(() {
          _feedItems = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('💥 FEED_SCREEN: Error loading feed: $e');
      setState(() {
        _feedItems = [];
        _isLoading = false;
      });
    }
  }

  Widget _buildFeedItem(FeedItem item) {
    if (item.type == 'live') {
      return _buildLiveStreamCard(item);
    } else {
      return _buildVideoCard(item);
    }
  }

  Widget _buildLiveStreamCard(FeedItem item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LiveRoomScreen(
              title: item.title,
              isHost: false,
              streamId: item.id,
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail with LIVE badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      item.thumbnail,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.surface,
                          child: const Icon(Icons.live_tv, size: 48, color: AppColors.textSecondary),
                        );
                      },
                    ),
                  ),
                ),
                // LIVE badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.circle, size: 8, color: Colors.white),
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
                ),
                // Viewer count
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.visibility, size: 14, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          '${item.viewerCount}',
                          style: GoogleFonts.urbanist(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(item.userAvatar),
                    radius: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: GoogleFonts.urbanist(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.userName,
                          style: GoogleFonts.urbanist(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoCard(FeedItem item) {
    return GestureDetector(
      onTap: () {
        _playVideo(item);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail with play button
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      item.thumbnail,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.surface,
                          child: const Icon(Icons.video_library, size: 48, color: AppColors.textSecondary),
                        );
                      },
                    ),
                  ),
                ),
                // Play button overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                    child: const Icon(
                      Icons.play_circle_filled,
                      size: 64,
                      color: Colors.white,
                    ),
                  ),
                ),
                // Duration badge
                if (item.duration != null)
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _formatDuration(item.duration!),
                        style: GoogleFonts.urbanist(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(item.userAvatar),
                        radius: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: GoogleFonts.urbanist(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${item.userName} • ${_formatTimestamp(item.timestamp)}',
                              style: GoogleFonts.urbanist(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Stats row
                  Row(
                    children: [
                      _buildStatItem(Icons.visibility, item.viewCount ?? 0),
                      const SizedBox(width: 16),
                      _buildStatItem(Icons.favorite, item.likeCount ?? 0),
                      const SizedBox(width: 16),
                      _buildStatItem(Icons.card_giftcard, item.giftCount ?? 0),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.share, size: 20),
                        onPressed: () => _shareItem(item),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, int count) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          _formatCount(count),
          style: GoogleFonts.urbanist(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${(difference.inDays / 7).floor()}w ago';
    }
  }

  void _playVideo(FeedItem item) {
    // TODO: Implement video player
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Playing: ${item.title}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareItem(FeedItem item) {
    Share.share(
      'Check out "${item.title}" by ${item.userName} on Nurse Mingle!',
    );
  }

  void _startLiveStream(BuildContext context, AuthProvider authProvider) {
    if (!authProvider.canLiveStream) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Live streaming is only available for Starter, Gold, and Platinum subscribers.'),
          backgroundColor: AppColors.error,
          action: SnackBarAction(
            label: 'Upgrade',
            onPressed: () {
              Navigator.pushNamed(context, '/subscription-plans');
            },
          ),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const GoLiveScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Feed', style: GoogleFonts.urbanist(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        actions: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _startLiveStream(context, authProvider),
                tooltip: 'Start Live Stream',
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _feedItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.video_library_outlined,
                        size: 64,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No content yet',
                        style: GoogleFonts.urbanist(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Follow users to see their live streams and videos!',
                        style: GoogleFonts.urbanist(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadFeedItems,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _feedItems.length,
                    itemBuilder: (context, index) {
                      return _buildFeedItem(_feedItems[index]);
                    },
                  ),
                ),
    );
  }
}

class FeedItem {
  final String id;
  final String type; // 'live' or 'video'
  final String title;
  final String userName;
  final String userAvatar;
  final String thumbnail;
  final DateTime timestamp;
  final bool isLive;
  final int? viewerCount; // For live streams
  final int? viewCount; // For videos
  final int? likeCount;
  final int? giftCount;
  final int? duration; // In seconds, for videos

  FeedItem({
    required this.id,
    required this.type,
    required this.title,
    required this.userName,
    required this.userAvatar,
    required this.thumbnail,
    required this.timestamp,
    this.isLive = false,
    this.viewerCount,
    this.viewCount,
    this.likeCount,
    this.giftCount,
    this.duration,
  });

  factory FeedItem.fromJson(Map<String, dynamic> json) {
    return FeedItem(
      id: json['id'] ?? '',
      type: json['type'] ?? 'video',
      title: json['title'] ?? '',
      userName: json['user_name'] ?? json['userName'] ?? '',
      userAvatar: json['user_avatar'] ?? json['userAvatar'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp']) 
          : DateTime.now(),
      isLive: json['is_live'] ?? json['isLive'] ?? false,
      viewerCount: json['viewer_count'] ?? json['viewerCount'],
      viewCount: json['view_count'] ?? json['viewCount'],
      likeCount: json['like_count'] ?? json['likeCount'],
      giftCount: json['gift_count'] ?? json['giftCount'],
      duration: json['duration'],
    );
  }
} 
