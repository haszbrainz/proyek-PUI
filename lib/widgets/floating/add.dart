import 'package:flutter/material.dart';
import 'package:pui/themes/custom_colors.dart';


class FloatingAddButton extends StatelessWidget {
  final VoidCallback? onTap;

  const FloatingAddButton({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 32,
      bottom: 88,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: CustomColors.primary100,
            borderRadius: BorderRadius.circular(28),
          ),
          child: const Icon(
            Icons.add,
            color: CustomColors.secondary50,
            size: 32,
          ),
        ),
      ),
      );  
    }

}