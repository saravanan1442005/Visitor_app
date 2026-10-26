# Gate Security Guard — Visitor Cockpit Mobile Application

A mobile application for security guards to manage visitor entries, auto-detect returning visitors, and receive real-time camera match popup notifications for frequent visitors.

Built with **Flutter** (Android, iOS, Web/PWA) and connected to **Supabase PostgreSQL** (`https://xxoslmzgvpooxwwckzia.supabase.co`).

---

## 🚀 Key Features

1. **Guard Visitor Registration & Entry**:
   - Quick entry form: Full Name, Phone Number, Vehicle License Plate, Company, Purpose, Category.
   - 1-tap fast pass generation (`VIS-XXXXX`).

2. **Smart Returning Visitor Lookup**:
   - Instant search by phone number (or last 4 digits) or vehicle plate.
   - When a returning visitor arrives, the app displays:
     - `⭐ RETURNING VISITOR FOUND (X PREVIOUS VISITS)`
     - Auto-populates all visitor details.
     - **1-Tap Check-In** button without needing to re-enter info!

3. **Real-Time Camera Match Pop-Up Notification**:
   - When the Gate CCTV / ANPR / AI Camera recognizes a visitor:
     - An attention-grabbing **Pop-up Alert Dialog** immediately appears on the guard's mobile screen.
     - Displays:
       - Visitor Name & Photo Avatar
       - Visitor Code (`VIS-10002`)
       - Vehicle Plate (`TN19BE2844`)
       - Match Confidence (e.g. `97.8% ANPR Match`)
       - Visit Count (`Frequent Visitor • 3 Visits`)
       - 1-Tap **"Confirm Entry"** button to log entry pass immediately.

4. **Active On Premises Tracker**:
   - Live view of everyone currently inside the facility.
   - One-tap check-out / exit pass logging.

5. **Frequent Visitors Directory**:
   - Catalog of frequent and VIP visitors with visit counts and history.

---

## 📁 Project Architecture

```
d:/visitor app/
├── lib/
│   ├── main.dart                        # Flutter entry point & theme
│   ├── config/
│   │   └── constants.dart               # Supabase URL, colors & endpoints
│   ├── models/
│   │   ├── visitor.dart                 # Visitor model with isFrequentVisitor
│   │   ├── visitor_entry.dart           # Check-in / check-out history
│   │   └── camera_match_event.dart      # Camera AI detection event
│   ├── services/
│   │   └── api_service.dart             # Supabase & CCTV API client with realtime stream
│   ├── screens/
│   │   ├── guard_dashboard_screen.dart  # Cockpit with live stream, stats & alerts
│   │   ├── visitor_entry_screen.dart    # Registration & 1-tap returning visitor check-in
│   │   ├── active_visitors_screen.dart  # Currently inside tracking & checkout
│   │   └── visitor_history_screen.dart  # Frequent visitors directory
│   └── widgets/
│       └── camera_match_dialog.dart     # Interactive popup alert dialog
├── android/                             # Android native build & permissions
├── web/
│   └── index.html                       # Responsive mobile PWA / Web Cockpit
└── pubspec.yaml                         # Flutter dependencies
```

---

## 📲 How to Run

### 1. Run Flutter Mobile App (Android / iOS / Chrome):
```bash
cd "d:\visitor app"
flutter pub get
flutter run
```
To run on Android emulator or connected device:
```bash
flutter run -d android
```
To build Android APK:
```bash
flutter build apk --release
```

### 2. Immediate Web / Mobile Browser Preview:
You can preview and test the mobile application directly in your browser:
```bash
# Using python:
python -m http.server 8080 --directory "d:\visitor app\web"
```
Then open `http://localhost:8080` in Chrome or on any mobile phone connected to the same Wi-Fi.
