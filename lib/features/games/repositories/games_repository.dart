import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/app_logger.dart';
import '../tictactoe/tictactoe_logic.dart';

class GamesRepository extends ChangeNotifier {
  final FirebaseDatabase _rtdb = FirebaseDatabase.instance;

  List<String?> _board = List.filled(9, null);
  String _currentTurn = 'user1'; // 'user1' (❤️) or 'user2' (⭐)
  String? _winner;
  int _user1Score = 0;
  int _user2Score = 0;
  int _tiesCount = 0;

  List<String?> get board => _board;
  String get currentTurn => _currentTurn;
  String? get winner => _winner;
  int get user1Score => _user1Score;
  int get user2Score => _user2Score;
  int get liamScore => _user1Score;
  int get emmaScore => _user2Score;
  int get tiesCount => _tiesCount;

  void listenToGameState() {
    try {
      final gameRef = _rtdb.ref(AppStrings.rtdbGames);
      gameRef.onValue.listen((event) {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;
        if (data != null) {
          final rawBoard = data['board'] as List<dynamic>?;
          if (rawBoard != null) {
            _board = rawBoard.map((e) => e as String?).toList();
          }
          _currentTurn = data['current_turn'] ?? 'user1';
          _winner = data['winner'];
          _user1Score = data['user1_score'] ?? data['liam_score'] ?? _user1Score;
          _user2Score = data['user2_score'] ?? data['emma_score'] ?? _user2Score;
          _tiesCount = data['ties_count'] ?? _tiesCount;
          notifyListeners();
        }
      });
    } catch (e) {
      AppLogger.w('Games RTDB listener fallback: $e');
    }
  }

  /// Buat langkah bidak Tic-Tac-Toe (SRS FR-GAM-01)
  Future<void> makeMove(int index, String playerKey) async {
    if (_board[index] != null || _winner != null || _currentTurn != playerKey) {
      return;
    }

    final symbol = (playerKey == 'user1' || playerKey == 'liam') ? '❤️' : '⭐';
    _board[index] = symbol;

    final winResult = TicTacToeLogic.checkWinner(_board);
    if (winResult != null) {
      if (winResult == '❤️') {
        _winner = 'user1';
        _user1Score++;
      } else if (winResult == '⭐') {
        _winner = 'user2';
        _user2Score++;
      } else {
        _winner = 'tie';
        _tiesCount++;
      }
    } else {
      _currentTurn = (playerKey == 'user1' || playerKey == 'liam') ? 'user2' : 'user1';
    }

    notifyListeners();

    try {
      await _rtdb.ref(AppStrings.rtdbGames).update({
        'board': _board,
        'current_turn': _currentTurn,
        'winner': _winner,
        'user1_score': _user1Score,
        'user2_score': _user2Score,
        'ties_count': _tiesCount,
        'updated_at': ServerValue.timestamp,
      });
    } catch (_) {}
  }

  /// Reset papan permainan
  Future<void> resetGame() async {
    _board = List.filled(9, null);
    _winner = null;
    _currentTurn = 'user1';
    notifyListeners();

    try {
      await _rtdb.ref(AppStrings.rtdbGames).update({
        'board': _board,
        'current_turn': 'user1',
        'winner': null,
      });
    } catch (_) {}
  }
}
