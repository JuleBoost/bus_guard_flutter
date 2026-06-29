import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'package:csv/csv.dart';
import '../services/supabase_service.dart';
import '../theme/memphis_theme.dart';

class SmartPlannerScreen extends StatefulWidget {
  final SupabaseService supabaseService;

  const SmartPlannerScreen({super.key, required this.supabaseService});

  @override
  State<SmartPlannerScreen> createState() => _SmartPlannerScreenState();
}

class _SmartPlannerScreenState extends State<SmartPlannerScreen> {
  final MapController _mapController = MapController();
  final Map<String, dynamic> _startDepot = { 'id': 'depot-1', 'name': 'School Main Base Depot', 'lat': 33.8900, 'lng': 35.5050 };
  
  List<Map<String, dynamic>> _studentStops = [
    { 'id': 'student-1', 'name': 'Student Stop A (Hamra Residential)', 'lat': 33.8965, 'lng': 35.4832 },
    { 'id': 'student-2', 'name': 'Student Stop B (Downtown Tower)', 'lat': 33.8938, 'lng': 35.5065 },
    { 'id': 'student-3', 'name': 'Student Stop C (Achrafieh Terminal)', 'lat': 33.8885, 'lng': 35.5180 },
  ];

  bool _clickMode = true;
  bool _isCalculating = false;
  Map<String, dynamic>? _routeResults;
  String _routeError = '';
  Map<String, dynamic>? _assignedBus;

  @override
  void initState() {
    super.initState();
    _updateAssignedBus();
  }

  void _updateAssignedBus() {
    if (widget.supabaseService.buses.isNotEmpty) {
      final available = widget.supabaseService.buses.firstWhere(
        (b) => b['status'] == 'Idle' || b['status'] == 'Parked',
        orElse: () => widget.supabaseService.buses[0],
      );
      setState(() => _assignedBus = available);
    }
  }

