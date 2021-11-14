import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:loadmore/loadmore.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter loading items'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<dynamic> _planets = [];
  String nextPage = "";
  int loadedPage = 1;

  List<dynamic> _allPlanets = [];

  void _removeItem(String name) {
    setState(() {
      _planets.removeWhere((item) => item['name'] == name);
    });
  }

  String loadUrl() {
    String url;
    if (_planets.length > 0 && nextPage != "") {
      loadedPage++;

      url = nextPage;
    } else {
      url = "https://swapi.dev/api/planets/";
    }

    return url;
  }

  void mergeData(planets) {
    _allPlanets.addAll(planets);
  }

  Future<bool> _loadMore() async {
    await Future.delayed(Duration(seconds: 0, milliseconds: 500));
    _loadData();

    return true;
  }

  void _loadData() async {
    // Parsovanie URL pre pouzitie v get()
    var url = Uri.parse(loadUrl());

    Future<http.Response> fr = http.get(url);

    // Async pre ziskanie dat
    http.Response res = await fr;

    // Do retazca sa nahra telo stranky cize JSON
    String data = res.body;

    // Sting sa Decoduje do pola
    Map<String, dynamic> dataMap = convert.jsonDecode(data);

    var results = dataMap['results'];

    if (dataMap['next'] != null) {
      nextPage = dataMap['next'];
    } else {
      nextPage = "stop";
    }

    if (loadedPage > 1) {
      mergeData(results);
    } else {
      _allPlanets = results;
    }

    setState(() {
      _planets = _allPlanets;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: LoadMore(
        isFinish: nextPage == "stop",
        onLoadMore: _loadMore,
        child: ListView.builder(
          itemCount: _planets.length,
          itemBuilder: (BuildContext context, int i) => Card(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    child: Text(
                      _planets[i]['name'],
                      style: const TextStyle(fontSize: 20),
                    ),
                    padding: const EdgeInsets.all(10),
                  ),
                ),
                Column(
                  children: [
                    Container(
                      child: Text(
                        "Population",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.purple,
                        ),
                      ),
                      padding: const EdgeInsets.only(top: 10, right: 5),
                    ),
                    Container(
                      child: Text(_planets[i]['population']),
                      padding: const EdgeInsets.all(10),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete,
                    color: Colors.pink[300],
                  ),
                  tooltip: 'Remove item',
                  onPressed: () {
                    _removeItem(_planets[i]['name']);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      //floatingActionButton: FloatingActionButton(
      //  onPressed: _loadData,
      //  tooltip: 'Increment',
      //  child: const Icon(Icons.add),
      //), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
