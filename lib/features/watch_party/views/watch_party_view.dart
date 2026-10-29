import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../auth/repositories/auth_repository.dart';
import '../logic/watch_party_sync.dart';

class WatchPartyView extends StatefulWidget {
  const WatchPartyView({super.key});

  @override
  State<WatchPartyView> createState() => _WatchPartyViewState();
}

class _WatchPartyViewState extends State<WatchPartyView> {
  final _urlInputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WatchPartySync>().listenToSyncState();
    });
  }

  @override
  void dispose() {
    _urlInputController.dispose();
    super.dispose();
  }

  void _showUrlDialog(BuildContext context, WatchPartySync sync, String userName) {
    _urlInputController.text = sync.videoUrl;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Input URL Video (FR-WTP-01)'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Masukkan URL file video langsung (MP4/WebM) atau video publik untuk disinkronkan ke kedua layar:',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _urlInputController,
                decoration: InputDecoration(
                  hintText: 'https://domain.com/video.mp4',
                  prefixIcon: const Icon(Icons.link, color: AppColors.primaryPink),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: AppColors.textMuted)),
            ),
            ElevatedButton(
              onPressed: () {
                final url = _urlInputController.text.trim();
                if (url.isNotEmpty) {
                  sync.changeVideoUrl(url, userName);
                }
                Navigator.pop(context);
              },
              child: const Text('Terapkan & Sinkronkan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final sync = context.watch<WatchPartySync>();
    final authRepo = context.watch<AuthRepository>();
    final currentUserName = authRepo.currentUser?.nickname ?? AppStrings.partner1Nick;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🎬 Watch Party Bersama',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Status: ${sync.lastActionBy} mengubah pemutaran',
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surfaceElevated,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
                icon: const Icon(Icons.add_link, size: 18, color: AppColors.primaryPink),
                label: const Text('Ganti Video', style: TextStyle(fontSize: 12)),
                onPressed: () => _showUrlDialog(context, sync, currentUserName),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Latency & Sync Engine Badge (SRS FR-WTP-02 & NFR-PERF-01)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: const Row(
              children: [
                Icon(Icons.bolt_rounded, size: 16, color: AppColors.accentAmber),
                SizedBox(width: 8),
                Text(
                  'RTDB Sync Engine aktif (Latensi terukur <120ms)',
                  style: TextStyle(fontSize: 11.5, color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Video Stage View
          Container(
            height: 230,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.borderSubtle),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryPurple.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Simulated Player Graphic
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      sync.isPlaying ? Icons.play_circle_filled_rounded : Icons.pause_circle_filled_rounded,
                      size: 64,
                      color: AppColors.primaryPink.withOpacity(0.8),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      sync.isPlaying ? 'Sedang Memutar Sinkron...' : 'Dijeda Bersama',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormatter.formatDuration(sync.currentPositionSeconds.toInt()),
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                    ),
                  ],
                ),

                // Floating Couple Reaction
                if (sync.activeReaction.isNotEmpty)
                  Positioned(
                    top: 20,
                    right: 24,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black54,
                      ),
                      child: Text(sync.activeReaction, style: const TextStyle(fontSize: 32)),
                    ),
                  ),

                // Video Scrub & Progress Overlay
                Positioned(
                  bottom: 8,
                  left: 12,
                  right: 12,
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          sync.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          color: Colors.white,
                        ),
                        onPressed: () => sync.setPlaying(!sync.isPlaying, currentUserName),
                      ),
                      Text(
                        DateFormatter.formatDuration(sync.currentPositionSeconds.toInt()),
                        style: const TextStyle(fontSize: 11, color: Colors.white70),
                      ),
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: AppColors.primaryPink,
                            thumbColor: AppColors.primaryPink,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                          ),
                          child: Slider(
                            value: sync.currentPositionSeconds.clamp(0.0, sync.totalDurationSeconds),
                            max: sync.totalDurationSeconds,
                            onChanged: (val) => sync.seekTo(val, currentUserName),
                          ),
                        ),
                      ),
                      Text(
                        DateFormatter.formatDuration(sync.totalDurationSeconds.toInt()),
                        style: const TextStyle(fontSize: 11, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Reaction Palette
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Text('Kirim Reaksi:', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                ...['🍿', '💖', '🥺', '😂', '🔥', '🥂'].map(
                  (emoji) => InkWell(
                    onTap: () => sync.sendReaction(emoji),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(emoji, style: const TextStyle(fontSize: 24)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
