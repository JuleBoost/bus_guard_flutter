# 📱 BusGuard AI — Mobile School Bus Safety System & Realtime Flutter App

> **A cross-platform iOS and Android real-time school bus safety monitoring app powered by AI edge detection, Supabase Realtime Telemetry, and advanced Multi-Stop TSP Routing.**

---

## 🎨 Design Identity: The Memphis Design System (Flutter Edition)
The mobile user interface has been engineered around a bold, modern, and playful **Memphis design aesthetic**, bringing high contrast, exceptional visual hierarchy, and delightful tactile interactivity to mission-critical telemetry data.

### Design Properties Applied (`lib/theme/memphis_theme.dart`):
* **Bold Color Palette**: Primary Pink (`#E8879F`), Secondary Teal (`#4DB8A8`), Accent Yellow (`#F5D76E`), Warm Background (`#FAF8F5`), Crisp Surface (`#FFFEF7`), and Dark Solid Text (`#1A1A2E`).
* **Typography**: Clean, professional mobile headers and data readouts utilizing `GoogleFonts.poppins`.
* **Distinctive Borders & Shadows**: Uniform `12px` border radius, prominent `3px` solid `#1A1A2E` borders, and high-contrast `4px 4px 0px #1A1A2E` offset hard drop shadows.

---

## 🛠️ Mobile Technology Stack

* **Core SDK**: Flutter 3.x (Dart 3)
* **Database & Realtime Engine**: `supabase_flutter` (v2 API for Postgres, Realtime WebSockets, Storage)
* **Interactive Web/Mobile Mapping**: `flutter_map` + `latlong2` + OpenStreetMap (100% Free, No API Keys needed)
* **Live GPS Tracking**: `geolocator` + `geocoding` (Turns your mobile device into a live virtual bus)
* **Multi-Stop Routing Engines**: `http` querying Open Source Routing Machine (OSRM Driving & Trip TSP APIs)
* **Data Visualization**: `fl_chart` (Advanced responsive Line & Bar charts)
* **Document Archival & Sharing**: `pdf` + `printing` + `share_plus` + `path_provider` (Automated PDF Trip generation & native OS share sheet)
* **File Operations**: `file_picker` + `excel` + `csv` (Mobile spreadsheet parsing for student stop rosters)
* **Local Persistence**: `shared_preferences` (Persists custom project URLs, keys, and simulation modes)
* **Sound Effects Compatibility**: `audioplayers` (Custom SFX integration)

---

## 🚀 Key Mobile Screens & Advanced Features

### 1. 🗺️ Fleet Map (`lib/screens/fleet_map_screen.dart`)
* **Free Interactive Mapping**: Full OpenStreetMap mobile tile rendering requiring zero API keys. Supports fluid pinch-to-zoom and smooth panning animations.
* **Turn-by-Turn GPS Driving Simulation**: Select any Start Point (A) and End Point (B) from real city intersections. The OSRM engine fetches the exact physical road network GeoJSON and drives the bus smoothly along the true street curves right on your screen.
* **Live Database Syncing**: Watch the vehicle drive in real-time. As it moves, the mobile app actively pushes updated `gps_lat`, `gps_lng`, and `speed` telemetry directly back to your live Supabase database.
* **"Ride Along" GPS Tracker**: Click **📍 Track My Real Location** to request native iOS/Android location permissions and turn your physical iPhone or Android device into an active virtual bus on the OpenStreetMap grid.

### 2. 🛣️ Smart Route Planner (`lib/screens/smart_planner_screen.dart`)
* **Excel & CSV File Import**: Tap **📂 Import Excel / CSV Stops** to open the native mobile file picker. Upload any `.xlsx`, `.xls`, or `.csv` student roster file. The engine instantly decodes the buffers and parses columns for `name`, `lat`, and `lng` to place student waypoints on the map.
* **Interactive Map Tap Pinning**: Tap anywhere on the real interactive mobile map to drop student stop waypoints instantly.
* **Optimal TSP Round-Trip Solver**: Tap **🚀 Calculate Optimal Route** to query the OSRM Trip API. It locks the **School Main Base Depot (`🏫`)** as the starting point, evaluates all student waypoints to calculate the fastest physical turn-by-turn road visiting order, and plots the exact return path back to the school depot!
* **Intelligent Bus Allocation**: Inspects your live Supabase database inventory to assign an `Idle` or `Parked` vehicle, verifying that total passenger capacity exceeds your student waypoint count (with real-time warning banners).

