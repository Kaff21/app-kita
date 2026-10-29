import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../auth/repositories/auth_repository.dart';
import '../models/memory_item_model.dart';
import '../repositories/gallery_repository.dart';

class GalleryView extends StatefulWidget {
  const GalleryView({super.key});

  @override
  State<GalleryView> createState() => _GalleryViewState();
}

class _GalleryViewState extends State<GalleryView> {
  String _selectedCategory = 'Semua';
  final List<String> _categories = ['Semua', 'Kencan', 'Liburan', 'Anniversary'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GalleryRepository>().listenToGallery();
    });
  }

  void _showAddMemoryDialog(BuildContext context) {
    final titleController = TextEditingController();
    final urlController = TextEditingController(text: 'https://images.unsplash.com/photo-1529333166437-7750a6dd5a70?w=800');
    final captionController = TextEditingController();
    String category = 'Kencan';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.surfaceCard,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Tambah Foto Kenangan (FR-GAL-01)'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Judul Momen (misal: Sunset Pantai)'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: urlController,
                      decoration: const InputDecoration(labelText: 'URL Foto (atau Storage Path)'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: category,
                      dropdownColor: AppColors.surfaceElevated,
                      decoration: const InputDecoration(labelText: 'Kategori'),
                      items: ['Kencan', 'Liburan', 'Anniversary', 'Spesial'].map((cat) {
                        return DropdownMenuItem(value: cat, child: Text(cat));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => category = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: captionController,
                      maxLines: 2,
                      decoration: const InputDecoration(labelText: 'Catatan Cinta Singkat'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal', style: TextStyle(color: AppColors.textMuted)),
                ),
                ElevatedButton(
                  onPressed: () {
                    final title = titleController.text.trim();
                    final url = urlController.text.trim();
                    final caption = captionController.text.trim();
                    if (title.isNotEmpty && url.isNotEmpty) {
                      final authRepo = context.read<AuthRepository>();
                      final userName = authRepo.currentUser?.nickname ?? 'Liam';
                      context.read<GalleryRepository>().addMemory(
                            title: title,
                            imageUrl: url,
                            category: category,
                            uploadedBy: userName,
                            caption: caption.isNotEmpty ? caption : null,
                          );
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('Simpan ke Galeri'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showLightbox(BuildContext context, MemoryItemModel item) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  child: Image.network(
                    item.imageUrl,
                    fit: BoxFit.cover,
                    height: 280,
                    errorBuilder: (_, __, ___) => Container(
                      height: 200,
                      color: AppColors.surfaceElevated,
                      child: const Center(child: Text('📸 Kenangan Indah')),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryPink.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '#${item.category}',
                              style: const TextStyle(fontSize: 11, color: AppColors.primaryPink, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Diunggah oleh ${item.uploadedBy} • ${DateFormatter.formatDate(item.date)}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                      if (item.caption != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          '💬 "${item.caption}"',
                          style: const TextStyle(fontSize: 13.5, fontStyle: FontStyle.italic, color: Colors.white70),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryPink,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                            icon: const Icon(Icons.favorite, size: 18, color: Colors.white),
                            label: Text('${item.likes} Cinta'),
                            onPressed: () {
                              context.read<GalleryRepository>().likeMemory(item.id);
                              Navigator.pop(context);
                            },
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Tutup', style: TextStyle(color: AppColors.textMuted)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final galleryRepo = context.watch<GalleryRepository>();
    final filteredItems = _selectedCategory == 'Semua'
        ? galleryRepo.memories
        : galleryRepo.memories.where((m) => m.category == _selectedCategory).toList();

    return Column(
      children: [
        // Action Header: Category Filter & Upload Button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 38,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final cat = _categories[index];
                      final isSelected = cat == _selectedCategory;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(cat),
                          selected: isSelected,
                          selectedColor: AppColors.primaryPink,
                          backgroundColor: AppColors.surfaceCard,
                          side: const BorderSide(color: AppColors.borderSubtle),
                          onSelected: (val) {
                            if (val) setState(() => _selectedCategory = cat);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPink,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
                icon: const Icon(Icons.add_photo_alternate_rounded, size: 18),
                label: const Text('Unggah', style: TextStyle(fontSize: 12)),
                onPressed: () => _showAddMemoryDialog(context),
              ),
            ],
          ),
        ),

        // Chronological Photos Grid (SRS FR-GAL-02)
        Expanded(
          child: galleryRepo.isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primaryPink))
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    return InkWell(
                      onTap: () => _showLightbox(context, item),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.borderSubtle),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.network(
                                    item.imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      color: AppColors.surfaceElevated,
                                      child: const Center(child: Text('📸')),
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.favorite, size: 12, color: AppColors.primaryPink),
                                          const SizedBox(width: 4),
                                          Text('${item.likes}', style: const TextStyle(fontSize: 11, color: Colors.white)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '#${item.category} • ${DateFormatter.formatDate(item.date)}',
                                    style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
