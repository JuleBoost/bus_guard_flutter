import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/supabase_service.dart';
import '../theme/memphis_theme.dart';

class AnalyticsScreen extends StatelessWidget {
  final SupabaseService supabaseService;

  const AnalyticsScreen({super.key, required this.supabaseService});

  @override
  Widget build(BuildContext context) {
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
                        Icon(Icons.bar_chart, color: MemphisTheme.secondaryTeal, size: 28),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Fleet Security Analytics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                              Text('AI Violation Counters & Predictive Trends', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(color: MemphisTheme.warmBackground, borderRadius: BorderRadius.circular(12), border: Border.all(color: MemphisTheme.darkText, width: 3)),
                      child: const Text('LIVE DATA WAREHOUSE AGGREGATION', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Charts Grid
              LayoutBuilder(
                builder: (context, constraints) {
                  bool isWide = constraints.maxWidth > 800;

                  Widget incChart = MemphisTheme.buildContainer(
                    bgColor: MemphisTheme.crispSurface,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('INCIDENTS PER BUS PER WEEK', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                        const SizedBox(height: 4),
                        const Text('Weekly total infractions flagged by AI vision', style: TextStyle(fontSize: 12)),
                        const SizedBox(height: 20),
                        Container(
                          height: 250,
                          padding: const EdgeInsets.only(top: 24, right: 20, left: 12, bottom: 12),
                          decoration: BoxDecoration(color: MemphisTheme.warmBackground, borderRadius: BorderRadius.circular(16), border: Border.all(color: MemphisTheme.darkText, width: 3)),
                          child: BarChart(
                            BarChartData(
                              maxY: 20, minY: 0,
                              gridData: const FlGridData(show: true, drawVerticalLine: false),
                              borderData: FlBorderData(show: true, border: Border.all(color: MemphisTheme.darkText, width: 2)),
                              barGroups: [
                                BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 5, color: MemphisTheme.primaryPink, width: 24, borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: MemphisTheme.darkText, width: 2))]),
                                BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 12, color: MemphisTheme.primaryPink, width: 24, borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: MemphisTheme.darkText, width: 2))]),
                                BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 15, color: MemphisTheme.primaryPink, width: 24, borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: MemphisTheme.darkText, width: 2))]),
                                BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 3, color: MemphisTheme.primaryPink, width: 24, borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: MemphisTheme.darkText, width: 2))]),
                                BarChartGroupData(x: 5, barRods: [BarChartRodData(toY: 7, color: MemphisTheme.primaryPink, width: 24, borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: MemphisTheme.darkText, width: 2))]),
                              ],
                              titlesData: FlTitlesData(
                                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 24, getTitlesWidget: (val, meta) => Text('Bus #${val.toInt()}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11)))),
                                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28, getTitlesWidget: (val, meta) => Text('${val.toInt()}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11)))),
                                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );

                  Widget compChart = MemphisTheme.buildContainer(
                    bgColor: MemphisTheme.crispSurface,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('SEATBELT COMPLIANCE TREND', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                        const SizedBox(height: 4),
                        const Text('Daily percentage of buckled vs unbuckled passengers', style: TextStyle(fontSize: 12)),
                        const SizedBox(height: 20),
                        Container(
                          height: 250,
                          padding: const EdgeInsets.only(top: 24, right: 20, left: 12, bottom: 12),
                          decoration: BoxDecoration(color: MemphisTheme.warmBackground, borderRadius: BorderRadius.circular(16), border: Border.all(color: MemphisTheme.darkText, width: 3)),
                          child: LineChart(
                            LineChartData(
                              minY: 70, maxY: 100, minX: 1, maxX: 5,
                              gridData: const FlGridData(show: true, drawVerticalLine: true),
                              borderData: FlBorderData(show: true, border: Border.all(color: MemphisTheme.darkText, width: 2)),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: const [FlSpot(1, 85), FlSpot(2, 88), FlSpot(3, 82), FlSpot(4, 91), FlSpot(5, 89)],
                                  isCurved: true,
                                  color: MemphisTheme.accentYellow,
                                  barWidth: 5,
                                  dotData: FlDotData(show: true, getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(radius: 6, color: MemphisTheme.primaryPink, strokeColor: MemphisTheme.darkText, strokeWidth: 3)),
                                ),
                              ],
                              titlesData: FlTitlesData(
                                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 24, getTitlesWidget: (val, meta) => Text(['Mon','Tue','Wed','Thu','Fri'][val.toInt()-1], style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11)))),
                                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28, getTitlesWidget: (val, meta) => Text('${val.toInt()}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11)))),
                                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );

                  return isWide ? Row(children: [Expanded(child: incChart), const SizedBox(width: 16), Expanded(child: compChart)]) : Column(children: [incChart, const SizedBox(height: 16), compChart]);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
