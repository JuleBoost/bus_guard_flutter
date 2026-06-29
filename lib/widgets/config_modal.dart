import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../theme/memphis_theme.dart';

class ConfigModal extends StatefulWidget {
  final SupabaseService supabaseService;

  const ConfigModal({super.key, required this.supabaseService});

  @override
  State<ConfigModal> createState() => _ConfigModalState();
}

class _ConfigModalState extends State<ConfigModal> {
  late TextEditingController _urlController;
  late TextEditingController _keyController;
  late bool _simMode;
  bool _isSeeding = false;
  String? _seedMessage;
  bool _seedSuccess = false;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: widget.supabaseService.supabaseUrl);
    _keyController = TextEditingController(text: widget.supabaseService.supabaseKey);
    _simMode = widget.supabaseService.simulationMode;
  }

  @override
  void dispose() {
    _urlController.dispose();
    _keyController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    await widget.supabaseService.saveConfig(_urlController.text, _keyController.text, _simMode);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Configuration Saved Successfully!', style: TextStyle(fontWeight: FontWeight.w900, color: MemphisTheme.darkText)),
          backgroundColor: MemphisTheme.secondaryTeal,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: MemphisTheme.darkText, width: 3)),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  Future<void> _handleSeedDatabase() async {
    setState(() {
      _isSeeding = true;
      _seedMessage = null;
    });
    final result = await widget.supabaseService.seedSupabaseDatabase();
    setState(() {
      _isSeeding = false;
      _seedSuccess = result['success'] as bool;
      _seedMessage = result['message'] as String;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: MemphisTheme.crispSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
        border: Border.all(color: MemphisTheme.darkText, width: 3.0),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.storage, color: MemphisTheme.secondaryTeal, size: 28),
                      SizedBox(width: 8),
                      Text('SUPABASE CONFIG', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, size: 28),
                  ),
                ],
              ),
              const Divider(color: MemphisTheme.darkText, thickness: 3),
              const SizedBox(height: 16),
              
              // Simulation Mode Switch
              MemphisTheme.buildContainer(
                bgColor: MemphisTheme.warmBackground,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Mock AI Realtime Simulator', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                        Switch(
                          value: _simMode,
                          activeColor: MemphisTheme.secondaryTeal,
                          onChanged: (val) => setState(() => _simMode = val),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _simMode ? 'Active: Simulated AI alerts fire automatically.' : 'Disabled (Recommended): Connected directly to your live Supabase DB.',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // URL Input
              const Text('SUPABASE PROJECT URL', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              TextField(
                controller: _urlController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: MemphisTheme.darkText, width: 3)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: MemphisTheme.darkText, width: 3)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),

              // Anon Key Input
              const Text('SUPABASE ANON KEY', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              TextField(
                controller: _keyController,
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: MemphisTheme.darkText, width: 3)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: MemphisTheme.darkText, width: 3)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),

              // Database Seeding Card
              MemphisTheme.buildContainer(
                bgColor: MemphisTheme.warmBackground,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('DATABASE INITIALIZATION', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                    const SizedBox(height: 4),
                    const Text('If your real Supabase tables are empty, click below to populate them with fully compliant seed data.', style: TextStyle(fontSize: 12)),
                    const SizedBox(height: 12),
                    MemphisTheme.buildButton(
                      bgColor: MemphisTheme.secondaryTeal,
                      onPressed: _isSeeding ? () {} : _handleSeedDatabase,
                      child: Text(_isSeeding ? 'Seeding Supabase Tables...' : '🚀 Seed Supabase Database Now', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                    ),
                    if (_seedMessage != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _seedSuccess ? MemphisTheme.secondaryTeal.withOpacity(0.3) : MemphisTheme.primaryPink,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: MemphisTheme.darkText, width: 2),
                        ),
                        child: Text(_seedMessage!, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Trigger Manual Alert Button
              MemphisTheme.buildButton(
                bgColor: MemphisTheme.accentYellow,
                onPressed: () {
                  widget.supabaseService.triggerRandomAlert();
                  Navigator.of(context).pop();
                },
                child: const Text('⚠️ Manual Trigger: Push Alert to Supabase DB', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
              ),
              const SizedBox(height: 24),

              // Save Button
              MemphisTheme.buildButton(
                bgColor: MemphisTheme.secondaryTeal,
                onPressed: _handleSave,
                child: const Text('SAVE CONFIGURATION', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
