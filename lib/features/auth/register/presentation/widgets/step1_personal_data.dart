import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:rotafy_frontend/core/theme/roy_theme.dart';
import 'package:rotafy_frontend/core/theme/roy_colors.dart';

class Step1PersonalData extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController cpfController;
  final TextEditingController phoneController;
  final String? errorMessage;
  final VoidCallback onNext;

  const Step1PersonalData({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.cpfController,
    required this.phoneController,
    required this.onNext,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nome
        const _FieldLabel('Nome'),
        const SizedBox(height: 6),
        TextField(
          controller: nameController,
          textCapitalization: TextCapitalization.words,
          decoration: RoyTheme.fieldDecoration(placeholder: 'Nome'),
          style: const TextStyle(fontSize: 14, color: RoyColors.textPrimary),
        ),

        const SizedBox(height: 16),

        // Email
        const _FieldLabel('Email'),
        const SizedBox(height: 6),
        TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: RoyTheme.fieldDecoration(placeholder: '...@edu.com.br'),
          style: const TextStyle(fontSize: 14, color: RoyColors.textPrimary),
        ),

        const SizedBox(height: 16),

        // CPF
        Row(children: [const _FieldLabel('CPF')]),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Text(
              'Porque precisamos do seu CPF?',
              style: TextStyle(fontSize: 11, color: RoyColors.textSecondary),
            ),
            GestureDetector(
              onTap: () => _showCpfInfo(context),
              child: const Icon(
                Icons.help_outline,
                size: 16,
                color: RoyColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: cpfController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            _CpfInputFormatter(),
          ],
          decoration: RoyTheme.fieldDecoration(placeholder: '000.000.000-00'),
          style: const TextStyle(fontSize: 14, color: RoyColors.textPrimary),
        ),

        const SizedBox(height: 16),

        // Telefone
        const _FieldLabel('Telefone'),
        const SizedBox(height: 6),
        TextField(
          controller: phoneController,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            _PhoneInputFormatter(),
          ],
          decoration: RoyTheme.fieldDecoration(placeholder: '(42) 99999-9999'),
          style: const TextStyle(fontSize: 14, color: RoyColors.textPrimary),
        ),

        const SizedBox(height: 8),

        // Mensagem de erro
        if (errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),

        const SizedBox(height: 16),

        // Botão Avançar
        ElevatedButton(
          onPressed: onNext,
          style: RoyTheme.primaryButton(),
          child: const Text('Avançar'),
        ),
        const SizedBox(height: 16),

        Center(
          child: GestureDetector(
            onTap: () => context.go('/login'),
            child: RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: 'Já tem conta? ',
                    style: TextStyle(color: RoyColors.textSecondary, fontSize: 14),
                  ),
                  TextSpan(
                    text: 'Entrar',
                    style: TextStyle(
                      color: RoyColors.blueNavy,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showCpfInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          'Por que pedimos o CPF?',
          style: TextStyle(fontSize: 20),
        ),
        content: const Text(
          'Usamos seu CPF para criar sua carteira no app e garantir sua identificação.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: RoyColors.textPrimary,
      ),
    );
  }
}

// ── Formatadores ──────────────────────────────────────────────

class _CpfInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length && i < 11; i++) {
      if (i == 3 || i == 6) buffer.write('.');
      if (i == 9) buffer.write('-');
      buffer.write(digits[i]);
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length && i < 11; i++) {
      if (i == 0) buffer.write('(');
      if (i == 2) buffer.write(') ');
      if (i == 7) buffer.write('-');
      buffer.write(digits[i]);
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
