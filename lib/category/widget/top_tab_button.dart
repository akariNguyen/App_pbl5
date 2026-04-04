import 'package:flutter/material.dart';

class TopTabButton extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const TopTabButton({
    super.key,
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? scheme.primary.withOpacity(0.22)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: selected ? scheme.primary : scheme.onSurface,
          ),
        ),
      ),
    );
  }
}