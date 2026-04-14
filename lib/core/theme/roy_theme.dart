import 'package:flutter/material.dart';
import 'package:rotafy_frontend/core/theme/roy_colors.dart';

class RoyTheme {
	static InputDecoration fieldDecoration({
		required String placeholder,
		Widget? suffix,
	}) {
		return InputDecoration(
			hintText: placeholder,
			hintStyle: const TextStyle(
				color: RoyColors.hint,
				fontSize: 14,
			),
			contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
			enabledBorder: OutlineInputBorder(
				borderRadius: BorderRadius.circular(8),
				borderSide: const BorderSide(color: RoyColors.border, width: 1),
			),
			focusedBorder: OutlineInputBorder(
				borderRadius: BorderRadius.circular(8),
				borderSide: const BorderSide(color: RoyColors.blueNavy, width: 1.5),
			),
			errorBorder: OutlineInputBorder(
				borderRadius: BorderRadius.circular(8),
				borderSide: const BorderSide(color: Colors.red, width: 1),
			),
			focusedErrorBorder: OutlineInputBorder(
				borderRadius: BorderRadius.circular(8),
				borderSide: const BorderSide(color: Colors.red, width: 1.5),
			),
			filled: true,
			fillColor: RoyColors.surface,
			suffixIcon: suffix,
		);
	}

	static ButtonStyle primaryButton() {
		return ElevatedButton.styleFrom(
			backgroundColor: RoyColors.blueNavy,
			foregroundColor: Colors.white,
			minimumSize: const Size(double.infinity, 52),
			shape: RoundedRectangleBorder(
				borderRadius: BorderRadius.circular(10),
			),
			elevation: 0,
			textStyle: const TextStyle(
				fontSize: 16,
				fontWeight: FontWeight.w600,
				letterSpacing: 0.3,
			),
		);
	}
}