import 'package:client/Widgets/auth/custom_text_field.dart';
import 'package:client/models/registration_form_data.dart';
import 'package:flutter/material.dart';
import 'package:client/utils/validators.dart';

class Step1Form extends StatefulWidget {
  final RegistrationFormData formData;
  final VoidCallback onNext;

  const Step1Form({
    super.key,
    required this.formData,
    required this.onNext,
  });

  @override
  State<Step1Form> createState() => _Step1FormState();
}

class _Step1FormState extends State<Step1Form> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fullNameController.text = widget.formData.fullName;
    _emailController.text = widget.formData.email;
    _phoneController.text = widget.formData.phone;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextField(
              controller: _fullNameController,
              label: 'Full Name',
              icon: Icons.person_outline,
              validator: Validators.validateFullName,
              onSaved: (value) => widget.formData.fullName = value!,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: _emailController,
              label: 'Email',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: Validators.validateEmail,
              onSaved: (value) => widget.formData.email = value!,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: _phoneController,
              label: 'Phone Number',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: Validators.validatePhone,
              onSaved: (value) => widget.formData.phone = value!,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF48B1A5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              onPressed: _submitForm,
              child: const Text('Next'),
            ),
            //                   child: ElevatedButton(
//                     onPressed: _isLoading ? null : _completeRegistration,
//                     child: _isLoading
//                         ? const CircularProgressIndicator(
//                       valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                     )
//                         : const Text(
//                       'Register',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
          ],
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      widget.onNext();
    }
  }
}
