class MockData {
  static const Map<int, String> busUuids = {
    1: '11111111-1111-1111-1111-111111111111',
    2: '22222222-2222-2222-2222-222222222222',
    3: '33333333-3333-3333-3333-333333333333',
    4: '44444444-4444-4444-4444-444444444444',
    5: '55555555-5555-5555-5555-555555555555',
  };

  static List<Map<String, dynamic>> initialBuses = [
    {
      'id': busUuids[1],
      'name': 'Bus #1 (Yellow Jacket)',
      'driver': 'Arthur Pendelton',
      'status': 'En Route',
      'gps_lat': 33.8938,
      'gps_lng': 35.5018,
      'speed': 42.0,
      'route': 'Route A - North Suburbs',
      'last_seen': DateTime.now().toIso8601String(),
      'bus_count_in_parking': 0,
      'driver_score': 92,
      'capacity': 24,
      'camera_feed': 'https://images.unsplash.com/photo-1557223562-6c77ef16210f?auto=format&fit=crop&w=600&q=80',
    },
    {
      'id': busUuids[2],
      'name': 'Bus #2 (Falcon Express)',
      'driver': 'Sarah Jenkins',
      'status': 'Alert',
      'gps_lat': 33.8885,
      'gps_lng': 35.4955,
      'speed': 55.0,
      'route': 'Route B - Downtown Loop',
      'last_seen': DateTime.now().toIso8601String(),
      'bus_count_in_parking': 0,
      'driver_score': 85,
      'capacity': 30,
      'camera_feed': 'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?auto=format&fit=crop&w=600&q=80',
    },
    {
      'id': busUuids[3],
      'name': 'Bus #3 (Bluebird Defender)',
      'driver': 'Marcus Vance',
      'status': 'Parked',
      'gps_lat': 33.8820,
      'gps_lng': 35.5120,
      'speed': 0.0,
      'route': 'Route C - West Hills',
      'last_seen': DateTime.now().toIso8601String(),
      'bus_count_in_parking': 1,
      'driver_score': 78,
      'capacity': 20,
      'camera_feed': 'https://images.unsplash.com/photo-1570125909232-eb263c188f7e?auto=format&fit=crop&w=600&q=80',
    },
    {
      'id': busUuids[4],
      'name': 'Bus #4 (Grizzly Cruiser)',
      'driver': 'David Chen',
      'status': 'Idle',
      'gps_lat': 33.8910,
      'gps_lng': 35.5230,
      'speed': 0.0,
      'route': 'Route D - Pine Valley',
      'last_seen': DateTime.now().toIso8601String(),
      'bus_count_in_parking': 1,
      'driver_score': 95,
      'capacity': 28,
      'camera_feed': 'https://images.unsplash.com/photo-1509062522246-3755977927d7?auto=format&fit=crop&w=600&q=80',
    },
    {
      'id': busUuids[5],
      'name': 'Bus #5 (Thunderbird)',
      'driver': 'Elena Rostova',
      'status': 'En Route',
      'gps_lat': 33.9001,
      'gps_lng': 35.4890,
      'speed': 38.0,
      'route': 'Route E - Coastal Way',
      'last_seen': DateTime.now().toIso8601String(),
      'bus_count_in_parking': 0,
      'driver_score': 89,
      'capacity': 24,
      'camera_feed': 'https://images.unsplash.com/photo-1616401784845-180882ba9ba8?auto=format&fit=crop&w=600&q=80',
    }
  ];

  static List<Map<String, dynamic>> initialChecklists = [
    {
      'id': 'c1111111-1111-1111-1111-111111111111',
      'bus_id': busUuids[1],
      'front_clear': true,
      'rear_clear': true,
      'all_seated': false,
      'door_closed': true,
      'seatbelt_on': true,
      'tire_ok': true,
      'clear_to_move': false,
      'updated_at': DateTime.now().toIso8601String(),
    },
    {
      'id': 'c2222222-2222-2222-2222-222222222222',
      'bus_id': busUuids[2],
      'front_clear': true,
      'rear_clear': true,
      'all_seated': true,
      'door_closed': true,
      'seatbelt_on': false,
      'tire_ok': true,
      'clear_to_move': false,
      'updated_at': DateTime.now().toIso8601String(),
    },
    {
      'id': 'c3333333-3333-3333-3333-333333333333',
      'bus_id': busUuids[3],
      'front_clear': true,
      'rear_clear': false,
      'all_seated': true,
      'door_closed': false,
      'seatbelt_on': true,
      'tire_ok': true,
      'clear_to_move': false,
      'updated_at': DateTime.now().toIso8601String(),
    },
    {
      'id': 'c4444444-4444-4444-4444-444444444444',
      'bus_id': busUuids[4],
      'front_clear': true,
      'rear_clear': true,
      'all_seated': true,
      'door_closed': true,
      'seatbelt_on': true,
      'tire_ok': false,
      'clear_to_move': false,
      'updated_at': DateTime.now().toIso8601String(),
    },
    {
      'id': 'c5555555-5555-5555-5555-555555555555',
      'bus_id': busUuids[5],
      'front_clear': false,
      'rear_clear': true,
      'all_seated': true,
      'door_closed': true,
      'seatbelt_on': true,
      'tire_ok': true,
      'clear_to_move': false,
      'updated_at': DateTime.now().toIso8601String(),
    }
  ];

