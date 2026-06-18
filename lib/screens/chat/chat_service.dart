import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Envoyer message public
  Future<void> sendPublicMessage({
    required String senderId,
    required String quartier,
    required String text,
  }) async {
    await _firestore
        .collection('public_chats')
        .doc(quartier)
        .collection('messages')
        .add({
      'senderId': senderId,
      'message': text,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Envoyer message produit (CORRIGÉ)
  Future<void> sendProductMessage({
    required String senderId,
    required String receiverId,
    required String productId,
    required String text,
    String? imageUrl,
    String? productName,
    double? productPrice,
    String? productImage,
  }) async {
    final chatId = getProductChatId(senderId, receiverId, productId);
    final timestamp = FieldValue.serverTimestamp();

    // 1. Ajouter le message dans la sous-collection
    await _firestore
        .collection('product_chats')
        .doc(chatId)
        .collection('messages')
        .add({
      'senderId': senderId,
      'receiverId': receiverId,
      'message': text,
      'imageUrl': imageUrl, // Peut être null
      'timestamp': timestamp,
    });

    // 2. Mettre à jour ou créer le document principal du chat (AVEC VALEURS PAR DÉFAUT)
    await _firestore.collection('product_chats').doc(chatId).set({
      'participants': [senderId, receiverId],
      'productId': productId,
      'productName': productName ?? 'Produit', // ✅ Jamais null
      'productPrice': productPrice ?? 0.0, // ✅ Jamais null
      'productImage': productImage ?? '', // ✅ Jamais null (string vide)
      'lastMessage': text,
      'lastMessageTime': timestamp,
    }, SetOptions(merge: true));
  }

  // Stream messages publics
  Stream<QuerySnapshot<Map<String, dynamic>>> publicMessagesStream(
      String quartier) {
    return _firestore
        .collection('public_chats')
        .doc(quartier)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // Stream messages produit
  Stream<QuerySnapshot<Map<String, dynamic>>> productMessagesStream(
    String currentUserId,
    String otherUserId,
    String productId,
  ) {
    final chatId = getProductChatId(currentUserId, otherUserId, productId);
    return _firestore
        .collection('product_chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // Stream conversations utilisateur
  Stream<QuerySnapshot<Map<String, dynamic>>> getUserProductChats(
      String userId) {
    return _firestore
        .collection('product_chats')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots();
  }

  // ID unique chat produit
  String getProductChatId(String userId1, String userId2, String productId) {
    final ids = [userId1, userId2]..sort();
    return '${ids[0]}_${ids[1]}_$productId';
  }
}