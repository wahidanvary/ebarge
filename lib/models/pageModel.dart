
class pageModel {
  String? _page_id;
  String? _page_image;
  String? _page_thumb;
  String? _view_count;
  String? _pdf_page_num;
  String? _real_page_num;
  String? _hotrates;
  String? _uview_id;
  String? _user_id;
  String? _uview_count;
  String? _saved_image;
  String? _hotrate;
  String? _saved_date;
  String? _visit_date;
  String? _page_ns_count;
  String? _page_qs_count;
  String? _page_cs_count;
  String? _status;
  String? _error_code;
  String? _error_description;


  pageModel(
      this._page_id,
      this._page_image,
      this._page_thumb,
      this._view_count,
      this._pdf_page_num,
      this._real_page_num,
      this._hotrates,
      this._uview_id,
      this._user_id,
      this._uview_count,
      this._saved_image,
      this._hotrate,
      this._saved_date,
      this._visit_date,
      this._page_ns_count,
      this._page_qs_count,
      this._page_cs_count,
      this._status,
      this._error_code,
      this._error_description);


  String get page_id => _page_id!;

  set page_id(String value) {
    _page_id = value;
  }

  set real_page_num(String value) {
    _real_page_num = value;
  }

  set page_ns_count(String value) {
    _page_ns_count = value;
  }

  set page_qs_count(String value) {
    _page_qs_count = value;
  }

  set page_cs_count(String value) {
    _page_cs_count = value;
  }

  set page_image(String value) {
    _page_image = value;
  }

  set page_thumb(String value) {
    _page_thumb = value;
  }

  String get page_image => _page_image!;

  String get page_thumb => _page_thumb!;

  String get view_count => _view_count!;

  String get pdf_page_num => _pdf_page_num!;

  String get real_page_num => _real_page_num!;

  String get hotrates => _hotrates!;

  String get uview_id => _uview_id!;

  String get user_id => _user_id!;

  String get uview_count => _uview_count!;

  String get saved_image => _saved_image!;

  String get hotrate => _hotrate!;

  String get saved_date => _saved_date!;

  String get visit_date => _visit_date!;

  String get page_ns_count => _page_ns_count!;

  String get page_qs_count => _page_qs_count!;

  String get page_cs_count => _page_cs_count!;

  String get status => _status!;

  String get error_code => _error_code!;

  String get error_description => _error_description!;
}
