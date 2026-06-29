import 'dart:async';
import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../theme/memphis_theme.dart';

class AlertToastOverlay extends StatefulWidget {
  final SupabaseService supabaseService;
  final Widget child;
  final Function(int) onNavigateToTab;

  const AlertToastOverlay({super.key, required this.supabaseService, required this.child, required this.onNavigateToTab});

  @override
  State<AlertToastOverlay> createState() => _AlertToastOverlayState();
}

class _AlertToastOverlayState extends State<AlertToastOverlay> {
  Map<String, dynamic>? _activeAlert;
  StreamSubscription? _sub;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _sub = widget.supabaseService.alertStream.listen((newAlert) {
      setState(() {
        _activeAlert = newAlert;
      });
      _timer?.cancel();
      _timer = Timer(const Duration(seconds: 6), () {
        if (mounted) {
          setState(() {
            _activeAlert = null;
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_activeAlert != null)
          Positioned(
            bottom: 24,
            right: 24,
            left: 24,
            child: Material(
              color: Colors.transparent,
              child: MemphisTheme.buildContainer(
                bgColor: MemphisTheme.primaryPink,
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.shield, color: MemphisTheme.darkText, size: 24),
                            SizedBox(width: 8),
                            Text('NEW SUPABASE ALERT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                          ],
                        ),
                        IconButton(
                          onPressed: () => setState(() => _activeAlert = null),
                          icon: const Icon(Icons.close, size: 20),
                        ),
                      ],
                    ),
                    const Divider(color: MemphisTheme.darkText, thickness: 2),
                    const SizedBox(height: 8),
                    Text(
                      '[${_activeAlert!['timestamp'] ?? 'Live'}] Bus — ${_activeAlert!['type']}',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _activeAlert!['message'] ?? _activeAlert!['description'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    MemphisTheme.buildButton(
                      bgColor: MemphisTheme.secondaryTeal,
                      isSmall: true,
                      onPressed: () {
                        setState(() => _activeAlert = null);
                        widget.onNavigateToTab(4); // Navigate to Alert Feed Tab
                      },
                      child: const Text('OPEN ALERT FEED', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
