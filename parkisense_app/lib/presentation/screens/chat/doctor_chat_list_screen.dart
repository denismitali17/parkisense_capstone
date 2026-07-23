import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/firestore_service.dart';
import '../../../data/models/chat_conversation_model.dart';
import 'doctor_chat_screen.dart';

class DoctorChatListScreen extends StatefulWidget {
  const DoctorChatListScreen({super.key});

  @override
  State<DoctorChatListScreen> createState() => _DoctorChatListScreenState();
}

class _DoctorChatListScreenState extends State<DoctorChatListScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<ChatConversationModel> _conversations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  void _loadConversations() {
    final doctor = FirebaseAuth.instance.currentUser;
    if (doctor == null) return;

    _firestoreService.streamDoctorConversations(doctor.uid).listen((conversations) {
      if (mounted) {
        setState(() {
          _conversations = conversations;
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        title: Text(
          'Chats',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _conversations.isEmpty
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
                        'No conversations yet',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Patients will appear here when they send messages',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _conversations.length,
                  itemBuilder: (context, index) {
                    final conversation = _conversations[index];
                    return _buildConversationCard(conversation);
                  },
                ),
    );
  }

  Widget _buildConversationCard(ChatConversationModel conversation) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DoctorChatScreen(
                conversationId: conversation.id,
                userId: conversation.userId,
                userName: conversation.userName,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                    radius: 28,
                    child: Icon(
                      Icons.person_rounded,
                      color: AppColors.primaryBlue,
                      size: 32,
                    ),
                  ),
                  if (conversation.unreadDoctorCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.dangerRed,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        child: Text(
                          conversation.unreadDoctorCount > 9
                              ? '9+'
                              : '${conversation.unreadDoctorCount}',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          conversation.userName,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        Text(
                          _formatTime(conversation.lastMessageTime),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      conversation.lastMessage ?? 'No messages yet',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: conversation.unreadDoctorCount > 0
                            ? Theme.of(context).textTheme.bodyLarge?.color
                            : AppColors.textLight,
                        fontWeight: conversation.unreadDoctorCount > 0
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.borderGrey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }
}
