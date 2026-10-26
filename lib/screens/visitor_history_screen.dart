import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:heroicons/heroicons.dart';
import 'package:provider/provider.dart';
import '../config/constants.dart';
import '../models/visitor.dart';
import '../services/api_service.dart';

class VisitorHistoryScreen extends StatefulWidget {
  const VisitorHistoryScreen({super.key});

  @override
  State<VisitorHistoryScreen> createState() => _VisitorHistoryScreenState();
}

class _VisitorHistoryScreenState extends State<VisitorHistoryScreen> {
  List<Visitor> _frequentVisitors = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final api = Provider.of<ApiService>(context, listen: false);
    // Search default query to list returning visitors
    final list = await api.searchVisitor(' ');
    if (mounted) {
      setState(() {
        _frequentVisitors = list;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.scaffoldLight,
      appBar: AppBar(
        backgroundColor: AppConstants.surfaceWhite,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppConstants.borderLight, height: 1),
        ),
        title: Text(
          'FREQUENT & RETURNING VISITORS',
          style: GoogleFonts.roboto(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: AppConstants.textPrimary,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppConstants.accentGreen))
          : _frequentVisitors.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: AppConstants.greenLight,
                          shape: BoxShape.circle,
                        ),
                        child: const HeroIcon(
                          HeroIcons.sparkles,
                          color: AppConstants.accentGreen,
                          size: 36,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No returning visitor records found.',
                        style: GoogleFonts.roboto(
                          color: AppConstants.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Returning visitors will be listed here after their first visit.',
                        style: GoogleFonts.nunito(color: AppConstants.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _frequentVisitors.length,
                  itemBuilder: (ctx, idx) {
                    final v = _frequentVisitors[idx];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppConstants.surfaceWhite,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: v.isFrequentVisitor
                              ? AppConstants.accentAmber.withValues(alpha: 0.35)
                              : AppConstants.borderLight,
                          width: 1.2,
                        ),
                        boxShadow: AppConstants.softShadow,
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: v.isFrequentVisitor
                                ? AppConstants.amberLight
                                : AppConstants.greenLight,
                            child: Text(
                              v.fullName.isNotEmpty ? v.fullName[0].toUpperCase() : 'V',
                              style: GoogleFonts.roboto(
                                color: v.isFrequentVisitor
                                    ? AppConstants.accentAmber
                                    : AppConstants.accentGreen,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
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
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppConstants.amberLight,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: AppConstants.accentAmber.withValues(alpha: 0.3)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const HeroIcon(
                                            HeroIcons.sparkles,
                                            size: 11,
                                            color: AppConstants.accentAmber,
                                            style: HeroIconStyle.solid,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${v.totalVisits} Visits',
                                            style: GoogleFonts.nunito(
                                              color: AppConstants.accentAmber,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${v.visitorCode} • Plate: ${v.vehicleNumber ?? "N/A"}',
                                  style: GoogleFonts.nunito(
                                    color: AppConstants.textSecondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (v.phoneNumber != null && v.phoneNumber!.isNotEmpty)
                                  Text(
                                    'Phone: ${v.phoneNumber}',
                                    style: GoogleFonts.nunito(
                                      color: AppConstants.textMuted,
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              final api = Provider.of<ApiService>(context, listen: false);
                              api.simulateFrequentVisitorMatch(customVisitor: v);
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppConstants.greenLight,
                              foregroundColor: AppConstants.accentGreen,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(color: AppConstants.accentGreen.withValues(alpha: 0.3)),
                              ),
                            ),
                            icon: const HeroIcon(HeroIcons.videoCamera, size: 14, color: AppConstants.accentGreen),
                            label: Text(
                              'Test Alert',
                              style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
