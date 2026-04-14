import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:rotafy_frontend/core/theme/roy_colors.dart';
import 'package:rotafy_frontend/core/theme/roy_theme.dart';
import '../state/login_controller.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginController(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatelessWidget {
  const _LoginView();

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<LoginController>();
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, 32, 24, bottomInset + 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 50,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.network(
                      'https://res.cloudinary.com/dhzd047g9/image/upload/v1775319435/logo-rotafy_gtrv0s.jpg',
                      height: 120,
                      width: 120,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.image_not_supported),
                    ),

                    const SizedBox(height: 8),

                    RichText(
                      text: const TextSpan(
                        style: TextStyle(fontSize: 16),
                        children: [
                          TextSpan(text: 'Combine. ', style: TextStyle(color: RoyColors.textPrimary)),
                          TextSpan(text: 'Confirme. ', style: TextStyle(color: RoyColors.blueNavy)),
                          TextSpan(text: 'Chegue.', style: TextStyle(color: RoyColors.green)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Email
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Email',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: RoyColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: ctrl.emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: RoyTheme.fieldDecoration(placeholder: 'Email'),
                    ),

                    const SizedBox(height: 16),

                    // Senha
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Senha',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: RoyColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: ctrl.passwordController,
                      obscureText: true,
                      decoration: RoyTheme.fieldDecoration(placeholder: 'Senha'),
                    ),

                    if (ctrl.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          ctrl.errorMessage!,
                          style: const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),

                    const SizedBox(height: 24),

                    ElevatedButton(
                      onPressed: ctrl.isLoading
                          ? null
                          : () async {
                              ctrl.onSuccess = () => context.go('/passenger/home');
                              await ctrl.submit();
                            },
                      style: RoyTheme.primaryButton(),
                      child: ctrl.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Entrar'),
                    ),

                    const SizedBox(height: 16),

                    GestureDetector(
                      onTap: () => context.go('/register'),
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(fontSize: 14),
                          children: [
                            TextSpan(
                              text: 'Não tem conta? ',
                              style: TextStyle(color: RoyColors.textSecondary),
                            ),
                            TextSpan(
                              text: 'Cadastre-se',
                              style: TextStyle(
                                color: RoyColors.blueNavy,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
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
    );
  }
}