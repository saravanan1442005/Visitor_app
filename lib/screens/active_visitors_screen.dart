import 'package:flutter/material.dart';
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
      backgroundColor: AppConstants.primaryDark,
      appBar: AppBar(
        backgroundColor: AppConstants.surfaceDark,
        elevation: 0,
        title: const Text(
          'CURRENTLY INSIDE PREMISES',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 1.1),
        ),
        actions: [
          IconButton(onPressed: _fetch, icon: const Icon(Icons.refresh_rounded)),
        ],
      ),
      body: Column(
        children: [
          // Filter Search Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppConstants.surfaceDark,
            child: TextField(
              style: const TextStyle(color: AppConstants.textPrimary),
              decoration: InputDecoration(
                hintText: 'Filter by name, code, or plate...',
                hintStyle: const TextStyle(color: AppConstants.textSecondary, fontSize: 13),
                prefixIcon: const Icon(Icons.filter_list_rounded, color: AppConstants.textSecondary, size: 20),
                filled: true,
                fillColor: AppConstants.primaryDark,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? Center(
                        child: Text(
                          _searchQuery.isEmpty ? 'No active visitors inside.' : 'No matches found.',
                          style: const TextStyle(color: AppConstants.textSecondary),
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
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      v.fullName,
                      style: const TextStyle(color: AppConstants.textPrimary, fontWeight: FontWeight.bold, fontSize: 15),
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
                const SizedBox(height: 4),
                Text(
                  '${v.visitorCode} • Plate: ${v.vehicleNumber ?? "None"}',
                  style: const TextStyle(color: AppConstants.textSecondary, fontSize: 12),
                ),
                if (v.company != null)
                  Text(
                    'Company: ${v.company}',
                    style: const TextStyle(color: AppConstants.textSecondary, fontSize: 11),
                  ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final api = Provider.of<ApiService>(context, listen: false);
              await api.confirmExit(v.id);
              _fetch();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Visitor ${v.fullName} checked-out successfully.')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.accentRed.withOpacity(0.2),
              foregroundColor: AppConstants.accentRed,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: const Text('Exit Pass', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
