import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RwandaPhoneAuth extends StatefulWidget {
  const RwandaPhoneAuth({super.key});

  @override
  State<RwandaPhoneAuth> createState() => _RwandaPhoneAuthState();
}

class _RwandaPhoneAuthState extends State<RwandaPhoneAuth> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  String _verificationId = '';
  bool _codeSent = false;
  bool _isLoading = false;
  String? _errorMessage;
  String? _statusMessage;
  int? _resendToken;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyPhoneNumber() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _statusMessage = null;
    });

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: _phoneController.text.trim(),
        verificationCompleted: _onVerificationCompleted,
        verificationFailed: _onVerificationFailed,
        codeSent: _onCodeSent,
        codeAutoRetrievalTimeout: _onCodeAutoRetrievalTimeout,
        forceResendingToken: _resendToken,
        timeout: const Duration(seconds: 120), // Longer timeout for Rwanda
      );
    } catch (e) {
      setState(() {
        _errorMessage = _getErrorMessage(e);
        _isLoading = false;
      });
    }
  }

  void _onVerificationCompleted(PhoneAuthCredential credential) async {
    // Automatic verification succeeded (Android only)
    setState(() {
      _statusMessage = 'Automatic verification successful!';
    });
    await _signInWithCredential(credential);
  }

  void _onVerificationFailed(FirebaseAuthException e) {
    setState(() {
      _errorMessage = _getErrorMessage(e);
      _isLoading = false;
    });

    // Special handling for Rwanda-specific cases
    if (e.code == 'quota-exceeded') {
      _statusMessage = 'SMS quota exceeded. Please try again later.';
    }
  }

  void _onCodeSent(String verificationId, int? resendToken) {
    // Code sent to phone, prompt user to enter OTP
    setState(() {
      _verificationId = verificationId;
      _resendToken = resendToken;
      _codeSent = true;
      _isLoading = false;
      _statusMessage = 'SMS sent to ${_phoneController.text}';
    });
  }

  void _onCodeAutoRetrievalTimeout(String verificationId) {
    // Auto-retrieval timeout (Android only)
    setState(() {
      _verificationId = verificationId;
      _statusMessage = 'Auto-verification timeout. Please enter code manually.';
    });
  }

  Future<void> _signInWithCredential(PhoneAuthCredential credential) async {
    try {
      final UserCredential userCredential =
      await _auth.signInWithCredential(credential);

      if (userCredential.user != null && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const AuthSuccessScreen(),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = _getErrorMessage(e);
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyOTP() async {
    if (_verificationId.isEmpty || _otpController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _otpController.text,
      );
      await _signInWithCredential(credential);
    } catch (e) {
      setState(() {
        _errorMessage = _getErrorMessage(e);
        _isLoading = false;
      });
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-phone-number':
          return 'Invalid phone number format. Please use +250 format.';
        case 'quota-exceeded':
          return 'SMS quota exceeded. Please try again later.';
        case 'user-disabled':
          return 'This account has been disabled.';
        case 'operation-not-allowed':
          return 'Phone auth not enabled in Firebase console.';
        case 'session-expired':
          return 'Session expired. Please request a new code.';
        default:
          return 'Authentication failed: ${error.message}';
      }
    }
    return 'An error occurred: ${error.toString()}';
  }

  Future<void> _resendCode() async {
    setState(() {
      _otpController.clear();
      _isLoading = true;
    });
    await _verifyPhoneNumber();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rwanda Phone Sign-In')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (_errorMessage != null)
                _buildMessage(_errorMessage!, Colors.red),
              if (_statusMessage != null)
                _buildMessage(_statusMessage!, Colors.green),
              const SizedBox(height: 20),
              if (!_codeSent) _buildPhoneInput(),
              if (_codeSent) _buildOTPInput(),
              const SizedBox(height: 20),
              if (_isLoading)
                const CircularProgressIndicator()
              else if (_codeSent)
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _verifyOTP,
                        child: const Text('Verify Code'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    TextButton(
                      onPressed: _resendCode,
                      child: const Text('Resend Code'),
                    ),
                  ],
                )
              else
                ElevatedButton(
                  onPressed: _verifyPhoneNumber,
                  child: const Text('Send Verification Code'),
                ),
              const SizedBox(height: 20),
              _buildRwandaInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneInput() {
    return TextField(
      controller: _phoneController,
      decoration: const InputDecoration(
        labelText: 'Phone Number',
        hintText: '+250790110231',
        prefixIcon: Icon(Icons.phone),
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.phone,
    );
  }

  Widget _buildOTPInput() {
    return Column(
      children: [
        TextField(
          controller: _otpController,
          decoration: const InputDecoration(
            labelText: '6-digit Verification Code',
            prefixIcon: Icon(Icons.sms),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          maxLength: 6,
        ),
        const Text('Enter the code sent to your phone'),
      ],
    );
  }

  Widget _buildMessage(String message, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.info, color: color),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: TextStyle(color: color))),
        ],
      ),
    );
  }

  Widget _buildRwandaInfo() {
    return const Column(
      children: [
        Divider(),
        Text('Rwanda Phone Number Format'),
        Text('Example: +250790110231'),
        SizedBox(height: 10),
        Text('Standard SMS rates may apply'),
      ],
    );
  }
}

class AuthSuccessScreen extends StatelessWidget {
  const AuthSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 80),
            SizedBox(height: 20),
            Text('Successfully authenticated!',
                style: TextStyle(fontSize: 24)),
          ],
        ),
      ),
    );
  }
}