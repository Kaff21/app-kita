import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/app_logger.dart';
import '../models/message_model.dart';

class ChatRepository extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  List<MessageModel> _messages = [];
  bool _isLoading = false;

  List<MessageModel> get messages => _messages;
  bool get isLoading => _isLoading;

  ChatRepository() {
    _initDefaultMessages();
  }

  void _initDefaultMessages() {
    final now = DateTime.now();
    _messages = [
      MessageModel(
        id: 'msg_1',
        senderId: AppStrings.partner2Id,
        text: 'Sayang, nanti malam kita jadi nonton film bareng di Watch Party kan? 🍿✨',
        timestamp: now.subtract(const Duration(minutes: 45)),
        status: MessageStatus.read,
      ),
      MessageModel(
        id: 'msg_2',
        senderId: AppStrings.partner1Id,
        text: 'Pasti jadi dong! Aku udah siapin playlist video romantis favorit kita. ❤️',
        timestamp: now.subtract(const Duration(minutes: 40)),
        status: MessageStatus.read,
      ),
      MessageModel(
        id: 'msg_3',
        senderId: AppStrings.partner2Id,
        text: 'Yay! Jangan lupa foto liburan kita kemarin diupload ke galeri yaa 📸',
        timestamp: now.subtract(const Duration(minutes: 15)),
        status: MessageStatus.read,
      ),
      MessageModel(
        id: 'msg_4',
        senderId: AppStrings.partner1Id,
        text: 'Siap komandan! Barusan udah aku upload 3 foto pantai terindah kita. Cek yaa 🥰',
        timestamp: now.subtract(const Duration(minutes: 5)),
        status: MessageStatus.delivered,
      ),
    ];
  }

  /// Mulai mendengarkan pesan real-time dari Firestore (SRS FR-MSG-01)
  void listenToMessages() {
    _isLoading = true;
    notifyListeners();

    try {
      _firestore
          .collection(AppStrings.colMessages)
          .orderBy('timestamp', descending: false)
          .snapshots()
          .listen(
        (snapshot) {
          if (snapshot.docs.isNotEmpty) {
            _messages = snapshot.docs
                .map((doc) => MessageModel.fromMap(doc.data(), doc.id))
                .toList();
          }
          _isLoading = false;
          notifyListeners();
        },
        onError: (e) {
          AppLogger.w('Firestore listener fallback to memory messages: $e');
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      AppLogger.w('Firestore offline mode enabled for chat: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Kirim pesan teks baru (SRS FR-MSG-01 & FR-MSG-02)
  Future<void> sendMessage({
    required String senderId,
    required String text,
    String? type,
  }) async {
    final messageId = _uuid.v4();
    final newMessage = MessageModel(
      id: messageId,
      senderId: senderId,
      text: text,
      timestamp: DateTime.now(),
      status: MessageStatus.sent,
      type: type ?? 'text',
    );

    // Update lokal instan (latensi <200ms NFR-PERF-01)
    _messages.add(newMessage);
    notifyListeners();

    // Simulasi delivered status dalam 400ms
    Future.delayed(const Duration(milliseconds: 400), () {
      final index = _messages.indexWhere((m) => m.id == messageId);
      if (index != -1) {
        _messages[index] = _messages[index].copyWith(status: MessageStatus.delivered);
        notifyListeners();
      }
    });

    // Coba simpan ke Firestore jika terhubung
    try {
      await _firestore
          .collection(AppStrings.colMessages)
          .doc(messageId)
          .set(newMessage.toMap());
    } catch (e) {
      AppLogger.w('Saved message in local session: $e');
    }
  }

  /// Tandai semua pesan lawan sebagai telah dibaca (Read - FR-MSG-02)
  void markMessagesAsRead(String currentUserId) {
    bool hasChanges = false;
    for (int i = 0; i < _messages.length; i++) {
      if (_messages[i].senderId != currentUserId && _messages[i].status != MessageStatus.read) {
        _messages[i] = _messages[i].copyWith(status: MessageStatus.read);
        hasChanges = true;
      }
    }
    if (hasChanges) {
      notifyListeners();
    }
  }
}
