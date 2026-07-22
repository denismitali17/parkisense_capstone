import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/screening_model.dart';

class ResultsScreen extends StatefulWidget {
  final ScreeningModel screening;
  final bool showAppointmentDialog;
  const ResultsScreen({super.key, required this.screening, this.showAppointmentDialog = false});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.showAppointmentDialog) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _showAppointmentDialog();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDetected = widget.screening.prediction == 1;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Biometric Diagnostics Analysis'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Structural Risk Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDetected ? AppColors.accentWarningRed : AppColors.successGreen,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CLASSIFIER REPORT EVALUATION',
                    style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.8), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.1),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.screening.diagnosis,
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Ensemble Prediction Confidence:',
                        style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.9), fontSize: 14),
                      ),
                      Text(
                        '${(widget.screening.confidenceScore * 100).toStringAsFixed(2)}%',
                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            Text('Statistical Architecture Verification', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            // Evaluated Metric Checklist Data Matrix
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildFeatureMetricRow(context, 'Total Audio Chunks Evaluated', '${widget.screening.totalChunksAnalyzed} Blocks'),
                    const Divider(),
                    _buildFeatureMetricRow(context, 'Core Jitter Dist. Variant', 'Evaluated (16-bit Matrix)'),
                    const Divider(),
                    _buildFeatureMetricRow(context, 'Shimmer Amplitude Variance', 'Processed (Log Scale)'),
                    const Divider(),
                    _buildFeatureMetricRow(context, '13 MFCC Coefficients Array', 'Aligned (sr=None)'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Medical Disclaimer Notice Board
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderGrey),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.gavel_outlined, color: AppColors.textLight, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Disclaimer: ParkiSense is an exploratory acoustic analysis screening mechanism. This output does not establish direct secondary medical verification. Results must be cross-analyzed by certified neurology infrastructure teams.',
                      style: TextStyle(color: AppColors.textLight, fontSize: 12, height: 1.4),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Share Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => _showShareDialog(context),
              icon: const Icon(Icons.share_rounded),
              label: const Text('Share Report', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDarkNavy,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
              child: const Text('Dismiss Report and Sync Workspace', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureMetricRow(BuildContext context, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      key: ValueKey(title),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showShareDialog(BuildContext context) {
    final shareLink = 'https://parkisense.app/report/${widget.screening.id}';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Share Report',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: QrImageView(
                data: shareLink,
                version: QrVersions.auto,
                size: 200.0,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              shareLink,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: shareLink));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Link copied to clipboard'),
                  backgroundColor: AppColors.successGreen,
                ),
              );
            },
            icon: const Icon(Icons.copy),
            label: Text(
              'Copy Link',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.close),
            label: Text(
              'Close',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAppointmentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Parkinson\'s Detected',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: AppColors.dangerRed,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.warning_rounded,
              color: AppColors.dangerRed,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Based on the analysis, indicators of Parkinson\'s disease were detected. We recommend booking an appointment with a specialist for further evaluation.',
              style: GoogleFonts.poppins(
                fontSize: 14,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Maybe Later',
              style: GoogleFonts.poppins(
                color: AppColors.textLight,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/appointment');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Book Appointment',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}