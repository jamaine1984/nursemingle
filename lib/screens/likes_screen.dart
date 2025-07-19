import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../models/user.dart';
import '../utils/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class LikesScreen extends StatefulWidget {
  const LikesScreen({super.key});

  @override
  State<LikesScreen> createState() => _LikesScreenState();
}

class _LikesScreenState extends State<LikesScreen> {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Likes', style: GoogleFonts.urbanist(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
      ),
      body: appState.likedProfiles.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: appState.likedProfiles.length,
              itemBuilder: (context, index) {
                final profile = appState.likedProfiles[index];
                return _buildLikeCard(profile, appState);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          Text(
            'No likes yet',
            style: GoogleFonts.urbanist(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Start swiping to get likes!',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLikeCard(User profile, AppStateProvider appState) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage(profile.profileImages?.isNotEmpty == true ? profile.profileImages!.first : ''),
              onBackgroundImageError: (exception, stackTrace) {
                // Handle error
              },
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.name,
                    style: GoogleFonts.urbanist(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${profile.age ?? 'N/A'} • ${profile.city ?? 'Unknown'}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    profile.bio ?? 'No bio available',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    // TODO: Implement like back functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('You liked ${profile.name} back!')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('Like Back'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    // TODO: Open chat with this user
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Opening chat with ${profile.name}...')),
                    );
                  },
                  child: const Text('Message'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 
