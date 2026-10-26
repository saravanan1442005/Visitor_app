import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/constants.dart';
import '../models/camera_match_event.dart';
import '../models/visitor.dart';
import '../services/api_service.dart';
import '../widgets/camera_match_dialog.dart';
import 'visitor_entry_screen.dart';
import 'active_visitors_screen.dart';
import 'visitor_history_screen.dart';

class GuardDashboardScreen extends StatefulWidget {
  const GuardDashboardScreen({super.key});

  @override
  State<GuardDashboardScreen> createState() => _GuardDashboardScreenState();
}

class _GuardDashboardScreenState extends State<GuardDashboardScreen> {
  StreamSubscription<CameraMatchEvent>? _cameraSubscription;
  List<Visitor> _activeVisitors = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final api = Provider.of<ApiService>(context, listen: false);

    // Listen to camera match alerts and show interactive popup
    _cameraSubscription = api.onCameraMatch.listen((event) {
      if (mounted) {
        CameraMatchDialog.show(
          context,
          event: event,
          onConfirmEntry: () async {
            await api.confirmEntry(event.visitor.id, source: 'CAMERA_MATCH_CONFIRMED');
            _loadData();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppConstants.accentGreen,
                  content: Text('✅ Entry confirmed for ${event.visitor.fullName} (${event.visitor.visitorCode})'),
                ),
              );
            }
          },
        );
      }
    });

    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final api = Provider.of<ApiService>(context, listen: false);
    final active = await api.fetchActiveVisitors();
    if (mounted) {
      setState(() {
        _activeVisitors = active;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _cameraSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final api = Provider.of<ApiService>(context);

    return Scaffold(
      backgroundColor: AppConstants.primaryDark,
      appBar: AppBar(
        backgroundColor: AppConstants.surfaceDark,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppConstants.cardDark,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.shield_rounded, color: AppConstants.accentGreen, size: 22),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GATE SECURITY COCKPIT',
                  style: TextStyle(
                    color: AppConstants.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
                Text(
                  'Gate 1 (Visitor Access Lane)',
                  style: TextStyle(color: AppConstants.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Simulate Camera Match',
            onPressed: () => api.simulateFrequentVisitorMatch(),
            icon: const Icon(Icons.videocam_rounded, color: AppConstants.accentAmber),
          ),
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loadData,
            icon: const Icon(Icons.refresh_rounded, color: AppConstants.textSecondary),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppConstants.accentGreen,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Live Status Banner
              _buildLiveCameraBanner(api),

              const SizedBox(height: 18),

              // KPI Stats Grid
              Row(
                children: [
                  Expanded(
                    child: _buildKpiCard(
                      title: 'Active Inside',
                      count: _activeVisitors.length.toString(),
                      icon: Icons.person_pin_circle_rounded,
                      color: AppConstants.accentGreen,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ActiveVisitorsScreen()),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildKpiCard(
                      title: 'Frequent Visitors',
                      count: _activeVisitors.where((v) => v.isFrequentVisitor).length.toString(),
                      icon: Icons.stars_rounded,
                      color: AppConstants.accentAmber,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const VisitorHistoryScreen()),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // Primary Guard Actions
              const Text(
                'QUICK GUARD ACTIONS',
                style: TextStyle(
                  color: AppConstants.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 12),

              // Action 1: New Visitor Entry
              _buildBigActionButton(
                title: 'New Visitor Registration & Entry',
                subtitle: 'Enter phone, plate, details & log entry pass',
                icon: Icons.person_add_alt_1_rounded,
                color: AppConstants.accentGreen,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const VisitorEntryScreen()),
                  );
                  _loadData();
                },
              ),

              const SizedBox(height: 12),

              // Action 2: Check Returning Visitor
              _buildBigActionButton(
                title: 'Check Returning Visitor',
                subtitle: 'Auto-fetch history by phone or vehicle plate number',
                icon: Icons.history_rounded,
                color: AppConstants.accentBlue,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const VisitorEntryScreen(initialSearchMode: true),
                    ),
                  );
                  _loadData();
                },
              ),

              const SizedBox(height: 12),

              // Action 3: Test Camera Detection Popup
              _buildBigActionButton(
                title: 'Test Camera Match Popup',
                subtitle: 'Simulate CCTV / ANPR frequent visitor detection',
                icon: Icons.notification_important_rounded,
                color: AppConstants.accentAmber,
                onTap: () => api.simulateFrequentVisitorMatch(),
              ),

              const SizedBox(height: 24),

              // Active Visitors Currently Inside Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'CURRENTLY INSIDE PREMISES',
                    style: TextStyle(
                      color: AppConstants.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ActiveVisitorsScreen()),
                    ),
                    child: const Text('View All', style: TextStyle(color: AppConstants.accentGreen, fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (_isLoading)
                const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
              else if (_activeVisitors.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppConstants.surfaceDark,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Text('No visitors currently checked-in inside.', style: TextStyle(color: AppConstants.textSecondary)),
                  ),
                )
              else
                ..._activeVisitors.take(3).map((v) => _buildVisitorItem(v)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLiveCameraBanner(ApiService api) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppConstants.surfaceDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppConstants.borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: AppConstants.accentGreen,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CCTV & ANPR Camera Feed Active',
                  style: TextStyle(color: AppConstants.textPrimary, fontSize: 13, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Monitoring Gate 1 • Auto-match alert ready',
                  style: TextStyle(color: AppConstants.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => api.simulateFrequentVisitorMatch(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              backgroundColor: AppConstants.cardDark,
            ),
            child: const Text(
              'Test Match',
              style: TextStyle(color: AppConstants.accentAmber, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String count,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppConstants.surfaceDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 24),
                Text(
                  count,
                  style: TextStyle(color: color, fontSize: 26, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(color: AppConstants.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBigActionButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppConstants.surfaceDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppConstants.borderLight),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: AppConstants.textPrimary, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(color: AppConstants.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: AppConstants.textSecondary, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildVisitorItem(Visitor v) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppConstants.surfaceDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppConstants.borderLight),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppConstants.cardDark,
            child: Text(
              v.fullName.isNotEmpty ? v.fullName[0].toUpperCase() : 'V',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      v.fullName,
                      style: const TextStyle(color: AppConstants.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    if (v.isFrequentVisitor) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppConstants.accentAmber.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${v.totalVisits} visits',
                          style: const TextStyle(color: AppConstants.accentAmber, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  '${v.visitorCode} • Plate: ${v.vehicleNumber ?? "N/A"}',
                  style: const TextStyle(color: AppConstants.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () async {
              final api = Provider.of<ApiService>(context, listen: false);
              await api.confirmExit(v.id);
              _loadData();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Visitor ${v.fullName} checked-out.')),
                );
              }
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppConstants.accentRed,
              side: const BorderSide(color: AppConstants.accentRed, width: 0.8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            ),
            child: const Text('Check Out', style: TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }
}
