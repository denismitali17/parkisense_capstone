import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        title: Row(
          children: [
            Icon(
              Icons.health_and_safety_rounded,
              color: AppColors.primaryBlue,
              size: 32,
            ),
            const SizedBox(width: 8),
            Text(
              'ParkiSense',
              style: TextStyle(
                color: Theme.of(context).appBarTheme.foregroundColor,
                fontWeight: FontWeight.bold,
                fontSize: 20,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryBlue,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text(
              'Login',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const SignUpScreen()),
              );
            },
            child: Text(
              'Sign Up',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryDarkNavy,
                    AppColors.secondaryBlue,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  // Hero Icon
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.record_voice_over_rounded,
                      size: 64,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Hero Title
                  Text(
                    'Parkinson\'s Disease',
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  Text(
                    'Voice Screening',
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  // Hero Description
                  Text(
                    'Detect early signs through advanced voice analysis',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.white.withOpacity(0.9),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Services Section
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Text(
                    'OUR SERVICES',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.headlineMedium?.color,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Service Card 1
                  _buildServiceCard(
                    context: context,
                    icon: Icons.mic_rounded,
                    title: 'Instant Voice Screening',
                    description: 'Record a quick voice sample for analysis',
                  ),

                  const SizedBox(height: 16),

                  // Service Card 2
                  _buildServiceCard(
                    context: context,
                    icon: Icons.security_rounded,
                    title: 'Secure Health Records',
                    description: 'All data encrypted and stored safely',
                  ),

                  const SizedBox(height: 16),

                  // Service Card 3
                  _buildServiceCard(
                    context: context,
                    icon: Icons.medical_services_rounded,
                    title: 'Professional Insights',
                    description: 'Share results with doctors for expert consultation',
                  ),

                  const SizedBox(height: 48),

                  // CTA Buttons
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    child: Text(
                      'Login',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryBlue,
                      minimumSize: const Size(double.infinity, 56),
                      side: const BorderSide(color: AppColors.primaryBlue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const SignUpScreen()),
                      );
                    },
                    child: Text(
                      'Sign Up',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Footer Links
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          _showPrivacyPolicyDialog(context);
                        },
                        child: Text(
                          'Privacy Policy',
                          style: TextStyle(
                            color: AppColors.textLight,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '|',
                        style: TextStyle(
                          color: AppColors.borderGrey,
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () {
                          _showAboutUsDialog(context);
                        },
                        child: Text(
                          'About Us',
                          style: TextStyle(
                            color: AppColors.textLight,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
  }) {
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
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppColors.primaryBlue,
              size: 28,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),

          Icon(
            Icons.check_circle_rounded,
            color: AppColors.successGreen,
            size: 24,
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

  void _showAboutUsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About ParkiSense'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPolicySection(
                context,
                'Our Mission',
                'ParkiSense is dedicated to making Parkinson\'s disease screening accessible to everyone through advanced AI technology.',
              ),
              _buildPolicySection(
                context,
                'Technology',
                'Our platform uses state-of-the-art machine learning models to analyze voice patterns and detect early signs of Parkinson\'s disease.',
              ),
              _buildPolicySection(
                context,
                'Team',
                'We are a team of healthcare professionals, researchers, and software engineers committed to improving early diagnosis.',
              ),
              _buildPolicySection(
                context,
                'Contact',
                'For inquiries, please contact us at support@parkisense.app',
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
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }
}