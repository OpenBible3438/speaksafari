import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:speak_safari/src/view/base/base_view_model.dart';
import 'package:speak_safari/src/view/main/word_quiz/word_quiz_view_model.dart';

class HomeViewModel extends BaseViewModel {
  // 주간 진도 상태
  Future<List<WeeklyDto>> getWeeklyStudyStatus() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot<Map<String, dynamic>> snapshot = await firestore
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.email)
        .collection('word')
        .get();
    List<WordDto> result =
        snapshot.docs.map((e) => WordDto.fromJson(e.data())).toList();

    List<DateTime> dates = getWeekDatesSunToSat();
    DateTime nowTime = DateTime.now();

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

  WeeklyDto({
    required this.day,
    required this.date,
    this.studied = false,
    this.isFuture = false,
    this.isAllQuiz = false,
  });
}
