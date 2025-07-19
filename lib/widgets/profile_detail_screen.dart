import 'package:flutter/material.dart';
import '../models/user.dart';
import '../utils/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileDetailScreen extends StatefulWidget {
  final User user;
  final bool showActions;

  const ProfileDetailScreen({
    super.key,
    required this.user,
    this.showActions = true,
  });

  @override
  State<ProfileDetailScreen> createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen> {
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App bar with image carousel
          SliverAppBar(
            expandedHeight: MediaQuery.of(context).size.height * 0.6,
            pinned: true,
            backgroundColor: AppColors.primary,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: _buildImageCarousel(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () => _showOptionsMenu(context),
              ),
            ],
          ),
          
          // Profile content
          SliverToBoxAdapter(
            child: _buildProfileContent(),
          ),
        ],
      ),
      
      // Action buttons (if enabled)
      bottomNavigationBar: widget.showActions ? _buildActionBar() : null,
    );
  }

  Widget _buildImageCarousel() {
    final images = widget.user.profileImages ?? 
        (widget.user.profileImageUrl != null ? [widget.user.profileImageUrl!] : <String>[]);
    
    if (images.isEmpty) {
      return _buildPlaceholderImage();
    }

    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentImageIndex = index;
            });
          },
          itemCount: images.length + 1, // +1 for intro video
          itemBuilder: (context, index) {
            if (index == 0) {
              return _buildIntroVideo();
            }
            return CachedNetworkImage(
              imageUrl: images[index - 1],
              fit: BoxFit.cover,
              placeholder: (context, url) => _buildPlaceholderImage(),
              errorWidget: (context, url, error) => _buildPlaceholderImage(),
            );
          },
        ),
        
        // Page indicator
        if (images.isNotEmpty)
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: _buildPageIndicator(images.length + 1),
          ),
        
        // Intro video indicator
        if (_currentImageIndex == 0)
          Positioned(
            bottom: 20,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.play_circle_filled, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Intro Video',
                    style: GoogleFonts.urbanist(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: AppColors.primary.withOpacity(0.1),
      child: Center(
        child: Icon(
          Icons.person,
          size: 120,
          color: AppColors.primary.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildPageIndicator(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index == _currentImageIndex
                ? Colors.white
                : Colors.white.withOpacity(0.5),
          ),
        );
      }),
    );
  }

  Widget _buildOnlineIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.success,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'Online',
            style: GoogleFonts.urbanist(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntroVideo() {
    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Video placeholder with user's profile image as background
          if (widget.user.profileImageUrl != null)
            CachedNetworkImage(
              imageUrl: widget.user.profileImageUrl!,
              fit: BoxFit.cover,
              placeholder: (context, url) => _buildPlaceholderImage(),
              errorWidget: (context, url, error) => _buildPlaceholderImage(),
            )
          else
            _buildPlaceholderImage(),
          
          // Video overlay
          Container(
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
          
          // Play button
          Center(
            child: GestureDetector(
              onTap: () => _playIntroVideo(),
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: AppColors.primary,
                  size: 40,
                ),
              ),
            ),
          ),
          
          // Video info
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${widget.user.name}\'s Intro',
                  style: GoogleFonts.urbanist(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap to play 15-second intro video',
                  style: GoogleFonts.urbanist(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _playIntroVideo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${widget.user.name}\'s Intro Video'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.video_library, size: 48, color: Colors.white),
                    const SizedBox(height: 8),
                    Text(
                      'Intro Video Player',
                      style: GoogleFonts.urbanist(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Coming Soon',
                      style: GoogleFonts.urbanist(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('This 15-second intro video will help you get to know ${widget.user.name} better!'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name and age
          Row(
            children: [
              Expanded(
                child: Text(
                  '${widget.user.firstName} ${widget.user.lastName}',
                  style: GoogleFonts.urbanist(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (widget.user.isVerified)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.info,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.verified,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
            ],
          ),
          
          ...[
          const SizedBox(height: 4),
          Text(
            '${widget.user.age} years old',
            style: GoogleFonts.urbanist(
              fontSize: 18,
              color: AppColors.textSecondary,
            ),
          ),
        ],
          
          const SizedBox(height: 20),
          
          // Professional info
          _buildInfoSection(
            'Professional Information',
            [
              if (widget.user.nursingSpecialty != null)
                _buildInfoItem(
                  Icons.local_hospital,
                  'Specialty',
                  widget.user.nursingSpecialty!,
                ),
              if (widget.user.workLocation != null)
                _buildInfoItem(
                  Icons.location_on,
                  'Work Location',
                  widget.user.workLocation!,
                ),
              if (widget.user.jobTitle != null)
                _buildInfoItem(
                  Icons.work,
                  'Job Title',
                  widget.user.jobTitle!,
                ),
            ],
          ),
          
          // Personal info
          if (widget.user.bio != null && widget.user.bio!.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildInfoSection(
              'About',
              [
                _buildBioItem(widget.user.bio!),
              ],
            ),
          ],
          
          // Location info
          if (widget.user.city != null || widget.user.state != null) ...[
            const SizedBox(height: 24),
            _buildInfoSection(
              'Location',
              [
                if (widget.user.city != null)
                  _buildInfoItem(
                    Icons.location_city,
                    'City',
                    widget.user.city!,
                  ),
                if (widget.user.state != null)
                  _buildInfoItem(
                    Icons.map,
                    'State',
                    widget.user.state!,
                  ),
              ],
            ),
          ],
          
          // Badges
          if (widget.user.badges != null && widget.user.badges!.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildBadgesSection(),
          ],
          
          const SizedBox(height: 100), // Space for action bar
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.urbanist(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...items,
      ],
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.urbanist(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.urbanist(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBioItem(String bio) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.divider,
          width: 1,
        ),
      ),
      child: Text(
        bio,
        style: GoogleFonts.urbanist(
          fontSize: 16,
          height: 1.5,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildBadgesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Achievements',
          style: GoogleFonts.urbanist(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.user.badges!.map((badge) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                badge,
                style: GoogleFonts.urbanist(
                  fontSize: 14,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActionBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Pass button
          _buildActionButton(
            icon: Icons.close,
            backgroundColor: Colors.grey[400]!,
            onPressed: () => Navigator.pop(context, 'pass'),
          ),
          
          // Super like button
          _buildActionButton(
            icon: Icons.star,
            backgroundColor: AppColors.warning,
            onPressed: () => Navigator.pop(context, 'super_like'),
          ),
          
          // Like button
          _buildActionButton(
            icon: Icons.favorite,
            backgroundColor: AppColors.error,
            onPressed: () => Navigator.pop(context, 'like'),
          ),
          
          // Message button
          _buildActionButton(
            icon: Icons.message,
            backgroundColor: AppColors.primary,
            onPressed: () => Navigator.pop(context, 'message'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color backgroundColor,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 56,
        height: 56,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: backgroundColor,
          size: 28,
        ),
      ),
    );
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            
            // Report option
            ListTile(
              leading: const Icon(Icons.report, color: AppColors.error),
              title: Text(
                'Report User',
                style: GoogleFonts.urbanist(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _showReportDialog(context);
              },
            ),
            
            // Block option
            ListTile(
              leading: const Icon(Icons.block, color: AppColors.error),
              title: Text(
                'Block User',
                style: GoogleFonts.urbanist(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _showBlockDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Report User',
          style: GoogleFonts.urbanist(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to report this user? This action will be reviewed by our team.',
          style: GoogleFonts.urbanist(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.urbanist(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Handle report action
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Report',
              style: GoogleFonts.urbanist(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showBlockDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Block User',
          style: GoogleFonts.urbanist(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to block this user? You won\'t see their profile again.',
          style: GoogleFonts.urbanist(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.urbanist(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Handle block action
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Block',
              style: GoogleFonts.urbanist(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
} 
