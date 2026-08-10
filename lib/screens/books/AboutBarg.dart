import 'package:flutter/material.dart';

class AboutBarg extends StatelessWidget {
  AboutBarg({Key? key,}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final levelIndicator = Container(
      child: Container(
        child: LinearProgressIndicator(
            backgroundColor: Color.fromRGBO(209, 224, 224, 0.2),
            value: 10.0,
            valueColor: AlwaysStoppedAnimation(Colors.limeAccent)),
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
          "برگ چیست؟!",
          style: TextStyle(color: Colors.white, fontSize: 28.0, fontFamily: "Vazir"),
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
          ],
        ),
      ],
    );

    final topContent = Stack(
      children: <Widget>[
        Container(
            padding: EdgeInsets.only(left: 10.0),
            height: MediaQuery.of(context).size.height * 0.35,
            decoration: new BoxDecoration(
              image: new DecorationImage(
                image: new AssetImage("assets/elearning.png"),
                fit: BoxFit.contain,
              ),
            )),
        Container(
          height: MediaQuery.of(context).size.height * 0.35,
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

    final bottomContentText = Text(
      "شما در ازای فعالیتهایی که در ایبرگه دارید امتیاز برگی کسب می کنید. امتیازات برگی به شرح زیر است:" ,
      textAlign: TextAlign.justify,
      style: TextStyle(fontSize: 16.0, fontFamily: "Vazir"),
    );
    final bottomContentText2 = Text(
      "-- در ازای بارگذاری محتوا، اگر محتوا متعلق به خودتان باشد بسته به کیفیت محتوای تان از ۵۰ تا ۱۸۰۰ برگ می توانید کسب نمایید. اگر محتوا متعلق به شخص دیگری بوده و با اجازه آن شخص بارگذاری شده باشد پس از تائید ۲۰ درصد برگ به شما تعلق می گیرد و ۸۰ درصد مابقی برای شخص صاحب محتوا محفوظ می ماند." ,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 15.0, fontFamily: "Vazir", fontWeight: FontWeight.bold, color: Colors.amber[700]),
    );
    final bottomContentText3 = Text(
      "-- در ازای طراحی و بارگذاری سوال امتحانی پس از تائید به ازای هر سوال امتحانی ۳۰ برگ به شما تعلق می گیرد.",
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 16.0, fontFamily: "Vazir", fontWeight: FontWeight.bold, color: Colors.amber[700]),
    );

    final bottomContentText4 = Text(
      "برگهای کسب شده نشان دهنده تلاش شما و سطح دانش شما درکتاب موردنظر و ایبرگه می باشد.",
      textAlign: TextAlign.justify,
      style: TextStyle(fontSize: 16.0, fontFamily: "Vazir"),
    );

    final bottomContent = Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(40.0),
      child: Center(
        child: Column(
          children: <Widget>[bottomContentText, Divider(), bottomContentText3, bottomContentText2, Divider(), bottomContentText4,],
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
