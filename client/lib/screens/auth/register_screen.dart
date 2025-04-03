// import 'package:client/Widgets/auth/step1_form.dart';
// import 'package:client/Widgets/auth/step2_form.dart';
// import 'package:client/models/registration_form_data.dart';
// import 'package:client/utils/constants.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:client/services/auth_service.dart';
// import 'package:client/widgets/auth/auth_header.dart';
// import 'package:client/widgets/auth/progress_indicator.dart';
// import 'package:client/utils/extensions.dart';

// class RegisterScreen extends StatefulWidget {
//   const RegisterScreen({super.key});

//   @override
//   State<RegisterScreen> createState() => _RegisterScreenState();
// }

// class _RegisterScreenState extends State<RegisterScreen> {
//   int _currentStep = 1;
//   final _formData = RegistrationFormData();

//   void _handleStepChange(int newStep) => setState(() => _currentStep = newStep);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             const AuthHeader(
//               title: AppStrings.appName,
//               subtitle: AppStrings.slogan,
//             ),
//             const SizedBox(height: 50),
//             RegistrationProgressIndicator(currentStep: _currentStep),
//             const SizedBox(height: 30),
//             _currentStep == 1
//                 ? Step1Form(
//                     formData: _formData,
//                     onNext: () => _handleStepChange(2),
//                   )
//                 : Step2Form(
//                     formData: _formData,
//                     onBack: () => _handleStepChange(1),
//                     onRegister: _handleRegistration,
//                   ),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<void> _handleRegistration() async {
//     try {
//       await context.read<AuthService>().signUpWithEmailPassword(email: _formData.email, password: _formData.password, fullName: _formData.fullName, phone: _formData.phone);
      
//       Navigator.pushReplacementNamed(context, '/login');
//     } on FirebaseAuthException catch (e) {
//       context.showErrorSnackbar(e.message ?? 'An error occurred.');
//     }
//   }
// }