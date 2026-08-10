class RankModel {
  String? _user_id;
  String? _user_name;
  String? _totalAmount;
  String? _rank;

  RankModel(this._user_id, this._user_name, this._totalAmount, this._rank);

  String get rank => replaceFarsiNumber(_rank!);

  String get totalAmount => replaceFarsiNumber(_totalAmount!);

  String? get user_name => _user_name;

  String? get user_id => _user_id;

  String replaceFarsiNumber(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const farsi = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];

    for (int i = 0; i < english.length; i++) {
      input = input.replaceAll(english[i], farsi[i]);
    }

    return input;
  }
}