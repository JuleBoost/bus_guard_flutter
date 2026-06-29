import 'package:flutter/material.dart';
import 'services/supabase_service.dart';
import 'theme/memphis_theme.dart';
import 'widgets/alert_toast.dart';
import 'widgets/config_modal.dart';
import 'screens/fleet_map_screen.dart';
import 'screens/smart_planner_screen.dart';
import 'screens/live_panel_screen.dart';
import 'screens/passenger_screen.dart';
import 'screens/alert_feed_screen.dart';
import 'screens/scorecard_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/trip_report_screen.dart';
import 'screens/school_parking_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BusGuardApp());
}

class BusGuardApp extends StatefulWidget {
  const BusGuardApp({super.key});

  @override
  State<BusGuardApp> createState() => _BusGuardAppState();
}

class _BusGuardAppState extends State<BusGuardApp> {
  final SupabaseService _supabaseService = SupabaseService();

  @override
  void dispose() {
    _supabaseService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _supabaseService,
      builder: (context, _) {
        return MaterialApp(
          title: 'BusGuard AI Safety System',
          debugShowCheckedModeBanner: false,
          theme: MemphisTheme.theme,
          home: MainNavigationScreen(supabaseService: _supabaseService),
        );
      },
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  final SupabaseService supabaseService;

  const MainNavigationScreen({super.key, required this.supabaseService});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  Map<String, dynamic>? _selectedBusForLivePanel;

  void _handleSelectBusForLivePanel(Map<String, dynamic> bus) {
    setState(() {
      _selectedBusForLivePanel = bus;
      _currentIndex = 2; // Switch to Live Panel Tab
    });
  }

  void _handleNavigateToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _openConfigModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ConfigModal(supabaseService: widget.supabaseService),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int unackCount = widget.supabaseService.alerts.where((a) => !(a['acknowledged'] as bool)).length;

    final List<Widget> screens = [
      FleetMapScreen(supabaseService: widget.supabaseService, onSelectBusForLivePanel: _handleSelectBusForLivePanel),
      SmartPlannerScreen(supabaseService: widget.supabaseService),
      LivePanelScreen(supabaseService: widget.supabaseService, initialSelectedBus: _selectedBusForLivePanel),
      PassengerScreen(supabaseService: widget.supabaseService),
      AlertFeedScreen(supabaseService: widget.supabaseService),
      ScorecardScreen(supabaseService: widget.supabaseService),
      AnalyticsScreen(supabaseService: widget.supabaseService),
      TripReportScreen(supabaseService: widget.supabaseService),
      SchoolParkingScreen(supabaseService: widget.supabaseService),
    ];

    return AlertToastOverlay(
      supabaseService: widget.supabaseService,
      onNavigateToTab: _handleNavigateToTab,
      child: Scaffold(
        appBar: AppBar(
          title: const Row(
            children: [
              Text('🚌', style: TextStyle(fontSize: 24)),
              SizedBox(width: 8),
              // FIX: tracking → letterSpacing
              Text('BUSGUARD AI', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.5)),
            ],
          ),
          actions: [
            // Live Status indicator
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: widget.supabaseService.simulationMode ? MemphisTheme.accentYellow : MemphisTheme.secondaryTeal,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: MemphisTheme.darkText, width: 2),
              ),
              child: Center(
                child: Text(
                  widget.supabaseService.simulationMode ? 'SIMULATOR LIVE' : 'SUPABASE LIVE',
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: MemphisTheme.darkText),
                ),
              ),
            ),
            // Config Button
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: ElevatedButton.icon(
                onPressed: _openConfigModal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: MemphisTheme.primaryPink,
                  foregroundColor: MemphisTheme.darkText,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: MemphisTheme.darkText, width: 3)),
                ),
                icon: const Icon(Icons.settings, size: 16),
                label: const Text('Config', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
              ),
            ),
          ],
        ),
        body: screens[_currentIndex],
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: MemphisTheme.darkText, width: 3)),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _handleNavigateToTab,
            type: BottomNavigationBarType.fixed,
            backgroundColor: MemphisTheme.crispSurface,
            selectedItemColor: MemphisTheme.darkText,
            unselectedItemColor: MemphisTheme.darkText.withOpacity(0.5),
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 10),
            items: [
              const BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Fleet'),
              const BottomNavigationBarItem(icon: Icon(Icons.route), label: 'Planner'),
              const BottomNavigationBarItem(icon: Icon(Icons.videocam), label: 'Live'),
              const BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Passenger'),
              BottomNavigationBarItem(
                icon: Stack(
                  children: [
                    const Icon(Icons.notifications),
                    if (unackCount > 0)
                      Positioned(
                        right: 0, top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(color: MemphisTheme.primaryPink, shape: BoxShape.circle, border: Border.all(color: MemphisTheme.darkText, width: 1)),
                          constraints: const BoxConstraints(minWidth: 12, minHeight: 12),
                          child: Text('$unackCount', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 8, color: MemphisTheme.darkText)),
                        ),
                      ),
                  ],
                ),
                label: 'Alerts',
              ),
              const BottomNavigationBarItem(icon: Icon(Icons.military_tech), label: 'Driver'),
              const BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Analytics'),
              const BottomNavigationBarItem(icon: Icon(Icons.picture_as_pdf), label: 'Trip PDF'),
              const BottomNavigationBarItem(icon: Icon(Icons.local_parking), label: 'Parking'),
            ],
          ),
        ),
      ),
    );
  }
}