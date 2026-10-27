import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:heroicons/heroicons.dart';
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
  bool _isCameraConnected = false;

  @override
  void initState() {
    super.initState();
    final api = Provider.of<ApiService>(context, listen: false);

    // Display both live backend matches and locally simulated match events.
    _cameraSubscription = api.onCameraMatch.listen((event) {
      if (mounted) {
        CameraMatchDialog.show(
          context,
          event: event,
          onConfirmEntry: () async {
            await api.confirmEntry(
              event.visitor.id,
              source: event.source,
              cameraId: event.cameraId,
              confidence: event.confidence,
            );
            _loadData();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppConstants.accentGreen,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  content: Text(
                    'Entry confirmed for ${event.visitor.fullName} (${event.visitor.visitorCode})',
                    style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            }
          },
          onConfirmExit: () async {
            await api.confirmExit(
              event.visitor.id,
              source: event.source,
              cameraId: event.cameraId,
              confidence: event.confidence,
            );
            _loadData();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppConstants.accentBlue,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  content: Text(
                    'Exit confirmed for ${event.visitor.fullName} (${event.visitor.visitorCode})',
                    style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
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
      backgroundColor: AppConstants.scaffoldLight,
      appBar: AppBar(
        backgroundColor: AppConstants.surfaceWhite,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppConstants.borderLight, height: 1),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppConstants.greenLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppConstants.accentGreen.withValues(alpha: 0.2)),
              ),
              child: const HeroIcon(
                HeroIcons.shieldCheck,
                color: AppConstants.accentGreen,
                size: 22,
                style: HeroIconStyle.solid,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GATE SECURITY COCKPIT',
                  style: GoogleFonts.roboto(
                    color: AppConstants.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                Text(
                  'Gate 1 (Visitor Access Lane)',
                  style: GoogleFonts.nunito(
                    color: AppConstants.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Simulate Camera Match',
            onPressed: () => api.simulateFrequentVisitorMatch(),
            icon: const HeroIcon(
              HeroIcons.videoCamera,
              color: AppConstants.accentGreen,
              size: 22,
              style: HeroIconStyle.solid,
            ),
          ),
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loadData,
            icon: const HeroIcon(
              HeroIcons.arrowPath,
              color: AppConstants.textSecondary,
              size: 20,
            ),
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
                      icon: HeroIcons.userGroup,
                      color: AppConstants.accentGreen,
                      bgColor: AppConstants.greenLight,
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
                      icon: HeroIcons.sparkles,
                      color: AppConstants.accentAmber,
                      bgColor: AppConstants.amberLight,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const VisitorHistoryScreen()),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Primary Guard Actions Header
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppConstants.accentGreen,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'QUICK GUARD ACTIONS',
                    style: GoogleFonts.roboto(
                      color: AppConstants.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Action 1: New Visitor Entry
              _buildBigActionButton(
                title: 'New Visitor Registration & Entry',
                subtitle: 'Enter phone, plate, details & log entry pass',
                icon: HeroIcons.userPlus,
                accentColor: AppConstants.accentGreen,
                iconBgColor: AppConstants.greenLight,
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
                icon: HeroIcons.clock,
                accentColor: AppConstants.accentBlue,
                iconBgColor: AppConstants.blueLight,
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

              // Action 3: Camera Recognition Match
              _buildBigActionButton(
                title: _isCameraConnected ? 'Test Camera Match Popup' : 'Camera Stream Offline',
                subtitle: _isCameraConnected
                    ? 'Simulate CCTV / ANPR frequent visitor detection'
                    : 'Connect camera feed above to enable auto-match detection',
                icon: HeroIcons.bellAlert,
                accentColor: _isCameraConnected ? AppConstants.accentAmber : AppConstants.textMuted,
                iconBgColor: _isCameraConnected ? AppConstants.amberLight : AppConstants.chipBackground,
                onTap: () {
                  if (!_isCameraConnected) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppConstants.accentAmber,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        content: Text(
                          'No camera is connected. Connect camera feed first.',
                          style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                    return;
                  }
                  api.simulateFrequentVisitorMatch();
                },
              ),

              const SizedBox(height: 26),

              // Active Visitors Currently Inside Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 16,
                        decoration: BoxDecoration(
                          color: AppConstants.accentGreen,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'CURRENTLY INSIDE PREMISES',
                        style: GoogleFonts.roboto(
                          color: AppConstants.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ActiveVisitorsScreen()),
                    ),
                    icon: const HeroIcon(HeroIcons.arrowRightOnRectangle, size: 14, color: AppConstants.accentGreen),
                    label: Text(
                      'View All (${_activeVisitors.length})',
                      style: GoogleFonts.nunito(
                        color: AppConstants.accentGreen,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(color: AppConstants.accentGreen),
                  ),
                )
              else if (_activeVisitors.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
                  decoration: BoxDecoration(
                    color: AppConstants.surfaceWhite,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppConstants.borderLight),
                    boxShadow: AppConstants.softShadow,
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppConstants.greenLight,
                          shape: BoxShape.circle,
                        ),
                        child: const HeroIcon(
                          HeroIcons.checkCircle,
                          color: AppConstants.accentGreen,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No visitors currently inside',
                        style: GoogleFonts.roboto(
                          color: AppConstants.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'All registered visitor passes are checked out.',
                        style: GoogleFonts.nunito(
                          color: AppConstants.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppConstants.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isCameraConnected ? AppConstants.accentGreen.withValues(alpha: 0.3) : AppConstants.borderLight,
          width: 1.2,
        ),
        boxShadow: AppConstants.softShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _isCameraConnected ? AppConstants.greenLight : AppConstants.chipBackground,
              shape: BoxShape.circle,
            ),
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: _isCameraConnected ? AppConstants.accentGreen : AppConstants.textMuted,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isCameraConnected ? 'CCTV & ANPR Camera Feed Active' : 'No Camera Connected',
                  style: GoogleFonts.roboto(
                    color: AppConstants.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  _isCameraConnected
                      ? 'Monitoring Gate 1 • Auto-match alert ready'
                      : 'Gate 1 Stream Offline • Connect camera to enable auto-match',
                  style: GoogleFonts.nunito(
                    color: AppConstants.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _isCameraConnected = !_isCameraConnected;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: _isCameraConnected ? AppConstants.accentGreen : AppConstants.accentAmber,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  content: Text(
                    _isCameraConnected
                        ? 'Camera connected! Gate 1 stream is now LIVE.'
                        : 'Camera disconnected. Stream is OFFLINE.',
                    style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              backgroundColor: _isCameraConnected ? AppConstants.redLight : AppConstants.greenLight,
              foregroundColor: _isCameraConnected ? AppConstants.accentRed : AppConstants.accentGreen,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: _isCameraConnected
                      ? AppConstants.accentRed.withValues(alpha: 0.3)
                      : AppConstants.accentGreen.withValues(alpha: 0.3),
                ),
              ),
            ),
            icon: HeroIcon(
              _isCameraConnected ? HeroIcons.videoCamera : HeroIcons.videoCamera,
              size: 14,
              color: _isCameraConnected ? AppConstants.accentRed : AppConstants.accentGreen,
            ),
            label: Text(
              _isCameraConnected ? 'Disconnect' : 'Connect',
              style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String count,
    required HeroIcons icon,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppConstants.surfaceWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1.2),
          boxShadow: AppConstants.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: HeroIcon(icon, color: color, size: 22, style: HeroIconStyle.solid),
                ),
                Text(
                  count,
                  style: GoogleFonts.roboto(
                    color: color,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.nunito(
                color: AppConstants.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBigActionButton({
    required String title,
    required String subtitle,
    required HeroIcons icon,
    required Color accentColor,
    required Color iconBgColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppConstants.surfaceWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppConstants.borderLight),
            boxShadow: AppConstants.softShadow,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: accentColor.withValues(alpha: 0.2)),
                ),
                child: HeroIcon(icon, color: accentColor, size: 24, style: HeroIconStyle.solid),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.roboto(
                        color: AppConstants.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: GoogleFonts.nunito(
                        color: AppConstants.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const HeroIcon(
                HeroIcons.chevronRight,
                color: AppConstants.textMuted,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVisitorItem(Visitor v) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppConstants.surfaceWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppConstants.borderLight),
        boxShadow: AppConstants.softShadow,
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppConstants.greenLight,
            child: Text(
              v.fullName.isNotEmpty ? v.fullName[0].toUpperCase() : 'V',
              style: GoogleFonts.roboto(
                color: AppConstants.accentGreen,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
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
                      style: GoogleFonts.roboto(
                        color: AppConstants.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    if (v.isFrequentVisitor) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppConstants.amberLight,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppConstants.accentAmber.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          '${v.totalVisits} visits',
                          style: GoogleFonts.nunito(
                            color: AppConstants.accentAmber,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  '${v.visitorCode} • Plate: ${v.vehicleNumber ?? "N/A"}',
                  style: GoogleFonts.nunito(
                    color: AppConstants.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: () async {
              final api = Provider.of<ApiService>(context, listen: false);
              await api.confirmExit(v.id);
              _loadData();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppConstants.accentGreen,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    content: Text(
                      'Visitor ${v.fullName} checked-out.',
                      style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              }
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppConstants.accentRed,
              side: const BorderSide(color: AppConstants.accentRed, width: 1.0),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const HeroIcon(HeroIcons.arrowRightOnRectangle, size: 14, color: AppConstants.accentRed),
            label: Text(
              'Check Out',
              style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
