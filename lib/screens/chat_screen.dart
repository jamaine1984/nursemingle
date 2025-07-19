import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';
import '../models/message.dart';
import '../models/user.dart';
import '../services/message_service.dart';
import 'gifts_screen.dart';
import 'VideoCallScreen/video_call_screen.dart';
import 'PhoneCallScreen/phone_call_screen.dart';

class ChatScreen extends StatefulWidget {
  final User? otherUser;
  final String? conversationId;

  const ChatScreen({
    Key? key,
    this.otherUser,
    this.conversationId,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Message> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  late User _otherUser;
  late String _conversationId;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeChat();
  }

  void _initializeChat() {
    // Get route arguments if available
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    
    if (widget.otherUser != null && widget.conversationId != null) {
      // Direct constructor parameters
      _otherUser = widget.otherUser!;
      _conversationId = widget.conversationId!;
    } else if (args != null) {
      // Route arguments - create mock user and conversation
      final userId = args['userId'] as String;
      _otherUser = User(
        id: userId,
        email: 'user$userId@example.com',
        firstName: 'User',
        lastName: userId,
        displayName: 'User $userId',
        age: 25,
        bio: 'Chat user',
        profession: 'Nurse',
        nursingSpecialty: 'General',
        interests: [],
        location: 'Unknown',
        isOnline: true,
        lastSeen: DateTime.now(),
        isVerified: false,
        subscriptionPlan: 'free',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      _conversationId = 'conv_$userId';
    } else {
      // Fallback - shouldn't happen
      _otherUser = User(
        id: 'unknown',
        email: 'unknown@example.com',
        firstName: 'Unknown',
        lastName: 'User',
        displayName: 'Unknown User',
        age: 25,
        bio: 'Chat user',
        profession: 'Nurse',
        nursingSpecialty: 'General',
        interests: [],
        location: 'Unknown',
        isOnline: false,
        lastSeen: DateTime.now(),
        isVerified: false,
        subscriptionPlan: 'free',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      _conversationId = 'conv_unknown';
    }
    
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    try {
      final messages = await MessageService.getMessagesForUser(_conversationId);
      setState(() {
        _messages = messages;
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading messages: $e');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _isSending) return;

    final content = _messageController.text.trim();
    _messageController.clear();

    setState(() {
      _isSending = true;
    });

    try {
      final newMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: 'current_user',
        recipientId: _otherUser.id,
        conversationId: _conversationId,
        content: content,
        type: 'text',
        timestamp: DateTime.now(),
        metadata: {'sender_name': 'You'},
      );

      setState(() {
        _messages.add(newMessage);
      });

      _scrollToBottom();

      // In a real app, you'd send this to your backend
      await Future.delayed(const Duration(milliseconds: 500));
      
    } catch (e) {
      print('Error sending message: $e');
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: _isLoading ? _buildLoadingState() : _buildMessagesList(),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(
          Icons.arrow_back,
          color: AppColors.text,
        ),
      ),
      title: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primary,
            backgroundImage: _otherUser.profileImageUrl != null
                ? NetworkImage(_otherUser.profileImageUrl!)
                : null,
            child: _otherUser.profileImageUrl == null
                ? const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 20,
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_otherUser.firstName} ${_otherUser.lastName}',
                  style: GoogleFonts.urbanist(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
                Text(
                  _otherUser.isOnline ? 'Online' : 'Last seen recently',
                  style: GoogleFonts.urbanist(
                    fontSize: 12,
                    color: _otherUser.isOnline 
                        ? AppColors.success 
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: _startPhoneCall,
          icon: const Icon(
            Icons.phone,
            color: AppColors.primary,
          ),
        ),
        IconButton(
          onPressed: _startVideoCall,
          icon: const Icon(
            Icons.videocam,
            color: AppColors.primary,
          ),
        ),
        PopupMenuButton<String>(
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'profile',
              child: Row(
                children: [
                  Icon(Icons.person, color: AppColors.text),
                  SizedBox(width: 12),
                  Text('View Profile'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'block',
              child: Row(
                children: [
                  Icon(Icons.block, color: AppColors.error),
                  SizedBox(width: 12),
                  Text('Block User'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'report',
              child: Row(
                children: [
                  Icon(Icons.report, color: AppColors.error),
                  SizedBox(width: 12),
                  Text('Report User'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildMessagesList() {
    if (_messages.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final isMe = message.senderId == 'current_user';
        final showDate = index == 0 || 
            !_isSameDay(_messages[index - 1].timestamp, message.timestamp);

        return Column(
          children: [
            if (showDate) _buildDateSeparator(message.timestamp),
            _buildMessageBubble(message, isMe),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.primary,
            backgroundImage: _otherUser.profileImageUrl != null
                ? NetworkImage(_otherUser.profileImageUrl!)
                : null,
            child: _otherUser.profileImageUrl == null
                ? const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 40,
                  )
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            'Start a conversation with\n${_otherUser.firstName}',
            style: GoogleFonts.urbanist(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Send a message to break the ice!',
            style: GoogleFonts.urbanist(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSeparator(DateTime date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          const Expanded(child: Divider(color: AppColors.border)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _formatDate(date),
              style: GoogleFonts.urbanist(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const Expanded(child: Divider(color: AppColors.border)),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message, bool isMe) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            const CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary,
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isMe ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.cardShadow,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: GoogleFonts.urbanist(
                      fontSize: 15,
                      color: isMe ? Colors.white : AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: GoogleFonts.urbanist(
                      fontSize: 11,
                      color: isMe 
                          ? Colors.white70 
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            const CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary,
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Gift Button
            IconButton(
              onPressed: _showGiftSelector,
              icon: const Icon(
                Icons.card_giftcard,
                color: AppColors.primary,
              ),
            ),
            
            // Message Input
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border),
                ),
                child: TextField(
                  controller: _messageController,
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: GoogleFonts.urbanist(
                      color: AppColors.textSecondary,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 8),
            
            // Send Button
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: _isSending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 20,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _startPhoneCall() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhoneCallScreen(
          roomName: 'call_${_otherUser.id}',
          participantId: _otherUser.id,
          participantName: _otherUser.name,
          isIncoming: false,
        ),
      ),
    );
  }

  void _startVideoCall() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoCallScreen(
          roomName: 'video_${_otherUser.id}',
          participantId: _otherUser.id,
          isIncoming: false,
        ),
      ),
    );
  }

  void _showGiftSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    'Send a Gift',
                    style: GoogleFonts.urbanist(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GiftsScreen(
                isModal: true,
                onGiftSelected: (gift) {
                  Navigator.pop(context);
                  _sendGiftMessage(gift);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendGiftMessage(dynamic gift) {
    // Send gift as a message
    final giftMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: 'current_user',
      recipientId: _otherUser.id,
      conversationId: _conversationId,
      content: 'Sent a ${gift.name}',
      type: 'gift',
      timestamp: DateTime.now(),
      metadata: {
        'sender_name': 'You',
        'gift_id': gift.id,
        'gift_name': gift.name,
        'gift_icon': gift.icon,
      },
    );

    setState(() {
      _messages.add(giftMessage);
    });

    _scrollToBottom();
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'profile':
        // Navigate to user profile
        break;
      case 'block':
        _showBlockDialog();
        break;
      case 'report':
        _showReportDialog();
        break;
    }
  }

  void _showBlockDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Block User'),
        content: Text('Are you sure you want to block ${_otherUser.firstName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement block functionality
            },
            child: const Text('Block'),
          ),
        ],
      ),
    );
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report User'),
        content: Text('Report ${_otherUser.firstName} for inappropriate behavior?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement report functionality
            },
            child: const Text('Report'),
          ),
        ],
      ),
    );
  }
} 
