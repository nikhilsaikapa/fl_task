import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:ntp/ntp.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter FL Task',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Task Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (int index) {
            if (currentIndex == index) return;
            setState(() {
              currentIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.timer_sharp), label: 'Timer Task'),
            BottomNavigationBarItem(
                icon: Icon(Icons.slideshow), label: 'Slider Task')
          ],
        ),
        body: currentIndex == 0 ? TimeTask() : SliderTask());
  }
}

class TimeTask extends StatefulWidget {
  @override
  _TimeTaskState createState() => _TimeTaskState();
}

class _TimeTaskState extends State<TimeTask> {
  DateTime trueTime;

  @override
  void initState() {
    super.initState();
    fetchTrueTime();
  }

  String formatTimeFromData(DateTime data) {
    return DateFormat('hh:mm a').format(data);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: trueTime != null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Device Time',
                  style: TextStyle(fontSize: 16.0),
                ),
                Text(
                  '${formatTimeFromData(DateTime.now().toLocal())}',
                  style: Theme.of(context).textTheme.headline4,
                ),
                SizedBox(
                  height: 16.0,
                ),
                Text(
                  'True Time',
                  style: TextStyle(fontSize: 16.0),
                ),
                Text(
                  '${formatTimeFromData(trueTime.toLocal())}',
                  style: Theme.of(context).textTheme.headline4,
                ),
                SizedBox(
                  height: 16.0,
                ),
                RaisedButton(
                  child: Text('Refresh'),
                  onPressed: fetchTrueTime,
                ),
              ],
            )
          : CircularProgressIndicator(),
    );
  }

  void fetchTrueTime() async {
    trueTime = await NTP.now();
    setState(() {});
  }
}

class SliderTask extends StatefulWidget {
  @override
  _SliderTaskState createState() => _SliderTaskState();
}

class _SliderTaskState extends State<SliderTask> {
  StreamController<int> streamController = StreamController();

  @override
  void dispose() {
    streamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SizedBox(
        height: 16.0,
      ),
      CarouselSlider(
        items: List<Widget>.generate(5, (index) {
          return SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Card(
              shape: RoundedRectangleBorder(
                  side: BorderSide(), borderRadius: BorderRadius.circular(4.0)),
              child: Center(
                  child: Text(
                '${(index + 1).toString()}',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              )),
            ),
          );
        }),
        options: CarouselOptions(
            autoPlay: false,
            enlargeCenterPage: true,
            aspectRatio: 2.0,
            onPageChanged: (index, reason) {
              streamController.add(index);
            }),
      ),
      SizedBox(
        height: 16.0,
      ),
      Expanded(
        child: StreamBuilder(
          stream: streamController.stream,
          initialData: 0,
          builder: (context, AsyncSnapshot<int> snapshot) {
            if (snapshot.hasData) {
              return Center(
                  child: Text(
                '${(snapshot.data + 1).toString()}',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ));
            }
            return Container();
          },
        ),
      )
    ]);
  }
}
