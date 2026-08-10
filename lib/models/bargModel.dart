class bargModel {
  String _barg_id;
  String _user_id;
  String _amount;
  String _type;
  String _book_id;
  String _item_id;
  String _wdate;
  String _detail;

  bargModel(this._barg_id, this._user_id, this._amount, this._type,
      this._book_id, this._item_id, this._wdate, this._detail);

  String get detail => _detail;

  String get wdate => _wdate;

  String get item_id => _item_id;

  String get book_id => _book_id;

  String get type => _type;

  String get amount => replaceFarsiNumber(_amount);

  String get user_id => _user_id;

  String get barg_id => _barg_id;

  String replaceFarsiNumber(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const farsi = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];

    for (int i = 0; i < english.length; i++) {
      input = input.replaceAll(english[i], farsi[i]);
    }

    return input;
  }
}