### 3. 📹 Live Bus Panel (`lib/screens/live_panel_screen.dart`)
* **AI Vision Feed**: Renders live simulated interior cabin overview streams complete with active YOLOv8 detector overlay HUDs (`🔴 REC`, `FPS: 30.0`, `CAM_01`).
* **Pre-Departure Go/No-Go Checklist**: Real-time validation of safety criteria (`Front zone clear`, `Rear zone clear`, `All passengers seated`, `Door closed`, `Driver seatbelt on`, `Tire pressure status`). Dynamically outputs either a solid green **`CLEAR TO MOVE`** or red **`HOLD DEPARTURE`** badge.
* **Seat Map Grid**: Color-coded mobile grid showing live occupancy and seatbelt compliance per individual seat.

### 4. 👥 Passenger Dashboard (`lib/screens/passenger_screen.dart`)
* **Live Demographics**: Prominent metric cards displaying Headcount vs. Capacity, Seatbelt Compliance %, and Standing Passengers Count.
* **Detailed Cabin Map**: A comprehensive visual layout of seat rows, entrance door placement, driver zone, and emergency exit sectors.

### 5. 🔔 Alert Feed (`lib/screens/alert_feed_screen.dart`)
* **Strict Formatting Compliance**: Presents real-time timestamped alerts matching exact official syntax: `[08:32] Bus #3 — CHILD LEFT BEHIND detected`.
* **Multi-Factor Filtering**: Instant mobile dropdown filtering by Bus ID, Alert Type (`PHONE USAGE`, `FLAT TIRE`, `BLIND SPOT`, etc.), Severity (`High`, `Medium`, `Low`), and Acknowledgment Status.
* **Evidence Snapshot Storage**: Opens a beautiful modal preview showcasing the AI-captured proof image from Supabase Storage. Includes quick **`Acknowledge`** actions to instantly resolve infractions in the Supabase database.

### 6. 🏆 Driver Scorecard (`lib/screens/scorecard_screen.dart`)
* **Performance Rating**: Displays overall driver safety scores out of 100 with active standing badges (`Excellent`, `Satisfactory`, `Needs Review`).
* **Historical Trend Graph**: Integrated **`fl_chart`** line chart demonstrating multi-week historical performance trends, fleet average comparisons, and compliance goals.

### 7. 📊 Fleet Analytics (`lib/screens/analytics_screen.dart`)
* **Incidents Per Bus Per Week**: Vertical bar chart highlighting which vehicles generate the most AI detection alerts.
* **Most Common Alert Types**: Line/Bar charts illustrating the distribution of infractions across categories and daily seatbelt compliance progression.

### 8. 📄 Auto-Generated Trip Reports (`lib/screens/trip_report_screen.dart`)
* **Automated PDF Engine**: Built using `pdf` and `printing`. Generates beautifully formatted, branded multi-page documents containing route assigned, headcount verified, AI incidents logged, driver safety score, departure times, and an official AI transit certification stamp.
* **Native OS Share Sheet**: Tapping **Download PDF Report** instantly generates the file in your temporary directory and brings up the native iOS AirDrop / Android Share sheet via `share_plus`.

### 9. 🅿️ School Parking Geofence Monitoring (`lib/screens/school_parking_screen.dart`)
* **Live Bus Counter**: Tracks the precise volume of stationary buses currently present in the school parking lot.
* **Entry/Exit Logging**: Detailed horizontal data tables tracking check-in and check-out timestamps accompanied by real-time status badges.

---

## 🗄️ Supabase Realtime Telemetry Integration

The application connects directly to your live Supabase Postgres database instance (`https://vobjjnoqukepgftorvgk.supabase.co`) using your publishable key.

### Supported Database Schema (UUID Aligned)
* `buses`: Tracks fleet active GPS coordinates, speed, driver name, route, and live status (`En Route`, `Alert`, `Parked`, `Idle`).
* `alerts`: Stores AI edge detection infraction logs, severity levels, snapshot evidence URLs, and acknowledgment states.
* `seats`: Manages live seatbelt telemetry and seat occupancy.
* `trips`: Archives completed route manifests, passenger headcounts, driver scores, and incident volumes.
* `parking`: Logs automated geofence entry and exit timestamps.
* `checklist`: Standalone table tracking pre-departure go/no-go verification parameters.

