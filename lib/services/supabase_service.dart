import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'mock_data.dart';

class SupabaseService extends ChangeNotifier {
  static const String defaultUrl = 'https://vobjjnoqukepgftorvgk.supabase.co';
  static const String defaultKey = 'sb_publishable_6CgfTsVH7cFZcYNZMft-MA_J-kFbIop';

  String _supabaseUrl = defaultUrl;
  String _supabaseKey = defaultKey;
  bool _simulationMode = false;

  List<Map<String, dynamic>> buses = List.from(MockData.initialBuses);
  List<Map<String, dynamic>> checklists = List.from(MockData.initialChecklists);
  List<Map<String, dynamic>> alerts = List.from(MockData.initialAlerts);
  List<Map<String, dynamic>> seats = MockData.generateInitialSeats();
  List<Map<String, dynamic>> trips = List.from(MockData.initialTrips);
  List<Map<String, dynamic>> parking = List.from(MockData.initialParking);

  final StreamController<Map<String, dynamic>> _alertStreamController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get alertStream => _alertStreamController.stream;

  Timer? _simTimer;
  SupabaseClient? _client;

  String get supabaseUrl => _supabaseUrl;
  String get supabaseKey => _supabaseKey;
  bool get simulationMode => _simulationMode;

  SupabaseService() {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _supabaseUrl = prefs.getString('SUPABASE_URL') ?? defaultUrl;
    _supabaseKey = prefs.getString('SUPABASE_ANON_KEY') ?? defaultKey;
    _simulationMode = prefs.getBool('SIMULATION_MODE') ?? false;

    await _initSupabaseClient();
    _startSimulation();
  }

  Future<void> saveConfig(String url, String key, bool simMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('SUPABASE_URL', url);
    await prefs.setString('SUPABASE_ANON_KEY', key);
    await prefs.setBool('SIMULATION_MODE', simMode);

    _supabaseUrl = url;
    _supabaseKey = key;
    _simulationMode = simMode;

    await _initSupabaseClient();
    _startSimulation();
    notifyListeners();
  }

  Future<void> _initSupabaseClient() async {
    try {
      if (_supabaseUrl.isNotEmpty && _supabaseKey.isNotEmpty) {
        // Initialize Supabase if not already done
        await Supabase.initialize(url: _supabaseUrl, anonKey: _supabaseKey);
        _client = Supabase.instance.client;
        await _fetchInitialSupabaseData();
        _setupRealtimeSubscriptions();
      }
    } catch (err) {
      debugPrint('Supabase init error: $err');
    }
  }

  Future<void> _fetchInitialSupabaseData() async {
    if (_client == null) return;
    try {
      final bData = await _client!.from('buses').select().order('created_at', ascending: true);
      if (bData.isNotEmpty) buses = List<Map<String, dynamic>>.from(bData);

      final cData = await _client!.from('checklist').select();
      if (cData.isNotEmpty) checklists = List<Map<String, dynamic>>.from(cData);

      final aData = await _client!.from('alerts').select().order('created_at', ascending: false);
      if (aData.isNotEmpty) alerts = List<Map<String, dynamic>>.from(aData);

      final sData = await _client!.from('seats').select().order('seat_number', ascending: true);
      if (sData.isNotEmpty) seats = List<Map<String, dynamic>>.from(sData);

      final tData = await _client!.from('trips').select().order('created_at', ascending: false);
      if (tData.isNotEmpty) trips = List<Map<String, dynamic>>.from(tData);

      final pData = await _client!.from('parking').select();
      if (pData.isNotEmpty) parking = List<Map<String, dynamic>>.from(pData);

      notifyListeners();
    } catch (err) {
      debugPrint('Error fetching Supabase data: $err');
    }
  }

