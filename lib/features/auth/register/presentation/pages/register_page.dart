import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rotafy_frontend/features/auth/register/presentation/widgets/step2_academic_data.dart';

import '../state/register_controller.dart';
import '../widgets/register_tab_bar.dart';
import '../widgets/step1_personal_data.dart';
import 'package:go_router/go_router.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RegisterController(),
      child: const _RegisterView(),
    );
  }
}

class _RegisterView extends StatelessWidget {
  const _RegisterView();

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<RegisterController>();
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
              child: Column(
                children: [
                  Expanded( // 👈 garante altura total
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
                        children: [
                          Image.network(
                            'https://res.cloudinary.com/dhzd047g9/image/upload/v1775319435/logo-rotafy_gtrv0s.jpg',
                            errorBuilder: (context, error, stackTrace) {
                              return Text('Erro ao carregar imagem');
                            },
                            height: 150,
                            width: 150,
                            fit: BoxFit.contain,
                          ),

                          const SizedBox(height: 16),

                          RegisterTabBar(
                            currentStep: ctrl.currentStep,
                            onTap: (i) {
                              if (i < ctrl.currentStep) ctrl.goToStep(i);
                            },
                          ),

                          const SizedBox(height: 28),

                          Expanded( // 👈 espaço pro conteúdo do step
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              transitionBuilder: (child, animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0.05, 0),
                                      end: Offset.zero,
                                    ).animate(animation),
                                    child: child,
                                  ),
                                );
                              },
                              child: KeyedSubtree(
                                key: ValueKey(ctrl.currentStep),
                                child: _buildStep(ctrl, context),
                              ),
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
    );
  }

  Widget _buildStep(RegisterController ctrl, BuildContext context) {
    switch (ctrl.currentStep) {
      case 0:
        return Step1PersonalData(
          nameController: ctrl.nameController,
          emailController: ctrl.emailController,
          cpfController: ctrl.cpfController,
          phoneController: ctrl.phoneController,
          onNext: ctrl.nextStep,
          errorMessage: ctrl.errorMessage,
        );

      case 1:
        return Step2AcademicData(
          cnpjController: ctrl.cnpjController,
          academicProfileController: ctrl.academicProfileController,
          selectedProfile: ctrl.selectedProfile,
          onProfileSelected: ctrl.setProfile,
          passwordController: ctrl.passwordController,
          onNext: () async {
            ctrl.onSuccess = () {
              context.go('/verify-email', extra: ctrl.emailController.text.trim());
            };
            await ctrl.submit();
          },
          errorMessage: ctrl.errorMessage,
          onPhotoPicked: ctrl.setPhoto
        );

      default:
        return const SizedBox.shrink();
    }
  }
}