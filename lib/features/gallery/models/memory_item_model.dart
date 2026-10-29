class MemoryItemModel {
  final String id;
  final String title;
  final String imageUrl;
  final String category;
  final String uploadedBy;
  final DateTime date;
  final int likes;
  final String? caption;

  const MemoryItemModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.category,
    required this.uploadedBy,
    required this.date,
    this.likes = 0,
    this.caption,
  });

  factory MemoryItemModel.fromMap(Map<String, dynamic> map, String id) {
    return MemoryItemModel(
      id: id,
      title: map['title'] ?? '',
      imageUrl: map['image_url'] ?? '',
      category: map['category'] ?? 'Kenangan',
      uploadedBy: map['uploaded_by'] ?? '',
      date: map['date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['date'])
          : DateTime.now(),
      likes: map['likes'] ?? 0,
      caption: map['caption'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'image_url': imageUrl,
      'category': category,
      'uploaded_by': uploadedBy,
      'date': date.millisecondsSinceEpoch,
      'likes': likes,
      'caption': caption,
    };
  }

  MemoryItemModel copyWith({
    int? likes,
  }) {
    return MemoryItemModel(
      id: id,
      title: title,
      imageUrl: imageUrl,
      category: category,
      uploadedBy: uploadedBy,
      date: date,
      likes: likes ?? this.likes,
      caption: caption,
    );
  }
}
