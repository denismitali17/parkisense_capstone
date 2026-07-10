import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/screening_model.dart';
import '../../../data/services/firestore_service.dart';

class HistoryAnalyticsScreen extends ConsumerStatefulWidget {
  const HistoryAnalyticsScreen({super.key});

  @override
  ConsumerState<HistoryAnalyticsScreen> createState() => _HistoryAnalyticsScreenState();
}

class _HistoryAnalyticsScreenState extends ConsumerState<HistoryAnalyticsScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Healthy', 'At Risk'];
  final FirestoreService _firestoreService = FirestoreService();

  List<ScreeningModel> _screenings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadScreenings();
  }

  Future<void> _loadScreenings() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      _firestoreService.streamUserScreenings(user.uid).listen((screenings) {
        if (mounted) {
          setState(() {
            _screenings = screenings;
            _isLoading = false;
          });
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<ScreeningModel> get _filteredScreenings {
    if (_selectedFilter == 'All') return _screenings;
    if (_selectedFilter == 'Healthy') {
      return _screenings.where((s) => s.prediction == 0).toList();
    }
    return _screenings.where((s) => s.prediction == 1).toList();
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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredScreenings.isEmpty
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
                        itemCount: _filteredScreenings.length,
                        itemBuilder: (context, index) {
                          final screening = _filteredScreenings[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildScreeningCard(screening),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildScreeningCard(ScreeningModel screening) {
    final isHealthy = screening.prediction == 0;
    
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
                        screening.diagnosis,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isHealthy ? AppColors.successGreen : AppColors.accentWarningRed,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(screening.timestamp),
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
                  '${(screening.confidenceScore * 100).toStringAsFixed(1)}% Confidence',
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
          
          // Additional Info
          Row(
            children: [
              Icon(
                Icons.analytics_rounded,
                size: 16,
                color: AppColors.textLight,
              ),
              const SizedBox(width: 8),
              Text(
                '${screening.totalChunksAnalyzed} chunks analyzed',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textLight,
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
                    _showDetailsDialog(screening);
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
                    _showShareDialog(screening);
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

  void _showDetailsDialog(ScreeningModel screening) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Screening Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Date', _formatDate(screening.timestamp)),
              _buildDetailRow('Result', screening.diagnosis),
              _buildDetailRow('Overall Confidence', '${(screening.confidenceScore * 100).toStringAsFixed(1)}%'),
              _buildDetailRow('Chunks Analyzed', '${screening.totalChunksAnalyzed}'),
              _buildDetailRow('Screening ID', screening.id),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showShareDialog(ScreeningModel screening) {
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else {
      return '${(difference.inDays / 30).floor()} months ago';
    }
  }

  Future<void> _exportToCSV() async {
    try {
      final csvData = StringBuffer();
      csvData.writeln('Date,Result,Confidence,Chunks Analyzed');
      
      for (final screening in _screenings) {
        csvData.writeln('${_formatDate(screening.timestamp)},${screening.diagnosis},${(screening.confidenceScore * 100).toStringAsFixed(1)},${screening.totalChunksAnalyzed}');
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