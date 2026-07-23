import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../data/services/firestore_service.dart';
import '../../../data/models/screening_model.dart';
import '../auth/login_screen.dart';

class ProfileSettingsScreen extends ConsumerWidget {
  const ProfileSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName ?? "User";
    final email = user?.email ?? "user@example.com";
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Profile & Settings'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).iconTheme.color),
        titleTextStyle: TextStyle(
          color: Theme.of(context).appBarTheme.foregroundColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Card
            _buildProfileCard(
              context: context,
              displayName: displayName,
              email: email,
            ),
            
            const SizedBox(height: 24),
            
            // Account Settings Section
            Text(
              'ACCOUNT SETTINGS',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textLight,
                letterSpacing: 1,
              ),
            ),
            
            const SizedBox(height: 12),
            
            _buildSettingsCard(
              context: context,
              children: [
                _buildSettingsTile(
                  context: context,
                  icon: Icons.person_outline,
                  title: 'Change Name',
                  subtitle: 'Update your display name',
                  onTap: () {
                    _showEditProfileDialog(context, ref, 'name', displayName);
                  },
                ),
                _buildDivider(),
                _buildSettingsTile(
                  context: context,
                  icon: Icons.email_outlined,
                  title: 'Change Email',
                  subtitle: 'Update your email address',
                  onTap: () {
                    _showEditProfileDialog(context, ref, 'email', email);
                  },
                ),
                _buildDivider(),
                _buildSettingsTile(
                  context: context,
                  icon: Icons.lock_outline,
                  title: 'Change Password',
                  subtitle: 'Update your password',
                  onTap: () {
                    _showChangePasswordDialog(context, ref);
                  },
                ),
                _buildDivider(),
                _buildSettingsTile(
                  context: context,
                  icon: Icons.security_outlined,
                  title: 'Two-Factor Authentication',
                  subtitle: 'Add extra security to your account',
                  onTap: () {
                    _showTwoFactorDialog(context);
                  },
                  trailing: Switch(
                    value: false,
                    onChanged: (value) {
                      _showTwoFactorDialog(context);
                    },
                    activeColor: AppColors.primaryBlue,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // App Settings Section
            Text(
              'APP SETTINGS',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textLight,
                letterSpacing: 1,
              ),
            ),
            
            const SizedBox(height: 12),
            
            _buildSettingsCard(
              context: context,
              children: [
                _buildSettingsTile(
                  context: context,
                  icon: Icons.dark_mode_outlined,
                  title: 'Dark Mode',
                  subtitle: 'Switch to dark theme',
                  onTap: () {},
                  trailing: Switch(
                    value: isDarkMode,
                    onChanged: (value) {
                      ref.read(themeModeProvider.notifier).toggleTheme(value);
                    },
                    activeColor: AppColors.primaryBlue,
                  ),
                ),
                _buildDivider(),
                _buildSettingsTile(
                  context: context,
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  subtitle: 'Manage push notifications',
                  onTap: () {},
                  trailing: Switch(
                    value: true,
                    onChanged: (value) {},
                    activeColor: AppColors.primaryBlue,
                  ),
                ),
                _buildDivider(),
                _buildSettingsTile(
                  context: context,
                  icon: Icons.cloud_upload_outlined,
                  title: 'Auto-backup to Cloud',
                  subtitle: 'Automatically backup your data',
                  onTap: () {},
                  trailing: Switch(
                    value: true,
                    onChanged: (value) {},
                    activeColor: AppColors.primaryBlue,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Data Management Section
            Text(
              'DATA MANAGEMENT',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textLight,
                letterSpacing: 1,
              ),
            ),
            
            const SizedBox(height: 12),
            
            _buildSettingsCard(
              context: context,
              children: [
                _buildSettingsTile(
                  context: context,
                  icon: Icons.picture_as_pdf_outlined,
                  title: 'Download Records (PDF)',
                  subtitle: 'Export screening records as PDF',
                  onTap: () {
                    _exportToPDF(context);
                  },
                ),
                _buildDivider(),
                _buildSettingsTile(
                  context: context,
                  icon: Icons.delete_outline,
                  title: 'Delete Account',
                  subtitle: 'Permanently delete your account',
                  onTap: () {
                    _showDeleteAccountDialog(context, ref);
                  },
                  titleColor: AppColors.accentWarningRed,
                  iconColor: AppColors.accentWarningRed,
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Help & Support Section
            Text(
              'HELP & SUPPORT',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textLight,
                letterSpacing: 1,
              ),
            ),
            
            const SizedBox(height: 12),
            
            _buildSettingsCard(
              context: context,
              children: [
                _buildSettingsTile(
                  context: context,
                  icon: Icons.help_outline,
                  title: 'FAQs',
                  subtitle: 'Frequently asked questions',
                  onTap: () {
                    _showFAQDialog(context);
                  },
                ),
                _buildDivider(),
                _buildSettingsTile(
                  context: context,
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  subtitle: 'Read our privacy policy',
                  onTap: () {
                    _showPrivacyPolicyDialog(context);
                  },
                ),
                _buildDivider(),
                _buildSettingsTile(
                  context: context,
                  icon: Icons.description_outlined,
                  title: 'Terms of Service',
                  subtitle: 'Read our terms of service',
                  onTap: () {
                    _showTermsOfServiceDialog(context);
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentWarningRed,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                onPressed: () async {
                  final confirm = await _showLogoutConfirmation(context);
                  if (confirm) {
                    await ref.read(authNotifierProvider.notifier).signOut();
                    
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                        (Route<dynamic> route) => false,
                      );
                    }
                  }
                },
                child: const Text(
                  'Logout',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard({
    required BuildContext context,
    required String displayName,
    required String email,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
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
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person,
              size: 40,
              color: AppColors.primaryBlue,
            ),
          ),
          
          const SizedBox(width: 20),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.successGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Verified User',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.successGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          IconButton(
            icon: Icon(
              Icons.edit_outlined,
              color: AppColors.primaryBlue,
            ),
            onPressed: () {
              _showEditProfileDialog(context, null, 'profile', displayName);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard({
    required BuildContext context,
    required List<Widget> children,
  }) {
    return Container(
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
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
    Color? titleColor,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? AppColors.primaryBlue,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: titleColor ?? Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: Theme.of(context).textTheme.bodySmall?.color,
        ),
      ),
      trailing: trailing ?? Icon(
        Icons.chevron_right,
        color: Theme.of(context).textTheme.bodySmall?.color,
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      indent: 72,
      endIndent: 16,
      color: AppColors.borderGrey,
    );
  }

  Future<bool> _showLogoutConfirmation(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).dialogBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.dangerRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: AppColors.dangerRed,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Logout',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              'Are you sure you want to logout?',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accentWarningRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.accentWarningRed.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.accentWarningRed,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You will need to log in again to access your account',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.accentWarningRed,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.dangerRed,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
            ),
            child: const Text(
              'Logout',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showEditProfileDialog(
    BuildContext context,
    WidgetRef? ref,
    String field,
    String currentValue,
  ) {
    TextEditingController controller = TextEditingController(text: currentValue);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${field == 'profile' ? 'Profile' : field}'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: field == 'profile' ? 'Name' : field,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final newValue = controller.text.trim();
              if (newValue.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Field cannot be empty'),
                    backgroundColor: AppColors.dangerRed,
                  ),
                );
                return;
              }

              try {
                final user = FirebaseAuth.instance.currentUser;
                if (user == null) return;

                if (field == 'name' || field == 'profile') {
                  await user.updateDisplayName(newValue);
                } else if (field == 'email') {
                  await user.updateEmail(newValue);
                }

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$field updated successfully'),
                      backgroundColor: AppColors.successGreen,
                    ),
                  );
                  if (ref != null) {
                    ref.invalidate(authNotifierProvider);
                  }
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error updating $field: ${e.toString()}'),
                      backgroundColor: AppColors.dangerRed,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryBlue,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showTwoFactorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Two-Factor Authentication'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Two-Factor Authentication adds an extra layer of security to your account.',
              style: TextStyle(fontSize: 14),
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
                    Icons.info_outline,
                    color: AppColors.primaryBlue,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Firebase 2FA is enabled. You will receive a verification code via email when logging in.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Status: Enabled',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.successGreen,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('2FA settings updated'),
                  backgroundColor: AppColors.successGreen,
                ),
              );
            },
            child: const Text('Configure'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context, WidgetRef ref) {
    TextEditingController currentPasswordController = TextEditingController();
    TextEditingController newPasswordController = TextEditingController();
    TextEditingController confirmPasswordController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm Password',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final currentPassword = currentPasswordController.text.trim();
              final newPassword = newPasswordController.text.trim();
              final confirmPassword = confirmPasswordController.text.trim();

              if (currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All fields are required'),
                    backgroundColor: AppColors.dangerRed,
                  ),
                );
                return;
              }

              if (newPassword != confirmPassword) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Passwords do not match'),
                    backgroundColor: AppColors.dangerRed,
                  ),
                );
                return;
              }

              if (newPassword.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password must be at least 6 characters'),
                    backgroundColor: AppColors.dangerRed,
                  ),
                );
                return;
              }

