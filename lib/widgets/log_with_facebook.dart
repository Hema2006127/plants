import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../screens/recent_scan.dart';
import '../state/user_state.dart';

class LoginWithFaceBook extends StatefulWidget {
  final void Function(String email)? onEmailSelected;

  const LoginWithFaceBook({super.key, this.onEmailSelected});

  @override
  State<LoginWithFaceBook> createState() => _LoginWithFaceBookState();
}

class _LoginWithFaceBookState extends State<LoginWithFaceBook> {
  bool _googleLoading = false;

  static final _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId:
        '450230241410-e96o3rartpo3u3k450e9edj5td2dc949.apps.googleusercontent.com',
  );

  static const _signinUrl =
      'https://plant-pules-api.vercel.app/api/v1/auth/signin';
  static const _signupUrl =
      'https://plant-pules-api.vercel.app/api/v1/auth/signup';
  static const _profileUrl =
      'https://plant-pules-api.vercel.app/api/v1/users/profile';

  Future<void> _signInWithGoogle() async {
    setState(() => _googleLoading = true);

    try {
      final account = await _googleSignIn.signIn();
      if (account == null) return;

      final email = account.email;
      final name = account.displayName ?? email.split('@')[0];
      // password مشتق من الـ Google ID — ثابت لكل مرة
      final password = 'ggl_${account.id}';

      final dio = Dio();
      String token = '';

      // جرّب signin الأول
      try {
        final res = await dio.post(
          _signinUrl,
          data: {'email': email, 'password': password},
          options: Options(
            receiveTimeout: const Duration(seconds: 15),
            sendTimeout: const Duration(seconds: 15),
          ),
        );
        token = res.data['token'] as String? ?? '';
      } on DioException catch (e) {
        final status = e.response?.statusCode ?? 0;
        // لو الـ account مش موجود → اعمل register
        if (status == 401 || status == 404 || status == 400) {
          final res = await dio.post(
            _signupUrl,
            data: {
              'name': name,
              'email': email,
              'password': password,
              'confirmPassword': password,
              'gender': 'male',
            },
            options: Options(
              receiveTimeout: const Duration(seconds: 15),
              sendTimeout: const Duration(seconds: 15),
            ),
          );
          token = res.data['token'] as String? ?? '';
        } else {
          rethrow;
        }
      }

      if (token.isEmpty) {
        _showError('Login failed. Please try again.');
        return;
      }

      await userState.saveToken(token);

      String fullName = name;
      String gender = 'male';

      try {
        final profileRes = await dio.get(
          _profileUrl,
          options: Options(headers: {'token': token}),
        );
        final profileData =
            profileRes.data['data'] as Map<String, dynamic>? ?? {};
        fullName = profileData['name'] as String? ?? fullName;
        final genderFromApi = profileData['gender'] as String? ?? '';
        if (genderFromApi.isNotEmpty) gender = genderFromApi.toLowerCase();
      } catch (_) {}

      await userState.saveUserData(
        email: email,
        password: password,
        fullName: fullName,
        gender: gender,
      );

      await loadScansFromApi(token);

      if (!mounted) return;

      Navigator.of(context).pushNamedAndRemoveUntil(
        'HomePage',
        (route) => false,
        arguments: {
          'firstName': fullName.isNotEmpty ? fullName.split(' ')[0] : '',
          'fullName': fullName,
          'email': email,
          'gender': gender,
        },
      );
    } on DioException catch (e) {
      final data = e.response?.data;
      final msg = (data is Map ? data['message'] : null) ?? 'Sign-in failed.';
      _showError(msg as String);
    } catch (e) {
      _showError('Google error: $e');
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  void _showComingSoon() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: const Text(
          'Facebook login coming soon!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
            color: Color(0xFF1F1F1F),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'OK',
              style: TextStyle(color: Color(0xFF399B25), fontFamily: 'Poppins'),
            ),
          ),
        ],
      ),
    );
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
        ),
        backgroundColor: const Color(0xFFD32F2F),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final logoSize = size.height * 0.0296;
    final logoWidth = size.width * 0.064;

    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFFC7C7C7), thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.015),
          child: Column(
            children: [
              const Text(
                'Or login with',
                style: TextStyle(
                  fontSize: 10,
                  color: Color(0xFF399B25),
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(height: size.height * 0.0296),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _showComingSoon,
                    child: Image.asset(
                      'assets/facebook_logo.png',
                      height: logoSize,
                      width: logoWidth,
                      cacheHeight: logoSize.toInt(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: _googleLoading ? null : _signInWithGoogle,
                    child: _googleLoading
                        ? SizedBox(
                            width: logoWidth,
                            height: logoSize,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF399B25),
                            ),
                          )
                        : Image.asset(
                            'assets/google_logo.png',
                            height: logoSize,
                            width: logoWidth,
                            cacheHeight: logoSize.toInt(),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Expanded(child: Divider(color: Color(0xFFC7C7C7), thickness: 1)),
      ],
    );
  }
}
