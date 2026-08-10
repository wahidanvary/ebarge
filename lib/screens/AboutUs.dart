import 'package:flutter/material.dart';

class AboutUs extends StatelessWidget {
  AboutUs({Key? key,}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final levelIndicator = Container(
      child: Container(
        child: LinearProgressIndicator(
            backgroundColor: Color.fromRGBO(209, 224, 224, 0.2),
            value: 10.0,
            valueColor: AlwaysStoppedAnimation(Colors.green)),
      ),
    );

    final coursePrice = Container(
      padding: const EdgeInsets.all(7.0),
      decoration: new BoxDecoration(
          border: new Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(5.0)),
      child: new Text(
        "نسخه: 4.3.2",
        style: TextStyle(color: Colors.white, fontFamily: "Vazir", fontSize: 14),
      ),
    );

    final topContentText = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 60.0),
        Icon(
          Icons.description,
          color: Colors.white,
          size: 40.0,
        ),
        Container(
          width: 90.0,
          child: new Divider(color: Colors.green),
        ),
        SizedBox(height: 10.0),
        Text(
          "درباره ایبرگه",
          style: TextStyle(color: Colors.white, fontSize: 24.0, fontFamily: "Vazir"),
        ),
        SizedBox(height: 10.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(flex: 1, child: levelIndicator),
            Expanded(
                flex: 4,
                child: Padding(
                  padding: EdgeInsets.only(left: 10.0),
                )),
            Expanded(flex: 4, child: coursePrice)
          ],
        ),
      ],
    );

    final topContent = Stack(
      children: <Widget>[
        Container(
            padding: EdgeInsets.only(left: 10.0),
            height: MediaQuery.of(context).size.height * 0.45,
            decoration: new BoxDecoration(
              image: new DecorationImage(
                image: new AssetImage("assets/elearning.png"),
                fit: BoxFit.contain,
              ),
            )),
        Container(
          height: MediaQuery.of(context).size.height * 0.40,
          padding: EdgeInsets.all(30.0),
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(color: Color.fromRGBO(58, 66, 86, .9)),
          child: Center(
            child: topContentText,
          ),
        ),
        Directionality(
          textDirection: TextDirection.ltr,
          child: Positioned(
            left: 8.0,
            top: 60.0,
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
        )
      ],
    );
    final bottomContentText = SelectableText(
      "🎮 ایبرگه (ebarge.ir) اپلیکیشنی هوشمند و بازی‌گونه برای یادگیری و تعامل با کتاب‌های درسی است! 📚"
          "\n\n"
          "اینجا، کتاب‌های درسی از ابتدایی تا دبیرستان فقط یک متن خشک نیستند، بلکه به دنیایی تعاملی، سرگرم‌کننده و جذاب تبدیل شده‌اند:",
      textAlign: TextAlign.justify,
      style: TextStyle(fontSize: 16.0, height: 1.6),
    );

    final bottomContentText2 = SelectableText(
      "• درس بخوان و همزمان با آزبازی‌ها مهارت‌های خودت را بسنج 🎯\n"
          "• یادداشت، طرح و علامت‌گذاری روی صفحات کتاب‌ها، همیشه همراهته ✏️\n"
          "• محتواهای آموزشی و سوالات امتحانی را با دیگر دانش‌آموزان و معلمان به‌صورت مشارکتی اعتبارسنجی کن 🤝\n"
          "• با دوستان و کلاس خود رقابت و اشتراک‌گذاری انجام بده و از تجربه یادگیری لذت ببر 🧠",
      textAlign: TextAlign.justify,
      style: TextStyle(fontSize: 16.0, height: 1.6),
    );

    final bottomContentText3 = SelectableText(
      "ایبرگه یادگیری را از حالت تکراری و خسته‌کننده خارج کرده و با بازی‌وارسازی، یادگیری معکوس و چالش‌های جذاب، درس خواندن را هیجان‌انگیز می‌کند 🌟"
          "\n\n"
          "💡 معلمان، دانش‌آموزان و اولیا می‌توانند همه کتاب‌ها را همیشه همراه داشته باشند، آزمون بسازند و در کمترین زمان به محتوای تعاملی دسترسی پیدا کنند.",
      textAlign: TextAlign.justify,
      style: TextStyle(fontSize: 16.0, height: 1.6),
    );


    final _padding = Padding(
      padding: EdgeInsets.only(top: 10.0),
    );

    final contactUs = Directionality(
        textDirection: TextDirection.ltr,
        child: Column(
          children: <Widget>[
            Row(
                children: <Widget>[
                  Icon(Icons.send_to_mobile, color: Colors.black,),
                  SelectableText(
                    " 09363298391",
                    textAlign: TextAlign.justify,
                    style: TextStyle(fontSize: 17.0),
                  ),
                ]
            ),
            Row(
                children: <Widget>[
                  Icon(Icons.email, color: Colors.black,),
                  SelectableText(
                    " anvary_w@ind.iust.ac.ir",
                    textAlign: TextAlign.justify,
                    style: TextStyle(fontSize: 17.0),
                  ),
                ]
            ),
          ],
        )
    );

    final bottomContentText4 = SelectableText(
      "به منظور هرگونه انتقاد، پیشنهاد و اعلام گزارشات سامانه و همچنین هرگونه پیشنهاد همکاری از راه‌های ارتباطی زیر می توانید به ما پیام دهید: ",
      textAlign: TextAlign.justify,
      style: TextStyle(fontSize: 16.0),
    );
    //
    // final thanks = Column(
    //   children: <Widget>[
    //     Row(
    //         children: <Widget>[
    //           Icon(Icons.assistant_photo_outlined, color: Colors.black,),
    //           Expanded(
    //             child: SelectableText(
    //               " اداره فناوری اطلاعات آموزش و پرورش استان آذربایجان غربی",
    //               textAlign: TextAlign.justify,
    //               style: TextStyle(fontSize: 14.0),
    //             ),
    //           ),
    //         ]
    //     ),
    //     Row(
    //         children: <Widget>[
    //           Icon(Icons.assistant_photo_outlined, color: Colors.black,),
    //           Expanded(
    //             child: SelectableText(
    //               " جامعه مدرسین کامپیوتر ایران",
    //               textAlign: TextAlign.justify,
    //               style: TextStyle(fontSize: 15.0),
    //             ),
    //           ),
    //         ]
    //     ),
    //   ],
    // );

    final bottomContent = Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(40.0),
      child: Center(
        child: Column(
          children: <Widget>[bottomContentText, bottomContentText2, _padding,  bottomContentText3, _padding, Divider(),bottomContentText4, contactUs, _padding,],
        ),
      ),
    );

    return Scaffold(
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[topContent, bottomContent],
          ),
        ),
      ),
    );
  }
}
