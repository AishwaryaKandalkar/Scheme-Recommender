import 'package:flutter/material.dart';


class StepIndicator extends StatelessWidget {
  final int totalSteps;
  final int currentStep;
  final Color activeColor;
  final Color inactiveColor;
  final double dotSize;

  const StepIndicator({
    Key? key,
    required this.totalSteps,
    required this.currentStep,
    this.activeColor = Colors.blue,
    this.inactiveColor = const Color(0xFFE0E0E0),
    this.dotSize = 16,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: dotSize,
          height: dotSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index <= currentStep ? activeColor : inactiveColor,
            boxShadow: index == currentStep
                ? [BoxShadow(color: activeColor.withOpacity(0.3), blurRadius: 8, spreadRadius: 1)]
                : [],
          ),
        );
      }),
    );
  }
}
