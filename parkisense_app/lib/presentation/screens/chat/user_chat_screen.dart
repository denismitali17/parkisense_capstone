import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/firestore_service.dart';
import '../../../data/models/chat_message_model.dart';
import '../../../data/models/chat_conversation_model.dart';

class UserChatScreen extends StatefulWidget {
  const UserChatScreen({super.key});

  @override
  State<UserChatScreen> createState() => _UserChatScreenState();
}

class _UserChatScreenState extends State<UserChatScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  String? _conversationId;
  String? _doctorId;
  String? _doctorName;
  ChatConversationModel? _conversation;
  List<ChatMessageModel> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Set default doctor info immediately to show UI right away
    _doctorName = 'Loading...';
    setState(() {
      _isLoading = false;
    });

    // Get user info
    final userInfo = await _firestoreService.getUserInfo(user.uid);
    final userName = userInfo?['name'] ?? userInfo?['displayName'] ?? user.email ?? 'Patient';

    // Get the first available doctor from the doctors collection
    try {
      final doctorsSnapshot = await FirebaseFirestore.instance
          .collection('doctors')
          .limit(1)
          .get();
      
      if (doctorsSnapshot.docs.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No doctors available. Please contact support.')),
          );
        }
        return;
      }
      
      final doctorDoc = doctorsSnapshot.docs.first;
      _doctorId = doctorDoc.id;
      _doctorName = doctorDoc.data()['name'] ?? 'Doctor';
      
      // Update UI with actual doctor name
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error fetching doctor: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error loading doctor information')),
        );
      }
      return;
    }

    try {
      // Get or create conversation
      _conversationId = await _firestoreService.getOrCreateConversation(
        user.uid,
        userName,
        _doctorId!,
        _doctorName!,
      );

      // Listen to conversation updates
      _firestoreService.streamUserConversation(user.uid, _doctorId!).listen((conversation) {
        if (mounted) {
          setState(() {
            _conversation = conversation;
          });
        }
      });

      // Listen to messages
      _firestoreService.streamMessages(_conversationId!).listen((messages) {
        if (mounted) {
          setState(() {
            _messages = messages;
          });
          // Mark messages as read when user opens chat
          _firestoreService.markMessagesAsRead(_conversationId!, 'user');
          // Scroll to bottom
          _scrollToBottom();
        }
      });
    } catch (e) {
      print('Error initializing chat: $e');
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _conversationId == null) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      _isSending = true;
    });

    try {
      final userInfo = await _firestoreService.getUserInfo(user.uid);
      final senderName = userInfo?['name'] ?? userInfo?['displayName'] ?? user.email ?? 'Patient';

      final message = ChatMessageModel(
        id: '',
        senderId: user.uid,
        senderName: senderName,
        text: text,
        timestamp: DateTime.now(),
        senderType: 'user',
      );

      await _firestoreService.sendMessage(_conversationId!, message);
      _messageController.clear();
      _scrollToBottom();
    } catch (e) {
      print('Error sending message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send message')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
              child: Icon(
                Icons.medical_services_rounded,
                color: AppColors.primaryBlue,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _doctorName ?? 'Doctor',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Theme.of(context).appBarTheme.foregroundColor,
                  ),
                ),
                if (_conversation != null && _conversation!.unreadUserCount > 0)
                  Text(
                    '${_conversation!.unreadUserCount} unread messages',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.primaryBlue,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: _messages.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline_rounded,
                                size: 64,
                                color: AppColors.borderGrey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No messages yet',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  color: Theme.of(context).textTheme.bodyMedium?.color,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Start a conversation with your doctor',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: AppColors.textLight,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final message = _messages[index];
                            final isMe = message.senderType == 'user';
                            return _buildMessageBubble(message, isMe);
                          },
                        ),
                ),
                _buildMessageInput(),
              ],
            ),
    );
  }

  Widget _buildMessageBubble(ChatMessageModel message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primaryBlue : Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Text(
                message.senderName,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryBlue,
                ),
              ),
            Text(
              message.text,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: isMe ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(message.timestamp),
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: isMe ? Colors.white70 : AppColors.textLight,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.isRead ? Icons.done_all : Icons.done,
                    size: 14,
                    color: message.isRead ? Colors.white70 : Colors.white54,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                hintStyle: GoogleFonts.poppins(
                  color: AppColors.textLight,
                ),
                filled: true,
                fillColor: Theme.of(context).scaffoldBackgroundColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: _isSending ? null : _sendMessage,
              icon: _isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
