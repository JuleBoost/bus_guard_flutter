import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../theme/memphis_theme.dart';

class SchoolParkingScreen extends StatelessWidget {
  final SupabaseService supabaseService;

  const SchoolParkingScreen({super.key, required this.supabaseService});

  @override
  Widget build(BuildContext context) {
    final parkedBuses = supabaseService.buses.where((b) => b['status'] == 'Parked' || b['status'] == 'Idle').toList();
    final countEnRoute = supabaseService.buses.where((b) => b['status'] == 'En Route').length;
    final countParked = supabaseService.buses.where((b) => b['status'] == 'Parked').length;
    final countIdle = supabaseService.buses.where((b) => b['status'] == 'Idle').length;
    final countAlert = supabaseService.buses.where((b) => b['status'] == 'Alert').length;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Banner
              MemphisTheme.buildContainer(
                bgColor: MemphisTheme.crispSurface,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.local_parking, color: MemphisTheme.primaryPink, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('School Parking Lot Monitoring', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                              Text('Live count of stationary buses & fleet status badges', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: MemphisTheme.accentYellow, borderRadius: BorderRadius.circular(12), border: Border.all(color: MemphisTheme.darkText, width: 3)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('CURRENTLY IN LOT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                          Text('${parkedBuses.length} Buses', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Status Summary Badges Grid
              LayoutBuilder(
                builder: (context, constraints) {
                  bool isWide = constraints.maxWidth > 500;
                  return Flex(
                    direction: isWide ? Axis.horizontal : Axis.vertical,
                    children: [
                      _buildStatusCard('EN ROUTE', '$countEnRoute', MemphisTheme.secondaryTeal, isWide),
                      SizedBox(height: isWide ? 0 : 12, width: isWide ? 12 : 0),
                      _buildStatusCard('PARKED', '$countParked', MemphisTheme.accentYellow, isWide),
                      SizedBox(height: isWide ? 0 : 12, width: isWide ? 12 : 0),
                      _buildStatusCard('IDLE', '$countIdle', MemphisTheme.warmBackground, isWide),
                      SizedBox(height: isWide ? 0 : 12, width: isWide ? 12 : 0),
                      _buildStatusCard('ALERT STATUS', '$countAlert', MemphisTheme.primaryPink, isWide),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),

              // Entry/Exit Log
              MemphisTheme.buildContainer(
                bgColor: MemphisTheme.crispSurface,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('PARKING LOT ENTRY & EXIT LOG', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                    const SizedBox(height: 4),
                    const Text('Auto-logged via license plate geofence cameras', style: TextStyle(fontSize: 12)),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: 24,
                        border: TableBorder.symmetric(inside: const BorderSide(color: MemphisTheme.darkText, width: 1)),
                        headingTextStyle: const TextStyle(fontWeight: FontWeight.w900, color: MemphisTheme.darkText, fontSize: 11),
                        dataTextStyle: const TextStyle(fontWeight: FontWeight.w700, color: MemphisTheme.darkText, fontSize: 13),
                        columns: const [
                          DataColumn(label: Text('VEHICLE NAME')),
                          DataColumn(label: Text('ASSIGNED DRIVER')),
                          DataColumn(label: Text('ENTERED LOT AT')),
                          DataColumn(label: Text('EXITED LOT AT')),
                          DataColumn(label: Text('STATUS')),
                        ],
                        rows: supabaseService.parking.map((p) {
                          final bus = supabaseService.buses.firstWhere((b) => b['id'].toString() == p['bus_id'].toString(), orElse: () => { 'name': 'Bus #${p['bus_id']}', 'driver': 'Unknown Driver', 'status': p['status'] ?? 'Parked' });
                          Color badgeCol = bus['status'] == 'Alert' ? MemphisTheme.primaryPink : (bus['status'] == 'Parked' ? MemphisTheme.accentYellow : MemphisTheme.secondaryTeal);

                          return DataRow(
                            cells: [
                              DataCell(Text(bus['name'], style: const TextStyle(fontWeight: FontWeight.w900))),
                              DataCell(Text(bus['driver'] ?? 'Driver')),
                              DataCell(Text(p['entered_at'] ?? '06:30 AM', style: const TextStyle(color: MemphisTheme.secondaryTeal, fontWeight: FontWeight.w900))),
                              DataCell(Text(p['exited_at'] ?? '— (In Lot)', style: const TextStyle(color: MemphisTheme.primaryPink, fontWeight: FontWeight.w900))),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(color: badgeCol, borderRadius: BorderRadius.circular(8), border: Border.all(color: MemphisTheme.darkText, width: 2)),
                                  child: Text(bus['status'] ?? 'Parked', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10)),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
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

  Widget _buildStatusCard(String label, String val, Color color, bool isWide) {
    Widget card = MemphisTheme.buildContainer(
      bgColor: color,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
          const SizedBox(height: 4),
          Text(val, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 28)),
        ],
      ),
    );
    return isWide ? Expanded(child: card) : card;
  }
}
