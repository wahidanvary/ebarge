import 'package:flutter/material.dart';

class Donation extends StatelessWidget {
  Donation({Key? key,}) : super(key: key);
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
          borderRadius: BorderRadius.circular(5.0)),
      child: new Text(
        "",
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
          "حمایت از ایبرگه",
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
            Expanded(flex: 0, child: coursePrice)
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
          height: MediaQuery.of(context).size.height * 0.45,
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
    final bottomContentText1 = SelectableText(
      "دوستان و همراهان عزیز پروژه استارت آپی حاضر کاملا با هزینه شخصی در حال پیش روی است و کاملا رایگان در اختیار فرزندان سرزمین  مان قرار گرفته است. بعد از استفاده اگر احساس کردید چیز بدرد بخوری است و می تواند در بهبود آینده فرزندان عزیزمان مفید باشد از شما دعوت می کنیم شما نیز با دونیت(هدیه) مبلغی هرچند ناچیز با ما در این مسیر هم قدم شوید...! شماره کارت بانکی و آدرس های ارز دیجیتالی: ",
      textAlign: TextAlign.justify,
      style: TextStyle(fontSize: 16.0),
    );

    final bottomContentText2 = SelectableText(
      "بعد از واریز به منظور تشکر از شما اگر مایل باشید می توانید از راههای ارتباطی زیر با اعلام نام کاربری ایبرگه خود به ما اطلاع دهید. از همراهی شما سپاسگزاریم... ",
      textAlign: TextAlign.justify,
      style: TextStyle(fontSize: 16.0),
    );

    final _padding = Padding(
      padding: EdgeInsets.only(top: 20.0),
    );
    final _padding2 = Padding(
      padding: EdgeInsets.only(top: 20.0),
    );

    final donation = Directionality(
        textDirection: TextDirection.ltr,
        child: Column(
          children: <Widget>[
            Row(
                children: <Widget>[
                  Icon(Icons.credit_card, color: Colors.black,),
                  SelectableText(
                    " 6037997183445528",
                    textAlign: TextAlign.justify,
                    style: TextStyle(fontSize: 15.0),
                  ),
                  Text(
                    " (به نام وحید انوری)",
                    textAlign: TextAlign.justify,
                    style: TextStyle(fontSize: 14.0),
                  ),
                  _padding2
                ]
            ),
            Row(
                children: <Widget>[
                  Icon(Icons.money_rounded, color: Colors.black, size: 14,),
                  SelectableText(
                    " doge: DTyBS99KhJvZz5LPqJfTBvAZxMFQb7FiRw",
                    textAlign: TextAlign.justify,
                    style: TextStyle(fontSize: 12.0),
                  ),
                ]
            ),
            Row(
                children: <Widget>[
                  Icon(Icons.money_rounded, color: Colors.black, size: 14,),
                  SelectableText(
                    " btt: TUUt4dQeCqdeQLDAuQMPk4qjceeWDzM3bu",
                    textAlign: TextAlign.justify,
                    style: TextStyle(fontSize: 12.0),
                  ),
                ]
            ),
            Row(
                children: <Widget>[
                  Icon(Icons.money_rounded, color: Colors.black, size: 14,),
                  SelectableText(
                    " usdt(trc20): TQ2XBtDcrv7s8cnTR8yPGV6hfQnGXngyaM",
                    textAlign: TextAlign.justify,
                    style: TextStyle(fontSize: 12.0),
                  ),
                ]
            ),
          ],
        )
    );

    final contactUs = Directionality(
        textDirection: TextDirection.ltr,
        child: Column(
          children: <Widget>[
            Row(
                children: <Widget>[
                  Icon(Icons.send_to_mobile, color: Colors.black,),
                  SelectableText(
                    " 09143617238",
                    textAlign: TextAlign.justify,
                    style: TextStyle(fontSize: 17.0),
                  ),
                ]
            ),
            Row(
                children: <Widget>[
                  Icon(Icons.email, color: Colors.black,),
                  SelectableText(
                    " ebargeco@gmail.com",
                    textAlign: TextAlign.justify,
                    style: TextStyle(fontSize: 17.0),
                  ),
                ]
            ),
          ],
        )
    );

    final bottomContent = Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(40.0),
      child: Center(
        child: Column(
          children: <Widget>[bottomContentText1, _padding, donation, _padding, bottomContentText2, _padding, contactUs, _padding, Divider(), _padding],
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
