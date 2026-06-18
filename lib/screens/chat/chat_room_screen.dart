import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rabatlink/core/app_colors.dart';
import 'chat_service.dart';

class ChatRoomScreen extends StatefulWidget {
  final String currentUserId;
  final bool isPublic;
  final String targetId;
  final String? productId;
  final String? productName;
  final String? productImage; // Ajoute ça
  final double? productPrice;

  const ChatRoomScreen({
    super.key,
    required this.currentUserId,
    required this.isPublic,
    required this.targetId,
this.productId,
  this.productName,
this.productImage,
     this.productPrice,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final ChatService chatService = ChatService();
  final TextEditingController messageCtrl = TextEditingController();
  final ScrollController scrollController = ScrollController();

  @override
  void dispose() {
    messageCtrl.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot<Map<String, dynamic>>> stream = widget.isPublic
        ? chatService.publicMessagesStream(widget.targetId)
        : chatService.productMessagesStream(
            widget.currentUserId, widget.targetId, widget.productId!);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.isPublic ? Icons.location_city : Icons.shopping_bag,
                color: AppColors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.isPublic
                        ? widget.targetId
                        : widget.productName ?? "Chat",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    widget.isPublic ? "Chat de quartier" : "Discussion produit",
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary.withValues(alpha: 0.03),
              AppColors.white,
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: stream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primary));
                  }

                  final messages = snapshot.data!.docs;

                  if (messages.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.chat_bubble_outline,
                              size: 60,
                              color: AppColors.primary.withValues(alpha: 0.5),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Aucun message',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  WidgetsBinding.instance
                      .addPostFrameCallback((_) => _scrollToBottom());

                  return ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index].data();
                      final isMe = msg['senderId'] == widget.currentUserId;

                      return _buildMessageBubble(
                        msg['message'] ?? '',
                        isMe,
                        msg['imageUrl'],
                        msg['timestamp'] != null
                            ? (msg['timestamp'] as Timestamp).toDate()
                            : DateTime.now(),
                      );
                    },
                  );
                },
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.grey.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: TextField(
                            controller: messageCtrl,
                            decoration: const InputDecoration(
                              hintText: "Écrire un message...",
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                            ),
                            maxLines: null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withValues(alpha: 0.8),
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.send_rounded,
                              color: AppColors.white),
                          onPressed: () async {
                            final text = messageCtrl.text.trim();
                            if (text.isEmpty) return;

                            if (widget.isPublic) {
                              await chatService.sendPublicMessage(
                                senderId: widget.currentUserId,
                                quartier: widget.targetId,
                                text: text,
                              );
                            } else {
                              await chatService.sendProductMessage(
                                senderId: widget.currentUserId,
                                receiverId: widget.targetId,
                                productId: widget.productId!,
                                text: text,
                              );
                            }

                            messageCtrl.clear();
                            _scrollToBottom();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(
      String message, bool isMe, String? imageUrl, DateTime timestamp) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.lightGreen.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person,
                  color: AppColors.secondary, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: isMe
                    ? LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withValues(alpha: 0.8),
                        ],
                      )
                    : null,
                color: isMe ? null : AppColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isMe ? 20 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isMe
                        ? AppColors.primary.withValues(alpha: 0.2)
                        : AppColors.grey.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (imageUrl != null && imageUrl.isNotEmpty) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        imageUrl,
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 200,
                            height: 200,
                            color: AppColors.grey.withValues(alpha: 0.2),
                            child: const Icon(Icons.image_not_supported),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    message,
                    style: TextStyle(
                      color: isMe ? AppColors.white : AppColors.primary,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(timestamp),
                    style: TextStyle(
                      color: isMe
                          ? AppColors.white.withValues(alpha: 0.7)
                          : AppColors.grey.withValues(alpha: 0.7),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMe) const SizedBox(width: 8),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) return 'À l\'instant';
    if (difference.inHours < 1) return '${difference.inMinutes}min';
    if (difference.inDays < 1)
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    return '${time.day}/${time.month}';
  }
}