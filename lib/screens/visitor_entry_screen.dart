import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/constants.dart';
import '../models/visitor.dart';
import '../services/api_service.dart';

class VisitorEntryScreen extends StatefulWidget {
  final bool initialSearchMode;

  const VisitorEntryScreen({super.key, this.initialSearchMode = false});

  @override
  State<VisitorEntryScreen> createState() => _VisitorEntryScreenState();
}

class _VisitorEntryScreenState extends State<VisitorEntryScreen> {
  final _formKey = GlobalKey<FormState>();

  final _searchController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _vehicleController = TextEditingController();
  final _companyController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedCategory = AppConstants.visitorCategories[0];
  Visitor? _matchedReturningVisitor;
  bool _isSearching = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _handleSearch(String query) async {
    if (query.trim().length < 3) {
      setState(() => _matchedReturningVisitor = null);
      return;
    }

    setState(() => _isSearching = true);
    final api = Provider.of<ApiService>(context, listen: false);
    final results = await api.searchVisitor(query.trim());

    if (mounted) {
      setState(() {
        _isSearching = false;
        if (results.isNotEmpty) {
          _matchedReturningVisitor = results.first;
          // Autofill form
          _nameController.text = _matchedReturningVisitor!.fullName;
          _phoneController.text = _matchedReturningVisitor!.phoneNumber ?? '';
          _vehicleController.text = _matchedReturningVisitor!.vehicleNumber ?? '';
          _companyController.text = _matchedReturningVisitor!.company ?? '';
          if (_matchedReturningVisitor!.category != null &&
              AppConstants.visitorCategories.contains(_matchedReturningVisitor!.category)) {
            _selectedCategory = _matchedReturningVisitor!.category!;
          }
        } else {
          _matchedReturningVisitor = null;
        }
      });
    }
  }

