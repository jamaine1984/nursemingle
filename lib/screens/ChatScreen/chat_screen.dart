import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import '../../providers/app_state_provider.dart'; // For RewardedAdDialog
import '../../models/gift_model.dart'; // For GiftShelf
import '../../models/gift_shelf.dart';
import '../../components/rewarded_ad_dialog.dart' as reward_dialog;

class ChatScreen extends StatefulWidget {
  static const routeName = '/chat';
  final dynamic profile;
  final String matchId;
  const ChatScreen({super.key, required this.profile, required this.matchId});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> messages = [
    {'text': 'Hi there! 👋', 'isMe': false, 'type': 'text'},
    {'text': 'Hey! How are you?', 'isMe': true, 'type': 'text'},
    {'text': 'I love your profile!', 'isMe': false, 'type': 'text'},
  ];
  bool isTyping = false;
  Timer? typingTimer;
  int _adsWatched = 0;
  bool waitingForReply = false;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  @override
  void initState() {
    super.initState();
    // If this chat was just started, show waiting state
    if (messages.length == 1 && messages[0]['isMe'] == true) {
      waitingForReply = true;
    }
  }
  @override
  void dispose() {
    typingTimer?.cancel();
    super.dispose();
  }
  void _sendMessage(String text) {
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    if (appState.currentPlan == 'Gold' || appState.messagesLeft > 0) {
      appState.sendMessage(widget.profile.id, text);
      _controller.clear();
      setState(() {
        messages.insert(0, {'text': text, 'isMe': true, 'type': 'text'});
        _listKey.currentState?.insertItem(0);
      });
    } else {
      // Out of messages: prompt to watch 3 ads
      if (_adsWatched < 3) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => reward_dialog.RewardedAdDialog(
            title: 'Get Extra Messages!',
            message: 'Watch a short ad to get more messages.',
            rewardDescription: 'You\'ll receive extra messages after watching the ad',
            onRewarded: () {
              setState(() => _adsWatched++);
              if (_adsWatched == 3) {
                appState.watchAdForExtraMessages();
                _adsWatched = 0;
              }
            },
            onCancel: () => Navigator.of(context).pop(),
          ),
        );
      } else {
        appState.watchAdForExtraMessages();
        _adsWatched = 0;
      }
    }
  }
  void _simulateTyping() {
    setState(() => isTyping = true);
    typingTimer?.cancel();
    typingTimer = Timer(const Duration(seconds: 2), () => setState(() => isTyping = false));
  }
  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (!mounted) return;
      if (pickedFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No image selected.')),
        );
        return;
      }
      setState(() {
        messages.add({'text': pickedFile.path, 'isMe': true, 'type': 'image'});
      });
    } catch (e, stack) {
      debugPrint('🛑 AI Bug Guard: Exception in _pickImage: $e\n$stack');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to pick image. Please try again.')),
      );
    }
  }
  bool _canCall(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    return appState.currentPlan == 'Starter' || appState.currentPlan == 'Gold';
  }

  void _showGiftShelf(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) => _GiftShelfModal(
        onGiftBought: (gift) {
          _handleGiftPurchase(gift);
        },
      ),
    );
  }

  void _handleGiftPurchase(Gift gift) {
    if (gift.price == 0) {
      // Free gift - show ad to unlock
      _showGiftAdDialog(gift);
    } else {
      // Premium gift - check if user has enough points
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.giftPoints >= gift.price) {
        authProvider.spendGiftPoints(gift.price);
        _sendGift(gift);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You need ${gift.price} gift points to send this gift.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _showGiftAdDialog(Gift gift) {
    showDialog(
      context: context,
      builder: (context) => reward_dialog.RewardedAdDialog(
        title: 'Unlock Free Gift!',
        message: 'Watch a short ad to send ${gift.name} for free.',
        rewardDescription: 'You\'ll be able to send ${gift.name} immediately',
        onRewarded: () {
          _sendGift(gift);
        },
        onCancel: () => Navigator.of(context).pop(),
      ),
    );
  }

  void _sendGift(Gift gift) {
    setState(() {
      messages.insert(0, {
        'text': '🎁 ${gift.name}',
        'isMe': true,
        'type': 'gift',
        'gift': gift,
      });
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${gift.name} sent!'),
        backgroundColor: Colors.green,
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final isPaidUser = Provider.of<AuthProvider>(context, listen: false).isPaidUser;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(backgroundImage: NetworkImage(widget.profile?.imageUrl ?? '')),
            const SizedBox(width: 12),
            Text(widget.profile?.displayName ?? 'Chat', style: GoogleFonts.urbanist(fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        actions: [
          if (isPaidUser)
            IconButton(
              icon: const Icon(Icons.phone, color: Colors.green),
              tooltip: 'Phone Call',
              onPressed: _canCall(context) ? () => Navigator.pushNamed(context, '/phone_call') : null,
            ),
          if (isPaidUser)
            IconButton(
              icon: const Icon(Icons.videocam, color: Colors.blue),
              tooltip: 'Video Call',
              onPressed: _canCall(context) ? () => Navigator.pushNamed(context, '/video_call') : null,
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              itemCount: waitingForReply ? 1 : messages.length + (isTyping ? 1 : 0),
              itemBuilder: (context, i) {
                if (waitingForReply) {
                  final msg = messages[0];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              child: Text(
                                msg['text'],
                                style: GoogleFonts.poppins(fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text('Waiting for reply...', style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey)),
                    ],
                  );
                }
                if (isTyping && i == messages.length) {
                  // Typing indicator
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _Dot(),
                            SizedBox(width: 4),
                            _Dot(delay: 200),
                            SizedBox(width: 4),
                            _Dot(delay: 400),
                          ],
                        ),
                      ),
                    ],
                  );
                }
                final msg = messages[i];
                final isMe = msg['isMe'] as bool;
                final type = msg['type'] as String;
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                        color: isMe ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15) : Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          if (isMe)
                            BoxShadow(
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                        ],
                      ),
                      child: type == 'image'
                          ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.asset(msg['text'], width: 180, height: 180, fit: BoxFit.cover),
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              child: Text(
                                msg['text'],
                                style: GoogleFonts.poppins(fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
                              ),
                            ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.image, color: Colors.pinkAccent),
                  tooltip: 'Send Image',
                  onPressed: _pickImage,
                ),
                IconButton(
                  icon: const Icon(Icons.card_giftcard, color: Colors.deepPurple),
                  tooltip: 'Send Gift',
                  onPressed: () => _showGiftShelf(context),
                ),
                IconButton(
                  icon: const Icon(Icons.phone, color: Colors.green),
                  tooltip: 'Phone Call',
                  onPressed: _canCall(context) ? () => Navigator.pushNamed(context, '/phone_call') : null,
                ),
                IconButton(
                  icon: const Icon(Icons.videocam, color: Colors.blue),
                  tooltip: 'Video Call',
                  onPressed: _canCall(context) ? () => Navigator.pushNamed(context, '/video_call') : null,
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: GoogleFonts.poppins(fontSize: 16),
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: InputBorder.none,
                    ),
                    onChanged: (_) => _simulateTyping(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blueAccent),
                  tooltip: 'Send',
                  onPressed: () {
                    if (_controller.text.trim().isNotEmpty) {
                      _sendMessage(_controller.text.trim());
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatefulWidget {
  final int delay;
  const _Dot({this.delay = 0});
  @override
  State<_Dot> createState() => _DotState();
}
class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _anim;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _anim = Tween(begin: 0.3, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    Future.delayed(Duration(milliseconds: widget.delay), () => _controller.repeat(reverse: true));
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: Colors.grey,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _GiftShelfModal extends StatelessWidget {
  final void Function(Gift) onGiftBought;
  const _GiftShelfModal({required this.onGiftBought});

  @override
  Widget build(BuildContext context) {
    final gifts = GiftShelf.allGifts;
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
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
            Text('Gift Shelf', style: GoogleFonts.urbanist(fontWeight: FontWeight.bold, fontSize: 20)),
            const SizedBox(height: 20),
            SizedBox(
              height: 320,
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
                  return _GiftTile(
                    gift: gift,
                    onBuy: () => onGiftBought(gift),
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

class _GiftTile extends StatelessWidget {
  final Gift gift;
  final VoidCallback onBuy;
  const _GiftTile({required this.gift, required this.onBuy});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onBuy,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(gift.icon, style: const TextStyle(fontSize: 32)),
              const SizedBox(height: 4),
              Text(gift.name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              if (gift.price > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('Premium', style: TextStyle(fontSize: 10, color: Colors.amber)),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('Free', style: TextStyle(fontSize: 10, color: Colors.green)),
                ),
              const SizedBox(height: 4),
              ElevatedButton(
                onPressed: onBuy,
                style: ElevatedButton.styleFrom(
                  backgroundColor: gift.price > 0 ? Colors.amber : Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(60, 28),
                  padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(gift.price > 0 ? '${gift.price}pts' : 'Free'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 
