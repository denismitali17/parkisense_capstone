import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class HistoryAnalyticsScreen extends StatelessWidget {
  const HistoryAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Longitudinal Screening Trends')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.stacked_line_chart, size: 64, color: AppColors.secondaryBlue),
              const SizedBox(height: 16),
              Text('Analytical Aggregates Active', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text('Continuous user session telemetry tracks structural phonation anomalies over time.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}