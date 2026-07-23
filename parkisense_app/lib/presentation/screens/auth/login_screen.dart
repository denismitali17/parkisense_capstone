import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    // Listens closely to authentication status state changes
    ref.listen<AsyncValue>(authNotifierProvider, (previous, next) {
      next.when(
        data: (user) {
          if (user != null) {
            Navigator.pushReplacementNamed(context, '/main'); 


            // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
          }
        },
        error: (err, _) {
          String errorMessage = 'Authentication failed. Please check your credentials and try again.';
          if (err.toString().contains('user-not-found')) {
            errorMessage = 'No account found with this email. Please sign up first.';
          } else if (err.toString().contains('wrong-password')) {
            errorMessage = 'Incorrect password. Please try again.';
          } else if (err.toString().contains('invalid-email')) {
            errorMessage = 'Invalid email address. Please enter a valid email.';
          } else if (err.toString().contains('too-many-requests')) {
            errorMessage = 'Too many attempts. Please try again later.';
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage), backgroundColor: AppColors.dangerRed),
          );
        },
        loading: () => {},
      );
    });

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with logo and buttons
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.psychology,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'ParkiSense',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.titleLarge?.color,
                        ),
                      ),
                    ],
                  ),
                  // Login/Signup buttons
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/signup');
                        },
                        child: Text(
                          'Sign Up',
                          style: GoogleFonts.poppins(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          // Already on login screen
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Sign In',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Main content
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome Back',
                            style: GoogleFonts.poppins(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).textTheme.titleLarge?.color,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sign in to continue',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: AppColors.textLight,
                            ),
                          ),
                          const SizedBox(height: 32),
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Email Address',
                              prefixIcon: const Icon(Icons.email),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Theme.of(context).cardTheme.color,
                            ),
                            validator: (val) => val == null || !val.contains('@') ? 'Enter a valid email' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Theme.of(context).cardTheme.color,
                            ),
                            validator: (val) => val == null || val.length < 6 ? 'Password too short' : null,
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/forgot-password');
                              },
                              child: Text(
                                'Forgot Password?',
                                style: GoogleFonts.poppins(
                                  color: AppColors.primaryBlue,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: authState.isLoading ? null : () {
                                if (_formKey.currentState!.validate()) {
                                  ref.read(authNotifierProvider.notifier).signInWithEmail(
                                    _emailController.text.trim(), 
                                    _passwordController.text.trim(),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: authState.isLoading 
                                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                                  : Text('Log In', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Expanded(child: Divider()),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  'or continue with',
                                  style: GoogleFonts.poppins(
                                    color: AppColors.textLight,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              const Expanded(child: Divider()),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: OutlinedButton.icon(
                              onPressed: authState.isLoading ? null : () => ref.read(authNotifierProvider.notifier).signInWithGoogle(),
                              icon: Image.network(
                                'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcThWo3UwQ9eEl87JDDkU7ICxJqFhq5gOeFPk4ukR97kmw&s=10',
                                height: 24,
                              ),
                              label: Text(
                                'Google',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Center(
                            child: TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/doctor-login');
                              },
                              child: Text(
                                "Doctor? Sign in here",
                                style: GoogleFonts.poppins(
                                  color: AppColors.primaryBlue,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}