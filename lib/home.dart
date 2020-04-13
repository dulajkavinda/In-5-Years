import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:infiveyears/model/personal_det.dart';
import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Firestore firestore = Firestore.instance;

  PageController _controller = PageController(
    initialPage: 0,
    viewportFraction: 0.8,
  );

  int currentPage = 0;

  @override
  void initState() {
    _controller.addListener(() {
      int next = _controller.page.round();
      if (currentPage != next) {
        setState(() {
          currentPage = next;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: new BoxDecoration(
          gradient: new LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.fromARGB(255, 142, 45, 226),
          Color.fromARGB(255, 74, 0, 224)
        ],
      )),
      child: StreamBuilder<QuerySnapshot>(
          stream: firestore.collection("queries").snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return SpinKitDoubleBounce(
                color: Colors.white,
                size: 90.0,
              );
            }

            return _buildQueryList(snapshot);
          }),
    );
  }

  Widget _buildQueryList(AsyncSnapshot<QuerySnapshot> snapshot) {
    return PageView.builder(
      controller: _controller,
      itemCount: snapshot.data.documents.length,
      itemBuilder: (context, int currentIdx) {
        final DocumentSnapshot document = snapshot.data.documents[currentIdx];
        bool active = currentPage == currentIdx;

        return _buildPage(active, document);
      },
    );
  }

  Widget _buildPage(bool active, DocumentSnapshot document) {
    final double blur = active ? 30 : 0;
    final double offset = active ? 20 : 0;
    final double top = active ? 150 : 300;
    PersonalDetails _pdet = PersonalDetails.fromSnapshot(document);
    DateFormat df = new DateFormat("d MMM y");

    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      curve: Curves.easeOutQuint,
      margin: EdgeInsets.only(top: top, bottom: 50, right: 30),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black87,
                blurRadius: blur,
                offset: Offset(offset, offset))
          ]),
      child: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(left: 19),
            child: Align(
              alignment: Alignment.topLeft,
              child: Material(
                child: Text(
                  df.format(_pdet.date.toDate()),
                  style: TextStyle(fontSize: 17.0, color: Colors.black54),
                ),
              ),
            ),
          ),
          Divider(
            indent: 10,
            endIndent: 10,
            color: Colors.black,
          ),
          Material(
            child: Text(
              _pdet.name,
              style: TextStyle(
                  fontSize: 30.0,
                  color: Colors.black,
                  fontFamily: "Traffolight"),
            ),
          ),
          Expanded(
            child: Text(""),
          ),
          Container(
              margin: EdgeInsets.only(right: 15.0, bottom: 15.0, left: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[Icon(Icons.delete), Icon(Icons.edit)],
              ))
        ],
      ),
    );
  }
}