  static List<Map<String, dynamic>> initialAlerts = [
    {
      'id': 'a1111111-1111-1111-1111-111111111111',
      'bus_id': busUuids[3],
      'type': 'CHILD LEFT BEHIND',
      'severity': 'high',
      'message': 'Child detected in rear row 10 minutes after route completed.',
      'snapshot_url': 'https://images.unsplash.com/photo-1503454537195-1dcabb73ffb9?auto=format&fit=crop&w=500&q=80',
      'acknowledged': false,
      'created_at': DateTime.now().toIso8601String(),
      'timestamp': '08:32'
    },
    {
      'id': 'a2222222-2222-2222-2222-222222222222',
      'bus_id': busUuids[2],
      'type': 'PHONE USAGE BY DRIVER',
      'severity': 'high',
      'message': 'AI detected smartphone in driver\'s hand while vehicle moving at 55 km/h.',
      'snapshot_url': 'https://images.unsplash.com/photo-1528659103991-ec12a9e3d935?auto=format&fit=crop&w=500&q=80',
      'acknowledged': false,
      'created_at': DateTime.now().toIso8601String(),
      'timestamp': '08:29'
    },
    {
      'id': 'a3333333-3333-3333-3333-333333333333',
      'bus_id': busUuids[1],
      'type': 'PASSENGER STANDING',
      'severity': 'medium',
      'message': 'Passenger in Seat 8 standing while bus is in motion.',
      'snapshot_url': 'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?auto=format&fit=crop&w=500&q=80',
      'acknowledged': true,
      'created_at': DateTime.now().toIso8601String(),
      'timestamp': '08:25'
    },
    {
      'id': 'a4444444-4444-4444-4444-444444444444',
      'bus_id': busUuids[4],
      'type': 'FLAT TIRE',
      'severity': 'high',
      'message': 'Rear left tire pressure drop detected by edge vision and TPMS sensors.',
      'snapshot_url': 'https://images.unsplash.com/photo-1580273916550-e323be2ae537?auto=format&fit=crop&w=500&q=80',
      'acknowledged': false,
      'created_at': DateTime.now().toIso8601String(),
      'timestamp': '08:15'
    },
    {
      'id': 'a5555555-5555-5555-5555-555555555555',
      'bus_id': busUuids[5],
      'type': 'PERSON IN BLIND SPOT',
      'severity': 'high',
      'message': 'Pedestrian detected 1.2m in front of front bumper blind spot.',
      'snapshot_url': 'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=500&q=80',
      'acknowledged': true,
      'created_at': DateTime.now().toIso8601String(),
      'timestamp': '08:10'
    }
  ];

  static List<Map<String, dynamic>> generateInitialSeats() {
    List<Map<String, dynamic>> list = [];
    // Bus 1 (24 seats)
    for (int i = 1; i <= 24; i++) {
      list.add({
        'id': 's1000000-0000-0000-0000-${i.toString().padLeft(12, '0')}',
        'bus_id': busUuids[1],
        'seat_number': i,
        'occupied': i < 18,
        'seatbelt_on': i < 15,
        'updated_at': DateTime.now().toIso8601String()
      });
    }
    // Bus 2 (30 seats)
    for (int i = 1; i <= 30; i++) {
      list.add({
        'id': 's2000000-0000-0000-0000-${i.toString().padLeft(12, '0')}',
        'bus_id': busUuids[2],
        'seat_number': i,
        'occupied': i < 25,
        'seatbelt_on': i < 20,
        'updated_at': DateTime.now().toIso8601String()
      });
    }
    // Bus 3 (20 seats)
    for (int i = 1; i <= 20; i++) {
      list.add({
        'id': 's3000000-0000-0000-0000-${i.toString().padLeft(12, '0')}',
        'bus_id': busUuids[3],
        'seat_number': i,
        'occupied': i == 18, // child left behind
        'seatbelt_on': false,
        'updated_at': DateTime.now().toIso8601String()
      });
    }
    // Bus 4 (28 seats)
    for (int i = 1; i <= 28; i++) {
      list.add({
        'id': 's4000000-0000-0000-0000-${i.toString().padLeft(12, '0')}',
        'bus_id': busUuids[4],
        'seat_number': i,
        'occupied': i < 10,
        'seatbelt_on': i < 10,
        'updated_at': DateTime.now().toIso8601String()
      });
    }
    // Bus 5 (24 seats)
    for (int i = 1; i <= 24; i++) {
      list.add({
        'id': 's5000000-0000-0000-0000-${i.toString().padLeft(12, '0')}',
        'bus_id': busUuids[5],
        'seat_number': i,
        'occupied': i < 22,
        'seatbelt_on': i < 21,
        'updated_at': DateTime.now().toIso8601String()
      });
    }
    return list;
  }

