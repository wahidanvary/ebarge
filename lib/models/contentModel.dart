import 'dart:core';

class contentModel {
  String? _content_id;
  String? _book_id;
  String? _page_id;
  String? _user_id;
  String? _user_name;
  String? _editor_id;
  String? _owner_id;
  String? _owner_name;
  String? _isTeacher;
  String? _content_link;
  String? _thumb_link;
  String? _content_title;
  String? _content_note;
  String? _size;
  String? _language;
  String? _pages_include;
  String? _rate;
  String? _views;
  String? _rate_count;
  String? _created_date;
  String? _modified_date;
  String? _state;
  String? _isMine;
  bool? _isDeleteVideo;
  String? _isNewContent;
  List<dynamic>? _rejectReasons;
  String? _contentAccess;
  String? _book_name;
  String? _gap_pages;
  String? _page_image;
  String? _page_thumb;
  String? _real_page_num;
  String? _cViewId;
  String? _cViewCount;
  String? _crate;
  String? _visit_date;
  String? _status;
  String? _error_code;
  String? _error_description;

  contentModel(
      this._content_id,
      this._book_id,
      this._page_id,
      this._user_id,
      this._user_name,
      this._editor_id,
      this._owner_id,
      this._owner_name,
      this._isTeacher,
      this._content_link,
      this._thumb_link,
      this._content_title,
      this._content_note,
      this._size,
      this._language,
      this._pages_include,
      this._rate,
      this._views,
      this._rate_count,
      this._created_date,
      this._modified_date,
      this._state,
      this._isMine,
      this._isDeleteVideo,
      this._isNewContent,
      this._rejectReasons,
      this._contentAccess,
      this._book_name,
      this._gap_pages,
      this._page_image,
      this._page_thumb,
      this._real_page_num,
      this._cViewId,
      this._cViewCount,
      this._crate,
      this._visit_date,
      this._status,
      this._error_code,
      this._error_description);

  String? get error_description => _error_description;

  set error_description(String? value) {
    _error_description = value;
  }

  String? get error_code => _error_code;

  set error_code(String? value) {
    _error_code = value;
  }

  String? get status => _status;

  set status(String? value) {
    _status = value;
  }

  String? get visit_date => _visit_date;

  set visit_date(String? value) {
    _visit_date = value;
  }

  String? get crate => _crate;

  set crate(String? value) {
    _crate = value;
  }

  String? get cViewCount => _cViewCount;

  set cViewCount(String? value) {
    _cViewCount = value;
  }

  String? get cView_Id => _cViewId;

  set cView_Id(String? value) {
    _cViewId = value;
  }

  String? get real_page_num => _real_page_num;

  set real_page_num(String? value) {
    _real_page_num = value;
  }

  String? get page_thumb => _page_thumb;

  set page_thumb(String? value) {
    _page_thumb = value;
  }

  String? get page_image => _page_image;

  set page_image(String? value) {
    _page_image = value;
  }

  String? get gap_pages => _gap_pages;

  set gap_pages(String? value) {
    _gap_pages = value;
  }

  String? get book_name => _book_name;

  set book_name(String? value) {
    _book_name = value;
  }

  String? get contentAccess => _contentAccess;

  set contentAccess(String? value) {
    _contentAccess = value;
  }

  List<dynamic>? get rejectReasons => _rejectReasons;

  set rejectReasons(List<dynamic>? value) {
    _rejectReasons = value;
  }

  String? get isNewContent => _isNewContent;

  set isNewContent(String? value) {
    _isNewContent = value;
  }

  bool? get isDeleteVideo => _isDeleteVideo;

  set isDeleteVideo(bool? value) {
    _isDeleteVideo = value;
  }

  String? get isMine => _isMine;

  set isMine(String? value) {
    _isMine = value;
  }

  String? get state => _state;

  set state(String? value) {
    _state = value;
  }

  String? get modified_date => _modified_date;

  set modified_date(String? value) {
    _modified_date = value;
  }

  String? get created_date => _created_date;

  set created_date(String? value) {
    _created_date = value;
  }

  String? get rate_count => _rate_count;

  set rate_count(String? value) {
    _rate_count = value;
  }

  String? get views => _views;

  set views(String? value) {
    _views = value;
  }

  String? get rate => _rate;

  set rate(String? value) {
    _rate = value;
  }

  String? get pages_include => _pages_include;

  set pages_include(String? value) {
    _pages_include = value;
  }

  String? get language => _language;

  set language(String? value) {
    _language = value;
  }

  String? get size => _size;

  set size(String? value) {
    _size = value;
  }

  String? get content_note => _content_note;

  set content_note(String? value) {
    _content_note = value;
  }

  String? get content_title => _content_title;

  set content_title(String? value) {
    _content_title = value;
  }

  String? get thumb_link => _thumb_link;

  set thumb_link(String? value) {
    _thumb_link = value;
  }

  String? get content_link => _content_link;

  set content_link(String? value) {
    _content_link = value;
  }

  String? get isteacher => _isTeacher;

  set isteacher(String? value) {
    _isTeacher = value;
  }

  String? get owner_name => _owner_name;

  set owner_name(String? value) {
    _owner_name = value;
  }

  String? get owner_id => _owner_id;

  set owner_id(String? value) {
    _owner_id = value;
  }

  String? get editor_id => _editor_id;

  set editor_id(String? value) {
    _editor_id = value;
  }

  String? get user_name => _user_name;

  set user_name(String? value) {
    _user_name = value;
  }

  String? get user_id => _user_id;

  set user_id(String? value) {
    _user_id = value;
  }

  String? get page_id => _page_id;

  set page_id(String? value) {
    _page_id = value;
  }

  String? get book_id => _book_id;

  set book_id(String? value) {
    _book_id = value;
  }

  String? get content_id => _content_id;

  set content_id(String? value) {
    _content_id = value;
  }
}
