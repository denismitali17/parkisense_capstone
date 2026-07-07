import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../auth/login_screen.dart';

class ProfileSettingsScreen extends ConsumerWidget {
  const ProfileSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Workspace Settings')),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          ListTile(
            leading: const Icon(Icons.person_outline, color: AppColors.primaryDarkNavy),
            title: const Text('Account Classification'),
            subtitle: const Text('Clinical Practitioner Mode'),
            trailing: const Chip(label: Text('Verified', style: TextStyle(fontSize: 11))),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.shield_outlined),
            title: const Text('Compliance Logs'),
            subtitle: const Text('HIPAA & GDPR Attestation Profile'),
            onTap: () {},
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentWarningRed,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {

              await ref.read(authNotifierProvider.notifier).signOut();


              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (Route<dynamic> route) => false,
                );
              }
            },
            child: const Text('Logout'),
          )
        ],
      ),
    );
  }
}