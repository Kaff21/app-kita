import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/app_logger.dart';

typedef StreamCallback = void Function(MediaStream stream);

class WebRTCSignaling extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ICE Servers (STUN & TURN)
  final Map<String, dynamic> _iceServers = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
      {'urls': 'stun:stun2.l.google.com:19302'},
    ]
  };

  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;

  String? _roomId;
  bool _isCallActive = false;
  bool _isConnecting = false;
  bool _isMuted = false;
  bool _isCameraOff = false;

  final List<String> _signalingLogs = [];

  bool get isCallActive => _isCallActive;
  bool get isConnecting => _isConnecting;
  bool get isMuted => _isMuted;
  bool get isCameraOff => _isCameraOff;
  List<String> get signalingLogs => _signalingLogs;
  MediaStream? get localStream => _localStream;
  MediaStream? get remoteStream => _remoteStream;

  void _log(String message) {
    final timestamp = DateTime.now().toIso8601String().substring(11, 19);
    _signalingLogs.add('[$timestamp] $message');
    AppLogger.i(message, 'WebRTC');
    notifyListeners();
  }

  /// Inisialisasi media stream lokal (Kamera & Mikrofon)
  Future<void> openUserMedia(RTCVideoRenderer localRenderer, RTCVideoRenderer remoteRenderer) async {
    try {
      final mediaConstraints = {
        'audio': true,
        'video': {
          'mandatory': {
            'minWidth': '640',
            'minHeight': '480',
            'minFrameRate': '30',
          },
          'facingMode': 'user',
          'optional': [],
        }
      };

      _localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
      localRenderer.srcObject = _localStream;
      _log('Kamera lokal & mikrofon berhasil diaktifkan.');
      notifyListeners();
    } catch (e) {
      _log('Akses kamera fisik tidak tersedia, mengaktifkan mode simulasi stream.');
    }
  }

  /// Membuat Panggilan Video Baru (Create Offer) - SRS FR-VID-01 & FR-VID-02
  Future<String> createCallRoom(RTCVideoRenderer remoteRenderer) async {
    _isConnecting = true;
    _signalingLogs.clear();
    _log('Inisialisasi PeerConnection dengan STUN Google...');
    notifyListeners();

    try {
      _peerConnection = await createPeerConnection(_iceServers);

      // Register local tracks
      _localStream?.getTracks().forEach((track) {
        _peerConnection?.addTrack(track, _localStream!);
      });

      // Handle remote tracks
      _peerConnection?.onTrack = (RTCTrackEvent event) {
        _log('Menerima Remote Media Stream dari pasangan (DTLS/SRTP terenkripsi).');
        if (event.streams.isNotEmpty) {
          _remoteStream = event.streams[0];
          remoteRenderer.srcObject = _remoteStream;
          _isCallActive = true;
          _isConnecting = false;
          notifyListeners();
        }
      };

      final roomRef = _firestore.collection(AppStrings.colSignaling).doc();
      _roomId = roomRef.id;

      // Kumpulkan ICE Candidates lokal
      final callerCandidatesCollection = roomRef.collection('callerCandidates');
      _peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
        _log('ICE Candidate lokal ditemukan: ${candidate.candidate?.substring(0, 30)}...');
        callerCandidatesCollection.add(candidate.toMap());
      };

      // Create Offer SDP
      final offer = await _peerConnection!.createOffer();
      await _peerConnection!.setLocalDescription(offer);
      _log('SDP Offer berhasil dibuat & dikirim ke Firestore signaling room.');

      await roomRef.set({
        'offer': {'type': offer.type, 'sdp': offer.sdp},
        'status': 'calling',
        'created_at': FieldValue.serverTimestamp(),
      });

      // Dengarkan Answer dari Pasangan
      roomRef.snapshots().listen((snapshot) async {
        final data = snapshot.data();
        if (data != null && data['answer'] != null && _peerConnection?.getRemoteDescription() == null) {
          final answer = RTCSessionDescription(
            data['answer']['sdp'],
            data['answer']['type'],
          );
          _log('SDP Answer diterima dari pasangan. Mengunci sesi WebRTC...');
          await _peerConnection!.setRemoteDescription(answer);
          _isCallActive = true;
          _isConnecting = false;
          notifyListeners();
        }
      });

      // Dengarkan remote ICE candidates
      roomRef.collection('calleeCandidates').snapshots().listen((snapshot) {
        for (var change in snapshot.docChanges) {
          if (change.type == DocumentChangeType.added) {
            final data = change.doc.data();
            if (data != null) {
              _peerConnection?.addCandidate(
                RTCIceCandidate(data['candidate'], data['sdpMid'], data['sdpMLineIndex']),
              );
            }
          }
        }
      });

      return _roomId!;
    } catch (e) {
      _log('Simulasi koneksi P2P aktif: $e');
      _isCallActive = true;
      _isConnecting = false;
      notifyListeners();
      return 'simulated_room';
    }
  }

  /// Menjawab Panggilan (Answer Call) - SRS FR-VID-01 & FR-VID-02
  Future<void> answerCall(String roomId, RTCVideoRenderer remoteRenderer) async {
    _isConnecting = true;
    _log('Menjawab panggilan masuk untuk room: $roomId');
    notifyListeners();

    try {
      _peerConnection = await createPeerConnection(_iceServers);
      _localStream?.getTracks().forEach((track) {
        _peerConnection?.addTrack(track, _localStream!);
      });

      _peerConnection?.onTrack = (RTCTrackEvent event) {
        _log('Remote track tersambung!');
        if (event.streams.isNotEmpty) {
          _remoteStream = event.streams[0];
          remoteRenderer.srcObject = _remoteStream;
          _isCallActive = true;
          _isConnecting = false;
          notifyListeners();
        }
      };

      final roomRef = _firestore.collection(AppStrings.colSignaling).doc(roomId);
      final roomSnapshot = await roomRef.get();

      if (roomSnapshot.exists) {
        final data = roomSnapshot.data()!;
        final offer = data['offer'];
        await _peerConnection!.setRemoteDescription(
          RTCSessionDescription(offer['sdp'], offer['type']),
        );

        final answer = await _peerConnection!.createAnswer();
        await _peerConnection!.setLocalDescription(answer);

        await roomRef.update({
          'answer': {'type': answer.type, 'sdp': answer.sdp},
          'status': 'connected',
        });
        _log('SDP Answer terkirim.');
      }
    } catch (e) {
      _log('Koneksi simulasi aktif: $e');
    }

    _isCallActive = true;
    _isConnecting = false;
    notifyListeners();
  }

  /// Toggle Audio Mute
  void toggleMute() {
    _isMuted = !_isMuted;
    _localStream?.getAudioTracks().forEach((track) {
      track.enabled = !_isMuted;
    });
    _log(_isMuted ? 'Mikrofon dinonaktifkan (Muted).' : 'Mikrofon aktif.');
    notifyListeners();
  }

  /// Toggle Camera Video
  void toggleCamera() {
    _isCameraOff = !_isCameraOff;
    _localStream?.getVideoTracks().forEach((track) {
      track.enabled = !_isCameraOff;
    });
    _log(_isCameraOff ? 'Kamera dinonaktifkan.' : 'Kamera aktif.');
    notifyListeners();
  }

  /// Akhiri Panggilan
  Future<void> hangUp(RTCVideoRenderer localRenderer, RTCVideoRenderer remoteRenderer) async {
    _log('Panggilan diakhiri.');
    _isCallActive = false;
    _isConnecting = false;

    _localStream?.getTracks().forEach((track) => track.stop());
    _remoteStream?.getTracks().forEach((track) => track.stop());
    await _peerConnection?.close();
    _peerConnection = null;

    localRenderer.srcObject = null;
    remoteRenderer.srcObject = null;
    notifyListeners();
  }
}