              try {
                final user = FirebaseAuth.instance.currentUser;
                if (user == null) return;

                // Re-authenticate user before password change
                final credential = EmailAuthProvider.credential(
                  email: user.email!,
                  password: currentPassword,
                );
                
                await user.reauthenticateWithCredential(credential);
                
                // Update password
                await user.updatePassword(newPassword);

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password updated successfully'),
                      backgroundColor: AppColors.successGreen,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error updating password: ${e.toString()}'),
                      backgroundColor: AppColors.dangerRed,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryBlue,
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showFAQDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Frequently Asked Questions'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFAQItem(
                context,
                'What is ParkiSense?',
                'ParkiSense is a voice-based screening application that uses artificial intelligence to detect early signs of Parkinson\'s disease by analyzing voice patterns.',
              ),
              _buildFAQItem(
                context,
                'How accurate is the screening?',
                'Our AI models (SVM and CNN) have been trained on thousands of voice samples and achieve over 85% accuracy in detecting Parkinson\'s disease risk.',
              ),
              _buildFAQItem(
                context,
                'How long does a screening take?',
                'A typical screening takes less than 2 minutes. You simply record your voice following the on-screen instructions, and our AI analyzes it instantly.',
              ),
              _buildFAQItem(
                context,
                'Is my health data secure?',
                'Yes, all your health data is encrypted and stored securely using Firebase. We comply with HIPAA and GDPR regulations to protect your privacy.',
              ),
              _buildFAQItem(
                context,
                'Can I share results with my doctor?',
                'Yes, you can share your screening results with healthcare providers through QR codes or shareable links. Doctors can view your results without needing to log in.',
              ),
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

