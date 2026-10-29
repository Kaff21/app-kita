import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/app_logger.dart';

class WatchPartySync extends ChangeNotifier {
  final FirebaseDatabase _rtdb = FirebaseDatabase.instance;

  String _videoUrl = 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4';
  bool _isPlaying = false;
  double _currentPositionSeconds = 0.0;
  double _totalDurationSeconds = 596.0;
  String _lastActionBy = AppStrings.partner1Nick;
  String _activeReaction = '';

  String get videoUrl => _videoUrl;
  bool get isPlaying => _isPlaying;
  double get currentPositionSeconds => _currentPositionSeconds;
  double get totalDurationSeconds => _totalDurationSeconds;
  String get lastActionBy => _lastActionBy;
  String get activeReaction => _activeReaction;

  void listenToSyncState() {
    try {
      final syncRef = _rtdb.ref(AppStrings.rtdbWatchParty);
      syncRef.onValue.listen((event) {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;
        if (data != null) {
          _isPlaying = data['is_playing'] ?? false;
          _currentPositionSeconds = (data['position'] as num?)?.toDouble() ?? 0.0;
          _videoUrl = data['video_url'] ?? _videoUrl;
          _lastActionBy = data['action_by'] ?? 'Pasangan';
          _activeReaction = data['reaction'] ?? '';
          notifyListeners();
        }
      });
    } catch (e) {
      AppLogger.w('WatchParty RTDB listener fallback: $e');
    }
  }

  /// Sinkronkan aksi Play/Pause (SRS FR-WTP-02)
  Future<void> setPlaying(bool play, String actorName) async {
    _isPlaying = play;
    _lastActionBy = actorName;
    notifyListeners();

    try {
      await _rtdb.ref(AppStrings.rtdbWatchParty).update({
        'is_playing': play,
        'action_by': actorName,
        'timestamp': ServerValue.timestamp,
      });
    } catch (e) {
      AppLogger.w('WatchParty play state synced locally');
    }
  }

  /// Sinkronkan aksi Seek / Lompat waktu (SRS FR-WTP-02)
  Future<void> seekTo(double seconds, String actorName) async {
    _currentPositionSeconds = seconds;
    _lastActionBy = actorName;
    notifyListeners();

    try {
      await _rtdb.ref(AppStrings.rtdbWatchParty).update({
        'position': seconds,
        'action_by': actorName,
        'timestamp': ServerValue.timestamp,
      });
    } catch (e) {
      AppLogger.w('WatchParty seek state synced locally');
    }
  }

  /// Ubah URL Video (SRS FR-WTP-01)
  Future<void> changeVideoUrl(String newUrl, String actorName) async {
    _videoUrl = newUrl;
    _currentPositionSeconds = 0;
    _isPlaying = false;
    _lastActionBy = actorName;
    notifyListeners();

    try {
      await _rtdb.ref(AppStrings.rtdbWatchParty).update({
        'video_url': newUrl,
        'position': 0,
        'is_playing': false,
        'action_by': actorName,
      });
    } catch (e) {}
  }

  /// Kirim Reaksi Mengambang (Reaction Float)
  Future<void> sendReaction(String emoji) async {
    _activeReaction = emoji;
    notifyListeners();

    try {
      await _rtdb.ref(AppStrings.rtdbWatchParty).update({
        'reaction': emoji,
      });
    } catch (_) {}

    Future.delayed(const Duration(milliseconds: 2500), () {
      if (_activeReaction == emoji) {
        _activeReaction = '';
        notifyListeners();
      }
    });
  }
}
