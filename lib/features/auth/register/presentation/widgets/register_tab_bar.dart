import 'package:flutter/material.dart';
import 'package:rotafy_frontend/core/theme/roy_colors.dart';


class RegisterTabBar extends StatelessWidget {
  final int currentStep;
  final ValueChanged<int> onTap;

  const RegisterTabBar({
    super.key,
    required this.currentStep,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min, 
      children: [
        _Tab(
          icon: Icons.person_outline,
          index: 0,
          currentStep: currentStep,
          onTap: onTap,
        ),

        const SizedBox(width: 12),

        SizedBox(
          width: 50,
          child: const _Divider(),
        ),

        const SizedBox(width: 12),

        _Tab(
          icon: Icons.menu_book,
          index: 1,
          currentStep: currentStep,
          onTap: onTap,
        ),
      ],
    );
  }
}

class _Tab extends StatelessWidget {
  final IconData icon;
  final int index;
  final int currentStep;
  final ValueChanged<int> onTap;

  const _Tab({
    required this.icon,
    required this.index,
    required this.currentStep,
    required this.onTap,
  });

  bool get isActive => index == currentStep;
  bool get isDone => index < currentStep;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 60,
        height: 30,
        decoration: BoxDecoration(
          color: isActive ? RoyColors.green : Colors.transparent,
          borderRadius: BorderRadius.circular(34),
        ),
        child: Icon(
          icon,
          size: 22,
          color: isActive
              ?  RoyColors.blueNavy
              : isDone
                  ? RoyColors.blueNavy
                  : RoyColors.tabInactive,
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: RoyColors.border,
      margin: const EdgeInsets.symmetric(),
    );
  }
}