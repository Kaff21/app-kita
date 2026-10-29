import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../auth/repositories/auth_repository.dart';
import '../logic/webrtc_signaling.dart';

class VideoCallView extends StatefulWidget {
  const VideoCallView({super.key});

  @override
  State<VideoCallView> createState() => _VideoCallViewState();
}

class _VideoCallViewState extends State<VideoCallView> {
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();

  int _callDurationSeconds = 0;
  Timer? _callDurationTimer;

  @override
  void initState() {
    super.initState();
    _initRenderers();
  }

  Future<void> _initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();

    if (mounted) {
      final signaling = context.read<WebRTCSignaling>();
      await signaling.openUserMedia(_localRenderer, _remoteRenderer);
    }
  }

  @override
  void dispose() {
    _callDurationTimer?.cancel();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  void _startTimer() {
    _callDurationSeconds = 0;
    _callDurationTimer?.cancel();
    _callDurationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _callDurationSeconds++;
        });
      }
    });
  }

  void _stopTimer() {
    _callDurationTimer?.cancel();
    setState(() {
      _callDurationSeconds = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final signaling = context.watch<WebRTCSignaling>();
    final authRepo = context.watch<AuthRepository>();
    final partner = authRepo.partnerUser;

    return Stack(
      children: [
        // Background / Remote Video Feed
        Container(
          color: Colors.black,
          child: signaling.isCallActive
              ? RTCVideoView(
                  _remoteRenderer,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                )
              : Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 54,
                        backgroundImage: NetworkImage(
                          partner?.avatarUrl ?? 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200',
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        partner?.name ?? AppStrings.partner2Name,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        signaling.isConnecting ? 'Menghubungkan sesi WebRTC...' : 'Panggilan belum dimulai',
                        style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.lock, size: 14, color: AppColors.accentEmerald),
                            SizedBox(width: 6),
                            Text('Terenkripsi End-to-End (DTLS/SRTP)', style: TextStyle(fontSize: 11, color: Colors.white70)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        ),

        // PiP Local Camera Preview
        Positioned(
          top: 16,
          right: 16,
          child: Container(
            width: 110,
            height: 160,
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primaryPink.withOpacity(0.6), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                RTCVideoView(
                  _localRenderer,
                  mirror: true,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                ),
                Positioned(
                  bottom: 6,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('Kamu', style: TextStyle(fontSize: 10, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Top Status Header (Call duration & signaling inspector trigger)
        Positioned(
          top: 16,
          left: 16,
          child: Row(
            children: [
              if (signaling.isCallActive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Row(
                    children: [
                      Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Text(
                        DateFormatter.formatDuration(_callDurationSeconds),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              const SizedBox(width: 8),
              IconButton(
                style: IconButton.styleFrom(backgroundColor: Colors.black54),
                icon: const Icon(Icons.code_rounded, color: Colors.white70, size: 20),
                tooltip: 'Log Sinyal WebRTC (SRS FR-VID-02)',
                onPressed: () => _showSignalingLogsModal(context, signaling),
              ),
            ],
          ),
        ),

        // Bottom Controls Bar
        Positioned(
          bottom: 24,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceGlass,
                borderRadius: BorderRadius.circular(36),
                border: Border.all(color: AppColors.borderSubtle),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 24),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Mute Mic Button
                  IconButton(
                    icon: Icon(signaling.isMuted ? Icons.mic_off : Icons.mic),
                    color: signaling.isMuted ? Colors.redAccent : Colors.white,
                    onPressed: signaling.toggleMute,
                  ),
                  const SizedBox(width: 12),

                  // Main Call / Hangup Action
                  if (!signaling.isCallActive)
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentEmerald,
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                      ),
                      icon: const Icon(Icons.call, color: Colors.white),
                      label: const Text('Mulai Panggilan', style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: () async {
                        _startTimer();
                        await signaling.createCallRoom(_remoteRenderer);
                      },
                    )
                  else
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryRose,
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                      ),
                      icon: const Icon(Icons.call_end, color: Colors.white),
                      label: const Text('Akhiri', style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: () async {
                        _stopTimer();
                        await signaling.hangUp(_localRenderer, _remoteRenderer);
                      },
                    ),

                  const SizedBox(width: 12),

                  // Toggle Video Cam Button
                  IconButton(
                    icon: Icon(signaling.isCameraOff ? Icons.videocam_off : Icons.videocam),
                    color: signaling.isCameraOff ? Colors.redAccent : Colors.white,
                    onPressed: signaling.toggleCamera,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showSignalingLogsModal(BuildContext context, WebRTCSignaling signaling) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '📡 WebRTC Signaling Log (FR-VID-02)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Text(
                'Pertukaran Offer/Answer & ICE Candidates di Firestore:',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: ListView.builder(
                    itemCount: signaling.signalingLogs.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          signaling.signalingLogs[index],
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            color: AppColors.accentCyan,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
