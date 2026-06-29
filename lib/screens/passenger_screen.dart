import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../theme/memphis_theme.dart';

class PassengerScreen extends StatefulWidget {
  final SupabaseService supabaseService;

  const PassengerScreen({super.key, required this.supabaseService});

  @override
  State<PassengerScreen> createState() => _PassengerScreenState();
}

class _PassengerScreenState extends State<PassengerScreen> {
  late Map<String, dynamic> _currentBus;

  @override
  void initState() {
    super.initState();
    _currentBus = widget.supabaseService.buses.isNotEmpty ? widget.supabaseService.buses[0] : {
      'id': '11111111-1111-1111-1111-111111111111',
      'name': 'Bus #1',
      'capacity': 24
    };
  }

  @override
  Widget build(BuildContext context) {
    final busSeats = widget.supabaseService.seats.where((s) => s['bus_id'] == _currentBus['id']).toList();
    final cl = widget.supabaseService.checklists.firstWhere((c) => c['bus_id'] == _currentBus['id'], orElse: () => { 'all_seated': true });

    final totalCapacity = _currentBus['capacity'] ?? 24;
    final occupiedSeats = busSeats.where((s) => s['occupied'] as bool).length;
    final buckledSeats = busSeats.where((s) => (s['occupied'] as bool) && (s['seatbelt_on'] as bool)).length;
    final complianceRate = occupiedSeats > 0 ? ((buckledSeats / occupiedSeats) * 100).round() : 100;
    final standingCount = (cl['all_seated'] as bool) ? 0 : 2;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Selector Banner
              MemphisTheme.buildContainer(
                bgColor: MemphisTheme.crispSurface,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.people, color: MemphisTheme.secondaryTeal, size: 28),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Passenger Safety Dashboard', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                              Text('Seatbelt Compliance, Standing Counters & Occupancy', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('FILTER VEHICLE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
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
                        items: widget.supabaseService.buses.map((b) => DropdownMenuItem(value: b, child: Text(b['name']))).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Metrics Card Grid
              LayoutBuilder(
                builder: (context, constraints) {
                  bool isWide = constraints.maxWidth > 600;
                  return Flex(
                    direction: isWide ? Axis.horizontal : Axis.vertical,
                    children: [
                      _buildMetricCard('HEADCOUNT VS CAPACITY', '$occupiedSeats / $totalCapacity', Icons.people, MemphisTheme.accentYellow, isWide),
                      SizedBox(height: isWide ? 0 : 12, width: isWide ? 12 : 0),
                      _buildMetricCard('SEATBELT COMPLIANCE', '$complianceRate%', Icons.verified_user, MemphisTheme.secondaryTeal, isWide),
                      SizedBox(height: isWide ? 0 : 12, width: isWide ? 12 : 0),
                      _buildMetricCard('STANDING PASSENGERS', '$standingCount', Icons.warning, MemphisTheme.primaryPink, isWide),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),

              // Detailed Cabin Seat Map Grid
              MemphisTheme.buildContainer(
                bgColor: MemphisTheme.crispSurface,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('DETAILED CABIN SEAT MAP GRID', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                    const SizedBox(height: 4),
                    const Text('Visual inspection of seatbelt telemetry & child presence', style: TextStyle(fontSize: 12)),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: MemphisTheme.warmBackground, borderRadius: BorderRadius.circular(20), border: Border.all(color: MemphisTheme.darkText, width: 3)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(color: MemphisTheme.accentYellow, borderRadius: BorderRadius.circular(12), border: Border.all(color: MemphisTheme.darkText, width: 3)),
                                child: const Text('DRIVER ZONE (Front)', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(color: MemphisTheme.crispSurface, borderRadius: BorderRadius.circular(12), border: Border.all(color: MemphisTheme.darkText, width: 3)),
                                child: const Text('ENTRANCE DOOR', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const Divider(color: MemphisTheme.darkText, thickness: 3),
                          const SizedBox(height: 20),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.85,
                            ),
                            itemCount: busSeats.length,
                            itemBuilder: (context, index) {
                              final seat = busSeats[index];
                              final isViolation = (seat['occupied'] as bool) && !(seat['seatbelt_on'] as bool);
                              Color bgCol = isViolation ? MemphisTheme.primaryPink : MemphisTheme.secondaryTeal;

                              return Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(color: bgCol, borderRadius: BorderRadius.circular(12), border: Border.all(color: MemphisTheme.darkText, width: 3)),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('SEAT #${seat['seat_number']}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
                                    const SizedBox(height: 4),
                                    Text((seat['occupied'] as bool) ? ((seat['seatbelt_on'] as bool) ? '🔒💺' : '⚠️💺') : '💺', style: const TextStyle(fontSize: 16)),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                      decoration: BoxDecoration(color: MemphisTheme.crispSurface, borderRadius: BorderRadius.circular(4), border: Border.all(color: MemphisTheme.darkText, width: 1)),
                                      child: Text((seat['occupied'] as bool) ? ((seat['seatbelt_on'] as bool) ? 'Buckled' : 'Unbuckled') : 'Vacant', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 8)),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          const Divider(color: MemphisTheme.darkText, thickness: 3),
                          const SizedBox(height: 12),
                          const Center(child: Text('▼ REAR EMERGENCY EXIT ZONE ▼', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12))),
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

  Widget _buildMetricCard(String title, String val, IconData icon, Color color, bool isWide) {
    Widget card = MemphisTheme.buildContainer(
      bgColor: MemphisTheme.crispSurface,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12), border: Border.all(color: MemphisTheme.darkText, width: 3)),
            child: Icon(icon, size: 32, color: MemphisTheme.darkText),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
                const SizedBox(height: 4),
                Text(val, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22)),
              ],
            ),
          ),
        ],
      ),
    );
    return isWide ? Expanded(child: card) : card;
  }
}