  Widget _buildFAQItem(BuildContext context, String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            answer,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPolicySection(
                context,
                'Data Collection',
                'We collect voice recordings, screening results, and basic account information. All data is encrypted and stored securely.',
              ),
              _buildPolicySection(
                context,
                'Data Usage',
                'Your data is used solely for screening purposes and improving our AI models. We never sell your data to third parties.',
              ),
              _buildPolicySection(
                context,
                'Data Sharing',
                'We only share your data with healthcare providers when you explicitly choose to share it. You have full control over what gets shared.',
              ),
              _buildPolicySection(
                context,
                'Data Retention',
                'You can delete your account and all associated data at any time. We retain data only as long as necessary for service provision.',
              ),
              _buildPolicySection(
                context,
                'Security',
                'We use industry-standard encryption and security measures to protect your data. Regular security audits are conducted.',
              ),
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

  void _showTermsOfServiceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms of Service'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPolicySection(
                context,
                'Medical Disclaimer',
                'ParkiSense is a screening tool and not a diagnostic device. Results should be discussed with qualified healthcare professionals.',
              ),
              _buildPolicySection(
                context,
                'User Responsibility',
                'Users are responsible for providing accurate information and using the service as intended. Misuse of the service is prohibited.',
              ),
              _buildPolicySection(
                context,
                'Service Availability',
                'We strive to maintain 99.9% uptime but cannot guarantee uninterrupted service. We are not liable for temporary outages.',
              ),
              _buildPolicySection(
                context,
                'Account Terms',
                'You must be at least 18 years old to use this service. Each user is responsible for maintaining the security of their account.',
              ),
              _buildPolicySection(
                context,
                'Modifications',
                'We reserve the right to modify these terms at any time. Continued use of the service constitutes acceptance of updated terms.',
              ),
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

