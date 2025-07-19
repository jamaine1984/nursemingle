import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_colors.dart';
import '../edit_profile_screen.dart';
import '../settings_screen.dart';
import '../gifts_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: GoogleFonts.urbanist(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.user;
          
          if (user == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Image
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary,
                      width: 3,
                    ),
                  ),
                  child: ClipOval(
                    child: user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty
                        ? Image.network(
                            user.profileImageUrl!,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildPlaceholderImage();
                            },
                          )
                        : _buildPlaceholderImage(),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Name and basic info
                Text(
                  '${user.firstName} ${user.lastName}',
                  style: GoogleFonts.urbanist(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (user.age != null)
                  Text(
                    'Age: ${user.age}',
                    style: GoogleFonts.urbanist(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                if (user.profession != null)
                  Text(
                    user.profession!,
                    style: GoogleFonts.urbanist(
                      fontSize: 16,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                if (user.location != null)
                  Text(
                    user.location!,
                    style: GoogleFonts.urbanist(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                const SizedBox(height: 16),
                
                // Bio
                if (user.bio != null && user.bio!.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.border,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      user.bio!,
                      style: GoogleFonts.urbanist(
                        fontSize: 16,
                        color: AppColors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                
                // Subscription info
                _buildSubscriptionCard(authProvider),
                const SizedBox(height: 24),
                
                // Action buttons
                _buildActionButtons(context, authProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withOpacity(0.1),
      ),
      child: const Icon(
        Icons.person,
        size: 60,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildSubscriptionCard(AuthProvider authProvider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.star,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Subscription Plan',
                style: GoogleFonts.urbanist(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            authProvider.subscriptionPlan.toUpperCase(),
            style: GoogleFonts.urbanist(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _getSubscriptionDescription(authProvider.subscriptionPlan),
            style: GoogleFonts.urbanist(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _getSubscriptionDescription(String plan) {
    switch (plan.toLowerCase()) {
      case 'free':
        return 'Basic features with limited usage';
      case 'starter':
        return 'Enhanced features for active users';
      case 'gold':
        return 'Premium features with high limits';
      case 'platinum':
        return 'Unlimited access to all features';
      default:
        return 'Current subscription plan';
    }
  }

  Widget _buildActionButtons(BuildContext context, AuthProvider authProvider) {
    return Column(
      children: [
        // Edit Profile Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfileScreen(),
                ),
              );
            },
            icon: const Icon(Icons.edit),
            label: const Text('Edit Profile'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        
        // View Gifts Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const GiftsScreen(),
                ),
              );
            },
            icon: const Icon(Icons.card_giftcard),
            label: const Text('View Gifts'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        
        // Settings Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
            icon: const Icon(Icons.settings),
            label: const Text('Settings'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              side: const BorderSide(color: AppColors.border),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }
} 
