import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user.dart';
import '../utils/app_colors.dart';

class SwipeCard extends StatefulWidget {
  final User user;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final VoidCallback? onPass;
  final VoidCallback? onSuperLike;
  final bool isTopCard;
  
  const SwipeCard({
    Key? key,
    required this.user,
    this.onTap,
    this.onLike,
    this.onPass,
    this.onSuperLike,
    this.isTopCard = false,
  }) : super(key: key);
  
  @override
  State<SwipeCard> createState() => _SwipeCardState();
}

class _SwipeCardState extends State<SwipeCard> with TickerProviderStateMixin {
  late AnimationController _swipeController;
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  
  double _dragStartX = 0;
  double _dragStartY = 0;
  double _dragCurrentX = 0;
  double _dragCurrentY = 0;
  double _dragDistance = 0;
  
  bool _isDragging = false;
  
  @override
  void initState() {
    super.initState();
    print('💳 SWIPE_CARD: Initializing card for ${widget.user.firstName} ${widget.user.lastName}');
    
    _swipeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOut,
    ));
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeOut,
    ));
    
    if (widget.isTopCard) {
      _scaleController.forward();
    }
  }
  
  @override
  void dispose() {
    _swipeController.dispose();
    _scaleController.dispose();
    _rotationController.dispose();
    super.dispose();
  }
  
  void _onPanStart(DragStartDetails details) {
    print('💳 SWIPE_CARD: Pan start for ${widget.user.firstName}');
    _dragStartX = details.globalPosition.dx;
    _dragStartY = details.globalPosition.dy;
    _isDragging = true;
  }
  
  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;
    
    setState(() {
      _dragCurrentX = details.globalPosition.dx - _dragStartX;
      _dragCurrentY = details.globalPosition.dy - _dragStartY;
      _dragDistance = _dragCurrentX.abs();
    });
  }
  
  void _onPanEnd(DragEndDetails details) {
    print('💳 SWIPE_CARD: Pan end for ${widget.user.firstName} - Distance: $_dragDistance');
    
    _isDragging = false;
    
    const double threshold = 100.0;
    
    if (_dragDistance > threshold) {
      if (_dragCurrentX > 0) {
        // Swiped right - Like
        print('❤️ SWIPE_CARD: Swiped right (Like) on ${widget.user.firstName}');
        _animateSwipeRight();
      } else {
        // Swiped left - Pass
        print('👎 SWIPE_CARD: Swiped left (Pass) on ${widget.user.firstName}');
        _animateSwipeLeft();
      }
    } else {
      // Snap back to center
      print('🔄 SWIPE_CARD: Snapping back to center');
      _animateToCenter();
    }
  }
  
  void _animateSwipeRight() {
    _swipeController.forward().then((_) {
      if (widget.onLike != null) {
        widget.onLike!();
      }
    });
  }
  
  void _animateSwipeLeft() {
    _swipeController.forward().then((_) {
      if (widget.onPass != null) {
        widget.onPass!();
      }
    });
  }
  
  void _animateToCenter() {
    setState(() {
      _dragCurrentX = 0;
      _dragCurrentY = 0;
      _dragDistance = 0;
    });
  }
  
  void _handleLikeButton() {
    print('❤️ SWIPE_CARD: Like button pressed for ${widget.user.firstName}');
    _animateSwipeRight();
  }
  
  void _handlePassButton() {
    print('👎 SWIPE_CARD: Pass button pressed for ${widget.user.firstName}');
    _animateSwipeLeft();
  }
  
  void _handleSuperLikeButton() {
    print('⭐ SWIPE_CARD: Super like button pressed for ${widget.user.firstName}');
    if (widget.onSuperLike != null) {
      widget.onSuperLike!();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      onTap: () {
        print('👆 SWIPE_CARD: Card tapped for ${widget.user.firstName}');
        if (widget.onTap != null) {
          widget.onTap!();
        }
      },
      child: Transform.translate(
        offset: Offset(_dragCurrentX, _dragCurrentY * 0.3),
        child: Transform.rotate(
          angle: _dragCurrentX / screenWidth * 0.3,
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Stack(
                  children: [
                    // Main card
                    Container(
                      width: screenWidth * 0.9,
                      height: screenHeight * 0.7,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Stack(
                          children: [
                            // Background image
                            Positioned.fill(
                              child: _buildProfileImage(),
                            ),
                            
                            // Gradient overlay
                            Positioned.fill(
                              child: Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.transparent,
                                      Colors.black54,
                                    ],
                                    stops: [0.0, 0.5, 1.0],
                                  ),
                                ),
                              ),
                            ),
                            
                            // User info
                            Positioned(
                              bottom: 20,
                              left: 20,
                              right: 20,
                              child: _buildUserInfo(),
                            ),
                            
                            // Swipe indicators
                            if (_isDragging) ...[
                              // Like indicator
                              if (_dragCurrentX > 50)
                                Positioned(
                                  top: 100,
                                  right: 30,
                                  child: Transform.rotate(
                                    angle: -0.3,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withValues(alpha: 0.9),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 3,
                                        ),
                                      ),
                                      child: Text(
                                        'LIKE',
                                        style: GoogleFonts.urbanist(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              
                              // Pass indicator
                              if (_dragCurrentX < -50)
                                Positioned(
                                  top: 100,
                                  left: 30,
                                  child: Transform.rotate(
                                    angle: 0.3,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withValues(alpha: 0.9),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 3,
                                        ),
                                      ),
                                      child: Text(
                                        'PASS',
                                        style: GoogleFonts.urbanist(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    
                    // Action buttons
                    Positioned(
                      bottom: -30,
                      left: 0,
                      right: 0,
                      child: _buildActionButtons(),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
  
  Widget _buildProfileImage() {
    final imageUrl = widget.user.profileImageUrl ?? widget.user.profilePictureUrl;
    
    if (imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('❌ SWIPE_CARD: Failed to load image for ${widget.user.firstName}: $error');
          return _buildPlaceholderImage();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: AppColors.surfaceVariant,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      );
    } else {
      return _buildPlaceholderImage();
    }
  }
  
  Widget _buildPlaceholderImage() {
    return Container(
      color: AppColors.surfaceVariant,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.person,
            size: 100,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'No Photo',
            style: GoogleFonts.urbanist(
              color: AppColors.textSecondary,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildUserInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '${widget.user.firstName} ${widget.user.lastName}',
                style: GoogleFonts.urbanist(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (widget.user.age != null)
              Text(
                '${widget.user.age}',
                style: GoogleFonts.urbanist(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        if (widget.user.profession != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.work,
                color: Colors.white.withValues(alpha: 0.9),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                widget.user.profession!,
                style: GoogleFonts.urbanist(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
        if (widget.user.location != null) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: Colors.white.withValues(alpha: 0.9),
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.user.location!,
                  style: GoogleFonts.urbanist(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ],
        if (widget.user.bio != null && widget.user.bio!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            widget.user.bio!,
            style: GoogleFonts.urbanist(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
  
  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Pass button
          _buildActionButton(
            icon: Icons.close,
            color: Colors.red,
            onPressed: _handlePassButton,
          ),
          
          // Super like button
          _buildActionButton(
            icon: Icons.star,
            color: Colors.blue,
            onPressed: _handleSuperLikeButton,
          ),
          
          // Like button
          _buildActionButton(
            icon: Icons.favorite,
            color: Colors.green,
            onPressed: _handleLikeButton,
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: color,
          size: 30,
        ),
      ),
    );
  }
} 
