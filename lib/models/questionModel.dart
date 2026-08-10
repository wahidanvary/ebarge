class questionModel{
  questionModel({this.question_id,
    this.azbazi_id,
    this.book_id,
    this.page_id,
    this.user_id,
    this.editor_id,
    this.book_chapter,
    this.page_num,
    this.que_content,
    this.answer_map,
    this.que_level,
    this.que_type,
    this.question_in,
    this.que_answer,
    this.testi_answer,
    this.que_score,
    this.que_answertime,
    this.que_rate,
    this.que_source,
    this.print_count,
    this.created_date,
    this.modified_date,
    this.qstate,
    this.guide,
    this.max_score,
    this.qholes,
    this.first_solver,
    this.myqscore,
    this.qview_count,
    this.myqrate,
    this.visit_date,
    this.solved_date,
    this.uvstate,
    this.status,
    this.error_code,
    this.error_description});

  String? question_id;
  String? azbazi_id;
  String? book_id;
  String? page_id;
  String? user_id;
  String? editor_id;
  String? book_chapter;
  int? page_num;
  String? que_content;
  String? answer_map;
  String? que_level;
  String? que_type;
  String? question_in;
  String? que_answer;
  String? testi_answer;
  String? que_score;
  String? que_answertime;
  String? que_rate;
  String? que_source;
  String? print_count;
  String? created_date;
  String? modified_date;
  String? qstate;
  String? guide;
  double? max_score;
  int? qholes;
  String? first_solver;
  double? myqscore;
  int? qview_count;
  String? myqrate;
  String? visit_date;
  String? solved_date;
  int? uvstate;
  String? status;
  String? error_code;
  String? error_description;



  factory questionModel.fromJson(Map<String, dynamic> json) => questionModel(
    question_id: json["question_id"],
    azbazi_id: json["azbazi_id"],
    book_id: json["book_id"],
    page_id: json["page_id"],
    user_id: json["user_id"],
    editor_id: json["editor_id"],
    book_chapter: json["book_chapter"],
    page_num: json["page_num"],
    que_content: json["que_content"],
    answer_map: json["answer_map"],
    que_level: json["que_level"],
    que_type: json["que_type"],
    question_in: json["question_in"],
    que_answer: json["que_answer"],
    testi_answer: json["testi_answer"],
    que_score: json["que_score"],
    que_answertime: json["que_answertime"],
    que_rate: json["que_rate"],
    que_source: json["que_source"],
    print_count: json["print_count"],
    created_date: json["created_date"],
    modified_date: json["modified_date"],
    qstate: json["qstate"],
    guide: json["guide"],
    max_score: json["max_score"],
    qholes: json["qholes"],
    first_solver: json["first_solver"],
    myqscore: json["myqscore"],
    qview_count: json["qview_count"],
    myqrate: json["myqrate"],
    visit_date: json["visit_date"],
    solved_date: json["solved_date"],
    uvstate: json["uvstate"],
    status: json["status"],
    error_code: json["error_code"],
    error_description: json["error_description"],
  );

  Map<String, dynamic> toJson() => {
    "question_id": question_id,
    "azbazi_id": azbazi_id,
    "book_id": book_id,
    "page_id": page_id,
    "user_id": user_id,
    "editor_id": editor_id,
    "book_chapter": book_chapter,
    "page_num": page_num,
    "que_content": que_content,
    "answer_map": answer_map,
    "que_level": que_level,
    "que_type": que_type,
    "question_in": question_in,
    "que_answer": que_answer,
    "testi_answer": testi_answer,
    "que_score": que_score,
    "que_answertime": que_answertime,
    "que_rate": que_rate,
    "que_source": que_source,
    "print_count": print_count,
    "created_date": created_date,
    "modified_date": modified_date,
    "qstate": qstate,
    "guide": guide,
    "max_score": max_score,
    "qholes": qholes,
    "first_solver": first_solver,
    "myqscore": myqscore,
    "qview_count": qview_count,
    "myqrate": myqrate,
    "visit_date": visit_date,
    "solved_date": solved_date,
    "uvstate": uvstate,
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