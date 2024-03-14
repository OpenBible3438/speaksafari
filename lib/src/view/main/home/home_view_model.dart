import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:speak_safari/src/view/base/base_view_model.dart';
import 'package:speak_safari/src/view/main/word_quiz/word_quiz_view_model.dart';

class HomeViewModel extends BaseViewModel {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  String myEmail = FirebaseAuth.instance.currentUser!.email.toString();
  String myUID = FirebaseAuth.instance.currentUser!.uid;

  String thisWeekDate = '';
  int weeklyCount = 0;

  // 주간 진도 상태
  Future<List<WeeklyDto>> getWeeklyStudyStatus() async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await firestore
        .collection("users")
        .doc(myEmail)
        .collection('word')
        .get();
    List<WordDto> result =
        snapshot.docs.map((e) => WordDto.fromJson(e.data())).toList();

    List<DateTime> dates = getWeekDatesSunToSat();
    DateTime nowTime = DateTime.now();

    // Rank
    thisWeekDate = DateFormat('yyyyMMdd').format(dates[0]);

    List<WeeklyDto> weekly = [
      WeeklyDto(day: "일", date: ""),
      WeeklyDto(day: "월", date: ""),
      WeeklyDto(day: "화", date: ""),
      WeeklyDto(day: "수", date: ""),
      WeeklyDto(day: "목", date: ""),
      WeeklyDto(day: "금", date: ""),
      WeeklyDto(day: "토", date: ""),
    ];
    for (int i = 0; i < 7; i++) {
      if (!nowTime.isAfter(dates[i])) {
        // 미래
        weekly[i].date = DateFormat('MM/dd').format(dates[i]);
        weekly[i].isFuture = true;
      } else {
        // 과거 & 오늘
        try {
          WordDto dto = result.firstWhere((element) =>
              element.date == DateFormat('yyyy-MM-dd').format(dates[i]));
          bool isStudied = false;
          bool isAllQuiz = false;
          if (dto.count! > 0) {
            isStudied = true;
            weeklyCount += dto.count!;
            if (dto.count! > 9) {
              isAllQuiz = true;
            }
          }
          weekly[i].date = DateFormat('MM/dd').format(dates[i]);
          weekly[i].studied = isStudied;
          weekly[i].isAllQuiz = isAllQuiz;
        } catch (e) {
          // 데이터(공부 기록) 없는 경우
          weekly[i].date = DateFormat('MM/dd').format(dates[i]);
          weekly[i].studied = false;
        }
      }
    }

    return weekly;
  }

  // 주간 등수(Rank)
  Future<int> getMyWeeklyRank() async {
    // Rank
    List<UsersRankDto> usersRateList = [];
    QuerySnapshot<Map<String, dynamic>> snapshot2 = await firestore
        .collection("users_rate")
        .doc(thisWeekDate)
        .collection('users')
        .get();
    if (snapshot2.docs.isEmpty) {
      // 이번주 데이터가 없는 경우 생성
      await firestore
          .collection('users_rate')
          .doc(thisWeekDate)
          .collection('users')
          .doc()
          .set({myUID: weeklyCount});
      // data 재설정
      snapshot2 = await firestore
          .collection("users_rate")
          .doc(thisWeekDate)
          .collection('users')
          .get();
    }

    bool isMyUid = false;
    for (var doc in snapshot2.docs) {
      var data = doc.data();
      if (data.containsKey(myUID)) {
        isMyUid = true;
      }
    }
    if (!isMyUid) {
      debugPrint('내 UID 없음');
      // Insert Data
      await firestore
          .collection('users_rate')
          .doc(thisWeekDate)
          .collection('users')
          .doc()
          .set({myUID: weeklyCount});
      // data 재설정
      snapshot2 = await firestore
          .collection("users_rate")
          .doc(thisWeekDate)
          .collection('users')
          .get();
    }

    for (var doc in snapshot2.docs) {
      var data = doc.data();
      if (data.containsKey(myUID)) {
        // Update data
        await doc.reference.update({myUID: weeklyCount});
      }
      data.forEach((key, value) {
        usersRateList.add(UsersRankDto(uid: key, rate: value));
      });
    }

    usersRateList.sort((a, b) => b.rate.compareTo(a.rate)); // rate 기준 정렬
    int myIndex = usersRateList.indexWhere((element) => element.uid == myUID);
    if (myIndex != -1) {
      debugPrint('내 순위 : ${myIndex + 1}등!');
    } else {
      debugPrint('아직 학습 데이터가 없습니다.');
    }

    return (myIndex + 1);
  }

  // 일 - 토 날짜 계산
  List<DateTime> getWeekDatesSunToSat() {
    final now = DateTime.now();
    final int todayWeekday = now.weekday;
    final int daysToSunday = (todayWeekday % 7);

    final DateTime sunday = now.subtract(Duration(days: daysToSunday));

    List<DateTime> weekDates =
        List.generate(7, (index) => sunday.add(Duration(days: index)));

    return weekDates;
  }
}

class WeeklyDto {
  final String day;
  String date;
  bool studied;
  bool isFuture;
  bool isAllQuiz;
  int rank;

  WeeklyDto({
    required this.day,
    required this.date,
    this.studied = false,
    this.isFuture = false,
    this.isAllQuiz = false,
    this.rank = 0,
  });
}

class UsersRankDto {
  String uid;
  int rate;

  UsersRankDto({
    required this.uid,
    required this.rate,
  });
}
