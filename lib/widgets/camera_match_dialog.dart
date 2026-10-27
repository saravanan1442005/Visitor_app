import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:heroicons/heroicons.dart';
import '../config/constants.dart';
import '../models/camera_match_event.dart';

class CameraMatchDialog extends StatelessWidget {
  final CameraMatchEvent event;
  final VoidCallback onConfirmEntry;
  final VoidCallback? onConfirmExit;
  final VoidCallback? onViewDetails;

  const CameraMatchDialog({
    super.key,
    required this.event,
    required this.onConfirmEntry,
    this.onConfirmExit,
    this.onViewDetails,
  });

  static Future<void> show(
    BuildContext context, {
    required CameraMatchEvent event,
    required VoidCallback onConfirmEntry,
    VoidCallback? onConfirmExit,
    VoidCallback? onViewDetails,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => CameraMatchDialog(
        event: event,
        onConfirmEntry: onConfirmEntry,
        onConfirmExit: onConfirmExit,
        onViewDetails: onViewDetails,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visitor = event.visitor;
    final isFrequent = visitor.isFrequentVisitor;
    final primaryColor = isFrequent ? AppConstants.accentAmber : AppConstants.accentGreen;
    final lightColor = isFrequent ? AppConstants.amberLight : AppConstants.greenLight;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: AppConstants.surfaceWhite,
      elevation: 12,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: AppConstants.surfaceWhite,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: primaryColor.withValues(alpha: 0.6),
            width: 1.8,
          ),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.15),
              blurRadius: 24,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Alert Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: lightColor,
                    shape: BoxShape.circle,
                  ),
                  child: HeroIcon(
                    isFrequent ? HeroIcons.sparkles : HeroIcons.videoCamera,
                    color: primaryColor,
                    size: 24,
                    style: HeroIconStyle.solid,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isFrequent ? 'FREQUENT VISITOR DETECTED' : 'CAMERA MATCH DETECTED',
                        style: GoogleFonts.roboto(
                          color: primaryColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        event.cameraName,
                        style: GoogleFonts.nunito(
                          color: AppConstants.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const HeroIcon(HeroIcons.xMark, color: AppConstants.textMuted, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(color: AppConstants.borderLight, height: 1),
            const SizedBox(height: 16),

            // Visitor Profile Summary Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppConstants.inputFill,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppConstants.borderLight),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: lightColor,
                    child: Text(
                      visitor.fullName.isNotEmpty ? visitor.fullName[0].toUpperCase() : 'V',
                      style: GoogleFonts.roboto(
                        color: primaryColor,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          visitor.fullName,
                          style: GoogleFonts.roboto(
                            color: AppConstants.textPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppConstants.blueLight,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppConstants.accentBlue.withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                visitor.visitorCode,
                                style: GoogleFonts.roboto(
                                  color: AppConstants.accentBlue,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (visitor.company != null && visitor.company!.isNotEmpty)
                              Expanded(
                                child: Text(
                                  visitor.company!,
                                  style: GoogleFonts.nunito(
                                    color: AppConstants.textSecondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Detection Metrics & Visit Stats
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppConstants.surfaceWhite,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppConstants.borderLight),
              ),
              child: Column(
                children: [
                  _buildDetailRow(
                    heroIcon: HeroIcons.sparkles,
                    label: 'Total Visits',
                    value: '${visitor.totalVisits} visits (${isFrequent ? "Frequent" : "Returning"})',
                    valueColor: AppConstants.accentAmber,
                  ),
                  if (visitor.vehicleNumber != null && visitor.vehicleNumber!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      heroIcon: HeroIcons.truck,
                      label: 'Vehicle Plate',
                      value: visitor.vehicleNumber!,
                      valueColor: AppConstants.textPrimary,
                      isPlate: true,
                    ),
                  ],
                  if (visitor.phoneNumber != null && visitor.phoneNumber!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      heroIcon: HeroIcons.phone,
                      label: 'Phone',
                      value: visitor.phoneNumber!,
                      valueColor: AppConstants.textSecondary,
                    ),
                  ],
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    heroIcon: HeroIcons.shieldCheck,
                    label: 'Match Confidence',
                    value: '${(event.confidence * 100).toStringAsFixed(1)}% (${event.matchType})',
                    valueColor: AppConstants.accentGreen,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppConstants.textSecondary,
                      side: const BorderSide(color: AppConstants.borderLight),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      'Dismiss',
                      style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      if (event.eventType == 'EXIT' && onConfirmExit != null) {
                        onConfirmExit!();
                      } else {
                        onConfirmEntry();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.accentGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 2,
                      shadowColor: AppConstants.accentGreen.withValues(alpha: 0.3),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: HeroIcon(
                      event.eventType == 'EXIT' ? HeroIcons.arrowRightOnRectangle : HeroIcons.checkCircle,
                      size: 20,
                      color: Colors.white,
                      style: HeroIconStyle.solid,
                    ),
                    label: Text(
                      event.eventType == 'EXIT' ? 'Confirm Exit' : 'Confirm Entry',
                      style: GoogleFonts.roboto(fontWeight: FontWeight.w800, fontSize: 14, letterSpacing: 0.5),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required HeroIcons heroIcon,
    required String label,
    required String value,
    required Color valueColor,
    bool isPlate = false,
  }) {
    return Row(
      children: [
        HeroIcon(heroIcon, size: 16, color: AppConstants.textSecondary),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.nunito(color: AppConstants.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const Spacer(),
        if (isPlate)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppConstants.amberLight,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppConstants.accentAmber.withValues(alpha: 0.4), width: 0.8),
            ),
            child: Text(
              value,
              style: GoogleFonts.roboto(
                color: AppConstants.accentAmber,
                fontWeight: FontWeight.w800,
                fontSize: 12,
                letterSpacing: 1.0,
              ),
            ),
          )
        else
          Text(
            value,
            style: GoogleFonts.nunito(
              color: valueColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
      ],
    );
  }
}
