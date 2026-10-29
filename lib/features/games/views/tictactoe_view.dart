import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../auth/repositories/auth_repository.dart';
import '../repositories/games_repository.dart';

class TicTacToeView extends StatefulWidget {
  const TicTacToeView({super.key});

  @override
  State<TicTacToeView> createState() => _TicTacToeViewState();
}

class _TicTacToeViewState extends State<TicTacToeView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GamesRepository>().listenToGameState();
    });
  }

  @override
  Widget build(BuildContext context) {
    final gamesRepo = context.watch<GamesRepository>();
    final authRepo = context.watch<AuthRepository>();

    final isUser1 = authRepo.currentUser?.uid == AppStrings.partner1Id;
    final currentKey = isUser1 ? 'user1' : 'user2';
    final isMyTurn = gamesRepo.currentTurn == currentKey || (gamesRepo.currentTurn == 'liam' && isUser1) || (gamesRepo.currentTurn == 'emma' && !isUser1);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header Game
          const Text(
            '🎮 Tic-Tac-Toe Pasangan (FR-GAM-01)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Sinkronisasi papan real-time via Firebase RTDB',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),

          // Scoreboard Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text('👤 ${authRepo.currentUser?.nickname ?? AppStrings.partner1Nick} (❤️)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(
                      '${gamesRepo.user1Score}',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryPink),
                    ),
                  ],
                ),
                Container(width: 1, height: 36, color: AppColors.borderSubtle),
                Column(
                  children: [
                    const Text('Seri', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    const SizedBox(height: 4),
                    Text(
                      '${gamesRepo.tiesCount}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white70),
                    ),
                  ],
                ),
                Container(width: 1, height: 36, color: AppColors.borderSubtle),
                Column(
                  children: [
                    Text('💖 ${authRepo.partnerUser?.nickname ?? AppStrings.partner2Nick} (⭐)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(
                      '${gamesRepo.user2Score}',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryPurple),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Turn Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isMyTurn ? AppColors.primaryPink.withOpacity(0.2) : AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isMyTurn ? AppColors.primaryPink : AppColors.borderSubtle,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isMyTurn ? '✨ Giliran Kamu! Sentuh kotak kosong' : '⏳ Menunggu langkah pasangan...',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isMyTurn ? AppColors.primaryPink : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 3x3 Grid Board
          Container(
            constraints: const BoxConstraints(maxWidth: 320),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.borderSubtle),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryPink.withOpacity(0.15),
                  blurRadius: 24,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: AspectRatio(
              aspectRatio: 1,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: 9,
                itemBuilder: (context, index) {
                  final cell = gamesRepo.board[index];
                  return InkWell(
                    onTap: () => gamesRepo.makeMove(index, currentKey),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: Center(
                        child: Text(
                          cell ?? '',
                          style: const TextStyle(fontSize: 42),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Winner Alert & Reset Action
          if (gamesRepo.winner != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: AppColors.romanticGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                gamesRepo.winner == 'tie'
                    ? '🤝 Pertandingan Seri! Kalian sama-sama hebat!'
                    : '🎉 Pemenang: ${(gamesRepo.winner == "user1" || gamesRepo.winner == "liam") ? "${authRepo.currentUser?.nickname ?? AppStrings.partner1Nick} (❤️)" : "${authRepo.partnerUser?.nickname ?? AppStrings.partner2Nick} (⭐)"}!',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
              ),
            ),
            const SizedBox(height: 12),
          ],

          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.surfaceElevated,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primaryPink),
            label: const Text('Main Lagi / Reset Papan'),
            onPressed: gamesRepo.resetGame,
          ),
        ],
      ),
    );
  }
}