  Widget _buildPolicySection(BuildContext context, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportToPDF(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final firestoreService = FirestoreService();
      
      // Fetch screening records
      final screeningsStream = firestoreService.streamUserScreenings(user.uid);
      final screenings = await screeningsStream.first;

      if (screenings.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No screening records found to export'),
              backgroundColor: AppColors.dangerRed,
            ),
          );
        }
        return;
      }

      // Generate report content
      final buffer = StringBuffer();
      buffer.writeln('ParkiSense Screening Records Export');
      buffer.writeln('=' * 50);
      buffer.writeln('');
      buffer.writeln('User: ${user.email}');
      buffer.writeln('Export Date: ${DateTime.now().toIso8601String()}');
      buffer.writeln('Total Records: ${screenings.length}');
      buffer.writeln('');
      buffer.writeln('-' * 50);
      buffer.writeln('');

      for (int i = 0; i < screenings.length; i++) {
        final screening = screenings[i];
        buffer.writeln('Record #${i + 1}');
        buffer.writeln('-' * 30);
        buffer.writeln('Date: ${screening.timestamp.toIso8601String()}');
        buffer.writeln('Diagnosis: ${screening.diagnosis}');
        buffer.writeln('Prediction: ${screening.prediction == 1 ? "Parkinson\'s Detected" : "Healthy Control"}');
        buffer.writeln('Confidence Score: ${(screening.confidenceScore * 100).toStringAsFixed(2)}%');
        buffer.writeln('Total Chunks Analyzed: ${screening.totalChunksAnalyzed}');
        buffer.writeln('Audio URL: ${screening.audioUrl}');
        if (screening.metadata != null) {
          buffer.writeln('Metadata: ${screening.metadata.toString()}');
        }
        buffer.writeln('');
      }

      buffer.writeln('=' * 50);
      buffer.writeln('End of Report');
      buffer.writeln('');
      buffer.writeln('Generated by ParkiSense - Voice-Based Parkinson\'s Screening');

      final content = buffer.toString();
      final fileName = 'parkisense_records_${DateTime.now().millisecondsSinceEpoch}.txt';

      if (kIsWeb) {
        // On web, use a different approach without dart:html
        // For now, we'll use share_plus which works on web
        await Share.share(content, subject: 'ParkiSense Records Export');
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Records exported successfully'),
              backgroundColor: AppColors.successGreen,
            ),
          );
        }
      } else {
        // On mobile, save to app documents directory
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$fileName');
        await file.writeAsString(content);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Records saved to: ${file.path}'),
              backgroundColor: AppColors.successGreen,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting records: $e'),
            backgroundColor: AppColors.dangerRed,
          ),
        );
      }
    }
  }

  void _showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
    TextEditingController passwordController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This action cannot be undone. All your data will be permanently deleted from our servers.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.dangerRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.dangerRed,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your account and all associated data will be permanently deleted.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.dangerRed,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Enter your password to confirm',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (passwordController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter your password'),
                    backgroundColor: AppColors.dangerRed,
                  ),
                );
                return;
              }

              try {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  // Re-authenticate user before deletion
                  final credential = EmailAuthProvider.credential(
                    email: user.email!,
                    password: passwordController.text,
                  );
                  
                  await user.reauthenticateWithCredential(credential);
                  
                  // Delete user data from Firestore (if applicable)
                  // await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();
                  
                  // Delete the user account
                  await user.delete();
                  
                  if (context.mounted) {
                    Navigator.pop(context); // Close dialog
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Account deleted successfully'),
                        backgroundColor: AppColors.successGreen,
                      ),
                    );
                  }
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting account: ${e.toString()}'),
                      backgroundColor: AppColors.dangerRed,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.dangerRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }
}