import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import '../core/utils/app_logger.dart';
import '../firebase_options.dart';

class FirebaseSetup {
  static Future<void> initialize() async {
    try {
      // Inisialisasi Firebase Core dengan platform options (SRS Bab 6.2)
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Konfigurasi Firestore Offline Persistence (SRS Data Tier)
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );

      // Konfigurasi RTDB Offline Sync (SRS Bab 6.3)
      FirebaseDatabase.instance.setPersistenceEnabled(true);

      AppLogger.i('Firebase BaaS & RTDB initialized successfully', 'FirebaseSetup');
    } catch (e, stack) {
      AppLogger.e('Failed to initialize Firebase', e, stack);
    }
  }
}
