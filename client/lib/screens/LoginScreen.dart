import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:client/screens/dashboard_screen.dart';
import '../providers/state_provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _showOtpField = false;
  String? _verificationId;
  String? _phoneNumber;

  bool _validateRwandanPhoneNumber(String phoneNumber) {
    final regex = RegExp(r'^\+2507[0-9]{8}$');
    return regex.hasMatch(phoneNumber);
  }

  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        final user = userCredential.user;
        if (user != null) {
          // Fetch user data from Firestore
          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

          if (userDoc.exists) {
            final userData = userDoc.data() as Map<String, dynamic>;
            _phoneNumber = userData['phone'] as String? ?? '';

            // Normalize phone number format
            if (_phoneNumber!.startsWith('07') && _phoneNumber!.length == 10) {
              _phoneNumber = '+250${_phoneNumber!.substring(1)}';
            } else if (_phoneNumber!.startsWith('7') &&
                _phoneNumber!.length == 9) {
              _phoneNumber = '+250$_phoneNumber';
            } else if (_phoneNumber!.startsWith('2507') &&
                _phoneNumber!.length == 12) {
              _phoneNumber = '+$_phoneNumber';
            }

            // Validate phone number format
            if (_phoneNumber!.isEmpty ||
                !_validateRwandanPhoneNumber(_phoneNumber!)) {
              ScaffoldMessenger.of(context).showSnackBar(
                _buildErrorSnackBar(
                    'Invalid phone number format. Please contact support.'),
              );
              return;
            }

            User? firebaseUser = FirebaseAuth.instance.currentUser;
            if (firebaseUser != null) {
              // // Get user data from Firestore
              DocumentSnapshot userDoc = await FirebaseFirestore.instance
                  .collection('users')
                  .doc(firebaseUser?.uid)
                  .get();

              if (userDoc.exists) {
                final userData = userDoc.data() as Map<String, dynamic>;
                // print(userData);
                // Create UserInfoFam object
                UserInfoFam user = UserInfoFam(
                  id: firebaseUser.uid,
                  name: userData['fullName'] ?? '',
                  email: userData['email'] ?? firebaseUser.email ?? '',
                  phone: userData['phone'] ?? _phoneNumber,
                );

                //   // Save user to app state
                final appCubit = context.read<AppCubit>();
                await appCubit.saveUser(user);

                // Navigate to dashboard
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => DashboardScreen()),
                );
              }
            }

            // // Always send OTP
            // await _sendOtp();
            // setState(() {
            //   _showOtpField = true;
            // });
          }
        }
      } on FirebaseAuthException catch (e) {
        _handleAuthError(e);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('An unexpected error occurred. Please try again.')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _sendOtp() async {
    if (_phoneNumber == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: _phoneNumber!,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _verifyOtp(credential.smsCode!);
        },
        verificationFailed: (FirebaseAuthException e) {
          ScaffoldMessenger.of(context).showSnackBar(
            _buildErrorSnackBar('Failed to send OTP: ${e.message}'),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('OTP sent to your phone number')),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        _buildErrorSnackBar('Failed to send OTP. Please try again.'),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyOtp(String otp) async {
    if (_verificationId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );

      // First, get the current user from email/password sign-in
      User? firebaseUser = FirebaseAuth.instance.currentUser;

      if (firebaseUser == null) {
        throw Exception("User not logged in");
      }

      // Link the phone credential to the existing user
      await firebaseUser.linkWithCredential(credential);

      // Get user data from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        // print(userData);
        // Create UserInfoFam object
        UserInfoFam user = UserInfoFam(
          id: firebaseUser.uid,
          name: userData['fullName'] ?? '',
          email: userData['email'] ?? firebaseUser.email ?? '',
          phone: userData['phone'] ?? _phoneNumber,
        );

        // Save user to app state
        final appCubit = context.read<AppCubit>();
        await appCubit.saveUser(user);

        // Navigate to dashboard
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => DashboardScreen()),
        );
      } else {
        throw Exception("User document not found");
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Invalid OTP. Please try again.';
      if (e.code == 'provider-already-linked') {
        // Phone number is already linked, proceed with getting user data
        User? firebaseUser = FirebaseAuth.instance.currentUser;
        if (firebaseUser != null) {
          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(firebaseUser.uid)
              .get();

          if (userDoc.exists) {
            final userData = userDoc.data() as Map<String, dynamic>;

            UserInfoFam user = UserInfoFam(
              id: firebaseUser.uid,
              name: userData['fullName'] ?? '',
              email: userData['email'] ?? firebaseUser.email ?? '',
              phone: userData['phone'] ?? _phoneNumber,
            );

            final appCubit = context.read<AppCubit>();
            await appCubit.saveUser(user);

            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => DashboardScreen()),
            );
            return;
          }
        }
        errorMessage = 'User Info not found. Please try again.';
      } else if (e.code == 'credential-already-in-use') {
        errorMessage =
            'This phone number is already associated with another account.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        _buildErrorSnackBar(errorMessage),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        _buildErrorSnackBar('Verification failed. Please try again.'),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  SnackBar _buildErrorSnackBar(String message) {
    return SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.redAccent,
      content: Row(
        children: [
          const Icon(Icons.error, color: Colors.white),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _handleAuthError(FirebaseAuthException e) {
    String message = "An error occurred";
    if (e.code == 'user-not-found') {
      message = 'No user found for this email.';
    } else if (e.code == 'wrong-password') {
      message = 'Incorrect password.';
    } else if (e.code == 'invalid-email') {
      message = 'Invalid email address.';
    } else if (e.code == 'invalid-credential') {
      message = 'The given credential are incorrect';
    } else {
      message = 'Login failed. Please try again.';
    }

    ScaffoldMessenger.of(context).showSnackBar(_buildErrorSnackBar(message));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              width: screenWidth,
              height: 400,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: 0,
                    left: screenWidth * -0.25,
                    child: Container(
                      width: screenWidth * 1.5,
                      height: 350,
                      decoration: const BoxDecoration(
                        color: Color(0xFF48B1A5),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(400),
                          bottomRight: Radius.circular(400),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 30,
                    child: Center(
                      child: Image.asset(
                        'assets/logos/trans.png',
                        width: 260,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 210,
                    child: Column(
                      children: [
                        const Text(
                          'FAM CARE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'we love and care',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: -30,
                    child: Text(
                      'Stay Healthy, Stay Inspired!',
                      style: TextStyle(
                        color: const Color(0xFF48B1A5),
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 60),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Only show email/password when OTP is not shown
                    if (!_showOtpField) ...[
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          suffixIcon: const Icon(
                            Icons.email_outlined,
                            color: Color(0xFF48B1A5),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: const Color(0xFF48B1A5),
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                    ],

                    // Show OTP field when needed
                    if (_showOtpField) ...[
                      TextFormField(
                        controller: _otpController,
                        decoration: InputDecoration(
                          labelText: 'OTP',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          suffixIcon: const Icon(
                            Icons.sms_outlined,
                            color: Color(0xFF48B1A5),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the OTP';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: _sendOtp,
                        child: const Text(
                          'Resend OTP',
                          style: TextStyle(color: Color(0xFF48B1A5)),
                        ),
                      ),
                    ],

                    if (!_showOtpField) ...[
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // Handle forgot password
                          },
                          child: const Text(
                            'Forgot Password',
                            style: TextStyle(
                              color: Color(0xFF48B1A5),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],

                    ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : _showOtpField
                              ? () => _verifyOtp(_otpController.text.trim())
                              : _signIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF48B1A5),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            )
                          : Text(
                              _showOtpField ? 'Verify OTP' : 'Sign in',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                    ),

                    if (!_showOtpField) ...[
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: Colors.grey.shade300,
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              'or continue with',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: Colors.grey.shade300,
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () {},
                            child: const Icon(Icons.g_mobiledata_rounded,
                                size: 39, color: Colors.red),
                          ),
                          const SizedBox(width: 20),
                          InkWell(
                            onTap: () {},
                            child: const Icon(Icons.apple,
                                size: 30, color: Colors.black),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Don\'t have an account ? ',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/register');
                            },
                            child: const Text(
                              'Signup',
                              style: TextStyle(
                                color: Color(0xFF48B1A5),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
