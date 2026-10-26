import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/constants.dart';
import '../models/camera_match_event.dart';

class CameraMatchDialog extends StatelessWidget {
  final CameraMatchEvent event;
  final VoidCallback onConfirmEntry;
  final VoidCallback? onViewDetails;

  const CameraMatchDialog({
    super.key,
    required this.event,
    required this.onConfirmEntry,
    this.onViewDetails,
  });

  static Future<void> show(
    BuildContext context, {
    required CameraMatchEvent event,
    required VoidCallback onConfirmEntry,
    VoidCallback? onViewDetails,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => CameraMatchDialog(
        event: event,
        onConfirmEntry: onConfirmEntry,
        onViewDetails: onViewDetails,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visitor = event.visitor;
    final isFrequent = visitor.isFrequentVisitor;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppConstants.surfaceDark,
      elevation: 24,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: AppConstants.surfaceDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isFrequent ? AppConstants.accentAmber : AppConstants.accentGreen,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: (isFrequent ? AppConstants.accentAmber : AppConstants.accentGreen).withOpacity(0.25),
              blurRadius: 30,
              spreadRadius: 2,
            )
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
                    color: (isFrequent ? AppConstants.accentAmber : AppConstants.accentGreen).withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isFrequent ? Icons.stars_rounded : Icons.camera_alt_rounded,
                    color: isFrequent ? AppConstants.accentAmber : AppConstants.accentGreen,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isFrequent ? 'FREQUENT VISITOR DETECTED' : 'CAMERA MATCH DETECTED',
                        style: TextStyle(
                          color: isFrequent ? AppConstants.accentAmber : AppConstants.accentGreen,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        event.cameraName,
                        style: const TextStyle(
                          color: AppConstants.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: AppConstants.textSecondary, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),

            const SizedBox(height: 18),
            const Divider(color: AppConstants.borderLight, height: 1),
            const SizedBox(height: 18),

            // Visitor Profile Summary Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppConstants.primaryDark,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppConstants.borderLight),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppConstants.cardDark,
                    child: Text(
                      visitor.fullName.isNotEmpty ? visitor.fullName[0].toUpperCase() : 'V',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
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
                          style: const TextStyle(
                            color: AppConstants.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppConstants.cardDark,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                visitor.visitorCode,
                                style: const TextStyle(
                                  color: AppConstants.accentBlue,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            if (visitor.company != null)
                              Expanded(
                                child: Text(
                                  visitor.company!,
                                  style: const TextStyle(
                                    color: AppConstants.textSecondary,
                                    fontSize: 12,
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

            const SizedBox(height: 16),

            // Detection Metrics & Visit Stats
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppConstants.cardDark.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildDetailRow(
                    icon: Icons.repeat_rounded,
                    label: 'Total Visits',
                    value: '${visitor.totalVisits} visits (${isFrequent ? "Frequent" : "Returning"})',
                    valueColor: AppConstants.accentAmber,
                  ),
                  if (visitor.vehicleNumber != null && visitor.vehicleNumber!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      icon: Icons.directions_car_rounded,
                      label: 'Vehicle Plate',
                      value: visitor.vehicleNumber!,
                      valueColor: Colors.white,
                      isPlate: true,
                    ),
                  ],
                  if (visitor.phoneNumber != null) ...[
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      icon: Icons.phone_rounded,
                      label: 'Phone',
                      value: visitor.phoneNumber!,
                      valueColor: AppConstants.textSecondary,
                    ),
                  ],
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    icon: Icons.verified_user_rounded,
                    label: 'Match Confidence',
                    value: '${(event.confidence * 100).toStringAsFixed(1)}% (${event.matchType})',
                    valueColor: AppConstants.accentGreen,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

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
                    child: const Text('Dismiss'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onConfirmEntry();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.accentGreen,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.check_circle_rounded, size: 20),
                    label: const Text(
                      'Confirm Entry',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
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
    required IconData icon,
    required String label,
    required String value,
    required Color valueColor,
    bool isPlate = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppConstants.textSecondary),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(color: AppConstants.textSecondary, fontSize: 12),
        ),
        const Spacer(),
        if (isPlate)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.amber.shade900.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.amber.shade700, width: 0.8),
            ),
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.amber,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 1.1,
              ),
            ),
          )
        else
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
      ],
    );
  }
}
