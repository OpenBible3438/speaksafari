import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:speak_safari/src/view/login/auth_provider.dart';
import 'package:speak_safari/src/view/login/auth_service.dart';
import 'package:speak_safari/theme/foundation/app_theme.dart';
import 'package:speak_safari/theme/res/typo.dart';
import 'package:speak_safari/util/route_path.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<FirebaseAuthProvider>(
      builder: (context, authService, child) {
        return Scaffold(
          body: Stack(
            children: [
              // 백그라운드 PNG 이미지
              Positioned.fill(
                child: Image.asset(
                  'assets/images/login_background_image.png',
                  fit: BoxFit.cover,
                ),
              ),
              // 로그인 UI
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Welcome",
                        style: AppTypo(
                                typo: const SoyoMaple(),
                                fontColor: Colors.black,
                                fontWeight: FontWeight.w600)
                            .headline1),
                    const SizedBox(height: 100),
                    IconButton(
                      onPressed: () {},
                      icon: SvgPicture.asset(
                          'assets/icons/apple_login_button2.svg'),
                      iconSize: 160,
                    ),
                    IconButton(
                      onPressed: () async {
                        final navigator = Navigator.of(context);
                        final user = await authService.signInWithGoogle();
                        if (user != null) {
                          navigator.pushReplacementNamed(RoutePath.main);
                        } else {
                          if (!mounted) {
                            // BuildContext가 여전히 유효한지 확인
                            return; // 이 위젯의 context가 더 이상 유효하지 않다면 여기서 함수를 종료
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Google 로그인 실패')),
                          );
                        }
                      },
                      icon: SvgPicture.asset(
                          'assets/icons/google_login_button3.svg'),
                      iconSize: 160,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