  void _setupRealtimeSubscriptions() {
    if (_client == null) return;
    try {
      _client!
        .channel('bus-safety-flutter')
        .on(
          RealtimeListenTypes.postgresChanges,
          ChannelFilter(event: '*', schema: 'public', table: 'alerts'),
          (payload, [ref]) {
            if (payload['eventType'] == 'INSERT') {
              final newAlert = Map<String, dynamic>.from(payload['new']);
              alerts.insert(0, newAlert);
              _alertStreamController.add(newAlert);
              notifyListeners();
            } else if (payload['eventType'] == 'UPDATE') {
              final updated = Map<String, dynamic>.from(payload['new']);
              final idx = alerts.indexWhere((a) => a['id'] == updated['id']);
              if (idx != -1) alerts[idx] = updated;
              notifyListeners();
            }
          },
        )
        .on(
          RealtimeListenTypes.postgresChanges,
          ChannelFilter(event: '*', schema: 'public', table: 'buses'),
          (payload, [ref]) {
            if (payload['eventType'] == 'UPDATE') {
              final updated = Map<String, dynamic>.from(payload['new']);
              final idx = buses.indexWhere((b) => b['id'] == updated['id']);
              if (idx != -1) buses[idx] = updated;
              notifyListeners();
            }
          },
        )
        .subscribe();
    } catch (err) {
      debugPrint('Realtime sub error: $err');
    }
  }

  Future<void> acknowledgeAlert(String id) async {
    final idx = alerts.indexWhere((a) => a['id'] == id);
    if (idx != -1) {
      alerts[idx]['acknowledged'] = true;
      notifyListeners();
    }
    if (_client != null) {
      try {
        await _client!.from('alerts').update({'acknowledged': true}).eq('id', id);
      } catch (err) {
        debugPrint('Ack error: $err');
      }
    }
  }

  Future<void> acknowledgeAllAlerts() async {
    for (var a in alerts) {
      a['acknowledged'] = true;
    }
    notifyListeners();
    if (_client != null) {
      try {
        await _client!.from('alerts').update({'acknowledged': true}).eq('acknowledged', false);
      } catch (err) {
        debugPrint('Ack All error: $err');
      }
    }
  }

  Future<void> updateBusTelemetry(String busId, double lat, double lng, double speed) async {
    final idx = buses.indexWhere((b) => b['id'] == busId);
    if (idx != -1) {
      buses[idx]['gps_lat'] = lat;
      buses[idx]['gps_lng'] = lng;
      buses[idx]['speed'] = speed;
      notifyListeners();
    }
    if (_client != null) {
      try {
        await _client!.from('buses').update({
          'gps_lat': lat,
          'gps_lng': lng,
          'speed': speed,
          'last_seen': DateTime.now().toIso8601String()
        }).eq('id', busId);
      } catch (err) {
        debugPrint('Sync telemetry error: $err');
      }
    }
  }

  Future<void> triggerRandomAlert() async {
    final randomAI = MockData.aiAlertTypesPool[Random().nextInt(MockData.aiAlertTypesPool.length)];
    final randomBus = buses[Random().nextInt(buses.length)];
    final timestamp = "${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}";

    final snapshotPool = [
      "https://images.unsplash.com/photo-1503454537195-1dcabb73ffb9?auto=format&fit=crop&w=500&q=80",
      "https://images.unsplash.com/photo-1528659103991-ec12a9e3d935?auto=format&fit=crop&w=500&q=80",
      "https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?auto=format&fit=crop&w=500&q=80",
      "https://images.unsplash.com/photo-1580273916550-e323be2ae537?auto=format&fit=crop&w=500&q=80",
      "https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=500&q=80",
      "https://images.unsplash.com/photo-1509062522246-3755977927d7?auto=format&fit=crop&w=500&q=80",
    ];

    final alertData = {
      'bus_id': randomBus['id'],
      'type': randomAI['type'],
      'severity': randomAI['severity'],
      'message': randomAI['desc'],
      'snapshot_url': snapshotPool[Random().nextInt(snapshotPool.length)],
      'acknowledged': false,
    };

    if (_client != null) {
      try {
        final data = await _client!.from('alerts').insert(alertData).select();
        if (data.isNotEmpty) {
          final inserted = Map<String, dynamic>.from(data[0]);
          inserted['timestamp'] = timestamp;
          alerts.insert(0, inserted);
          _alertStreamController.add(inserted);
          notifyListeners();
          return;
        }
      } catch (err) {
        debugPrint('Insert alert error: $err');
      }
    }

    // Local fallback
    final mockAlert = Map<String, dynamic>.from(alertData);
    mockAlert['id'] = 'a-mock-${DateTime.now().millisecondsSinceEpoch}';
    mockAlert['timestamp'] = timestamp;
    alerts.insert(0, mockAlert);
    _alertStreamController.add(mockAlert);
    notifyListeners();
  }

