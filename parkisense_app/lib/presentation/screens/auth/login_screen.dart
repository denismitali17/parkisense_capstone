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
            Navigator.pushReplacementNamed(context, '/home'); 


            // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
          }
        },
        error: (err, _) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Authentication Failed: ${err.toString()}'), backgroundColor: AppColors.dangerRed),
        ),
        loading: () => {},
      );
    });

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Sign In', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email Address'),
                    validator: (val) => val == null || !val.contains('@') ? 'Enter a valid email' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password'),
                    validator: (val) => val == null || val.length < 6 ? 'Password too short' : null,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // Routes to forgot password page
                        Navigator.pushNamed(context, '/forgot-password');
                        

                      },
                      child: const Text('Forgot Password?', style: TextStyle(color: AppColors.primaryBlue)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: authState.isLoading ? null : () {
                            if (_formKey.currentState!.validate()) {
                              ref.read(authNotifierProvider.notifier).signInWithEmail(
                                _emailController.text.trim(), 
                                _passwordController.text.trim(),
                              );
                            }
                          },
                          child: authState.isLoading 
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                              : Text('Log In', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      InkWell(
                        onTap: authState.isLoading ? null : () => ref.read(authNotifierProvider.notifier).signInWithGoogle(),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          height: 52,
                          width: 64,
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.borderGrey),
                            borderRadius: BorderRadius.circular(12),
                            color: Theme.of(context).cardTheme.color,
                          ),
                          child: Center(
                            child: Image.network(
                              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQfV2PhdwCNpTbSy118m4bQiRA25RmQjKb12BSdz8iGFQ&s=10',
                              height: 24,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        //  Routes to signup page
                        Navigator.pushNamed(context, '/signup');
                        


                      },
                      child: const Text("Don't have an account? Sign Up", style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}