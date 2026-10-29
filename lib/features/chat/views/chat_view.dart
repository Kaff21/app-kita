import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../auth/repositories/auth_repository.dart';
import '../repositories/chat_repository.dart';
import 'chat_bubble.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatRepository>().listenToMessages();
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage([String? customText]) {
    final text = customText ?? _messageController.text.trim();
    if (text.isEmpty) return;

    final authRepo = context.read<AuthRepository>();
    final currentUid = authRepo.currentUser?.uid ?? AppStrings.partner1Id;

    context.read<ChatRepository>().sendMessage(
          senderId: currentUid,
          text: text,
        );

    _messageController.clear();
    authRepo.setTypingStatus(false);
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  @override
  Widget build(BuildContext context) {
    final authRepo = context.watch<AuthRepository>();
    final chatRepo = context.watch<ChatRepository>();
    final currentUid = authRepo.currentUser?.uid ?? AppStrings.partner1Id;
    final partner = authRepo.partnerUser;

    return Column(
      children: [
        // Top Presence Bar in Chat
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: const BoxDecoration(
            color: AppColors.surfaceElevated,
            border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
          ),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundImage: NetworkImage(
                      partner?.avatarUrl ?? 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200',
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: (partner?.isOnline ?? true) ? AppColors.onlineGreen : AppColors.offlineGrey,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.surfaceElevated, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${partner?.name ?? AppStrings.partner2Name} 💖',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      partner?.isTyping == true
                          ? 'Sedang mengetik...'
                          : ((partner?.isOnline ?? true) ? 'Online saat ini' : 'Terakhir dilihat beberapa saat lalu'),
                      style: TextStyle(
                        fontSize: 11,
                        color: partner?.isTyping == true ? AppColors.primaryPink : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.videocam_rounded, color: AppColors.primaryPink),
                onPressed: () {
                  // Switch to video call tab
                  DefaultTabController.of(context).animateTo(1);
                },
                tooltip: 'Panggilan Video',
              ),
            ],
          ),
        ),


        // Chat Messages List
        Expanded(
          child: chatRepo.isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primaryPink))
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: chatRepo.messages.length,
                  itemBuilder: (context, index) {
                    final msg = chatRepo.messages[index];
                    return ChatBubble(
                      message: msg,
                      isMe: msg.senderId == currentUid,
                    );
                  },
                ),
        ),

        // Typing indicator balloon
        if (partner?.isTyping == true)
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
            child: Row(
              children: [
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryPink),
                ),
                const SizedBox(width: 8),
                Text(
                  '${partner?.nickname ?? "Pasangan"} sedang mengetik...',
                  style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.textMuted),
                ),
              ],
            ),
          ),

        // Input Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: const BoxDecoration(
            color: AppColors.surfaceCard,
            border: Border(top: BorderSide(color: AppColors.borderSubtle)),
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    onChanged: (val) {
                      authRepo.setTypingStatus(val.trim().isNotEmpty);
                    },
                    onSubmitted: (_) => _sendMessage(),
                    decoration: InputDecoration(
                      hintText: 'Tulis pesan cinta...',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      fillColor: AppColors.surfaceElevated,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.romanticGradient,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    onPressed: () => _sendMessage(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
