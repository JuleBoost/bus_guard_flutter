import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../theme/memphis_theme.dart';

class LivePanelScreen extends StatefulWidget {
  final SupabaseService supabaseService;
  final Map<String, dynamic>? initialSelectedBus;

  const LivePanelScreen({super.key, required this.supabaseService, this.initialSelectedBus});

  @override
  State<LivePanelScreen> createState() => _LivePanelScreenState();
}

class _LivePanelScreenState extends State<LivePanelScreen> {
  late Map<String, dynamic> _currentBus;

  @override
  void initState() {
    super.initState();
    _currentBus = widget.initialSelectedBus ?? (widget.supabaseService.buses.isNotEmpty ? widget.supabaseService.buses[0] : {
      'id': '11111111-1111-1111-1111-111111111111',
      'name': 'Bus #1',
      'speed': 45.0,
      'status': 'En Route',
      'camera_feed': 'https://images.unsplash.com/photo-1557223562-6c77ef16210f?auto=format&fit=crop&w=600&q=80'
    });
  }

  @override
  Widget build(BuildContext context) {
    final busAlerts = widget.supabaseService.alerts.where((a) => a['bus_id'] == _currentBus['id'] && !(a['acknowledged'] as bool)).toList();
    final busSeats = widget.supabaseService.seats.where((s) => s['bus_id'] == _currentBus['id']).toList();
    
    final cl = widget.supabaseService.checklists.firstWhere(
      (c) => c['bus_id'] == _currentBus['id'],
      orElse: () => { 'front_clear': true, 'rear_clear': true, 'all_seated': true, 'door_closed': true, 'seatbelt_on': true, 'tire_ok': true },
    );

    final isClearToMove = (cl['front_clear'] as bool) && (cl['rear_clear'] as bool) && (cl['all_seated'] as bool) && (cl['door_closed'] as bool) && (cl['seatbelt_on'] as bool) && (cl['tire_ok'] as bool);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Bar Selector
              MemphisTheme.buildContainer(
                bgColor: MemphisTheme.crispSurface,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.videocam, color: MemphisTheme.primaryPink, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Live Bus Telemetry Panel', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                              Text('AI Camera Feed & Supabase Checklist Store', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: MemphisTheme.darkText.withOpacity(0.7))),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('SELECT BUS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(color: MemphisTheme.accentYellow, borderRadius: BorderRadius.circular(12), border: Border.all(color: MemphisTheme.darkText, width: 3)),
                      child: DropdownButton<Map<String, dynamic>>(
                        value: widget.supabaseService.buses.firstWhere((b) => b['id'] == _currentBus['id'], orElse: () => _currentBus),
                        isExpanded: true,
                        underline: const SizedBox(),
                        style: const TextStyle(fontWeight: FontWeight.w800, color: MemphisTheme.darkText, fontSize: 13),
                        onChanged: (val) { if (val != null) setState(() => _currentBus = val); },
                        items: widget.supabaseService.buses.map((b) => DropdownMenuItem(value: b, child: Text('${b['name']} (${b['status']})'))).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Camera Feed View
              MemphisTheme.buildContainer(
                bgColor: MemphisTheme.crispSurface,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('AI VISION CAMERA FEED', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: (_currentBus['speed'] as num) > 45 ? MemphisTheme.primaryPink : MemphisTheme.secondaryTeal, borderRadius: BorderRadius.circular(8), border: Border.all(color: MemphisTheme.darkText, width: 2)),
                          child: Text('${_currentBus['speed']} km/h', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 220,
                      decoration: BoxDecoration(color: MemphisTheme.darkText, borderRadius: BorderRadius.circular(12), border: Border.all(color: MemphisTheme.darkText, width: 3)),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(_currentBus['camera_feed'], fit: BoxFit.cover),
                          Positioned(
                            top: 12,
                            left: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(color: MemphisTheme.darkText.withOpacity(0.85), borderRadius: BorderRadius.circular(8), border: Border.all(color: MemphisTheme.accentYellow, width: 2)),
                              child: const Text('🔴 REC • FPS: 30.0 • YOLOv8 DETECTOR', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: MemphisTheme.accentYellow)),
                            ),
                          ),
                          if (busAlerts.isNotEmpty)
                            Positioned(
                              bottom: 12,
                              right: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(color: MemphisTheme.primaryPink, borderRadius: BorderRadius.circular(8), border: Border.all(color: MemphisTheme.darkText, width: 2)),
                                child: const Text('⚠️ AI ALERT ACTIVE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: MemphisTheme.darkText)),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Go/No-Go Checklist
              MemphisTheme.buildContainer(
                bgColor: MemphisTheme.crispSurface,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(child: Text('PRE-DEPARTURE GO/NO-GO CHECKLIST', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(color: isClearToMove ? MemphisTheme.secondaryTeal : MemphisTheme.primaryPink, borderRadius: BorderRadius.circular(12), border: Border.all(color: MemphisTheme.darkText, width: 3)),
                          child: Text(isClearToMove ? '✅ CLEAR TO MOVE' : '⛔ HOLD DEPARTURE', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Column(
                      children: [
                        _buildCheckItem('Front Zone Clear', cl['front_clear'] as bool, '✅ CLEAR', '⛔ PERSON DETECTED'),
                        const SizedBox(height: 8),
                        _buildCheckItem('Rear Zone Clear', cl['rear_clear'] as bool, '✅ CLEAR', '⛔ OBSTACLE / CHILD'),
                        const SizedBox(height: 8),
                        _buildCheckItem('All Passengers Seated', cl['all_seated'] as bool, '✅ SEATED', '⛔ STANDING DETECTED'),
                        const SizedBox(height: 8),
                        _buildCheckItem('Door Closed', cl['door_closed'] as bool, '✅ CLOSED', '⚠️ OPEN'),
                        const SizedBox(height: 8),
                        _buildCheckItem('Driver Seatbelt On', cl['seatbelt_on'] as bool, '✅ BUCKLED', '⛔ UNBUCKLED'),
                        const SizedBox(height: 8),
                        _buildCheckItem('Tire Pressure Status', cl['tire_ok'] as bool, '✅ NORMAL', '⛔ FLAT TIRE DETECTED'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Active Alerts
              MemphisTheme.buildContainer(
                bgColor: MemphisTheme.crispSurface,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('ACTIVE BUS ALERTS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(color: MemphisTheme.primaryPink, borderRadius: BorderRadius.circular(12), border: Border.all(color: MemphisTheme.darkText, width: 2)),
                          child: Text('${busAlerts.length}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (busAlerts.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: MemphisTheme.warmBackground, borderRadius: BorderRadius.circular(12), border: Border.all(color: MemphisTheme.darkText, width: 3)),
                        child: const Center(child: Text('✅ No Active Alerts. AI models detect zero infractions.', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13))),
                      )
                    else
                      Column(
                        children: busAlerts.map((alert) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: MemphisTheme.warmBackground, borderRadius: BorderRadius.circular(12), border: Border.all(color: MemphisTheme.darkText, width: 2)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(color: MemphisTheme.primaryPink, borderRadius: BorderRadius.circular(6), border: Border.all(color: MemphisTheme.darkText, width: 1)),
                                    child: Text(alert['type'], style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10)),
                                  ),
                                  Text(alert['timestamp'] ?? 'Live', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(alert['message'] ?? alert['description'] ?? '', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                            ],
                          ),
                        )).toList(),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Seat Map Grid
              MemphisTheme.buildContainer(
                bgColor: MemphisTheme.crispSurface,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('SEAT MAP GRID', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                    const SizedBox(height: 4),
                    const Text('Real-time occupancy & seatbelt compliance per seat', style: TextStyle(fontSize: 12)),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: MemphisTheme.warmBackground, borderRadius: BorderRadius.circular(16), border: Border.all(color: MemphisTheme.darkText, width: 3)),
                      child: Column(
                        children: [
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 1.0,
                            ),
                            itemCount: busSeats.length,
                            itemBuilder: (context, index) {
                              final seat = busSeats[index];
                              final isViolation = (seat['occupied'] as bool) && !(seat['seatbelt_on'] as bool);
                              Color bgCol = isViolation ? MemphisTheme.primaryPink : MemphisTheme.secondaryTeal;

                              return Container(
                                decoration: BoxDecoration(color: bgCol, borderRadius: BorderRadius.circular(12), border: Border.all(color: MemphisTheme.darkText, width: 3)),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('${seat['seat_number']}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                                    const SizedBox(height: 2),
                                    Text((seat['occupied'] as bool) ? ((seat['seatbelt_on'] as bool) ? '🔒' : '⚠️') : '💺', style: const TextStyle(fontSize: 12)),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          const Divider(color: MemphisTheme.darkText, thickness: 2),
                          const SizedBox(height: 8),
                          const Text('FRONT OF BUS ▲', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckItem(String label, bool isOk, String okText, String failText) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: MemphisTheme.warmBackground, borderRadius: BorderRadius.circular(12), border: Border.all(color: MemphisTheme.darkText, width: 2)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: isOk ? MemphisTheme.secondaryTeal : MemphisTheme.primaryPink, borderRadius: BorderRadius.circular(8), border: Border.all(color: MemphisTheme.darkText, width: 2)),
            child: Text(isOk ? okText : failText, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
          ),
        ],
      ),
    );
  }
}
