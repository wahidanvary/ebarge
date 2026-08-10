class bookModel{
  bookModel({this.book_id,
  this.tids,
  this.admin_id,
  this.admin_name,
  this.assistant_id,
  this.assistant_name,
  this.book_name,
  this.bchap_id,
  this.avatar,
  this.small_avatar,
  this.ebavatar,
  this.small_ebavatar,
  this.section_num,
  this.ref_link,
  this.bchap_pdf,
  this.ebarge_pdf,
  this.pdfsize,
  this.pages_count,
  this.gap_pages,
  this.rate,
  this.edu_year,
  this.state,
  this.azbaziCount,
  this.status,
  this.error_code,
  this.error_description});

  String? book_id;
  String? tids;
  String? admin_id;
  String? admin_name;
  String? assistant_id;
  String? assistant_name;
  String? book_name;
  String? bchap_id;
  String? avatar;
  String? small_avatar;
  String? ebavatar;
  String? small_ebavatar;
  String? section_num;
  String? ref_link;
  String? bchap_pdf;
  String? ebarge_pdf;
  String? pdfsize;
  String? pages_count;
  String? gap_pages;
  String? rate;
  String? edu_year;
  String? state;
  String? azbaziCount;
  String? status;
  String? error_code;
  String? error_description;

  factory bookModel.fromJson(Map<String, dynamic> json) => bookModel(
    book_id: json["book_id"],
    tids: json["tids"],
    admin_id: json["admin_id"],
    admin_name: json["admin_name"],
    assistant_id: json["assistant_id"],
    assistant_name: json["assistant_name"],
    book_name: json["book_name"],
    bchap_id: json["bchap_id"],
    avatar: json["avatar"],
    small_avatar: json["small_avatar"],
    ebavatar: json["ebavatar"],
    small_ebavatar: json["small_ebavatar"],
    section_num: json["section_num"],
    ref_link: json["ref_link"],
    bchap_pdf: json["bchap_pdf"],
    ebarge_pdf: json["ebarge_pdf"],
    pdfsize: json["pdfsize"],
    pages_count: json["pages_count"],
    gap_pages: json["gap_pages"],
    rate: json["rate"],
    edu_year: json["edu_year"],
    state: json["state"],
    azbaziCount: json["azbazi_count"],
    status: json["status"],
    error_code: json["error_code"],
    error_description: json["error_description"],
  );

  Map<String, dynamic> toJson() => {
    "book_id": book_id,
    "tids": tids,
    "admin_id": admin_id,
    "admin_name": admin_name,
    "assistant_id": assistant_id,
    "assistant_name": assistant_name,
    "book_name": book_name,
    "bchap_id": bchap_id,
    "avatar": avatar,
    "small_avatar": small_avatar,
    "ebavatar": ebavatar,
    "small_ebavatar": small_ebavatar,
    "section_num": section_num,
    "ref_link": ref_link,
    "bchap_pdf": bchap_pdf,
    "ebarge_pdf": ebarge_pdf,
    "pdfsize": pdfsize,
    "pages_count": pages_count,
    "gap_pages": gap_pages,
    "rate": rate,
    "edu_year": edu_year,
    "state": state,
    "azbazi_count": azbaziCount,
    "status": status,
    "error_code": error_code,
    "error_description": error_description,
  };

  String? replaceFarsiNumber(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const farsi = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];

    for (int i = 0; i < english.length; i++) {
      input = input.replaceAll(english[i], farsi[i]);
    }

    return input;
  }
}