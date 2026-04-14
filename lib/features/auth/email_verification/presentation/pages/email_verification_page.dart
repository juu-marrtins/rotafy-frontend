import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rotafy_frontend/core/theme/roy_colors.dart';
import 'package:rotafy_frontend/core/theme/roy_theme.dart';

class VerifyEmailPage extends StatelessWidget {
  final String email;
  const VerifyEmailPage({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Container(
            margin: const EdgeInsets.all(24),
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
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/images/logo.png', height: 60),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: RoyColors.blueNavy.withOpacity(0.06),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.mark_email_unread_outlined,
                    size: 48,
                    color: RoyColors.blueNavy,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Verifique seu e-mail',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: RoyColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Enviamos um link de confirmação para',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: RoyColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: RoyColors.blueNavy,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Acesse sua caixa de entrada e clique no link para ativar sua conta.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: RoyColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => context.go('/register'),
                  style: RoyTheme.primaryButton(),
                  child: const Text('Voltar ao início'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}