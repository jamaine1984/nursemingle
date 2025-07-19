import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';
import '../models/user.dart';
import '../utils/api_service.dart';

class BlockedUsersScreen extends StatefulWidget {
  const BlockedUsersScreen({Key? key}) : super(key: key);

  @override
  State<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> {
  List<User> _blockedUsers = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBlockedUsers();
  }

  Future<void> _loadBlockedUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      print('🚫 BLOCKED_USERS: Loading blocked users...');
      final response = await ApiService.get('/api/user/blocked');
      
      if (response['success'] == true) {
        final List<dynamic> blockedUsersJson = response['data'] ?? [];
        List<User> blockedUsers = [];
        
        for (var userJson in blockedUsersJson) {
          try {
            final user = User.fromJson(userJson);
            blockedUsers.add(user);
          } catch (e) {
            print('⚠️ BLOCKED_USERS: Failed to parse blocked user: $e');
          }
        }
        
        setState(() {
          _blockedUsers = blockedUsers;
          _isLoading = false;
        });
        
        print('✅ BLOCKED_USERS: Loaded ${blockedUsers.length} blocked users');
      } else {
        setState(() {
          _blockedUsers = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ BLOCKED_USERS: Error loading blocked users: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
        _blockedUsers = [];
      });
    }
  }

  Future<void> _unblockUser(User user) async {
    try {
      print('🚫 BLOCKED_USERS: Unblocking user: ${user.firstName} ${user.lastName}');
      
      final response = await ApiService.post('/api/user/unblock', {
        'user_id': user.id,
      });
      
      if (response['success'] == true) {
        setState(() {
          _blockedUsers.removeWhere((blockedUser) => blockedUser.id == user.id);
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${user.firstName} ${user.lastName} has been unblocked'),
            backgroundColor: Colors.green,
          ),
        );
        
        print('✅ BLOCKED_USERS: User unblocked successfully');
      } else {
        throw Exception(response['error'] ?? 'Failed to unblock user');
      }
    } catch (e) {
      print('❌ BLOCKED_USERS: Error unblocking user: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to unblock user: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Blocked Users',
          style: GoogleFonts.urbanist(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Error Loading Blocked Users',
              style: GoogleFonts.urbanist(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: GoogleFonts.urbanist(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadBlockedUsers,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_blockedUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.block,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No Blocked Users',
              style: GoogleFonts.urbanist(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You haven\'t blocked anyone yet.',
              style: GoogleFonts.urbanist(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBlockedUsers,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _blockedUsers.length,
        itemBuilder: (context, index) {
          final user = _blockedUsers[index];
          return _buildBlockedUserCard(user);
        },
      ),
    );
  }

  Widget _buildBlockedUserCard(User user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Profile Image
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.1),
              ),
              child: ClipOval(
                child: user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty
                    ? Image.network(
                        user.profileImageUrl!,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.person,
                            size: 25,
                            color: AppColors.primary,
                          );
                        },
                      )
                    : const Icon(
                        Icons.person,
                        size: 25,
                        color: AppColors.primary,
                      ),
              ),
            ),
            const SizedBox(width: 16),
            
            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${user.firstName} ${user.lastName}',
                    style: GoogleFonts.urbanist(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (user.profession != null)
                    Text(
                      user.profession!,
                      style: GoogleFonts.urbanist(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            
            // Unblock Button
            TextButton(
              onPressed: () => _showUnblockConfirmation(user),
              style: TextButton.styleFrom(
                backgroundColor: Colors.green.withOpacity(0.1),
                foregroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Unblock',
                style: GoogleFonts.urbanist(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUnblockConfirmation(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Unblock User',
          style: GoogleFonts.urbanist(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to unblock ${user.firstName} ${user.lastName}?',
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
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _unblockUser(user);
            },
            child: Text(
              'Unblock',
              style: GoogleFonts.urbanist(color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }
} 