### 🚀 Built-in Database Seeding Utility
If your real Supabase database tables are currently empty, **you do not need to manually enter data**. 
1. Open the mobile app.
2. Tap the pink **"Config"** button at the top right of the app bar.
3. Tap the green **"🚀 Seed Supabase Database Now"** button. The app will automatically batch-insert fully formatted sample data across your `buses`, `checklist`, `alerts`, `seats`, `trips`, and `parking` tables in one click!

---

## 💻 Installation, Build & GitHub Actions Sideloading Guide

### Local Mobile Development (iOS & Android)

1. **Clone / Navigate to Project Directory:**
   Open your terminal and navigate to the project folder:
   ```bash
   cd bus_guard_flutter
   ```

2. **Fetch Dependencies:**
   Run the following command to download all required Flutter packages:
   ```bash
   flutter pub get
   ```

3. **Run on iOS Simulator or Android Device:**
   Launch the app on your connected device or simulator:
   ```bash
   flutter run
   ```

---

### 🌐 Automated GitHub Actions CI/CD (Unsigned IPA for Sideloadly)

The project includes an advanced, highly customized GitHub Actions workflow (`.github/workflows/ios-build.yml`) specifically engineered to build an unsigned release iOS IPA (`bus_guard_ai.ipa`) without requiring a paid Apple Developer Account.

#### How It Works Under the Hood:
1. **Ensures Native Wrapper**: Calls `flutter create .` on the fly to build the native Xcode structure if missing.
2. **Dynamic Ruby Patching**: Automatically edits `ios/Podfile` and `ios/Runner.xcodeproj/project.pbxproj` via an inline Ruby script to strip out `CODE_SIGNING_REQUIRED = YES`, bypass CocoaPods multi-hook rules, and print the debug Podfile directly to your GitHub logs.
3. **Direct Xcode 16 Force Build**: Bypasses Flutter's stripping of environment variables by calling `xcodebuild` directly with overriding command-line arguments (`CODE_SIGNING_ALLOWED=NO`). Command-line arguments have the highest priority in Xcode 16, allowing the build to succeed without a Development Team.
4. **Download & Sideload**: You can download the resulting `bus_guard_ai.ipa` artifact from your GitHub Actions tab, drop it directly into **Sideloadly**, log in with your free Apple iCloud account, and install it directly onto your physical iPhone!

---

## 📁 Mobile Project Structure

```text
bus_guard_flutter/
├── pubspec.yaml                        # Core dependency registry
├── README.md                           # Mobile documentation manifest
├── .github/
│   └── workflows/
│       └── ios-build.yml               # GitHub Action for automated unsigned IPA generation
└── lib/
    ├── main.dart                       # App initialization, Theme provider, bottom navigation
    ├── theme/
    │   └── memphis_theme.dart          # Memphis color palette, thick borders, drop shadow helpers
    ├── services/
    │   ├── mock_data.dart              # UUID-aligned seed data representing your Postgres schema
    │   └── supabase_service.dart       # Supabase Realtime client, state manager & DB seeding utility
    ├── widgets/
    │   ├── config_modal.dart           # Supabase URL/Key sheet & one-click DB seeding action
    │   └── alert_toast.dart            # Stacked floating overlay notification for live AI alerts
    └── screens/
        ├── fleet_map_screen.dart       # OSM Map, OSRM road navigator, playback simulation engine
        ├── smart_planner_screen.dart   # Excel import, map click pins, OSRM TSP optimal routing
        ├── live_panel_screen.dart      # AI video stream HUD & Go/No-Go checklist telemetry
        ├── passenger_screen.dart       # Cabin demographics metric cards & full seat map grid
        ├── alert_feed_screen.dart      # Timestamped alerts, multi-factor filters, snapshot modal
        ├── scorecard_screen.dart       # fl_chart trend line graph & operator safety ratings
        ├── analytics_screen.dart       # Fleet-wide aggregate violation and compliance bar charts
        ├── trip_report_screen.dart     # Automated pdf generation & native share_plus integration
        └── school_parking_screen.dart  # Geofence stationary counter & entry/exit timestamp log
```