  Future<Map<String, dynamic>> seedSupabaseDatabase() async {
    if (_client == null) return {'success': false, 'message': 'No Supabase client configured.'};

    try {
      // Check existing buses
      final existing = await _client!.from('buses').select('id').limit(1);
      if (existing.isNotEmpty) {
        return {'success': true, 'message': 'Database is already seeded with buses.'};
      }

      // Insert Buses
      await _client!.from('buses').insert(MockData.initialBuses);
      // Insert Checklists
      await _client!.from('checklist').insert(MockData.initialChecklists);
      // Insert Alerts
      await _client!.from('alerts').insert(MockData.initialAlerts);
      
      // Insert Seats in batches
      final seatsList = MockData.generateInitialSeats();
      for (int i = 0; i < seatsList.length; i += 50) {
        final end = (i + 50 < seatsList.length) ? i + 50 : seatsList.length;
        await _client!.from('seats').insert(seatsList.sublist(i, end));
      }

      // Insert Trips
      await _client!.from('trips').insert(MockData.initialTrips);
      // Insert Parking
      await _client!.from('parking').insert(MockData.initialParking);

      await _fetchInitialSupabaseData();
      return {'success': true, 'message': 'Successfully seeded all tables in your Supabase database!'};
    } catch (err) {
      debugPrint('Seed DB error: $err');
      return {'success': false, 'message': 'Error seeding database: $err'};
    }
  }

  void _startSimulation() {
    _simTimer?.cancel();
    _simTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (!_simulationMode) return;
      if (Random().nextDouble() < 0.15) {
        triggerRandomAlert();
      }
    });
  }

  // HTTP Helpers for OSRM Free Routing Engines
  Future<List<List<double>>> fetchRealRoadPath(Map<String, dynamic> start, Map<String, dynamic> end) async {
    try {
      final response = await http.get(Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/${start['lng']},${start['lat']};${end['lng']},${end['lat']}?overview=full&geometries=geojson'
      ));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == 'Ok' && data['routes'].isNotEmpty) {
          final coords = data['routes'][0]['geometry']['coordinates'] as List;
          return coords.map((c) => [c[1] as double, c[0] as double]).toList();
        }
      }
    } catch (err) {
      debugPrint('OSRM fetch error: $err');
    }
    return [];
  }

  Future<Map<String, dynamic>?> calculateTSPRoute(List<Map<String, dynamic>> points) async {
    if (points.isEmpty) return null;
    try {
      final coordString = points.map((p) => "${p['lng']},${p['lat']}").join(';');
      final response = await http.get(Uri.parse(
        'https://router.project-osrm.org/trip/v1/driving/$coordString?roundtrip=true&source=first&overview=full&geometries=geojson'
      ));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == 'Ok' && data['trips'].isNotEmpty) {
          final trip = data['trips'][0];
          final coords = trip['geometry']['coordinates'] as List;
          final latLngs = coords.map((c) => [c[1] as double, c[0] as double]).toList();

          final waypoints = data['waypoints'] as List;
          List<Map<String, dynamic>> optimized = [];
          for (int i = 0; i < points.length; i++) {
            optimized.add({
              ...points[i],
              'optimalSequenceIndex': waypoints[i]['waypoint_index'],
            });
          }
          optimized.sort((a, b) => (a['optimalSequenceIndex'] as int).compareTo(b['optimalSequenceIndex'] as int));

          return {
            'path': latLngs,
            'distanceKm': ((trip['distance'] as num) / 1000).toStringAsFixed(1),
            'durationMins': ((trip['duration'] as num) / 60).round(),
            'optimizedOrder': optimized.where((w) => w['id'] != points[0]['id']).toList(),
          };
        }
      }
    } catch (err) {
      debugPrint('TSP fetch error: $err');
    }
    return null;
  }
}