  Future<void> _submitEntry() async {
    final api = Provider.of<ApiService>(context, listen: false);

    // If it's a returning visitor matched, quick check-in
    if (_matchedReturningVisitor != null) {
      setState(() => _isSubmitting = true);
      final ok = await api.confirmEntry(_matchedReturningVisitor!.id, source: 'GUARD_RETURNING');
      setState(() => _isSubmitting = false);

      if (mounted) {
        if (ok) {
          _showSuccessPassDialog(_matchedReturningVisitor!, isReturning: true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to confirm entry. Check server.')),
          );
        }
      }
      return;
    }

    // Otherwise, validate and register new visitor
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      final newVisitor = await api.registerVisitor(
        fullName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        vehicleNumber: _vehicleController.text.trim(),
        company: _companyController.text.trim(),
        category: _selectedCategory,
        notes: _notesController.text.trim(),
      );

      setState(() => _isSubmitting = false);
      if (mounted && newVisitor != null) {
        _showSuccessPassDialog(newVisitor, isReturning: false);
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: AppConstants.accentRed, content: Text('Error: $e')),
        );
      }
    }
  }

  void _showSuccessPassDialog(Visitor visitor, {required bool isReturning}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppConstants.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: AppConstants.accentGreen, size: 28),
            const SizedBox(width: 10),
            Text(
              isReturning ? 'Entry Confirmed!' : 'Visitor Registered!',
              style: const TextStyle(color: AppConstants.textPrimary, fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isReturning)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppConstants.accentAmber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '⭐ Returning Visitor (Visit #${visitor.totalVisits + 1})',
                  style: const TextStyle(color: AppConstants.accentAmber, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            Text('Pass Code: ${visitor.visitorCode}', style: const TextStyle(color: AppConstants.accentBlue, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 6),
            Text('Name: ${visitor.fullName}', style: const TextStyle(color: AppConstants.textPrimary)),
            if (visitor.vehicleNumber != null) ...[
              const SizedBox(height: 4),
              Text('Vehicle: ${visitor.vehicleNumber}', style: const TextStyle(color: AppConstants.textSecondary)),
            ],
            const SizedBox(height: 4),
            Text('Gate: Gate 1 (Visitor Access)', style: const TextStyle(color: AppConstants.textSecondary)),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.accentGreen,
              foregroundColor: Colors.black,
            ),
            child: const Text('Done & Print / Badge', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.primaryDark,
      appBar: AppBar(
        backgroundColor: AppConstants.surfaceDark,
        elevation: 0,
        title: const Text(
          'VISITOR REGISTRATION & ENTRY',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 1.1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Search / Autofill Bar
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppConstants.surfaceDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppConstants.accentBlue.withOpacity(0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.search_rounded, color: AppConstants.accentBlue, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'RETURNING VISITOR LOOKUP',
                          style: TextStyle(
                            color: AppConstants.accentBlue,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _searchController,
                      style: const TextStyle(color: AppConstants.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Enter phone number, last 4 digits, or vehicle plate...',
                        hintStyle: const TextStyle(color: AppConstants.textSecondary, fontSize: 13),
                        filled: true,
                        fillColor: AppConstants.primaryDark,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                        suffixIcon: _isSearching
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                              )
                            : IconButton(
                                icon: const Icon(Icons.arrow_forward_rounded, color: AppConstants.accentBlue),
                                onPressed: () => _handleSearch(_searchController.text),
                              ),
                      ),
                      onChanged: _handleSearch,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Returning Visitor Detected Banner
              if (_matchedReturningVisitor != null) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppConstants.accentAmber.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppConstants.accentAmber),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.stars_rounded, color: AppConstants.accentAmber, size: 30),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'RETURNING VISITOR DETECTED (${_matchedReturningVisitor!.totalVisits} PREVIOUS VISITS)',
                              style: const TextStyle(
                                color: AppConstants.accentAmber,
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${_matchedReturningVisitor!.fullName} • Code: ${_matchedReturningVisitor!.visitorCode}',
                              style: const TextStyle(color: AppConstants.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            if (_matchedReturningVisitor!.vehicleNumber != null)
                              Text(
                                'Plate: ${_matchedReturningVisitor!.vehicleNumber}',
                                style: const TextStyle(color: AppConstants.textSecondary, fontSize: 12),
                              ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitEntry,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.accentAmber,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        child: const Text('1-Tap Check-In', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
              ],

              // Visitor Details Form
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppConstants.surfaceDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppConstants.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'VISITOR INFORMATION',
                      style: TextStyle(
                        color: AppConstants.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Full Name
                    _buildTextField(
                      controller: _nameController,
                      label: 'Full Name *',
                      icon: Icons.person_rounded,
                      validator: (val) => val == null || val.trim().isEmpty ? 'Full name is required' : null,
                    ),

                    const SizedBox(height: 14),

                    // Phone Number
                    _buildTextField(
                      controller: _phoneController,
                      label: 'Phone Number *',
                      icon: Icons.phone_rounded,
                      keyboardType: TextInputType.phone,
                      validator: (val) => val == null || val.trim().length < 10 ? 'Valid phone number required' : null,
                    ),

                    const SizedBox(height: 14),

                    // Vehicle Number
                    _buildTextField(
                      controller: _vehicleController,
                      label: 'Vehicle Plate Number',
                      icon: Icons.directions_car_rounded,
                      hint: 'e.g. TN19BE2844',
                    ),

                    const SizedBox(height: 14),

                    // Company / Department
                    _buildTextField(
                      controller: _companyController,
                      label: 'Company / Organization',
                      icon: Icons.business_rounded,
                      hint: 'e.g. EcoTech / Visitor',
                    ),

                    const SizedBox(height: 14),

                    // Category Dropdown
                    const Text('Visitor Category', style: TextStyle(color: AppConstants.textSecondary, fontSize: 12)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: AppConstants.primaryDark,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCategory,
                          dropdownColor: AppConstants.cardDark,
                          isExpanded: true,
                          style: const TextStyle(color: AppConstants.textPrimary, fontSize: 14),
                          items: AppConstants.visitorCategories
                              .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedCategory = val);
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Purpose / Notes
                    _buildTextField(
                      controller: _notesController,
                      label: 'Purpose of Visit / Notes',
                      icon: Icons.notes_rounded,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submitEntry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _matchedReturningVisitor != null ? AppConstants.accentAmber : AppConstants.accentGreen,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 4,
                ),
                icon: _isSubmitting
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                    : Icon(_matchedReturningVisitor != null ? Icons.repeat_rounded : Icons.check_circle_rounded),
                label: Text(
                  _matchedReturningVisitor != null ? 'CONFIRM RETURNING VISITOR ENTRY' : 'REGISTER & GRANT ENTRY PASS',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppConstants.textSecondary, fontSize: 12)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(color: AppConstants.textPrimary, fontSize: 14),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppConstants.cardDark, fontSize: 13),
            prefixIcon: Icon(icon, color: AppConstants.textSecondary, size: 20),
            filled: true,
            fillColor: AppConstants.primaryDark,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }
}
