import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../providers/auth_provider.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});
  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _acceptedTerms = false;

  double _calculatePasswordStrength(String password) {
    if (password.isEmpty) return 0.0;
    double strength = 0.0;
    if (password.length >= 8) strength += 0.3;
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.25;
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.25;
    if (password.contains(RegExp(r'[!@密#\$%^&*(),.?":{}|<>]'))) strength += 0.2;
    return strength;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final strength = _calculatePasswordStrength(_passwordController.text);

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
                  const Text('Create Account', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                  const SizedBox(height: 24),
                  TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Full Name'), validator: (val) => val!.isEmpty ? 'Enter name' : null),
                  const SizedBox(height: 16),
                  TextFormField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email Address'), validator: (val) => val == null || !val.contains('@') ? 'Enter a valid email' : null),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password'),
                    onChanged: (_) => setState(() {}),
                    validator: (val) => val!.length < 8 ? 'Password must be at least 8 characters' : null,
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: strength,
                    backgroundColor: AppColors.borderGrey,
                    color: strength < 0.4 ? AppColors.dangerRed : strength < 0.8 ? Colors.orange : Colors.green,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Confirm Password'),
                    validator: (val) => val != _passwordController.text ? 'Passwords do not match' : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Checkbox(value: _acceptedTerms, activeColor: AppColors.primaryBlue, onChanged: (val) => setState(() => _acceptedTerms = val ?? false)),
                      const Expanded(child: Text('I agree to the Terms & Conditions', style: TextStyle(color: AppColors.textDark))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: (!_acceptedTerms || authState.isLoading) ? null : () {
                      if (_formKey.currentState!.validate()) {
                        ref.read(authNotifierProvider.notifier).signUpWithEmail(_emailController.text.trim(), _passwordController.text.trim(), _nameController.text.trim());
                      }
                    },
                    child: authState.isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Create Account'),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Already have an account? Log In', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
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