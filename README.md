# SoulSync (AmourPrivé) — Aplikasi Couple Privat (Web & Mobile)

Implementasi lengkap aplikasi interaksi privat eksklusif untuk 2 pengguna (**Liam** & **Emma**) berdasarkan dokumen **Software Requirements Specification (SRS)** dengan pendekatan **Anti-Gravity** *(Frictionless, Agile, Minimum Overhead)*.

---

## 🏛️ Arsitektur Proyek (SRS Bab 6 — Feature-First Architecture)

Sistem dibangun menggunakan kerangka kerja **Flutter (Dart)** dengan pendekatan **Feature-First Architecture** dan layanan **Serverless Firebase + WebRTC P2P**.

```
couple-privat-app/
├── pubspec.yaml                 # Spesifikasi dependency Flutter & Firebase
├── firestore.rules              # Aturan keamanan database Cloud Firestore (Closed-Loop 2 UID)
├── database.rules.json          # Aturan sinkronisasi cepat Firebase RTDB (<200ms)
├── storage.rules                # Aturan brankas foto Firebase Cloud Storage
│
├── lib/
│   ├── main.dart                # Entry point aplikasi (runApp, Theme, MultiProvider)
│   ├── core/                    # Inti aplikasi, tema, dan utilitas global
│   │   ├── constants/
│   │   │   ├── app_colors.dart      # Palet warna Dark Romantic Luxury
│   │   │   ├── app_dimensions.dart  # Radius, padding, & icon token
│   │   │   └── app_strings.dart     # Definisi entitas Liam & Emma, nama koleksi
│   │   ├── theme/
│   │   │   └── app_theme.dart       # Konfigurasi ThemeData & Google Fonts
│   │   ├── utils/
│   │   │   ├── app_logger.dart      # Logger diagnostik
│   │   │   └── date_formatter.dart  # Format waktu, durasi, & hitungan hari bersama
│   │   └── routes/
│   │       └── app_router.dart      # Konfigurasi navigasi GoRouter (Splash, Login, Home)
│   │
│   ├── services/                # Layanan BaaS & penyimpanan lokal
│   │   ├── firebase_setup.dart  # Inisialisasi Firebase Core, Firestore, & RTDB
│   │   └── local_storage.dart   # SharedPreferences untuk cache sesi
│   │
│   └── features/                # Modul fitur utama (Jantung aplikasi)
│       ├── auth/                # FR-AUTH-01 & FR-AUTH-02 (Autentikasi & Presence)
│       │   ├── models/user_model.dart
│       │   ├── repositories/auth_repository.dart
│       │   └── views/
│       │       ├── splash_view.dart
│       │       └── login_view.dart
│       ├── chat/                # FR-MSG-01 & FR-MSG-02 (Chatting & Indikator Status)
│       │   ├── models/message_model.dart
│       │   ├── repositories/chat_repository.dart
│       │   └── views/
│       │       ├── chat_view.dart
│       │       └── chat_bubble.dart
│       ├── video_call/          # FR-VID-01 & FR-VID-02 (WebRTC Video Call & Signaling)
│       │   ├── logic/webrtc_signaling.dart
│       │   └── views/video_call_view.dart
│       ├── watch_party/         # FR-WTP-01 & FR-WTP-02 (Nonton Bareng & Sync Engine)
│       │   ├── logic/watch_party_sync.dart
│       │   └── views/watch_party_view.dart
│       ├── gallery/             # FR-GAL-01 & FR-GAL-02 (Galeri Kenangan & Lightbox)
│       │   ├── models/memory_item_model.dart
│       │   ├── repositories/gallery_repository.dart
│       │   └── views/gallery_view.dart
│       ├── games/               # FR-GAM-01 (Tic-Tac-Toe Sync RTDB)
│       │   ├── tictactoe/tictactoe_logic.dart
│       │   ├── repositories/games_repository.dart
│       │   └── views/tictactoe_view.dart
│       └── home/
│           └── views/home_nav_view.dart  # Tab navigasi utama 5 modul
```

