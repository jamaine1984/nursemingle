import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';

class VideoScreen extends StatefulWidget {
  const VideoScreen({Key? key}) : super(key: key);

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  // Mock video data
  final List<VideoPost> _videos = [
    VideoPost(
      id: '1',
      userId: 'user1',
      username: 'Sarah M.',
      profession: 'ICU Nurse',
      videoUrl: 'mock_video_1.mp4',
      thumbnailUrl: 'https://via.placeholder.com/400x600',
      description: 'Just finished a 12-hour shift! 💪 #NurseLife #Healthcare',
      likes: 234,
      comments: 45,
      shares: 12,
      duration: 25,
    ),
    VideoPost(
      id: '2',
      userId: 'user2',
      username: 'Mike R.',
      profession: 'ER Nurse',
      videoUrl: 'mock_video_2.mp4',
      thumbnailUrl: 'https://via.placeholder.com/400x600',
      description: 'Emergency room vibes! Always ready to help 🏥 #EmergencyNurse',
      likes: 189,
      comments: 32,
      shares: 8,
      duration: 18,
    ),
    VideoPost(
      id: '3',
      userId: 'user3',
      username: 'Emma L.',
      profession: 'Pediatric Nurse',
      videoUrl: 'mock_video_3.mp4',
      thumbnailUrl: 'https://via.placeholder.com/400x600',
      description: 'Working with kids is the best! 👶 #PediatricNurse #KidsHealth',
      likes: 312,
      comments: 67,
      shares: 23,
      duration: 30,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    try {
      return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: _videos.isEmpty
              ? _buildEmptyState()
              : PageView.builder(
                  controller: _pageController,
                  scrollDirection: Axis.vertical,
                  onPageChanged: (index) {
                    if (mounted) {
                      setState(() {
                        _currentIndex = index;
                      });
                    }
                  },
                  itemCount: _videos.length,
                  itemBuilder: (context, index) {
                    return _buildVideoItem(_videos[index]);
                  },
                ),
        ),
      );
    } catch (e) {
      print('Error in VideoScreen build: $e');
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.white),
              const SizedBox(height: 16),
              const Text(
                'Something went wrong',
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (mounted) {
                    setState(() {
                      // Trigger rebuild
                    });
                  }
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.video_library_outlined,
            size: 64,
            color: Colors.white70,
          ),
          const SizedBox(height: 16),
          Text(
            'No videos yet',
            style: GoogleFonts.urbanist(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to share a video!',
            style: GoogleFonts.urbanist(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoItem(VideoPost video) {
    return Stack(
      children: [
        // Video Background (Mock)
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(video.thumbnailUrl),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
          ),
        ),

        // Top Bar
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    'Video Feed',
                    style: GoogleFonts.urbanist(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.search,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // User Info and Description
        Positioned(
          bottom: 0,
          left: 0,
          right: 80,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // User Info
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.primary,
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            video.username,
                            style: GoogleFonts.urbanist(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            video.profession,
                            style: GoogleFonts.urbanist(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      _buildFollowButton(),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Description
                  Text(
                    video.description,
                    style: GoogleFonts.urbanist(
                      fontSize: 14,
                      color: Colors.white,
                      height: 1.3,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Duration
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${video.duration}s',
                      style: GoogleFonts.urbanist(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Action Buttons
        Positioned(
          bottom: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildActionButton(
                    icon: Icons.favorite,
                    count: video.likes,
                    onTap: () => _likeVideo(video),
                  ),
                  const SizedBox(height: 20),
                  _buildActionButton(
                    icon: Icons.comment,
                    count: video.comments,
                    onTap: () => _showComments(video),
                  ),
                  const SizedBox(height: 20),
                  _buildActionButton(
                    icon: Icons.share,
                    count: video.shares,
                    onTap: () => _shareVideo(video),
                  ),
                  const SizedBox(height: 20),
                  _buildActionButton(
                    icon: Icons.card_giftcard,
                    count: null,
                    onTap: () => _sendGift(video),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFollowButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Follow',
        style: GoogleFonts.urbanist(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required int? count,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Colors.black54,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          if (count != null) ...[
            const SizedBox(height: 4),
            Text(
              _formatCount(count),
              style: GoogleFonts.urbanist(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }

  void _likeVideo(VideoPost video) {
    // Implement like functionality
    print('Liked video: ${video.id}');
  }

  void _showComments(VideoPost video) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildCommentsSheet(video),
    );
  }

  Widget _buildCommentsSheet(VideoPost video) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'Comments',
                  style: GoogleFonts.urbanist(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                const Spacer(),
                Text(
                  '${video.comments}',
                  style: GoogleFonts.urbanist(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Comments List
          Expanded(
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) {
                return _buildCommentItem(index);
              },
            ),
          ),
          
          // Comment Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppColors.background,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.send,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primary,
            child: Icon(
              Icons.person,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'User $index',
                  style: GoogleFonts.urbanist(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Great video! Thanks for sharing your experience.',
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
    );
  }

  void _shareVideo(VideoPost video) {
    // Implement share functionality
    print('Shared video: ${video.id}');
  }

  void _sendGift(VideoPost video) {
    // Navigate to gifts selection
    print('Send gift to video: ${video.id}');
  }
}

class VideoPost {
  final String id;
  final String userId;
  final String username;
  final String profession;
  final String videoUrl;
  final String thumbnailUrl;
  final String description;
  final int likes;
  final int comments;
  final int shares;
  final int duration;

  VideoPost({
    required this.id,
    required this.userId,
    required this.username,
    required this.profession,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.description,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.duration,
  });
} 