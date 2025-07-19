import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:nursemingle/services/messages_service.dart';
import 'package:nursemingle/models/profile_model.dart';
import 'package:provider/provider.dart';
import 'package:nursemingle/providers/auth_provider.dart';
import 'package:nursemingle/providers/app_state_provider.dart';
import 'package:nursemingle/components/rewarded_ad_dialog.dart';
import 'package:nursemingle/utils/api_service.dart';

class ChatScreen extends StatefulWidget {
  final String matchId;
  final ProfileModel profile;
  const ChatScreen({required this.matchId, required this.profile, super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final MessagesService _messagesService = MessagesService();
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> messages = [];
  bool isLoading = true;
  String? errorMessage;
  Timer? _pollTimer;
  bool showEmojiPicker = false;
  bool isTyping = false;
  bool otherTyping = false;
  File? mediaFile;
  String? mediaType; // 'image' or 'video'
  VideoPlayerController? _videoController;
  bool isPaidUser = true; // TODO: Get from Provider (user plan)
  Timer? _typingTimeout;
  bool useWebSocket = false; // Set to true if backend supports
  List<Map<String, dynamic>> giftInventory = [
    {'name': 'Stethoscope', 'emoji': '🩺', 'count': 2},
    {'name': 'Bandage', 'emoji': '🩹', 'count': 5},
    {'name': 'Diamond', 'emoji': '💎', 'count': 1},
  ];
  int _adsWatched = 0;
  List<Map<String, dynamic>> moderationFeedback = [];

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  void _initChat() {
    if (useWebSocket) {
      _messagesService.connectWebSocket(widget.matchId, _onWebSocketMessage);
    } else {
      _loadMessages();
      _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) => _loadMessages());
    }
  }

