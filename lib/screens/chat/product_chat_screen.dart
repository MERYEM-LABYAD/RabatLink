import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rabatlink/core/app_colors.dart';
import 'chat_service.dart';

class ProductChatScreen extends StatefulWidget {
  final String currentUserId;
  final String sellerId;
  final String productId;
  final String productName;
  final String productImage;
  final double productPrice;

  const ProductChatScreen({
    super.key,
    required this.currentUserId,
    required this.sellerId,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.productPrice,
  });

  @override
  State<ProductChatScreen> createState() => _ProductChatScreenState();
}

class _ProductChatScreenState extends State<ProductChatScreen> {
  final ChatService chatService = ChatService();
  final TextEditingController messageCtrl = TextEditingController();
  final ScrollController scrollController = ScrollController();
  bool hasInitialized = false;

  @override
  void dispose() {
    messageCtrl.dispose();
    scrollController.dispose();
    super.dispose();
  }

  Future<void> _initializeChat() async {
    if (hasInitialized) return;

    try {
      final chatId = chatService.getProductChatId(
        widget.currentUserId,
        widget.sellerId,
        widget.productId,
      );

      final chatDoc = await FirebaseFirestore.instance
          .collection('product_chats')
          .doc(chatId)
          .get();

      if (!chatDoc.exists) {
        // Créer le chat avec toutes les infos
        await chatService.sendProductMessage(
          senderId: widget.currentUserId,
          receiverId: widget.sellerId,
          productId: widget.productId,
          text: "Je suis intéressé par ce produit",
          imageUrl: widget.productImage.isNotEmpty ? widget.productImage : null,
          productName: widget.productName,
          productPrice: widget.productPrice,
          productImage: widget.productImage.isNotEmpty ? widget.productImage : null,
        );
      }

      setState(() => hasInitialized = true);
    } catch (e) {
      print('Erreur initialisation chat: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    _initializeChat();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.shopping_bag, color: AppColors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.productName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${widget.productPrice.toStringAsFixed(0)} DH',
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
                stream: chatService.productMessagesStream(
                  widget.currentUserId,
                  widget.sellerId,
                  widget.productId,
                ),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    );
                  }

                  final messages = snapshot.data!.docs;

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (scrollController.hasClients) {
                      scrollController.jumpTo(scrollController.position.maxScrollExtent);
                    }
                  });

                  return ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index].data();
                      final isMe = msg['senderId'] == widget.currentUserId;

                      return _buildMessageBubble(msg, isMe);
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
                            decoration: InputDecoration(
                              hintText: "Écrire un message...",
                              hintStyle: TextStyle(
                                color: AppColors.grey.withValues(alpha: 0.6),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
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
                          icon: const Icon(Icons.send_rounded, color: AppColors.white),
                          onPressed: () async {
                            final text = messageCtrl.text.trim();
                            if (text.isEmpty) return;

                            await chatService.sendProductMessage(
                              senderId: widget.currentUserId,
                              receiverId: widget.sellerId,
                              productId: widget.productId,
                              text: text,
                              productName: widget.productName,
                              productPrice: widget.productPrice,
                              productImage: widget.productImage.isNotEmpty ? widget.productImage : null,
                            );

                            messageCtrl.clear();
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

  Widget _buildMessageBubble(Map<String, dynamic> msg, bool isMe) {
    final imageUrl = msg['imageUrl'];
    final hasImage = imageUrl != null && imageUrl.toString().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.lightGreen.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, color: AppColors.secondary, size: 16),
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
                    color: AppColors.grey.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hasImage) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        imageUrl.toString(),
                        width: 150,
                        height: 150,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 150,
                            height: 150,
                            color: AppColors.grey.withValues(alpha: 0.2),
                            child: const Icon(Icons.image_not_supported, size: 40),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    msg['message']?.toString() ?? '',
                    style: TextStyle(
                      color: isMe ? AppColors.white : AppColors.primary,
                      fontSize: 15,
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
}