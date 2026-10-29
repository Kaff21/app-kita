import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/app_logger.dart';
import '../models/memory_item_model.dart';

class GalleryRepository extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  List<MemoryItemModel> _memories = [];
  bool _isLoading = false;

  List<MemoryItemModel> get memories => _memories;
  bool get isLoading => _isLoading;

  GalleryRepository() {
    _initDefaultMemories();
  }

  void _initDefaultMemories() {
    _memories = [
      MemoryItemModel(
        id: 'mem_1',
        title: 'Sunset Pantai Kuta',
        imageUrl: 'https://images.unsplash.com/photo-1518495973542-4542c06a5843?w=800&auto=format&fit=crop&q=80',
        category: 'Liburan',
        uploadedBy: 'Liam',
        date: DateTime(2025, 9, 14),
        likes: 12,
        caption: 'Momen magis saat matahari tenggelam dan kita berjanji untuk saling menjaga selamanya.',
      ),
      MemoryItemModel(
        id: 'mem_2',
        title: 'Dinner Candlelight 1st Anniversary',
        imageUrl: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800&auto=format&fit=crop&q=80',
        category: 'Anniversary',
        uploadedBy: AppStrings.partner2Nick,
        date: DateTime(2025, 6, 17),
        likes: 19,
        caption: 'Makan malam romantis di rooftop. Bunga mawarnya masih kusimpan rapi di buku harian.',
      ),
      MemoryItemModel(
        id: 'mem_3',
        title: 'Kopi Pertama di Sudut Kota',
        imageUrl: 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=800&auto=format&fit=crop&q=80',
        category: 'Kencan',
        uploadedBy: AppStrings.partner1Nick,
        date: DateTime(2025, 3, 20),
        likes: 8,
        caption: 'Pertama kali kita ngobrol berjam-jam sampai kafe mau tutup tanpa rasa bosan.',
      ),
      MemoryItemModel(
        id: 'mem_4',
        title: 'Piknik Sore di Kebun Raya',
        imageUrl: 'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?w=800&auto=format&fit=crop&q=80',
        category: 'Kencan',
        uploadedBy: AppStrings.partner2Nick,
        date: DateTime(2025, 5, 2),
        likes: 15,
        caption: 'Bawa bekal sandwich buatan sendiri sambil nikmati semilir angin sejuk.',
      ),
    ];
  }

  /// Sinkronkan memori foto dari Firestore (SRS FR-GAL-02)
  void listenToGallery() {
    _isLoading = true;
    notifyListeners();

    try {
      _firestore
          .collection(AppStrings.colGallery)
          .orderBy('date', descending: true)
          .snapshots()
          .listen(
        (snapshot) {
          if (snapshot.docs.isNotEmpty) {
            _memories = snapshot.docs
                .map((doc) => MemoryItemModel.fromMap(doc.data(), doc.id))
                .toList();
          }
          _isLoading = false;
          notifyListeners();
        },
        onError: (e) {
          AppLogger.w('Firestore gallery listener fallback: $e');
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Tambah foto kenangan baru ke galeri (SRS FR-GAL-01)
  Future<void> addMemory({
    required String title,
    required String imageUrl,
    required String category,
    required String uploadedBy,
    String? caption,
  }) async {
    final newId = _uuid.v4();
    final item = MemoryItemModel(
      id: newId,
      title: title,
      imageUrl: imageUrl,
      category: category,
      uploadedBy: uploadedBy,
      date: DateTime.now(),
      likes: 1,
      caption: caption,
    );

    _memories.insert(0, item);
    notifyListeners();

    try {
      await _firestore.collection(AppStrings.colGallery).doc(newId).set(item.toMap());
    } catch (e) {
      AppLogger.w('Memory saved in local session: $e');
    }
  }

  /// Like foto kenangan
  void likeMemory(String id) {
    final index = _memories.indexWhere((m) => m.id == id);
    if (index != -1) {
      final updated = _memories[index].copyWith(likes: _memories[index].likes + 1);
      _memories[index] = updated;
      notifyListeners();

      try {
        _firestore.collection(AppStrings.colGallery).doc(id).update({
          'likes': FieldValue.increment(1),
        });
      } catch (_) {}
    }
  }
}
