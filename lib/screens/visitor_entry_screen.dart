import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:google_fonts/google_fonts.dart';
import 'package:heroicons/heroicons.dart';
import 'package:image_picker/image_picker.dart';
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
  XFile? _profilePhoto;
  Uint8List? _profilePhotoBytes;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _handleSearch(String query) async {
    if (query.trim().length < 3) {
      setState(() => _matchedReturningVisitor = null);
      return;
    }

    Future<void> _pickProfilePhoto() async {
      final picker = ImagePicker();
      final photo = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1200,
        imageQuality: 85,
      ) ?? await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        imageQuality: 85,
      );
      if (photo == null) return;
      final bytes = await photo.readAsBytes();
      if (mounted) {
        setState(() {
          _profilePhoto = photo;
          _profilePhotoBytes = bytes;
        });
      }
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
            SnackBar(
              backgroundColor: AppConstants.accentRed,
              behavior: SnackBarBehavior.floating,
              content: Text(
                'Failed to confirm entry. Check server.',
                style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
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
        profilePhotoPath: _profilePhoto?.path,
        profilePhotoBytes: _profilePhotoBytes,
        profilePhotoName: _profilePhoto?.name ?? 'visitor.jpg',
      );

      setState(() => _isSubmitting = false);
      if (mounted && newVisitor != null) {
        _showSuccessPassDialog(newVisitor, isReturning: false);
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppConstants.accentRed,
            behavior: SnackBarBehavior.floating,
            content: Text(
              'Error: $e',
              style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        );
      }
    }
  }

  void _showSuccessPassDialog(Visitor visitor, {required bool isReturning}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppConstants.surfaceWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppConstants.greenLight,
                shape: BoxShape.circle,
              ),
              child: const HeroIcon(
                HeroIcons.checkCircle,
                color: AppConstants.accentGreen,
                size: 26,
                style: HeroIconStyle.solid,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isReturning ? 'Entry Confirmed!' : 'Visitor Registered!',
                style: GoogleFonts.roboto(
                  color: AppConstants.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        content: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppConstants.greenSubtle,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppConstants.accentGreen.withValues(alpha: 0.2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isReturning)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppConstants.amberLight,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppConstants.accentAmber.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const HeroIcon(HeroIcons.sparkles, size: 14, color: AppConstants.accentAmber, style: HeroIconStyle.solid),
                      const SizedBox(width: 6),
                      Text(
                        'Returning Visitor (Visit #${visitor.totalVisits + 1})',
                        style: GoogleFonts.nunito(
                          color: AppConstants.accentAmber,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              Text(
                'Pass Code: ${visitor.visitorCode}',
                style: GoogleFonts.roboto(
                  color: AppConstants.accentGreen,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Divider(color: AppConstants.borderLight),
              const SizedBox(height: 8),
              Text(
                'Name: ${visitor.fullName}',
                style: GoogleFonts.nunito(
                  color: AppConstants.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              if (visitor.vehicleNumber != null && visitor.vehicleNumber!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Vehicle: ${visitor.vehicleNumber}',
                  style: GoogleFonts.nunito(
                    color: AppConstants.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
              const SizedBox(height: 4),
              Text(
                'Gate: Gate 1 (Visitor Access)',
                style: GoogleFonts.nunito(
                  color: AppConstants.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.accentGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              'Done & Print Badge',
              style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
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
          'VISITOR REGISTRATION & ENTRY',
          style: GoogleFonts.roboto(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: AppConstants.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Search / Autofill Bar Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppConstants.surfaceWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppConstants.accentBlue.withValues(alpha: 0.4), width: 1.2),
                  boxShadow: AppConstants.softShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppConstants.blueLight,
                            shape: BoxShape.circle,
                          ),
                          child: const HeroIcon(
                            HeroIcons.magnifyingGlass,
                            color: AppConstants.accentBlue,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'RETURNING VISITOR LOOKUP',
                          style: GoogleFonts.roboto(
                            color: AppConstants.accentBlue,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _searchController,
                      style: GoogleFonts.nunito(color: AppConstants.textPrimary, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Enter phone number, last 4 digits, or vehicle plate...',
                        hintStyle: GoogleFonts.nunito(color: AppConstants.textMuted, fontSize: 13),
                        filled: true,
                        fillColor: AppConstants.inputFill,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                          borderSide: const BorderSide(color: AppConstants.accentBlue, width: 1.5),
                        ),
                        suffixIcon: _isSearching
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: AppConstants.accentBlue),
                                ),
                              )
                            : IconButton(
                                icon: const HeroIcon(HeroIcons.arrowRight, color: AppConstants.accentBlue, size: 18),
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
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppConstants.surfaceWhite,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppConstants.accentAmber, width: 1.5),
                    boxShadow: AppConstants.softShadow,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: AppConstants.amberLight,
                          shape: BoxShape.circle,
                        ),
                        child: const HeroIcon(
                          HeroIcons.sparkles,
                          color: AppConstants.accentAmber,
                          size: 26,
                          style: HeroIconStyle.solid,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'RETURNING VISITOR (${_matchedReturningVisitor!.totalVisits} PREVIOUS VISITS)',
                              style: GoogleFonts.roboto(
                                color: AppConstants.accentAmber,
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${_matchedReturningVisitor!.fullName} • Code: ${_matchedReturningVisitor!.visitorCode}',
                              style: GoogleFonts.roboto(
                                color: AppConstants.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            if (_matchedReturningVisitor!.vehicleNumber != null)
                              Text(
                                'Plate: ${_matchedReturningVisitor!.vehicleNumber}',
                                style: GoogleFonts.nunito(color: AppConstants.textSecondary, fontSize: 12),
                              ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitEntry,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.accentAmber,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(
                          '1-Tap Check-In',
                          style: GoogleFonts.nunito(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
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
                  color: AppConstants.surfaceWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppConstants.borderLight),
                  boxShadow: AppConstants.softShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                          'VISITOR INFORMATION',
                          style: GoogleFonts.roboto(
                            color: AppConstants.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Full Name
                    _buildTextField(
                      controller: _nameController,
                      label: 'Full Name *',
                      heroIcon: HeroIcons.user,
                      hint: 'e.g. Rahul Sharma',
                      validator: (val) => val == null || val.trim().isEmpty ? 'Full name is required' : null,
                    ),

                    const SizedBox(height: 14),

                    // Phone Number
                    _buildTextField(
                      controller: _phoneController,
                      label: 'Phone Number *',
                      heroIcon: HeroIcons.phone,
                      hint: 'e.g. +91 98765 43210',
                      keyboardType: TextInputType.phone,
                      validator: (val) => val == null || val.trim().length < 10 ? 'Valid phone number required' : null,
                    ),

                    const SizedBox(height: 14),

                    // Vehicle Number
                    _buildTextField(
                      controller: _vehicleController,
                      label: 'Vehicle Plate Number',
                      heroIcon: HeroIcons.truck,
                      hint: 'e.g. TN19BE2844',
                    ),

                    const SizedBox(height: 14),

                    // Company / Department
                    _buildTextField(
                      controller: _companyController,
                      label: 'Company / Organization',
                      heroIcon: HeroIcons.buildingOffice,
                      hint: 'e.g. EcoTech / Visitor',
                    ),

                    const SizedBox(height: 14),

                    Text(
                      'Visitor Photo',
                      style: GoogleFonts.nunito(
                        color: AppConstants.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: _pickProfilePhoto,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppConstants.inputFill,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppConstants.borderLight),
                        ),
                        child: Row(
                          children: [
                            if (_profilePhotoBytes != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.memory(
                                  _profilePhotoBytes!,
                                  width: 52,
                                  height: 52,
                                  fit: BoxFit.cover,
                                ),
                              )
                            else
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: AppConstants.blueLight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const HeroIcon(
                                  HeroIcons.camera,
                                  color: AppConstants.accentBlue,
                                  size: 24,
                                ),
                              ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _profilePhoto == null
                                    ? 'Capture or choose a photo for identification'
                                    : 'Photo selected — tap to replace',
                                style: GoogleFonts.nunito(
                                  color: AppConstants.textSecondary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const HeroIcon(
                              HeroIcons.arrowUpTray,
                              color: AppConstants.accentBlue,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Category Dropdown
                    Text(
                      'Visitor Category',
                      style: GoogleFonts.nunito(
                        color: AppConstants.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: AppConstants.inputFill,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppConstants.borderLight),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCategory,
                          dropdownColor: AppConstants.surfaceWhite,
                          isExpanded: true,
                          style: GoogleFonts.nunito(color: AppConstants.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
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
                      heroIcon: HeroIcons.documentText,
                      hint: 'e.g. Meeting with Facility Manager',
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
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 2,
                  shadowColor: AppConstants.accentGreen.withValues(alpha: 0.3),
                ),
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : HeroIcon(
                        _matchedReturningVisitor != null ? HeroIcons.arrowPath : HeroIcons.checkCircle,
                        size: 20,
                        color: Colors.white,
                        style: HeroIconStyle.solid,
                      ),
                label: Text(
                  _matchedReturningVisitor != null ? 'CONFIRM RETURNING VISITOR ENTRY' : 'REGISTER & GRANT ENTRY PASS',
                  style: GoogleFonts.roboto(fontWeight: FontWeight.w800, fontSize: 14, letterSpacing: 0.6),
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
    required HeroIcons heroIcon,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.nunito(color: AppConstants.textSecondary, fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: GoogleFonts.nunito(color: AppConstants.textPrimary, fontSize: 14),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.nunito(color: AppConstants.textMuted, fontSize: 13),
            prefixIcon: Padding(
              padding: const EdgeInsets.all(12),
              child: HeroIcon(heroIcon, color: AppConstants.textSecondary, size: 20),
            ),
            filled: true,
            fillColor: AppConstants.inputFill,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppConstants.borderLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppConstants.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppConstants.accentGreen, width: 1.6),
            ),
          ),
        ),
      ],
    );
  }
}
