import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../services/supabase_service.dart';
import '../theme/memphis_theme.dart';

class FleetMapScreen extends StatefulWidget {
  final SupabaseService supabaseService;
  final Function(Map<String, dynamic>) onSelectBusForLivePanel;

  const FleetMapScreen({super.key, required this.supabaseService, required this.onSelectBusForLivePanel});

  @override
  State<FleetMapScreen> createState() => _FleetMapScreenState();
}

class _FleetMapScreenState extends State<FleetMapScreen> {
  final MapController _mapController = MapController();

  final List<Map<String, dynamic>> _presetLocations = [
    { 'id': 'hamra', 'name': 'Central High School (West Campus)', 'lat': 33.8965, 'lng': 35.4832 },
    { 'id': 'downtown', 'name': 'Downtown Main Library Terminal', 'lat': 33.8938, 'lng': 35.5065 },
    { 'id': 'achrafieh', 'name': 'East Hills Elementary (Achrafieh)', 'lat': 33.8885, 'lng': 35.5180 },
    { 'id': 'raouche', 'name': 'Coastal Science Academy (Raouche)', 'lat': 33.8890, 'lng': 35.4740 },
    { 'id': 'badaro', 'name': 'Southern Sports Complex (Badaro)', 'lat': 33.8740, 'lng': 35.5170 }
  ];

  late Map<String, dynamic> _startLoc;
  late Map<String, dynamic> _endLoc;
  List<LatLng> _roadPath = [];
  bool _isRouteLoading = false;

  bool _isPlaying = false;
  int _currentStep = 0;
  late LatLng _simulatedCoords;
  int _simulatedSpeed = 45;
  Timer? _timer;

  // Real GPS Geolocation State
  LatLng? _myLocation;
  bool _isTrackingMe = false;
  String _geoError = '';

  Map<String, dynamic>? _selectedBus;

