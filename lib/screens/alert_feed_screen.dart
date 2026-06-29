import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../theme/memphis_theme.dart';

class AlertFeedScreen extends StatefulWidget {
  final SupabaseService supabaseService;

  const AlertFeedScreen({super.key, required this.supabaseService});

  @override
  State<AlertFeedScreen> createState() => _AlertFeedFeedScreenState();
}

class _AlertFeedFeedScreenState extends State<AlertFeedScreen> {
  String _filterBusId = 'ALL';
  String _filterType = 'ALL';
  String _filterSeverity = 'ALL';
  String _filterStatus = 'ACTIVE'; // ACTIVE, ACKNOWLEDGED, ALL

  Map<String, dynamic>? _selectedSnapshot;

  void _showSnapshotModal(Map<String, dynamic> alert, String headline) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: MemphisTheme.darkText, width: 3)),
        child: MemphisTheme.buildContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(headline, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16))),
                  IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close, size: 24)),
                ],
              ),
              const Divider(color: MemphisTheme.darkText, thickness: 3),
              const SizedBox(height: 12),
              Text(alert['message'] ?? alert['description'] ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              Container(
                height: 240,
                decoration: BoxDecoration(color: MemphisTheme.darkText, borderRadius: BorderRadius.circular(16), border: Border.all(color: MemphisTheme.darkText, width: 3)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(alert['snapshot_url'] ?? 'https://images.unsplash.com/photo-1503454537195-1dcabb73ffb9?auto=format&fit=crop&w=500&q=80', fit: BoxFit.cover),
                    Positioned(
                      top: 12, left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: MemphisTheme.darkText.withOpacity(0.85), borderRadius: BorderRadius.circular(8), border: Border.all(color: MemphisTheme.accentYellow, width: 2)),
                        child: const Text('AI EVIDENCE STORAGE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: MemphisTheme.accentYellow)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              MemphisTheme.buildButton(
                bgColor: MemphisTheme.secondaryTeal,
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('CLOSE SNAPSHOT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final typesSet = widget.supabaseService.alerts.map((a) => a['type'].toString()).toSet().toList();
    
    final filteredAlerts = widget.supabaseService.alerts.where((alert) {
      if (_filterBusId != 'ALL' && alert['bus_id'].toString() != _filterBusId) return false;
      if (_filterType != 'ALL' && alert['type'].toString() != _filterType) return false;
      if (_filterSeverity != 'ALL' && alert['severity']?.toString().toLowerCase() != _filterSeverity.toLowerCase()) return false;
      if (_filterStatus == 'ACTIVE' && (alert['acknowledged'] as bool)) return false;
      if (_filterStatus == 'ACKNOWLEDGED' && !(alert['acknowledged'] as bool)) return false;
      return true;
    }).toList();

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
                    const Row(
                      children: [
                        Icon(Icons.notifications_active, color: MemphisTheme.primaryPink, size: 28),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Real-Time AI Alert Feed', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                              Text('Supabase Realtime Telemetry & Snapshot Logs', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (_filterStatus == 'ACTIVE' && filteredAlerts.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      MemphisTheme.buildButton(
                        bgColor: MemphisTheme.secondaryTeal,
                        onPressed: () => widget.supabaseService.acknowledgeAllAlerts(),
                        child: Text('Acknowledge All Active (${filteredAlerts.length})', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Filter Dropdowns Bar
              MemphisTheme.buildContainer(
                bgColor: MemphisTheme.crispSurface,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('FILTERS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                    const SizedBox(height: 12),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        bool isWide = constraints.maxWidth > 600;
                        return Flex(
                          direction: isWide ? Axis.horizontal : Axis.vertical,
                          children: [
                            _buildDrop('BUS FILTER', _filterBusId, [DropdownMenuItem(value: 'ALL', child: const Text('All Buses')), ...widget.supabaseService.buses.map((b) => DropdownMenuItem(value: b['id'].toString(), child: Text(b['name'])))], (val) => setState(() => _filterBusId = val!), isWide),
                            SizedBox(height: isWide ? 0 : 12, width: isWide ? 12 : 0),
                            _buildDrop('ALERT TYPE', _filterType, [DropdownMenuItem(value: 'ALL', child: const Text('All Types')), ...typesSet.map((t) => DropdownMenuItem(value: t, child: Text(t)))], (val) => setState(() => _filterType = val!), isWide),
                            SizedBox(height: isWide ? 0 : 12, width: isWide ? 12 : 0),
                            _buildDrop('SEVERITY', _filterSeverity, [DropdownMenuItem(value: 'ALL', child: const Text('All Severities')), DropdownMenuItem(value: 'high', child: const Text('High')), DropdownMenuItem(value: 'medium', child: const Text('Medium')), DropdownMenuItem(value: 'low', child: const Text('Low'))], (val) => setState(() => _filterSeverity = val!), isWide),
                            SizedBox(height: isWide ? 0 : 12, width: isWide ? 12 : 0),
                            _buildDrop('STATUS', _filterStatus, [DropdownMenuItem(value: 'ACTIVE', child: const Text('Unacknowledged (Active)')), DropdownMenuItem(value: 'ACKNOWLEDGED', child: const Text('Acknowledged (Resolved)')), DropdownMenuItem(value: 'ALL', child: const Text('All Alerts'))], (val) => setState(() => _filterStatus = val!), isWide),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Alerts Feed List
              if (filteredAlerts.isEmpty)
                MemphisTheme.buildContainer(
                  padding: const EdgeInsets.all(32),
                  child: const Center(
                    child: Column(
                      children: [
                        Icon(Icons.check_circle, color: MemphisTheme.secondaryTeal, size: 64),
                        SizedBox(height: 12),
                        Text('NO ALERTS FOUND', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
                        SizedBox(height: 4),
                        Text('You\'re fully caught up! All detections matching your filter criteria have been acknowledged or resolved.', textAlign: TextAlign.center, style: TextStyle(fontSize: 13)),
                      ],
                    ),
                  ),
                )
              else
                Column(
                  children: filteredAlerts.map((alert) {
                    final bus = widget.supabaseService.buses.firstWhere((b) => b['id'].toString() == alert['bus_id'].toString(), orElse: () => { 'name': 'Bus #${alert['bus_id']}' });
                    final headline = '[${alert['timestamp'] ?? 'Live'}] ${bus['name'].split(' ')[0]} — ${alert['type']} detected';

                    Color sevCol = alert['severity']?.toString().toLowerCase() == 'high' ? MemphisTheme.primaryPink : (alert['severity']?.toString().toLowerCase() == 'low' ? MemphisTheme.secondaryTeal : MemphisTheme.accentYellow);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: (alert['acknowledged'] as bool) ? MemphisTheme.warmBackground : MemphisTheme.crispSurface, borderRadius: BorderRadius.circular(16), border: Border.all(color: MemphisTheme.darkText, width: 3), boxShadow: MemphisTheme.memphisShadow),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: sevCol, borderRadius: BorderRadius.circular(8), border: Border.all(color: MemphisTheme.darkText, width: 2)),
                                child: Text('${alert['severity'] ?? 'Medium'} SEVERITY'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
                              ),
                              const SizedBox(width: 12),
                              if (alert['acknowledged'] as bool)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(color: MemphisTheme.secondaryTeal, borderRadius: BorderRadius.circular(8), border: Border.all(color: MemphisTheme.darkText, width: 2)),
                                  child: const Text('✅ ACKNOWLEDGED', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(headline, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text(alert['message'] ?? alert['description'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            alignment: WrapAlignment.end,
                            children: [
                              MemphisTheme.buildButton(
                                bgColor: MemphisTheme.accentYellow,
                                isSmall: true,
                                onPressed: () => _showSnapshotModal(alert, headline),
                                child: const Text('🖼️ View Snapshot', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                              ),
                              if (!(alert['acknowledged'] as bool))
                                MemphisTheme.buildButton(
                                  bgColor: MemphisTheme.secondaryTeal,
                                  isSmall: true,
                                  onPressed: () => widget.supabaseService.acknowledgeAlert(alert['id'].toString()),
                                  child: const Text('✅ Acknowledge', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrop(String title, String val, List<DropdownMenuItem<String>> items, Function(String?) onChanged, bool isWide) {
    Widget field = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: MemphisTheme.warmBackground, borderRadius: BorderRadius.circular(12), border: Border.all(color: MemphisTheme.darkText, width: 3)),
          child: DropdownButton<String>(
            value: val,
            isExpanded: true,
            underline: const SizedBox(),
            style: const TextStyle(fontWeight: FontWeight.w800, color: MemphisTheme.darkText, fontSize: 13),
            onChanged: onChanged,
            items: items,
          ),
        ),
      ],
    );
    return isWide ? Expanded(child: field) : field;
  }
}
