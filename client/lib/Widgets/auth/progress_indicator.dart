import 'package:flutter/material.dart';
import 'package:client/utils/constants.dart';

class RegistrationProgressIndicator extends StatelessWidget {
  final int currentStep;
  
  const RegistrationProgressIndicator({
    super.key,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          LinearProgressIndicator(
            value: currentStep / 2,
            backgroundColor: AppColors.greyLight,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 4,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStepText(1, 'Basic Info'),
              _buildStepText(2, 'Security'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepText(int stepNumber, String text) => Text(
    text,
    style: TextStyle(
      color: currentStep == stepNumber 
          ? AppColors.primary 
          : AppColors.greyDark,
      fontWeight: currentStep == stepNumber 
          ? FontWeight.bold 
          : FontWeight.normal,
    ),
  );
}