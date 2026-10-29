import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../auth/repositories/auth_repository.dart';
import '../../chat/views/chat_view.dart';
import '../../gallery/views/gallery_view.dart';
import '../../games/views/tictactoe_view.dart';
import '../../video_call/views/video_call_view.dart';
import '../../watch_party/views/watch_party_view.dart';

class HomeNavView extends StatefulWidget {
  const HomeNavView({super.key});

  @override
  State<HomeNavView> createState() => _HomeNavViewState();
}

class _HomeNavViewState extends State<HomeNavView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authRepo = context.watch<AuthRepository>();
    final currentUser = authRepo.currentUser;
    final isUser1 = currentUser?.uid == AppStrings.partner1Id;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.romanticGradient,
              ),
              child: const Text('💑', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  AppStrings.appName,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
                Text(
                  'Ruang Cinta • 🔒 Privat Berdua',
                  style: TextStyle(fontSize: 10, color: AppColors.textHighlight.withOpacity(0.9)),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Days Together Capsule
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primaryPink.withOpacity(0.4)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('❤️', style: TextStyle(fontSize: 12)),
                SizedBox(width: 4),
                Text('Hari Bersama', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Persona Switcher for Quick Multi-Client Testing
          PopupMenuButton<String>(
            tooltip: 'Ganti Sudut Pandang Pasangan',
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Text(isUser1 ? '👤' : '💖', style: const TextStyle(fontSize: 16)),
            ),
            onSelected: (key) => authRepo.switchPersona(key),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'user1',
                child: Row(
                  children: [
                    const Text('👤'),
                    const SizedBox(width: 8),
                    Text(authRepo.currentUser?.nickname ?? AppStrings.partner1Nick),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'user2',
                child: Row(
                  children: [
                    const Text('💖'),
                    const SizedBox(width: 8),
                    Text(authRepo.partnerUser?.nickname ?? AppStrings.partner2Nick),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppColors.primaryPink,
          indicatorWeight: 3,
          labelColor: AppColors.primaryPink,
          unselectedLabelColor: AppColors.textMuted,
          tabs: const [
            Tab(icon: Icon(Icons.chat_bubble_rounded), text: 'Obrolan'),
            Tab(icon: Icon(Icons.videocam_rounded), text: 'Video Call'),
            Tab(icon: Icon(Icons.movie_filter_rounded), text: 'Watch Party'),
            Tab(icon: Icon(Icons.photo_library_rounded), text: 'Galeri'),
            Tab(icon: Icon(Icons.videogame_asset_rounded), text: 'Mini Game'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(), // Hindari swipe conflict dengan slider video/game
        children: const [
          ChatView(),
          VideoCallView(),
          WatchPartyView(),
          GalleryView(),
          TicTacToeView(),
        ],
      ),
    );
  }
}
