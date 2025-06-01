import 'package:flutter/material.dart';
import 'package:pui/themes/custom_colors.dart';
import 'package:pui/themes/custom_text_styles.dart';
class NavigationItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const NavigationItem({
    super.key,
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive 
              ? CustomColors.primary200
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? CustomColors.secondary500 : CustomColors.secondary50,
              size: 20,
            ),
            if (isActive) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: CustomTextStyles.demiBoldSm.copyWith(color: CustomColors.secondary500),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

