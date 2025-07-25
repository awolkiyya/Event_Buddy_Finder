import 'package:event_buddy_finder/commens/components/custom_button.dart';
import 'package:event_buddy_finder/commens/components/custom_social_button.dart';
import 'package:event_buddy_finder/commens/components/custom_text_Input.dart';
import 'package:event_buddy_finder/commens/utils/form_validators.dart';
import 'package:event_buddy_finder/futures/auth/domain/entities/user_entity.dart';
import 'package:event_buddy_finder/futures/auth/presentation/blocs/auth_bloc.dart';
import 'package:event_buddy_finder/futures/auth/presentation/blocs/auth_event.dart';
import 'package:event_buddy_finder/futures/auth/presentation/blocs/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        isLoading = true;
      });
      final email = emailController.text.trim();
      final password = passwordController.text.trim();
      context.read<AuthBloc>().add(AuthSignInWithEmailRequested(email, password));
    }
  }

  Future<void> _handleGoogleLogin() async {
    context.read<AuthBloc>().add(AuthSignInWithGoogleRequested());
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<AuthBloc, AuthState>(
       listener: (context, state) {
          
          if (state is AuthProfileIncomplete) {
            // No need to create UserEntity or pass extra,
            // ProfileSetupPage will fetch current Firebase user internally
            GoRouter.of(context).go('/profileSetup');
            print("i'm here");
          }

          if (state is AuthAuthenticated) {
            setState(() {
              isLoading = false;
            });
            // Navigate to the main screen (replace '/main' with your route)
            GoRouter.of(context).go('/home');
          }
          if (state is AuthFailure) {
            setState(() {
              isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {

          return Scaffold(
            appBar: AppBar(
              title: const Text('Welcome Back!'),
              centerTitle: true,
              elevation: 0,
              backgroundColor: theme.scaffoldBackgroundColor,
              foregroundColor: Colors.black87,
            ),
            body:  SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Sign in to your account',
                            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),

                          CustomTextInput(
                            controller: emailController,
                            labelText: 'Email',
                            hintText: 'name@example.com',
                            keyboardType: TextInputType.emailAddress,
                            validator: validateEmail,
                            prefixIcon: const Icon(Icons.email_outlined),
                          ),
                          const SizedBox(height: 20),

                          CustomTextInput(
                            controller: passwordController,
                            labelText: 'Password',
                            hintText: 'Enter your password',
                            obscureText: _obscurePassword,
                            keyboardType: TextInputType.text,
                            validator: validatePassword,
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                            ),
                          ),
                          const SizedBox(height: 16),

                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                GoRouter.of(context).go('/forgot-password'); // Navigate to Forgot Password page
                              },
                              child: Text('Forgot Password?', style: TextStyle(color: theme.primaryColor)),
                            ),
                          ),
                          const SizedBox(height: 24),

                          CustomButton(label: "Log In", onPressed: _handleEmailLogin,isLoading: isLoading,),
                          const SizedBox(height: 32),

                          Row(
                            children: [
                              Expanded(child: Divider(color: Colors.grey.shade300)),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Text('OR', style: TextStyle(color: Colors.black54)),
                              ),
                              Expanded(child: Divider(color: Colors.grey.shade300)),
                            ],
                          ),
                          const SizedBox(height: 32),

                          CustomSocialButton(
                            label: 'Continue with Google',
                            icon: Image.asset('assets/icons/google.png', height: 24),
                            onPressed: _handleGoogleLogin,
                            backgroundColor: Colors.white,
                            textColor: Colors.black87,
                            borderColor: Colors.grey.shade300,
                          ),
                          // CustomButton(label: "signOut", onPressed:_handleSignOut,isLoading: isLoading,),

                          const SizedBox(height: 32),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Don't have an account?"),
                              TextButton(
                                onPressed: () =>{ 
                                  print("why called"),
                                  GoRouter.of(context).go('/signup')},
                                child: const Text('Sign Up', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }
}
