import 'package:flutter/material.dart';
import '../../services/messages_service.dart';
import '../../models/profile_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../utils/app_colors.dart';
import 'chat_screen.dart';

class MessagesScreen extends StatefulWidget {
  static const routeName = '/messages';

  const MessagesScreen({super.key});
  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final MessagesService _messagesService = MessagesService();
  bool isLoading = true;
  String? errorMessage;
  List<Map<String, dynamic>> matches = [];
      Set<String> unreadMatchIds = {}; // Track unread messages

  @override
  void initState() {
    super.initState();
    _loadMatches();
  }

  Future<void> _loadMatches() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    final result = await _messagesService.getMatches();
    if (result['success']) {
      setState(() {
        matches = List<Map<String, dynamic>>.from(result['data']['matches'] ?? []);
        isLoading = false;
      });
    } else {
      setState(() {
        errorMessage = result['message'];
        isLoading = false;
      });
    }
  }

  void _openChat(Map<String, dynamic> match) async {
    final profile = ProfileModel.fromJson(match['profile']);
    final matchId = match['matchId'];
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          matchId: matchId,
          profile: profile,
        ),
      ),
    );
    // Reload chat history on return
    _loadMatches();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Messages', style: GoogleFonts.urbanist(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: const Color(0xFFFFE5B4),
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!, style: GoogleFonts.poppins(color: theme.colorScheme.error)))
              : matches.isEmpty
                  ? Center(child: Text('No matches yet.', style: GoogleFonts.poppins(fontSize: 18)))
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                      itemCount: matches.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final match = matches[i];
                        final profile = ProfileModel.fromJson(match['profile']);
                        final lastMessage = match['lastMessage'] ?? '';
                        final isUnread = unreadMatchIds.contains(match['matchId']);
                        final onlyUserMessage = match['messages'] != null && match['messages'].length == 1 && match['messages'][0]['isMe'] == true;
                        return Slidable(
                          key: ValueKey(match['matchId']),
                          endActionPane: ActionPane(
                            motion: const DrawerMotion(),
                            extentRatio: 0.4,
                            children: [
                              SlidableAction(
                                onPressed: (_) {
                                  setState(() {
                                    matches.removeAt(i);
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Chat deleted.')),
                                  );
                                },
                                backgroundColor: theme.colorScheme.error,
                                foregroundColor: theme.colorScheme.onError,
                                icon: Icons.delete,
                                label: 'Delete',
                              ),
                            ],
                          ),
                          child: Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            elevation: 4,
                            color: theme.colorScheme.surface,
                            child: ListTile(
                              leading: Stack(
                                children: [
                                  CircleAvatar(backgroundImage: NetworkImage(profile.imageUrls.isNotEmpty ? profile.imageUrls[0] : ''), radius: 28),
                                  if (isUnread)
                                    Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primary,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.mark_chat_unread, size: 16, color: Colors.white),
                                      ),
                                    ),
                                ],
                              ),
                              title: Text(
                                profile.displayName,
                                style: GoogleFonts.urbanist(fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                              subtitle: onlyUserMessage
                                  ? Text('Waiting for reply...', style: GoogleFonts.poppins(fontSize: 15, color: Colors.grey))
                                  : Text(
                                      lastMessage,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.inter(fontSize: 15),
                                    ),
                              trailing: isUnread
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text('New', style: GoogleFonts.poppins(color: theme.colorScheme.primary)),
                                    )
                                  : null,
                              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                              onTap: () => _openChat(match),
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
} 