  @override
  void initState() {
    super.initState();
    _startLoc = _presetLocations[0];
    _endLoc = _presetLocations[1];
    _simulatedCoords = LatLng(_startLoc['lat'] as double, _startLoc['lng'] as double);
    if (widget.supabaseService.buses.isNotEmpty) {
      _selectedBus = widget.supabaseService.buses[0];
    }
    _calculateRealRoadPath(_startLoc, _endLoc);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _calculateRealRoadPath(Map<String, dynamic> start, Map<String, dynamic> end) async {
    setState(() {
      _isRouteLoading = true;
      _isPlaying = false;
      _currentStep = 0;
    });
    _timer?.cancel();

    final coords = await widget.supabaseService.fetchRealRoadPath(start, end);
    if (mounted) {
      setState(() {
        _isRouteLoading = false;
        if (coords.isNotEmpty) {
          _roadPath = coords.map((c) => LatLng(c[0], c[1])).toList();
          _simulatedCoords = _roadPath[0];
          _mapController.move(_simulatedCoords, 15.0);
        }
      });
    }
  }

  void _handleTogglePlayback() {
    if (_isPlaying) {
      setState(() => _isPlaying = false);
      _timer?.cancel();
    } else {
      if (_roadPath.isEmpty) return;
      setState(() => _isPlaying = true);
      _timer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
        if (_currentStep + 1 >= _roadPath.length) {
          timer.cancel();
          setState(() {
            _isPlaying = false;
            _simulatedSpeed = 0;
          });
          if (_selectedBus != null) {
            widget.supabaseService.updateBusTelemetry(_selectedBus!['id'], _roadPath.last.latitude, _roadPath.last.longitude, 0);
          }
          return;
        }

        setState(() {
          _currentStep++;
          _simulatedCoords = _roadPath[_currentStep];
          _simulatedSpeed = 35 + Random().nextInt(20);
          _mapController.move(_simulatedCoords, 15.0);
        });

        if (_currentStep % 3 == 0 && _selectedBus != null) {
          widget.supabaseService.updateBusTelemetry(_selectedBus!['id'], _simulatedCoords.latitude, _simulatedCoords.longitude, _simulatedSpeed.toDouble());
        }
      });
    }
  }

  void _handleResetPlayback() {
    _timer?.cancel();
    setState(() {
      _isPlaying = false;
      _currentStep = 0;
      if (_roadPath.isNotEmpty) {
        _simulatedCoords = _roadPath[0];
        _mapController.move(_simulatedCoords, 15.0);
        if (_selectedBus != null) {
          widget.supabaseService.updateBusTelemetry(_selectedBus!['id'], _simulatedCoords.latitude, _simulatedCoords.longitude, 0);
        }
      }
      _simulatedSpeed = 0;
    });
  }

  Future<void> _handleTrackMyLocation() async {
    setState(() {
      _isTrackingMe = true;
      _geoError = 'Locating your live GPS coordinates...';
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _geoError = 'Location services are disabled in your OS.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _geoError = 'Location permissions denied.';
            _isTrackingMe = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _geoError = 'Location permissions permanently denied.';
          _isTrackingMe = false;
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _myLocation = LatLng(position.latitude, position.longitude);
        _geoError = '';
        _mapController.move(_myLocation!, 15.0);
      });
    } catch (err) {
      setState(() {
        _geoError = 'Error obtaining GPS coordinates: $err';
        _isTrackingMe = false;
      });
    }
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
              // Real Road Navigation Controller Header
              MemphisTheme.buildContainer(
                bgColor: MemphisTheme.crispSurface,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.navigation, color: MemphisTheme.secondaryTeal, size: 28),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Real Road Turn-by-Turn GPS Navigator', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                              Text('Powered by OpenStreetMap OSRM driving engine (100% Free)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('🟢 START POINT (A)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: MemphisTheme.warmBackground,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: MemphisTheme.darkText, width: 2),
                                ),
                                child: DropdownButton<Map<String, dynamic>>(
                                  value: _startLoc,
                                  isExpanded: true,
                                  underline: const SizedBox(),
                                  style: const TextStyle(fontWeight: FontWeight.w700, color: MemphisTheme.darkText, fontSize: 13),
                                  onChanged: _isPlaying ? null : (val) {
                                    if (val != null) {
                                      setState(() => _startLoc = val);
                                      _calculateRealRoadPath(val, _endLoc);
                                    }
                                  },
                                  items: _presetLocations.map((loc) => DropdownMenuItem(value: loc, child: Text(loc['name']))).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('🔴 END POINT (B)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: MemphisTheme.warmBackground,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: MemphisTheme.darkText, width: 2),
                                ),
                                child: DropdownButton<Map<String, dynamic>>(
                                  value: _endLoc,
                                  isExpanded: true,
                                  underline: const SizedBox(),
                                  style: const TextStyle(fontWeight: FontWeight.w700, color: MemphisTheme.darkText, fontSize: 13),
                                  onChanged: _isPlaying ? null : (val) {
                                    if (val != null) {
                                      setState(() => _endLoc = val);
                                      _calculateRealRoadPath(_startLoc, val);
                                    }
                                  },
                                  items: _presetLocations.map((loc) => DropdownMenuItem(value: loc, child: Text(loc['name']))).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: MemphisTheme.buildButton(
                            bgColor: _isPlaying ? MemphisTheme.primaryPink : MemphisTheme.secondaryTeal,
                            onPressed: (_isRouteLoading || _roadPath.isEmpty) ? () {} : _handleTogglePlayback,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(_isPlaying ? Icons.stop : Icons.play_arrow, color: MemphisTheme.darkText),
                                const SizedBox(width: 8),
                                Text(_isPlaying ? 'STOP BUS' : 'START BUS MOVEMENT', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          onPressed: (_isRouteLoading || _roadPath.isEmpty) ? null : _handleResetPlayback,
                          style: IconButton.styleFrom(
                            backgroundColor: MemphisTheme.warmBackground,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: MemphisTheme.darkText, width: 3)),
                          ),
                          icon: const Icon(Icons.refresh, color: MemphisTheme.darkText),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Main Active Grid: Map + Bus Details
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    bool isWide = constraints.maxWidth > 800;
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (isWide) ...[
                          // Left sidebar bus list
                          SizedBox(
                            width: 320,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                MemphisTheme.buildContainer(
                                  bgColor: MemphisTheme.accentYellow,
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('ACTIVE FLEET', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                                      Text('${widget.supabaseService.buses.length} BUSES', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                MemphisTheme.buildButton(
                                  bgColor: _isTrackingMe ? MemphisTheme.accentYellow : MemphisTheme.secondaryTeal,
                                  onPressed: _handleTrackMyLocation,
                                  child: const Text('📍 Track My Real Location', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                                ),
                                if (_geoError.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(color: MemphisTheme.primaryPink, borderRadius: BorderRadius.circular(8), border: Border.all(color: MemphisTheme.darkText, width: 2)),
                                    child: Text(_geoError, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                                  ),
                                ],
                                const SizedBox(height: 12),
                                Expanded(
                                  child: ListView.separated(
                                    itemCount: widget.supabaseService.buses.length,
                                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                                    itemBuilder: (context, index) {
                                      final bus = widget.supabaseService.buses[index];
                                      final isSel = _selectedBus?['id'] == bus['id'] && !_isTrackingMe;
                                      Color statCol = bus['status'] == 'Alert' ? MemphisTheme.primaryPink : (bus['status'] == 'Parked' ? MemphisTheme.accentYellow : MemphisTheme.secondaryTeal);

                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _selectedBus = bus;
                                            _isTrackingMe = false;
                                            _mapController.move(LatLng(bus['gps_lat'] as double, bus['gps_lng'] as double), 15.0);
                                          });
                                        },
                                        child: MemphisTheme.buildContainer(
                                          bgColor: isSel ? MemphisTheme.accentYellow : MemphisTheme.warmBackground,
                                          padding: const EdgeInsets.all(12),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(bus['name'], style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                    decoration: BoxDecoration(color: statCol, borderRadius: BorderRadius.circular(8), border: Border.all(color: MemphisTheme.darkText, width: 2)),
                                                    child: Text(bus['status'], style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10)),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Text('Driver: ${bus['driver']}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                                              Text('Speed: ${isSel && _isPlaying ? _simulatedSpeed : bus['speed']} km/h', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
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
                                    initialCenter: _simulatedCoords,
                                    initialZoom: 15.0,
                                  ),
                                  children: [
                                    TileLayer(
                                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                      userAgentPackageName: 'com.busguard.app',
                                    ),
                                    if (_roadPath.isNotEmpty)
                                      PolylineLayer(
                                        polylines: [
                                          Polyline(
                                            points: _roadPath,
                                            color: MemphisTheme.darkText,
                                            strokeWidth: 8.0,
                                          ),
                                          Polyline(
                                            points: _roadPath,
                                            color: MemphisTheme.secondaryTeal,
                                            strokeWidth: 4.0,
                                          ),
                                        ],
                                      ),
                                    MarkerLayer(
                                      markers: [
                                        // Start Marker
                                        Marker(
                                          point: LatLng(_startLoc['lat'] as double, _startLoc['lng'] as double),
                                          width: 32,
                                          height: 32,
                                          child: Container(
                                            decoration: BoxDecoration(color: MemphisTheme.secondaryTeal, shape: BoxShape.circle, border: Border.all(color: MemphisTheme.darkText, width: 3)),
                                            child: const Center(child: Text('A', style: TextStyle(fontWeight: FontWeight.w900, color: MemphisTheme.darkText))),
                                          ),
                                        ),
                                        // End Marker
                                        Marker(
                                          point: LatLng(_endLoc['lat'] as double, _endLoc['lng'] as double),
                                          width: 32,
                                          height: 32,
                                          child: Container(
                                            decoration: BoxDecoration(color: MemphisTheme.primaryPink, shape: BoxShape.circle, border: Border.all(color: MemphisTheme.darkText, width: 3)),
                                            child: const Center(child: Text('B', style: TextStyle(fontWeight: FontWeight.w900, color: MemphisTheme.darkText))),
                                          ),
                                        ),
                                        // Live GPS Tracking Marker
                                        if (_isTrackingMe && _myLocation != null)
                                          Marker(
                                            point: _myLocation!,
                                            width: 140,
                                            height: 45,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8),
                                              decoration: BoxDecoration(color: MemphisTheme.accentYellow, borderRadius: BorderRadius.circular(12), border: Border.all(color: MemphisTheme.darkText, width: 3)),
                                              child: const Center(child: Text('📍 YOUR BUS (GPS)', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12))),
                                            ),
                                          ),
                                        // Active Simulated Bus
                                        if (!_isTrackingMe && _selectedBus != null)
                                          Marker(
                                            point: _simulatedCoords,
                                            width: 50,
                                            height: 50,
                                            child: Container(
                                              decoration: BoxDecoration(color: MemphisTheme.accentYellow, borderRadius: BorderRadius.circular(12), border: Border.all(color: MemphisTheme.darkText, width: 3)),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  const Text('🚀🚌', style: TextStyle(fontSize: 16)),
                                                  Text(_selectedBus!['name'].split(' ')[0], style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 9)),
                                                ],
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                                // Floating Overlay Badge
                                Positioned(
                                  top: 16,
                                  right: 16,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(color: MemphisTheme.crispSurface, borderRadius: BorderRadius.circular(12), border: Border.all(color: MemphisTheme.darkText, width: 3)),
                                    child: const Text('OpenStreetMap Live (Free)', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
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
              const SizedBox(height: 16),

              // Selected Bus Summary Footer Bar
              if (_selectedBus != null && !_isTrackingMe)
                MemphisTheme.buildContainer(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_selectedBus!['name'], style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                            const SizedBox(height: 4),
                            Text('Driver: ${_selectedBus!['driver']} • Speed: ${_isPlaying ? _simulatedSpeed : _selectedBus!['speed']} km/h', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                          ],
                        ),
                      ),
                      MemphisTheme.buildButton(
                        bgColor: MemphisTheme.secondaryTeal,
                        isSmall: true,
                        onPressed: () => widget.onSelectBusForLivePanel(_selectedBus!),
                        child: const Text('OPEN LIVE PANEL', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
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
}