  Future<void> _handleFileUpload() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls', 'csv'],
      );

      if (result != null && result.files.single.path != null) {
        String path = result.files.single.path!;
        List<Map<String, dynamic>> imported = [];

        if (path.endsWith('.csv')) {
          final input = File(path).openRead();
          final fields = await input.transform(const CsvToListConverter()).toList();
          if (fields.length > 1) {
            for (int i = 1; i < fields.length; i++) {
              final row = fields[i];
              imported.add({
                'id': 'imported-csv-$i-${DateTime.now().millisecondsSinceEpoch}',
                'name': row[0].toString(),
                'lat': double.tryParse(row[1].toString()) ?? (33.88 + (i * 0.002)),
                'lng': double.tryParse(row[2].toString()) ?? (35.49 + (i * 0.002)),
              });
            }
          }
        } else {
          var bytes = File(path).readAsBytesSync();
          var excel = Excel.decodeBytes(bytes);
          for (var table in excel.tables.keys) {
            var sheet = excel.tables[table]!;
            for (int i = 1; i < sheet.rows.length; i++) {
              var row = sheet.rows[i];
              imported.add({
                'id': 'imported-xls-$i-${DateTime.now().millisecondsSinceEpoch}',
                'name': row[0]?.value?.toString() ?? 'Student #$i',
                'lat': double.tryParse(row[1]?.value?.toString() ?? '') ?? (33.88 + (i * 0.002)),
                'lng': double.tryParse(row[2]?.value?.toString() ?? '') ?? (35.49 + (i * 0.002)),
              });
            }
          }
        }

        if (imported.isNotEmpty) {
          setState(() {
            _studentStops.addAll(imported);
            _routeResults = null;
            _routeError = 'Successfully imported ${imported.length} student stops!';
          });
        }
      }
    } catch (err) {
      setState(() => _routeError = 'Error parsing file: $err');
    }
  }

  Future<void> _handleCalculateOptimalRoute() async {
    if (_studentStops.isEmpty) {
      setState(() => _routeError = 'Add at least one student address stop.');
      return;
    }

    setState(() {
      _isCalculating = true;
      _routeError = '';
    });

    final allPoints = [_startDepot, ..._studentStops];
    final res = await widget.supabaseService.calculateTSPRoute(allPoints);

    setState(() {
      _isCalculating = false;
      if (res != null) {
        _routeResults = res;
      } else {
        _routeError = 'Error calculating TSP optimal route. Ensure points are near valid roads.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
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
                    const Row(
                      children: [
                        Icon(Icons.route, color: MemphisTheme.primaryPink, size: 28),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Smart Fleet Route Planner (TSP Engine)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                              Text('Optimal multi-stop AI routing & automatic vehicle allocation', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        MemphisTheme.buildButton(
                          bgColor: MemphisTheme.primaryPink,
                          isSmall: true,
                          onPressed: _handleFileUpload,
                          child: const Text('📂 Import Excel / CSV Stops', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                        ),
                        MemphisTheme.buildButton(
                          bgColor: _clickMode ? MemphisTheme.secondaryTeal : MemphisTheme.warmBackground,
                          isSmall: true,
                          onPressed: () => setState(() => _clickMode = !_clickMode),
                          child: Text(_clickMode ? '📍 Map Click Adds Stops: ON' : '📍 Map Click: OFF', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                        ),
                        if (_studentStops.isNotEmpty)
                          MemphisTheme.buildButton(
                            bgColor: MemphisTheme.accentYellow,
                            isSmall: true,
                            onPressed: () => setState(() { _studentStops.clear(); _routeResults = null; }),
                            child: const Text('🗑️ Clear', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              if (_routeError.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: MemphisTheme.accentYellow, borderRadius: BorderRadius.circular(12), border: Border.all(color: MemphisTheme.darkText, width: 3)),
                  child: Text(_routeError, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                ),
              ],
              const SizedBox(height: 16),

              // Main Active UI
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    bool isWide = constraints.maxWidth > 800;
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (isWide) ...[
                          // Left Sidebar
                          SizedBox(
                            width: 340,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                MemphisTheme.buildContainer(
                                  bgColor: MemphisTheme.warmBackground,
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      const Text('ASSIGNED VEHICLE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                                      const SizedBox(height: 8),
                                      if (_assignedBus != null) ...[
                                        Text(_assignedBus!['name'], style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                                        Text('Driver: ${_assignedBus!['driver']}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                                        Text('Capacity: ${_studentStops.length} / ${_assignedBus!['capacity'] ?? 24} Passengers', style: const TextStyle(fontWeight: FontWeight.w700, color: MemphisTheme.secondaryTeal, fontSize: 12)),
                                        if (_studentStops.length > (_assignedBus!['capacity'] ?? 24)) ...[
                                          const SizedBox(height: 8),
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(color: MemphisTheme.primaryPink, borderRadius: BorderRadius.circular(8), border: Border.all(color: MemphisTheme.darkText, width: 2)),
                                            child: const Text('⚠️ Warning: Student count exceeds vehicle capacity!', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11)),
                                          ),
                                        ],
                                      ],
                                      const SizedBox(height: 16),
                                      MemphisTheme.buildButton(
                                        bgColor: MemphisTheme.accentYellow,
                                        onPressed: _isCalculating || _studentStops.isEmpty ? () {} : _handleCalculateOptimalRoute,
                                        child: Text(_isCalculating ? 'Optimizing TSP Matrix...' : '🚀 Calculate Optimal Route', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Expanded(
                                  child: MemphisTheme.buildContainer(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        const Text('STUDENT WAYPOINTS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                                        const SizedBox(height: 12),
                                        Expanded(
                                          child: ListView.separated(
                                            itemCount: (_routeResults != null ? _routeResults!['optimizedOrder'] as List : _studentStops).length,
                                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                                            itemBuilder: (context, index) {
                                              final stop = (_routeResults != null ? _routeResults!['optimizedOrder'] as List : _studentStops)[index];
                                              return Container(
                                                padding: const EdgeInsets.all(12),
                                                decoration: BoxDecoration(color: MemphisTheme.warmBackground, borderRadius: BorderRadius.circular(12), border: Border.all(color: MemphisTheme.darkText, width: 2)),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      width: 28,
                                                      height: 28,
                                                      decoration: BoxDecoration(color: _routeResults != null ? MemphisTheme.accentYellow : MemphisTheme.primaryPink, shape: BoxShape.circle, border: Border.all(color: MemphisTheme.darkText, width: 2)),
                                                      child: Center(child: Text(_routeResults != null ? '${stop['optimalSequenceIndex']}' : '${index + 1}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12))),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(stop['name'], style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                                                          Text('Lat: ${(stop['lat'] as double).toStringAsFixed(4)}, Lng: ${(stop['lng'] as double).toStringAsFixed(4)}', style: const TextStyle(fontSize: 10)),
                                                        ],
                                                      ),
                                                    ),
                                                    IconButton(
                                                      onPressed: () => setState(() { _studentStops.removeWhere((s) => s['id'] == stop['id']); _routeResults = null; }),
                                                      icon: const Icon(Icons.delete, size: 20),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                        ],

                        // Interactive Map Container
                        Expanded(
                          child: MemphisTheme.buildContainer(
                            padding: const EdgeInsets.all(8),
                            child: Stack(
                              children: [
                                FlutterMap(
                                  mapController: _mapController,
                                  options: MapOptions(
                                    initialCenter: LatLng(_startDepot['lat'] as double, _startDepot['lng'] as double),
                                    initialZoom: 14.0,
                                    onTap: (tapPos, latlng) {
                                      if (!_clickMode) return;
                                      setState(() {
                                        _studentStops.add({
                                          'id': 'student-${DateTime.now().millisecondsSinceEpoch}',
                                          'name': 'Student Stop #${Random().nextInt(1000)}',
                                          'lat': latlng.latitude,
                                          'lng': latlng.longitude,
                                        });
                                        _routeResults = null;
                                      });
                                    },
                                  ),
                                  children: [
                                    TileLayer(
                                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                      userAgentPackageName: 'com.busguard.app',
                                    ),
                                    if (_routeResults != null && _routeResults!['path'] != null)
                                      PolylineLayer(
                                        polylines: [
                                          Polyline(
                                            points: (_routeResults!['path'] as List).map((c) => LatLng(c[0] as double, c[1] as double)).toList(),
                                            color: MemphisTheme.darkText,
                                            strokeWidth: 8.0,
                                          ),
                                          Polyline(
                                            points: (_routeResults!['path'] as List).map((c) => LatLng(c[0] as double, c[1] as double)).toList(),
                                            color: MemphisTheme.accentYellow,
                                            strokeWidth: 4.0,
                                          ),
                                        ],
                                      ),
                                    MarkerLayer(
                                      markers: [
                                        // Depot Marker
                                        Marker(
                                          point: LatLng(_startDepot['lat'] as double, _startDepot['lng'] as double),
                                          width: 60,
                                          height: 50,
                                          child: Container(
                                            decoration: BoxDecoration(color: MemphisTheme.secondaryTeal, borderRadius: BorderRadius.circular(12), border: Border.all(color: MemphisTheme.darkText, width: 3)),
                                            child: const Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text('🏫', style: TextStyle(fontSize: 16)),
                                                Text('DEPOT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 9)),
                                              ],
                                            ),
                                          ),
                                        ),
                                        // Student Waypoints
                                        ...(_routeResults != null ? _routeResults!['optimizedOrder'] as List : _studentStops).map((stop) => Marker(
                                          point: LatLng(stop['lat'] as double, stop['lng'] as double),
                                          width: 36,
                                          height: 36,
                                          child: Container(
                                            decoration: BoxDecoration(color: _routeResults != null ? MemphisTheme.accentYellow : MemphisTheme.primaryPink, shape: BoxShape.circle, border: Border.all(color: MemphisTheme.darkText, width: 3)),
                                            child: Center(child: Text(_routeResults != null ? '${stop['optimalSequenceIndex']}' : '👤', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13))),
                                          ),
                                        )),
                                      ],
                                    ),
                                  ],
                                ),
                                Positioned(
                                  top: 16,
                                  right: 16,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(color: MemphisTheme.crispSurface, borderRadius: BorderRadius.circular(12), border: Border.all(color: MemphisTheme.darkText, width: 3)),
                                    child: Text(_clickMode ? 'Click map to add student stops' : 'Exploration active', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
