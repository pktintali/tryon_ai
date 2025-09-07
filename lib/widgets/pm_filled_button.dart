import 'package:flutter/material.dart';

class PMFilledButton extends StatelessWidget {
  const PMFilledButton({
    required this.text,
    this.onPressed,
    this.backgroundColor,
    super.key,
  });
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 55,
      width: double.infinity,
      child: ElevatedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          padding: const EdgeInsets.all(14),
        ),
        onPressed: onPressed ?? () {},
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
