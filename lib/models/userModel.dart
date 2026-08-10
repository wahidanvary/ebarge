class UserModel {
  UserModel({this.status,
  this.userid,
  this.username,
  this.name,
  this.family,
  this.email,
  this.birthday,
  this.diploma,
  this.proficiency,
  this.edu_code,
  this.tell_mobile,
  this.zafran,
  this.time_balance,
  this.isactive_timebal,
  this.app_streak,
  this.max_app_streak,
  this.parent_lock_pin,
  this.grade_lock,
  this.state,
  this.walletId,
  this.walletAmount,
  this.modifiedDate,
  this.detail,
  this.password,
  this.session_id,
  this.error_code,
  this.error_description,
  this.is_guest,
  this.session_expire});

  String? status;
  String? userid;
  String? username;
  String? name;
  String? family;
  String? email;
  String? birthday;
  String? diploma;
  String? proficiency;
  String? edu_code;
  String? tell_mobile;
  double? zafran;
  int? time_balance;
  bool? isactive_timebal;
  int? app_streak;
  int? max_app_streak;
  String? parent_lock_pin;
  int? grade_lock;
  int? state;
  int? walletId;
  int? walletAmount;
  String? modifiedDate;
  String? detail;
  String? password;
  String? session_id;
  String? error_code;
  String? error_description;
  int? is_guest;
  int? session_expire;

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    status: json["status"],
    userid: json["user_id"],
    username: json["username"],
    name: json["name"],
    family: json["family"],
    email: json["email"],
    birthday: json["birthday"],
    diploma: json["diploma"],
    proficiency: json["proficiency"],
    edu_code: json["edu_code"],
    tell_mobile: json["tell_mobile"],
    zafran: json["zafran"],
    time_balance: json["time_balance"],
    isactive_timebal: json["isactive_timebal"],
    app_streak: json["app_streak"],
    max_app_streak: json["max_app_streak"],
    parent_lock_pin: json["parent_lock_pin"],
    grade_lock: json["grade_lock"],
    state: json["state"],
    walletId: json["wallet_id"],
    walletAmount: json["gold_amount"],
    modifiedDate: json["modified_date"],
    detail: json["detail"],
    password: json["password"],
    session_id: json["session_id"],
    error_code: json["error_code"],
    error_description: json["error_description"],
    is_guest: json["is_guest"],
    session_expire: json["session_expire"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "user_id": userid,
    "username": username,
    "name": name,
    "family": family,
    "email": email,
    "birthday": birthday,
    "diploma": diploma,
    "proficiency": proficiency,
    "edu_code": edu_code,
    "tell_mobile": tell_mobile,
    "zafran": zafran,
    "time_balance": time_balance,
    "isactive_timebal": isactive_timebal,
    "app_streak": app_streak,
    "max_app_streak": max_app_streak,
    "parent_lock_pin": parent_lock_pin,
    "grade_lock": grade_lock,
    "state": state,
    "wallet_id": walletId,
    "gold_amount": walletAmount,
    "modified_date": modifiedDate,
    "detail": detail,
    "password": password,
    "session_id": session_id,
    "error_code": error_code,
    "error_description": error_description,
    "is_guest": is_guest,
    "session_expire": session_expire,
  };

}