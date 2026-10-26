import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:heroicons/heroicons.dart';
import 'package:provider/provider.dart';
import '../config/constants.dart';
import '../models/visitor.dart';
import '../services/api_service.dart';

class ActiveVisitorsScreen extends StatefulWidget {
  const ActiveVisitorsScreen({super.key});

  @override
  State<ActiveVisitorsScreen> createState() => _ActiveVisitorsScreenState();
}

class _ActiveVisitorsScreenState extends State<ActiveVisitorsScreen> {
  List<Visitor> _visitors = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _isLoading = true);
    final api = Provider.of<ApiService>(context, listen: false);
    final list = await api.fetchActiveVisitors();
    if (mounted) {
      setState(() {
        _visitors = list;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _visitors.where((v) {
      final q = _searchQuery.toLowerCase();
      return v.fullName.toLowerCase().contains(q) ||
          v.visitorCode.toLowerCase().contains(q) ||
          (v.vehicleNumber != null && v.vehicleNumber!.toLowerCase().contains(q));
    }).toList();

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
          'CURRENTLY INSIDE PREMISES',
          style: GoogleFonts.roboto(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: AppConstants.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _fetch,
            icon: const HeroIcon(HeroIcons.arrowPath, color: AppConstants.textSecondary, size: 20),
            tooltip: 'Refresh',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Filter Search Bar Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppConstants.surfaceWhite,
              border: const Border(bottom: BorderSide(color: AppConstants.borderLight)),
            ),
            child: TextField(
              style: GoogleFonts.nunito(color: AppConstants.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Filter by name, code, or vehicle plate...',
                hintStyle: GoogleFonts.nunito(color: AppConstants.textMuted, fontSize: 13),
                prefixIcon: const Padding(
                  padding: EdgeInsets.all(12),
                  child: HeroIcon(HeroIcons.funnel, color: AppConstants.accentGreen, size: 18),
                ),
                filled: true,
                fillColor: AppConstants.inputFill,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppConstants.borderLight),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppConstants.borderLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppConstants.accentGreen, width: 1.5),
                ),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppConstants.accentGreen))
                : filtered.isEmpty
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
                                HeroIcons.checkCircle,
                                color: AppConstants.accentGreen,
                                size: 36,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _searchQuery.isEmpty ? 'No active visitors inside.' : 'No matches found.',
                              style: GoogleFonts.roboto(
                                color: AppConstants.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'All checked-in visitors have departed.'
                                  : 'Try adjusting your search query.',
                              style: GoogleFonts.nunito(color: AppConstants.textSecondary, fontSize: 13),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length,
                        itemBuilder: (ctx, idx) {
                          final v = filtered[idx];
                          return _buildCard(v);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(Visitor v) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
                const SizedBox(height: 4),
                Text(
                  '${v.visitorCode} • Plate: ${v.vehicleNumber ?? "None"}',
                  style: GoogleFonts.nunito(color: AppConstants.textSecondary, fontSize: 12),
                ),
                if (v.company != null && v.company!.isNotEmpty)
                  Text(
                    'Company: ${v.company}',
                    style: GoogleFonts.nunito(color: AppConstants.textMuted, fontSize: 11),
                  ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              final api = Provider.of<ApiService>(context, listen: false);
              await api.confirmExit(v.id);
              _fetch();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppConstants.accentGreen,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    content: Text(
                      'Visitor ${v.fullName} checked-out successfully.',
                      style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.redLight,
              foregroundColor: AppConstants.accentRed,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: AppConstants.accentRed.withValues(alpha: 0.3)),
              ),
            ),
            icon: const HeroIcon(HeroIcons.arrowRightOnRectangle, size: 14, color: AppConstants.accentRed),
            label: Text(
              'Exit Pass',
              style: GoogleFonts.nunito(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
