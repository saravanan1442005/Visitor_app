import 'package:flutter/material.dart';
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
      backgroundColor: AppConstants.primaryDark,
      appBar: AppBar(
        backgroundColor: AppConstants.surfaceDark,
        elevation: 0,
        title: const Text(
          'FREQUENT & RETURNING VISITORS',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 1.1),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _frequentVisitors.isEmpty
              ? const Center(
                  child: Text('No returning visitor records found.', style: TextStyle(color: AppConstants.textSecondary)),
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
                        color: AppConstants.surfaceDark,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppConstants.accentAmber.withOpacity(0.4)),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: AppConstants.cardDark,
                            child: Text(
                              v.fullName.isNotEmpty ? v.fullName[0].toUpperCase() : 'V',
                              style: const TextStyle(color: AppConstants.accentAmber, fontWeight: FontWeight.bold, fontSize: 18),
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
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppConstants.accentAmber.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '${v.totalVisits} Visits',
                                        style: const TextStyle(color: AppConstants.accentAmber, fontWeight: FontWeight.bold, fontSize: 11),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${v.visitorCode} • Plate: ${v.vehicleNumber ?? "N/A"}',
                                  style: const TextStyle(color: AppConstants.textSecondary, fontSize: 12),
                                ),
                                if (v.phoneNumber != null)
                                  Text(
                                    'Phone: ${v.phoneNumber}',
                                    style: const TextStyle(color: AppConstants.textSecondary, fontSize: 12),
                                  ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              final api = Provider.of<ApiService>(context, listen: false);
                              api.simulateFrequentVisitorMatch(customVisitor: v);
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppConstants.cardDark,
                              foregroundColor: AppConstants.accentAmber,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            ),
                            child: const Text('Test Match', style: TextStyle(fontSize: 11)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
