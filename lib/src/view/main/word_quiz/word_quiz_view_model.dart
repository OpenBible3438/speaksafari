import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:speak_safari/src/view/base/base_view_model.dart';

class WordQuizViewModel extends BaseViewModel {
  String todayString = DateTime.now().toString().substring(0, 10);

  // 오늘 단어 퀴즈 진행 횟수
  Future<int> getTodayWordRate() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot<Map<String, dynamic>> snapshot = await firestore
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.email)
        .collection('word')
        .get();
    List<WordDto> result =
        snapshot.docs.map((e) => WordDto.fromJson(e.data())).toList();

    try {
      WordDto dto = result.firstWhere((element) => element.date == todayString);
      debugPrint('count : ${dto.count}');

      return dto.count ?? 0;
    } catch (e) {
      // 오늘 날짜가 없는 경우 생성
      await firestore
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.email)
          .collection('word')
          .doc(todayString)
          .set(WordDto(date: todayString, count: 0).toJson());
      return 0;
    }
  }

  // 오늘 단어 퀴즈 진행 횟수 업데이트
  Future<void> updateTodayWordRate(int count) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    await firestore
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.email)
        .collection('word')
        .doc(todayString)
        .set(WordDto(date: todayString, count: count).toJson());
  }
}

class WordDto {
  String? date;
  int? count;

  WordDto({
    this.date,
    this.count,
  });

  factory WordDto.fromJson(Map<String, dynamic> json) {
    return WordDto(
      date: json['date'],
      count: json['count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "date": date,
      "count": count,
    };
  }
}