---

## 📑 Matriks Pemenuhan Kebutuhan SRS (SRS Compliance Matrix)

| Kode FR / NFR | Modul | Realisasi Teknis pada Proyek | Status |
| :--- | :--- | :--- | :---: |
| **FR-AUTH-01** | Autentikasi | `auth_repository.dart` & `login_view.dart`. Validasi kredensial closed-loop (`uid_liam_772` & `uid_emma_883`). Akses registrasi publik ditutup total. | ✅ Terpenuhi |
| **FR-AUTH-02** | Presence | `auth_repository.dart` sinkronisasi status `is_online`, `last_seen`, dan `is_typing` secara instan ke RTDB node `presence/`. | ✅ Terpenuhi |
| **FR-MSG-01** | Chatting | `chat_repository.dart` & `chat_view.dart`. Pengiriman pesan teks Firestore dengan timestamp millisecond & auto-scroll. | ✅ Terpenuhi |
| **FR-MSG-02** | Indikator Pesan | `chat_bubble.dart` menampilkan 3 status: Terkirim (`✓`), Diterima (`✓✓`), dan Dibaca (`✓✓` cyan). | ✅ Terpenuhi |
| **FR-VID-01** | Video Call | `video_call_view.dart` antarmuka panggilan P2P: PiP kamera lokal, remote video stage, mute mic, toggle cam, & timer durasi. | ✅ Terpenuhi |
| **FR-VID-02** | Signaling | `webrtc_signaling.dart` pertukaran SDP Offer/Answer dan ICE Candidates via Firestore `signaling_rooms` tanpa server Socket.io terpisah. | ✅ Terpenuhi |
| **FR-WTP-01** | Watch Party | `watch_party_view.dart` pemutar video bersama dengan input custom URL (MP4/WebM/YouTube). | ✅ Terpenuhi |
| **FR-WTP-02** | Sync Engine | `watch_party_sync.dart` sinkronisasi status Play, Pause, dan Seek ke Firebase RTDB dengan latensi <200ms. | ✅ Terpenuhi |
| **FR-GAL-01** | Galeri Media | `gallery_repository.dart` pengunggahan foto dari perangkat lokal ke Firebase Storage `couple_memories/`. | ✅ Terpenuhi |
| **FR-GAL-02** | Tampilan Galeri | `gallery_view.dart` perenderan grid kronologis dengan filter kategori (`#Kencan`, `#Liburan`, `#Anniversary`), hitungan suka, dan Lightbox. | ✅ Terpenuhi |
| **FR-GAM-01** | Mini Games | `tictactoe_logic.dart` & `tictactoe_view.dart` papan Tic-Tac-Toe real-time tersinkronisasi RTDB (❤️ Liam vs ⭐ Emma) dengan deteksi menang/seri. | ✅ Terpenuhi |
| **NFR-PERF-01** | Kinerja Latensi | Pembaruan chat, status video, dan langkah game tersinkronisasi cepat (<200ms) melalui Firebase RTDB & local state bus. | ✅ Terpenuhi |
| **NFR-SEC-01** | Privasi Database | Berkas `firestore.rules`, `database.rules.json`, dan `storage.rules` mengunci hak akses hanya untuk 2 UID terdaftar. | ✅ Terpenuhi |
| **NFR-SEC-02** | Enkripsi Media | Aliran video-audio WebRTC terenkripsi standar DTLS 1.2/1.3 dan SRTP (AES-128-GCM) bawaan protokol. | ✅ Terpenuhi |
| **NFR-PORT-01** | Portabilitas | Antarmuka Flutter responsif untuk target Android (APK), iOS, dan Web App. | ✅ Terpenuhi |

---

## 🚀 Cara Menjalankan

```bash
# 1. Unduh package dependensi
flutter pub get

# 2. Jalankan di browser (Chrome / Edge)
flutter run -d chrome

# 3. Atau jalankan di emulator Android / device fisik
flutter run
```
