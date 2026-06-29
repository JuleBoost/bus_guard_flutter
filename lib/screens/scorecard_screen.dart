import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/supabase_service.dart';
import '../theme/memphis_theme.dart';

class ScorecardScreen extends StatefulWidget {
  final SupabaseService supabaseService;

  const ScorecardScreen({super.key, required this.supabaseService});

  @override
  State<ScorecardScreen> createState() => _ScorecardScreenState();
}

class _ScorecardScreenState extends State<ScorecardScreen> {
  late Map<String, dynamic> _currentBus;

  @override
  void initState() {
    super.initState();
    _currentBus = widget.supabaseService.buses.isNotEmpty ? widget.supabaseService.buses[0] : {
      'id': '11111111-1111-1111-1111-111111111111',
      'driver': 'Arthur Pendelton',
      'name': 'Bus #1',
      'driver_score': 92
    };
  }

  @override
  Widget build(BuildContext context) {
    int score = _currentBus['driver_score'] ?? 92;
    Color scoreCol = score >= 90 ? MemphisTheme.secondaryTeal : (score >= 80 ? MemphisTheme.accentYellow : MemphisTheme.primaryPink);
    String standing = score >= 90 ? '🏆 EXCELLENT STANDING' : (score >= 80 ? '⚠️ SATISFACTORY' : '⛔ NEEDS REVIEW');

    // Multi-week trend simulation
    List<FlSpot> spots = [
      const FlSpot(1, 90),
      const FlSpot(2, 91),
      const FlSpot(3, 94),
      FlSpot(4, score.toDouble()),
    ];

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Banner Selector
              MemphisTheme.buildContainer(
                bgColor: MemphisTheme.crispSurface,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.military_tech, color: MemphisTheme.accentYellow, size: 28),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Driver Scorecard Dashboard', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                              Text('Performance Rating out of 100 & Multi-Week Historical Trend', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('SELECT DRIVER', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(color: MemphisTheme.primaryPink, borderRadius: BorderRadius.circular(12), border: Border.all(color: MemphisTheme.darkText, width: 3)),
                      child: DropdownButton<Map<String, dynamic>>(
                        value: widget.supabaseService.buses.firstWhere((b) => b['id'] == _currentBus['id'], orElse: () => _currentBus),
                        isExpanded: true,
                        underline: const SizedBox(),
                        style: const TextStyle(fontWeight: FontWeight.w800, color: MemphisTheme.darkText, fontSize: 13),
                        onChanged: (val) { if (val != null) setState(() => _currentBus = val); },
                        items: widget.supabaseService.buses.map((b) => DropdownMenuItem(value: b, child: Text('${b['driver'] ?? 'Driver'} (${b['name'].split(' ')[0]})'))).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Main Active Summary
              LayoutBuilder(
                builder: (context, constraints) {
                  bool isWide = constraints.maxWidth > 800;
                  Widget leftCol = MemphisTheme.buildContainer(
                    bgColor: MemphisTheme.crispSurface,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: MemphisTheme.warmBackground, borderRadius: BorderRadius.circular(12), border: Border.all(color: MemphisTheme.darkText, width: 2)),
                              child: const Icon(Icons.person, size: 28),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_currentBus['driver'] ?? 'Assigned Driver', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                                  Text('Assigned: ${_currentBus['name']}', style: const TextStyle(fontSize: 11)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(color: MemphisTheme.warmBackground, borderRadius: BorderRadius.circular(16), border: Border.all(color: MemphisTheme.darkText, width: 3)),
                          child: Column(
                            children: [
                              const Text('OVERALL SAFETY SCORE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text('$score', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 48)),
                                  const Text('/100', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(color: scoreCol, borderRadius: BorderRadius.circular(12), border: Border.all(color: MemphisTheme.darkText, width: 2)),
                                child: Text(standing, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildInfractionItem('Phone Usage Infractions', '0 this week', MemphisTheme.secondaryTeal),
                        const SizedBox(height: 8),
                        _buildInfractionItem('Speeding Alerts', '1 logged', MemphisTheme.primaryPink),
                        const SizedBox(height: 8),
                        _buildInfractionItem('Pre-trip Inspection Rate', '100% Complete', MemphisTheme.secondaryTeal),
                      ],
                    ),
                  );

                  Widget rightCol = MemphisTheme.buildContainer(
                    bgColor: MemphisTheme.crispSurface,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(child: Text('DRIVER SCORE TREND OVER TIME', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15))),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: MemphisTheme.secondaryTeal, borderRadius: BorderRadius.circular(8), border: Border.all(color: MemphisTheme.darkText, width: 2)),
                              child: const Text('4-WEEK HISTORY', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text('Weekly comparison of safety compliance & incident penalization', style: TextStyle(fontSize: 12)),
                        const SizedBox(height: 20),
                        Container(
                          height: 260,
                          padding: const EdgeInsets.only(top: 24, right: 24, left: 12, bottom: 12),
                          decoration: BoxDecoration(color: MemphisTheme.warmBackground, borderRadius: BorderRadius.circular(16), border: Border.all(color: MemphisTheme.darkText, width: 3)),
                          child: LineChart(
                            LineChartData(
                              minY: 70, maxY: 100, minX: 1, maxX: 4,
                              gridData: const FlGridData(show: true, drawVerticalLine: true),
                              borderData: FlBorderData(show: true, border: Border.all(color: MemphisTheme.darkText, width: 2)),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: spots,
                                  isCurved: true,
                                  color: MemphisTheme.primaryPink,
                                  barWidth: 5,
                                  dotData: FlDotData(show: true, getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(radius: 6, color: MemphisTheme.accentYellow, strokeColor: MemphisTheme.darkText, strokeWidth: 3)),
                                ),
                              ],
                              titlesData: FlTitlesData(
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 24,
                                    getTitlesWidget: (val, meta) => Text('Wk ${val.toInt()}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 28,
                                    getTitlesWidget: (val, meta) => Text('${val.toInt()}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
                                  ),
                                ),
                                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            _buildSummaryCell('FLEET AVERAGE', '87.4'),
                            const SizedBox(width: 12),
                            _buildSummaryCell('COMPLIANCE GOAL', '90.0'),
                            const SizedBox(width: 12),
                            _buildSummaryCell('STATUS VS GOAL', score >= 90 ? '✅ EXCEEDED' : '⚠️ NEAR GOAL'),
                          ],
                        ),
                      ],
                    ),
                  );

                  return isWide ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: leftCol), const SizedBox(width: 16), Expanded(flex: 2, child: rightCol)]) : Column(children: [leftCol, const SizedBox(height: 16), rightCol]);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfractionItem(String label, String val, Color valCol) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: MemphisTheme.crispSurface, borderRadius: BorderRadius.circular(12), border: Border.all(color: MemphisTheme.darkText, width: 2)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
          Text(val, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: valCol)),
        ],
      ),
    );
  }

  Widget _buildSummaryCell(String title, String val) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: MemphisTheme.warmBackground, borderRadius: BorderRadius.circular(12), border: Border.all(color: MemphisTheme.darkText, width: 2)),
        child: Column(
          children: [
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 9)),
            const SizedBox(height: 4),
            Text(val, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
