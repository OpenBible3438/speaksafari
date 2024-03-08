import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthProvider extends ChangeNotifier {
  Future<User?> currentUser() async {
    // 현재 유저(로그인 되지 않은 경우 null 반환)
    return FirebaseAuth.instance.currentUser;
  }

  /// 푸시를 하자
  /// 구글 로그인한 결과를 Firebase에 넘겨서 Auth와 연결
  /// 구글 로그인을 하면 GoogleSignInAccount 객체를 리턴 값으로 받는데,
  /// 해당 객체의 authentication 구조 안에 Token과 accessToken 값이 들어있다.
  /// 위에서 발급받은 토큰 정보를 통해 OAuthCredential을 생성할 수 있다.
  /// 이렇게 생성된 OAuthCredential firebase_auth 라이브러리에서 제공하는 signInWithCredential에 넣어주면 정상적으로 연결이 된다.
  Future<User?> signInWithGoogle() async {
    // 구글 로그인
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    User? user;
    // Firebase Auth에 user 전달
    UserCredential _credential =
        await FirebaseAuth.instance.signInWithCredential(credential);
    if (_credential.user != null) {
      user = _credential.user;
    } else {
      user = null;
    }
    return user;
  }

  void signOut() async {
    // 로그아웃
  }
}

bool isLoggedIn() {
  return FirebaseAuth.instance.currentUser == null;
}
