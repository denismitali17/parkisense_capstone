import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../../core/theme/app_colors.dart';

class HistoryAnalyticsScreen extends StatefulWidget {
  const HistoryAnalyticsScreen({super.key});

  @override
  State<HistoryAnalyticsScreen> createState() => _HistoryAnalyticsScreenState();
}

class _HistoryAnalyticsScreenState extends State<HistoryAnalyticsScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Healthy', 'At Risk'];

  // Sample data - in production, this would come from Firestore
  final List<ScreeningRecord> _screeningRecords = [
    ScreeningRecord(
      date: '2 days ago',
      result: 'Healthy',
      confidence: 95,
      svmScore: 94,
      cnnScore: 96,
    ),
    ScreeningRecord(
      date: '1 week ago',
      result: 'Healthy',
      confidence: 92,
      svmScore: 90,
      cnnScore: 94,
    ),
    ScreeningRecord(
      date: '2 weeks ago',
      result: 'Healthy',
      confidence: 88,
      svmScore: 87,
      cnnScore: 89,
    ),
    ScreeningRecord(
      date: '3 weeks ago',
      result: 'Healthy',
      confidence: 91,
      svmScore: 89,
      cnnScore: 93,
    ),
    ScreeningRecord(
      date: '1 month ago',
      result: 'Healthy',
      confidence: 85,
      svmScore: 83,
      cnnScore: 87,
    ),
  ];

  List<ScreeningRecord> get _filteredRecords {
    if (_selectedFilter == 'All') return _screeningRecords;
    if (_selectedFilter == 'Healthy') {
      return _screeningRecords.where((r) => r.result == 'Healthy').toList();
    }
    return _screeningRecords.where((r) => r.result == 'At Risk').toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Screening History'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).iconTheme.color),
        titleTextStyle: TextStyle(
          color: Theme.of(context).appBarTheme.foregroundColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            color: Theme.of(context).cardTheme.color,
            child: Row(
              children: _filters.map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    selectedColor: AppColors.primaryBlue.withOpacity(0.2),
                    checkmarkColor: AppColors.primaryBlue,
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.primaryBlue : AppColors.textLight,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    backgroundColor: AppColors.backgroundLight,
                    side: BorderSide(
                      color: isSelected ? AppColors.primaryBlue : AppColors.borderGrey,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          
          Expanded(
            child: _filteredRecords.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history,
                          size: 64,
                          color: AppColors.borderGrey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No screenings found',
                          style: TextStyle(
                            fontSize: 18,
                            color: AppColors.textLight,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _filteredRecords.length,
                    itemBuilder: (context, index) {
                      final record = _filteredRecords[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildScreeningCard(record),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildScreeningCard(ScreeningRecord record) {
    final isHealthy = record.result == 'Healthy';
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: AppColors.borderGrey,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isHealthy 
                          ? AppColors.successGreen.withOpacity(0.1)
                          : AppColors.accentWarningRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isHealthy ? Icons.check_rounded : Icons.warning_rounded,
                      color: isHealthy ? AppColors.successGreen : AppColors.accentWarningRed,
                      size: 24,
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.result,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isHealthy ? AppColors.successGreen : AppColors.accentWarningRed,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        record.date,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${record.confidence}% Confidence',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Model Results
          Row(
            children: [
              Expanded(
                child: _buildModelResult(
                  label: 'SVM Model',
                  score: record.svmScore,
                ),
              ),
              
              const SizedBox(width: 12),
              
              Expanded(
                child: _buildModelResult(
                  label: 'CNN Model',
                  score: record.cnnScore,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryBlue,
                    side: const BorderSide(color: AppColors.primaryBlue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    _showDetailsDialog(record);
                  },
                  child: const Text('View Details'),
                ),
              ),
              
              const SizedBox(width: 12),
              
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    _showShareDialog(record);
                  },
                  icon: const Icon(Icons.share, size: 18),
                  label: const Text('Share'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModelResult({
    required String label,
    required int score,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).textTheme.bodySmall?.color,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$score%',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }

  void _showDetailsDialog(ScreeningRecord record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Screening Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Date', record.date),
              _buildDetailRow('Result', record.result),
              _buildDetailRow('Overall Confidence', '${record.confidence}%'),
              _buildDetailRow('SVM Model Score', '${record.svmScore}%'),
              _buildDetailRow('CNN Model Score', '${record.cnnScore}%'),
              const SizedBox(height: 16),
              const Text(
                'Acoustic Features',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildFeatureRow('Jitter (local)', '0.0032'),
              _buildFeatureRow('Jitter (absolute)', '4.2e-05'),
              _buildFeatureRow('Jitter (RAP)', '0.0016'),
              _buildFeatureRow('Jitter (PPQ5)', '0.0021'),
              _buildFeatureRow('Jitter (DDP)', '0.0048'),
              _buildFeatureRow('Shimmer (local)', '0.028'),
              _buildFeatureRow('Shimmer (local, dB)', '0.25'),
              _buildFeatureRow('Shimmer (APQ3)', '0.015'),
              _buildFeatureRow('Shimmer (APQ5)', '0.018'),
              _buildFeatureRow('Shimmer (APQ11)', '0.022'),
              _buildFeatureRow('Shimmer (DDA)', '0.045'),
              _buildFeatureRow('NHR', '0.014'),
              _buildFeatureRow('HNR', '24.5'),
              _buildFeatureRow('RPDE', '0.42'),
              _buildFeatureRow('DFA', '0.72'),
              _buildFeatureRow('PPE', '0.18'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              _exportToPDF(record);
            },
            child: const Text('Export PDF'),
          ),
        ],
      ),
    );
  }

  void _showShareDialog(ScreeningRecord record) {
    // Generate a unique share link (in production, this would be a real URL)
    final shareLink = 'https://parkisense.app/share/${DateTime.now().millisecondsSinceEpoch}';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share with Healthcare Provider'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: QrImageView(
                  data: shareLink,
                  version: QrVersions.auto,
                  size: 200.0,
                ),
              ),
              
              const SizedBox(height: 16),
              
              const Text(
                'Scan to View Results',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                'Healthcare providers can view this screening without logging in.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textLight,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: AppColors.primaryBlue,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Link expires in 7 days',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Share.share(
                'View my Parkinson\'s screening results: $shareLink',
                subject: 'ParkiSense Screening Results',
              );
            },
            icon: const Icon(Icons.link, size: 18),
            label: const Text('Copy Link'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('QR code saved to gallery'),
                  backgroundColor: AppColors.successGreen,
                ),
              );
            },
            icon: const Icon(Icons.download, size: 18),
            label: const Text('Save QR'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.textLight,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.textLight,
              fontSize: 13,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportToPDF(ScreeningRecord record) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Header(
                  level: 0,
                  child: pw.Text('ParkiSense Screening Report'),
                ),
                pw.SizedBox(height: 20),
                pw.Text('Date: ${record.date}'),
                pw.Text('Result: ${record.result}'),
                pw.Text('Overall Confidence: ${record.confidence}%'),
                pw.SizedBox(height: 20),
                pw.Header(level: 1, child: pw.Text('Model Results')),
                pw.Text('SVM Model Score: ${record.svmScore}%'),
                pw.Text('CNN Model Score: ${record.cnnScore}%'),
                pw.SizedBox(height: 20),
                pw.Header(level: 1, child: pw.Text('Acoustic Features')),
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey400),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(2),
                    1: const pw.FlexColumnWidth(1),
                  },
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Feature', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Value', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Jitter (local)')),
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('0.0032')),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Jitter (absolute)')),
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('4.2e-05')),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Jitter (RAP)')),
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('0.0016')),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Jitter (PPQ5)')),
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('0.0021')),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Jitter (DDP)')),
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('0.0048')),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Shimmer (local)')),
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('0.028')),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Shimmer (local, dB)')),
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('0.25')),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Shimmer (APQ3)')),
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('0.015')),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Shimmer (APQ5)')),
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('0.018')),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Shimmer (APQ11)')),
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('0.022')),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Shimmer (DDA)')),
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('0.045')),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('NHR')),
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('0.014')),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('HNR')),
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('24.5')),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('RPDE')),
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('0.42')),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('DFA')),
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('0.72')),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('PPE')),
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('0.18')),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 40),
                pw.Text(
                  'This report was generated by ParkiSense - Parkinson\'s Disease Voice Screening Application',
                  style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic),
                ),
              ],
            );
          },
        ),
      );

      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: 'parkisense_screening_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF exported successfully'),
            backgroundColor: AppColors.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting PDF: $e'),
            backgroundColor: AppColors.accentWarningRed,
          ),
        );
      }
    }
  }

  Future<void> _exportToCSV() async {
    try {
      final csvData = StringBuffer();
      csvData.writeln('Date,Result,Confidence,SVM Score,CNN Score');
      
      for (final record in _screeningRecords) {
        csvData.writeln('${record.date},${record.result},${record.confidence},${record.svmScore},${record.cnnScore}');
      }

      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/parkisense_screenings_${DateTime.now().millisecondsSinceEpoch}.csv';
      final file = File(path);
      await file.writeAsString(csvData.toString());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('CSV exported successfully'),
            backgroundColor: AppColors.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting CSV: $e'),
            backgroundColor: AppColors.accentWarningRed,
          ),
        );
      }
    }
  }
}

class ScreeningRecord {
  final String date;
  final String result;
  final int confidence;
  final int svmScore;
  final int cnnScore;

  ScreeningRecord({
    required this.date,
    required this.result,
    required this.confidence,
    required this.svmScore,
    required this.cnnScore,
  });
}