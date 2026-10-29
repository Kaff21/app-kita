class TicTacToeLogic {
  static const List<List<int>> winPatterns = [
    [0, 1, 2], [3, 4, 5], [6, 7, 8], // Baris
    [0, 3, 6], [1, 4, 7], [2, 5, 8], // Kolom
    [0, 4, 8], [2, 4, 6]             // Diagonal
  ];

  /// Cek pemenang: return 'X', 'O', 'tie', atau null jika game belum selesai
  static String? checkWinner(List<String?> board) {
    for (final pattern in winPatterns) {
      final a = board[pattern[0]];
      final b = board[pattern[1]];
      final c = board[pattern[2]];

      if (a != null && a == b && a == c) {
        return a;
      }
    }

    if (!board.contains(null)) {
      return 'tie';
    }

    return null;
  }

  static List<int>? getWinningPattern(List<String?> board) {
    for (final pattern in winPatterns) {
      final a = board[pattern[0]];
      final b = board[pattern[1]];
      final c = board[pattern[2]];

      if (a != null && a == b && a == c) {
        return pattern;
      }
    }
    return null;
  }
}
