import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'features/auth/repositories/auth_repository.dart';
import 'features/chat/repositories/chat_repository.dart';
import 'features/gallery/repositories/gallery_repository.dart';
import 'features/games/repositories/games_repository.dart';
import 'features/video_call/logic/webrtc_signaling.dart';
import 'features/watch_party/logic/watch_party_sync.dart';
import 'services/firebase_setup.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Kunci orientasi portrait jika di perangkat mobile (SRS NFR-PORT-01)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar styling
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  // Inisialisasi Firebase BaaS & RTDB (SRS Bab 6.2 & 6.3)
  await FirebaseSetup.initialize();

  runApp(const SoulSyncApp());
}

class SoulSyncApp extends StatelessWidget {
  const SoulSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthRepository()),
        ChangeNotifierProvider(create: (_) => ChatRepository()),
        ChangeNotifierProvider(create: (_) => WebRTCSignaling()),
        ChangeNotifierProvider(create: (_) => WatchPartySync()),
        ChangeNotifierProvider(create: (_) => GalleryRepository()),
        ChangeNotifierProvider(create: (_) => GamesRepository()),
      ],
      child: MaterialApp.router(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkRomanticTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
