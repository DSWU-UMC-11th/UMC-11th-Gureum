import 'package:flutter/foundation.dart';

class LearningMemberSession extends ChangeNotifier {
  LearningMemberSession() {
    const seededId = int.fromEnvironment('WEEK7_MEMBER_ID');
    if (seededId > 0) memberId = seededId;
  }

  int? memberId;
  String? email;
  String? nickname;

  void setMember({required int id, String? email, String? nickname}) {
    memberId = id;
    this.email = email;
    this.nickname = nickname;
    notifyListeners();
  }

  void clear() {
    memberId = null;
    email = null;
    nickname = null;
    notifyListeners();
  }
}