  static List<Map<String, dynamic>> initialTrips = [
    {
      'id': 't1111111-1111-1111-1111-111111111111',
      'bus_id': busUuids[1],
      'start_time': '07:00 AM',
      'end_time': '08:15 AM',
      'headcount': 18,
      'capacity': 24,
      'driver_score': 92,
      'incidents': 2,
      'route_name': 'Route A - North Suburbs',
      'created_at': DateTime.now().toIso8601String()
    },
    {
      'id': 't2222222-2222-2222-2222-222222222222',
      'bus_id': busUuids[2],
      'start_time': '07:15 AM',
      'end_time': '08:30 AM',
      'headcount': 25,
      'capacity': 30,
      'driver_score': 85,
      'incidents': 4,
      'route_name': 'Route B - Downtown Loop',
      'created_at': DateTime.now().toIso8601String()
    },
    {
      'id': 't3333333-3333-3333-3333-333333333333',
      'bus_id': busUuids[3],
      'start_time': '06:45 AM',
      'end_time': '08:10 AM',
      'headcount': 19,
      'capacity': 20,
      'driver_score': 78,
      'incidents': 5,
      'route_name': 'Route C - West Hills',
      'created_at': DateTime.now().toIso8601String()
    },
    {
      'id': 't4444444-4444-4444-4444-444444444444',
      'bus_id': busUuids[4],
      'start_time': '07:30 AM',
      'end_time': '08:20 AM',
      'headcount': 10,
      'capacity': 28,
      'driver_score': 95,
      'incidents': 1,
      'route_name': 'Route D - Pine Valley',
      'created_at': DateTime.now().toIso8601String()
    },
    {
      'id': 't5555555-5555-5555-5555-555555555555',
      'bus_id': busUuids[5],
      'start_time': '07:10 AM',
      'end_time': '08:25 AM',
      'headcount': 22,
      'capacity': 24,
      'driver_score': 89,
      'incidents': 2,
      'route_name': 'Route E - Coastal Way',
      'created_at': DateTime.now().toIso8601String()
    }
  ];

  static List<Map<String, dynamic>> initialParking = [
    { 'id': 'p1111111-1111-1111-1111-111111111111', 'bus_id': busUuids[3], 'entered_at': '08:12 AM', 'exited_at': null, 'status': 'Parked' },
    { 'id': 'p2222222-2222-2222-2222-222222222222', 'bus_id': busUuids[4], 'entered_at': '08:22 AM', 'exited_at': null, 'status': 'Idle' },
    { 'id': 'p3333333-3333-3333-3333-333333333333', 'bus_id': busUuids[1], 'entered_at': '06:30 AM', 'exited_at': '07:00 AM', 'status': 'En Route' },
    { 'id': 'p4444444-4444-4444-4444-444444444444', 'bus_id': busUuids[2], 'entered_at': '06:45 AM', 'exited_at': '07:15 AM', 'status': 'Alert' },
    { 'id': 'p5555555-5555-5555-5555-555555555555', 'bus_id': busUuids[5], 'entered_at': '06:50 AM', 'exited_at': '07:10 AM', 'status': 'En Route' }
  ];

  static List<Map<String, dynamic>> aiAlertTypesPool = [
    { 'type': 'CHILD LEFT BEHIND', 'severity': 'high', 'desc': 'Child detected asleep in rear seat after engine shutoff.' },
    { 'type': 'PASSENGER STANDING', 'severity': 'medium', 'desc': 'Multiple students standing in aisle while bus speed > 20 km/h.' },
    { 'type': 'PHONE USAGE BY DRIVER', 'severity': 'high', 'desc': 'Driver detected looking at phone screen for > 3 seconds.' },
    { 'type': 'DRIVER SEATBELT OFF', 'severity': 'medium', 'desc': 'Driver unbuckled while transmission in Drive.' },
    { 'type': 'CHILD HAND HANGING OUT WINDOW', 'severity': 'high', 'desc': 'Child arm/head extended past window plane on left side.' },
    { 'type': 'PERSON IN BLIND SPOT', 'severity': 'high', 'desc': 'Pedestrian standing within 1 meter of front right blind spot.' },
    { 'type': 'CAR/MOTORCYCLE CLOSE DISTANCE', 'severity': 'low', 'desc': 'Motorcycle tailgating at 0.8 meters distance.' },
    { 'type': 'SPEEDING DETECTION', 'severity': 'medium', 'desc': 'Vehicle traveling at 48 km/h in a 30 km/h active school zone.' },
    { 'type': 'PERSON TOO CLOSE TO DOOR', 'severity': 'high', 'desc': 'Student detected within pinch radius while doors closing.' },
    { 'type': 'MANIFEST MISMATCH', 'severity': 'medium', 'desc': 'Children boarding count (15) does not match digital roster (16).' },
    { 'type': 'FLAT TIRE', 'severity': 'high', 'desc': 'Rapid pressure drop in tire #4 detected.' },
  ];
}