  void _onWebSocketMessage(Map<String, dynamic> msg) {
    if (msg['type'] == 'message') {
      setState(() {
        messages.add(msg['data']);
      });
    } else if (msg['type'] == 'typing') {
      setState(() {
        otherTyping = msg['typing'] == true;
      });
      _typingTimeout?.cancel();
      _typingTimeout = Timer(const Duration(seconds: 3), () {
        setState(() => otherTyping = false);
      });
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _typingTimeout?.cancel();
    _videoController?.dispose();
    if (useWebSocket) _messagesService.disconnectWebSocket();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    final result = await _messagesService.getMessages(widget.matchId);
    if (result['success']) {
      setState(() {
        messages = List<Map<String, dynamic>>.from(result['data']['messages'] ?? []);
        isLoading = false;
      });
      // Mark all received messages as read after a short delay
      Future.delayed(const Duration(milliseconds: 800), () {
        setState(() {
          for (var msg in messages) {
            if (!(msg['isMe'] ?? false)) {
              msg['read'] = true;
            }
          }
        });
      });
    } else {
      setState(() {
        errorMessage = result['message'];
        isLoading = false;
      });
    }
  }

  Future<void> _sendMessage({String? text, File? file, String? fileType}) async {
    if ((text == null || text.trim().isEmpty) && file == null) return;
    if (text != null) {
              final result = moderateContent(text);
      if (result['flagged']) {
        final feedback = await showDialog<String>(
          context: context,
          builder: (context) {
            String feedbackText = '';
            return AlertDialog(
              title: const Text('Message Blocked'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(result['reason']),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: const InputDecoration(hintText: 'Why do you think this is a mistake?'),
                    onChanged: (val) => feedbackText = val,
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, feedbackText),
                  child: const Text('Submit Feedback'),
                ),
              ],
            );
          },
        );
        if (feedback != null && feedback.trim().isNotEmpty) {
          moderationFeedback.add({
            'type': 'message',
            'content': text,
            'reason': result['reason'],
            'feedback': feedback.trim(),
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Feedback submitted for review.')),
          );
        }
        return;
      }
    }
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    // Free plan gating logic
    if (authProvider.currentPlan == 'Free' && authProvider.messagesLeft <= 0) {
      if (_adsWatched < 3) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => RewardedAdDialog(
            title: 'Get More Messages!',
            message: 'Watch a short ad to get 10 extra messages.',
            rewardDescription: 'You\'ll receive 10 additional messages',
            onRewarded: () {
              setState(() => _adsWatched++);
              if (_adsWatched == 3) {
                Provider.of<AppStateProvider>(context, listen: false).watchAdForExtraMessages();
                _adsWatched = 0;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('10 extra messages unlocked!')),
                );
              }
            },
            onCancel: () => Navigator.of(context).pop(),
          ),
        );
        return;
      } else {
        Provider.of<AppStateProvider>(context, listen: false).watchAdForExtraMessages();
        _adsWatched = 0;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('10 extra messages unlocked!')),
        );
        return;
      }
    }
    _controller.clear();
    setState(() {
      mediaFile = null;
      mediaType = null;
      // Append the message locally for instant feedback
      if (file != null) {
        messages.add({'isMe': true, 'fileUrl': file.path, 'fileType': fileType});
      } else {
        messages.add({'isMe': true, 'text': text});
      }
    });
    if (useWebSocket) {
      await _messagesService.sendWebSocketMessage({
        'type': 'message',
        'matchId': widget.matchId,
        'message': text ?? '',
      }, file: file, fileType: fileType);
    } else {
      await _messagesService.sendMessage(matchId: widget.matchId, message: text ?? '', file: file, fileType: fileType);
      _loadMessages();
    }
    // Decrement message count for free plan
    if (authProvider.currentPlan == 'Free') {
      authProvider.useMessage();
    }
  }

  void _onEmojiSelected(Emoji emoji) {
    _controller.text += emoji.emoji;
  }

  Future<void> _pickMedia({bool pickVideo = false}) async {
    try {
      final picker = ImagePicker();
      final picked = pickVideo
          ? await picker.pickVideo(source: ImageSource.gallery)
          : await picker.pickImage(source: ImageSource.gallery);
      if (!mounted) return;
      if (picked == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No ${pickVideo ? 'video' : 'image'} selected.')),
        );
        return;
      }
      setState(() {
        mediaFile = File(picked.path);
        mediaType = pickVideo ? 'video' : 'image';
        if (pickVideo) {
          _videoController = VideoPlayerController.file(mediaFile!)
            ..initialize().then((_) => setState(() {}));
        }
      });
    } catch (e, stack) {
      debugPrint('🛑 AI Bug Guard: Exception in _pickMedia: $e\n$stack');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to pick media. Please try again.')),
      );
    }
  }

  void _onTyping(String value) async {
    setState(() { isTyping = value.isNotEmpty; });
    if (useWebSocket) {
      await _messagesService.sendWebSocketMessage({
        'type': 'typing',
        'matchId': widget.matchId,
        'typing': isTyping,
      });
    } else {
      _messagesService.sendTypingStatus(widget.matchId, isTyping);
    }
    _typingTimeout?.cancel();
    _typingTimeout = Timer(const Duration(seconds: 3), () async {
      if (!mounted) return;
      setState(() { isTyping = false; });
      if (useWebSocket) {
        await _messagesService.sendWebSocketMessage({
          'type': 'typing',
          'matchId': widget.matchId,
          'typing': false,
        });
      } else {
        _messagesService.sendTypingStatus(widget.matchId, false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isPaidUser = Provider.of<AuthProvider>(context, listen: false).isPaidUser;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(backgroundImage: NetworkImage(widget.profile.imageUrls.isNotEmpty ? widget.profile.imageUrls[0] : '')),
            const SizedBox(width: 12),
            Text(widget.profile.displayName),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.flag, color: Colors.orange),
            tooltip: 'Report',
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Report User'),
                  content: const Text('Are you sure you want to report this user for inappropriate behavior?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                    ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Report')),
                  ],
                ),
              );
              if (confirmed == true && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User reported. Our team will review this conversation.')),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.block, color: Colors.red),
            tooltip: 'Block',
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Block User'),
                  content: const Text('Are you sure you want to block this user? You will no longer receive messages from them.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                    ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Block')),
                  ],
                ),
              );
              if (confirmed == true && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User blocked.')), 
                );
                Navigator.pop(context); // Exit chat
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.phone),
            onPressed: isPaidUser
                ? () => showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                                title: const Text('Phone Call'),
        content: const Text('Phone call feature coming soon.'),
                        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
                      ),
                    )
                : () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Upgrade to Starter to use phone calls!')),
                    ),
            tooltip: isPaidUser ? 'Phone Call' : 'Upgrade required',
          ),
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: isPaidUser
                ? () => showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                                title: const Text('Video Call'),
        content: const Text('Video call feature coming soon.'),
                        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
                      ),
                    )
                : () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Upgrade to Starter to use video calls!')),
                    ),
            tooltip: isPaidUser ? 'Video Call' : 'Upgrade required',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, i) {
                      final msg = messages[messages.length - 1 - i];
                      final isMe = msg['isMe'] ?? false;
                      final isMedia = msg['fileUrl'] != null && msg['fileUrl'].toString().isNotEmpty;
                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.blue[100] : Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (isMedia)
                                msg['fileType'] == 'image'
                                    ? Image.network(msg['fileUrl'], width: 180)
                                    : msg['fileType'] == 'video'
                                        ? _buildVideoPlayer(msg['fileUrl'])
                                        : const SizedBox.shrink(),
                              if (msg['message'] != null && msg['message'].toString().isNotEmpty)
                                Text(msg['message'], style: const TextStyle(fontSize: 16)),
                              if (isMe && (msg['read'] == true || msg['isRead'] == true))
                                const Align(
                                  alignment: Alignment.bottomRight,
                                  child: Icon(Icons.done_all, size: 16, color: Colors.green),
                                ),
                              if (msg['typing'] == true)
                                const Align(
                                  alignment: Alignment.bottomRight,
                                  child: Text('Typing...', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (mediaFile != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Stack(
                      children: [
                        mediaType == 'image'
                            ? Image.file(mediaFile!, width: 120, height: 120)
                            : mediaType == 'video' && _videoController != null && _videoController!.value.isInitialized
                                ? SizedBox(
                                    width: 120,
                                    height: 120,
                                    child: VideoPlayer(_videoController!),
                                  )
                                : const SizedBox.shrink(),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () => setState(() {
                              mediaFile = null;
                              mediaType = null;
                              _videoController?.dispose();
                              _videoController = null;
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                const Divider(height: 1),
                // Attachment bar (replace smiley with gift icon, prepare for inventory icon)
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.attach_file),
                        onPressed: () => _pickMedia(),
                        tooltip: 'Attach Image',
                      ),
                      IconButton(
                        icon: const Icon(Icons.card_giftcard, color: Colors.deepPurple),
                        onPressed: () => _showGiftShelf(context),
                        tooltip: 'Send Gift',
                      ),
                      IconButton(
                        icon: const Icon(Icons.inventory_2, color: Colors.orange),
                        onPressed: () => _showInventory(context),
                        tooltip: 'Gift Inventory',
                      ),
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          onChanged: _onTyping,
                          decoration: const InputDecoration(
                            hintText: 'Type a message...',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send, color: Colors.blueAccent),
                        onPressed: () {
                          if (_controller.text.trim().isNotEmpty) {
                            _sendMessage(text: _controller.text.trim());
                          }
                        },
                        tooltip: 'Send',
                      ),
                    ],
                  ),
                ),
                if (showEmojiPicker)
                  SizedBox(
                    height: 250,
                    child: EmojiPicker(
                      onEmojiSelected: (cat, emoji) => _onEmojiSelected(emoji),
                    ),
                  ),
                if (otherTyping)
                  const Padding(
                    padding: EdgeInsets.only(left: 16, bottom: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Typing...', style: TextStyle(fontSize: 14, color: Colors.grey)),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildVideoPlayer(String url) {
    final controller = VideoPlayerController.networkUrl(Uri.parse(url));
    return FutureBuilder(
      future: controller.initialize(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: VideoPlayer(controller),
          );
        } else {
          return const SizedBox(
            width: 180,
            height: 120,
            child: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }

  void _showInventory(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Gift Inventory', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            const SizedBox(height: 20),
            ...giftInventory.map((gift) => ListTile(
              leading: Text(gift['emoji'], style: const TextStyle(fontSize: 28)),
              title: Text(gift['name']),
              trailing: Text('x${gift['count']}'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Send ${gift['name']} (from inventory)')),
                );
              },
            )),
          ],
        ),
      ),
    );
  }

  void _showGiftShelf(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) => GiftShelfModal(
        onGiftBought: (gift) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('You bought ${gift['name']}!')),
          );
        },
      ),
    );
  }
}

// Minimal gift shelf modal for chat (reuse/adjust as needed)
class GiftShelfModal extends StatelessWidget {
  final void Function(Map<String, dynamic>) onGiftBought;
  const GiftShelfModal({required this.onGiftBought, super.key});

  @override
  Widget build(BuildContext context) {
            // Gift inventory for sending to users
    final List<Map<String, dynamic>> gifts = [
      {'name': 'Stethoscope', 'emoji': '🩺'},
      {'name': 'Bandage', 'emoji': '🩹'},
      {'name': 'Diamond', 'emoji': '💎'},
    ];
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Gift Shelf', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: GridView.builder(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: gifts.length,
                itemBuilder: (context, i) {
                  final gift = gifts[i];
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 2,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => onGiftBought(gift),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(gift['emoji'] ?? '', style: const TextStyle(fontSize: 32)),
                            const SizedBox(height: 4),
                            Text(gift['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            ElevatedButton(
                              onPressed: () => onGiftBought(gift),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(60, 28),
                                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                                textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Buy'),
                            ),
                          ],
                        ),
                      ),
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
} 
