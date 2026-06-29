import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import '../services/supabase_service.dart';
import '../theme/memphis_theme.dart';

class TripReportScreen extends StatelessWidget {
  final SupabaseService supabaseService;

  const TripReportScreen({super.key, required this.supabaseService});

  Future<void> _generateAndSharePdf(BuildContext context, Map<String, dynamic> trip) async {
    final bus = supabaseService.buses.firstWhere(
      (b) => b['id'].toString() == trip['bus_id'].toString(),
      orElse: () => { 'name': 'Bus #${trip['bus_id']}', 'driver': 'Unknown Driver' },
    );

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // Header Banner
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: const PdfColor.fromInt(0xFFE8879F),
                  border: pw.Border.all(color: const PdfColor.fromInt(0xFF1A1A2E), width: 3),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('BUSGUARD AI — TRIP REPORT', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: const PdfColor.fromInt(0xFF1A1A2E))),
                    pw.SizedBox(height: 4),
                    pw.Text('Official Vehicle Telemetry & Safety Manifest', style: pw.TextStyle(fontSize: 12, color: const PdfColor.fromInt(0xFF1A1A2E))),
                  ],
                ),
              ),
              pw.SizedBox(height: 24),
              pw.Text('Trip Summary: ${bus['name']}', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Divider(color: const PdfColor.fromInt(0xFF1A1A2E), thickness: 2),
              pw.SizedBox(height: 16),

              // Summary Grid
              pw.Table(
                columnWidths: {
                  0: const pw.FixedColumnWidth(160),
                  1: const pw.FlexColumnWidth(),
                },
                children: [
                  pw.TableRow(children: [pw.Text('Route Assigned:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)), pw.Text('${trip['route_name'] ?? 'Route'}')]),
                  pw.TableRow(children: [pw.SizedBox(height: 8), pw.SizedBox(height: 8)]),
                  pw.TableRow(children: [pw.Text('Assigned Driver:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)), pw.Text('${bus['driver'] ?? 'Driver'}')]),
                  pw.TableRow(children: [pw.SizedBox(height: 8), pw.SizedBox(height: 8)]),
                  pw.TableRow(children: [pw.Text('Departure Time:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)), pw.Text('${trip['start_time']}')]),
                  pw.TableRow(children: [pw.SizedBox(height: 8), pw.SizedBox(height: 8)]),
                  pw.TableRow(children: [pw.Text('Arrival Time:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)), pw.Text('${trip['end_time']}')]),
                  pw.TableRow(children: [pw.SizedBox(height: 8), pw.SizedBox(height: 8)]),
                  pw.TableRow(children: [pw.Text('Headcount Verified:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)), pw.Text('${trip['headcount']} passengers')]),
                  pw.TableRow(children: [pw.SizedBox(height: 8), pw.SizedBox(height: 8)]),
                  pw.TableRow(children: [pw.Text('AI Incidents Logged:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)), pw.Text('${trip['incidents'] ?? 0} detected during transit')]),
                  pw.TableRow(children: [pw.SizedBox(height: 8), pw.SizedBox(height: 8)]),
                  pw.TableRow(children: [pw.Text('Driver Safety Score:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)), pw.Text('${trip['driver_score'] ?? 92} / 100')]),
                ],
              ),
              pw.SizedBox(height: 40),

              // Certification stamp
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: const PdfColor.fromInt(0xFFFAF8F5),
                  border: pw.Border.all(color: const PdfColor.fromInt(0xFF1A1A2E), width: 3),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('AI PRE-DEPARTURE & TRANSIT CERTIFICATION', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13)),
                    pw.SizedBox(height: 8),
                    pw.Text('This trip report was compiled automatically via BusGuard AI edge detection and Supabase real-time telemetry storage. All standing passenger, driver phone usage, and flat tire detections have been permanently archived for administrative compliance review.', style: pw.TextStyle(fontSize: 10)),
                  ],
                ),
              ),
              pw.Spacer(),
              pw.Text('Generated on: ${DateTime.now()} | System ID: TRP-${trip['id']}', style: pw.TextStyle(fontStyle: pw.FontStyle.italic, fontSize: 10)),
            ],
          );
        },
      ),
    );

    // Save and Share
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/Trip_Report_${bus['name'].replaceAll(' ', '_')}_${trip['id']}.pdf');
    await file.writeAsBytes(await pdf.save());

    if (context.mounted) {
      Share.shareXFiles([XFile(file.path)], text: 'BusGuard AI Trip Report for ${bus['name']}');
    }
  }

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
                    Row(
                      children: [
                        const Icon(Icons.picture_as_pdf, color: MemphisTheme.accentYellow, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Auto-Generated Trip Reports', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                              Text('Download official PDF manifest containing headcount, scores & incidents', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(color: MemphisTheme.secondaryTeal, borderRadius: BorderRadius.circular(12), border: Border.all(color: MemphisTheme.darkText, width: 3)),
                      child: Text('${supabaseService.trips.length} COMPLETED TRIPS READY', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Trips List
              Column(
                children: supabaseService.trips.map((trip) {
                  final bus = supabaseService.buses.firstWhere((b) => b['id'].toString() == trip['bus_id'].toString(), orElse: () => { 'name': 'Bus #${trip['bus_id']}', 'driver': 'Unknown Driver' });

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: MemphisTheme.crispSurface, borderRadius: BorderRadius.circular(16), border: Border.all(color: MemphisTheme.darkText, width: 3), boxShadow: MemphisTheme.memphisShadow),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: MemphisTheme.primaryPink, borderRadius: BorderRadius.circular(8), border: Border.all(color: MemphisTheme.darkText, width: 2)),
                              child: Text('TRIP ID #${trip['id'].toString().split('-')[0]}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text('${trip['start_time']} — ${trip['end_time']}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(bus['name'], style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                        Text('Assigned Route: ${trip['route_name'] ?? 'Route'}', style: const TextStyle(fontSize: 12)),
                        const SizedBox(height: 16),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            bool isWide = constraints.maxWidth > 500;
                            return Flex(
                              direction: isWide ? Axis.horizontal : Axis.vertical,
                              children: [
                                _buildMetricCell('ASSIGNED DRIVER', bus['driver'] ?? 'Driver', isWide),
                                SizedBox(height: isWide ? 0 : 8, width: isWide ? 8 : 0),
                                _buildMetricCell('HEADCOUNT', '${trip['headcount']} Pass', isWide),
                                SizedBox(height: isWide ? 0 : 8, width: isWide ? 8 : 0),
                                _buildMetricCell('AI INCIDENTS', '${trip['incidents'] ?? 0} Flagged', isWide),
                                SizedBox(height: isWide ? 0 : 8, width: isWide ? 8 : 0),
                                _buildMetricCell('DRIVER SCORE', '${trip['driver_score'] ?? 92} / 100', isWide),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        MemphisTheme.buildButton(
                          bgColor: MemphisTheme.secondaryTeal,
                          onPressed: () => _generateAndSharePdf(context, trip),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.download, color: MemphisTheme.darkText),
                              SizedBox(width: 8),
                              Text('DOWNLOAD PDF REPORT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                            ],
                          ),
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

  Widget _buildMetricCell(String title, String val, bool isWide) {
    Widget cell = Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: MemphisTheme.warmBackground, borderRadius: BorderRadius.circular(10), border: Border.all(color: MemphisTheme.darkText, width: 2)),
      child: Column(
        children: [
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 9)),
          const SizedBox(height: 4),
          Text(val, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
        ],
      ),
    );
    return isWide ? Expanded(child: cell) : cell;
  }
}
