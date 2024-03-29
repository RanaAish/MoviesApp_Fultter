import 'dart:convert';
import 'package:flutter/material.dart';
import 'MyHelper.dart';
import 'films.dart';
import 'package:http/http.dart';
import 'package:toast/toast.dart';
import 'Film.dart';
import 'package:connectivity/connectivity.dart';
import 'dart:async';

void main() => runApp(MyApp());

/////////////////////////Screens//////////////////////////////

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Films',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage(title: 'Films'),
        debugShowCheckedModeBanner: false,
        routes: {
          "/first": (context) => MyHomePage(),
          "/second": (context) => mysecondscreen(),
          "/third": (context) => mysthirdcreen(),
        });
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  /////////////////////varables////////////////////////
  dynamic text;
  dynamic icon = '';
  List<Results> res = new List();
  bool click = true;
  var saved = [];
  bool addtofav;
  var helper = MyHelper();
  String _connectionStatus;
  final Connectivity _connectivity = new Connectivity();
  StreamSubscription<ConnectivityResult> _connectionSubscription;
  List<Film> filmlist;
  bool clickarrow = true;

/////////////////////////get content /////////////////////////

  Future<Response> getfilms() async {
    final response = await get(
        "https://api.themoviedb.org/3/movie/popular?api_key=d032214048c9ca94d788dcf68434f385");
    dynamic jsonString = response.body; // json
    dynamic parsedJson = json.decode(jsonString); // json to map
    dynamic Films = films.fromJson(parsedJson); // map to object
    setState(() {
      for (int i = 0; i < Films.results.length; i++) {
        res.add(Films.results[i]);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    ///////////////get data froma api ///////////////
    getfilms();
    //////////////check on connection ////////////////
    _connectionSubscription =
        _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        _connectionStatus = result.toString();
        print(" statusconnection ${result}");
      });
    });
  }

  //////////body of one screen ///////////////////
  @override
  Widget build(BuildContext context) {
    ///////////add , remove  favaouraite/////////////////
    bool pressfav(int index) {
      if (saved.contains(res[index].id)) {
        res[index].key = false;
        saved.remove(res[index].id);
        return false;
      } else {
        res[index].key = true;
        saved.add(res[index].id);
        return true;
      }
    }

    ///////////////create list of content of db///////////
    Future<List<Film>> favouraitefilms = select(context);
    favouraitefilms.then((filmlist) // result of the mehod select
        {
      setState(() {
        this.filmlist = filmlist;
      });
    });
    if (_connectionStatus == "ConnectivityResult.wifi" ||
        _connectionStatus == "ConnectivityResult.mobile") {
      //////////////////////// there is connection ///////////////
      return Scaffold(
        appBar: AppBar(
          title: Text('Movies'),
          actions: <Widget>[
            IconButton(
                icon: new Icon(
                  Icons.favorite,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/third',
                  );
                })
          ],
        ),
        body: Material(
          color: Colors.black12,
          child: GridView.count(
            crossAxisCount: 2,
            padding: EdgeInsets.all(6),
            children: List.generate(res.length, (index) {
              icon = res[index].posterPath;
              return GestureDetector(
                  child: Card(
                    child: Center(
                      child: Column(children: <Widget>[
                        Center(
                            child: Container(
                                padding:
                                    EdgeInsets.only(top: 5, bottom: 3, left: 3),
                                child: Text(
                                  reformat(res[index].title),
                                  style: TextStyle(fontSize: 15),
                                ))),
                        Image.network(
                          'http://image.tmdb.org/t/p/w500$icon',
                          height: 60,
                        ),
                        new IconButton(
                            icon: new Icon(
                              res[index].key
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: res[index].key ? Colors.red : null,
                            ),
                            onPressed: () {
                              setState(() {
                                addtofav = pressfav(index);
                                if (addtofav) {
                                  insertfilm(context, index);
                                } else {
                                  deletefilm(context, index);
                                }
                              });
                            }),
                      ]),
                    ),
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, '/second',
                        arguments: res[index]);
                  });
            }),
          ),
        ),
      );
      ////////////////////No connection //////////////////////
    } else {
      return Scaffold(
          appBar: AppBar(
            title: Text('Favourite Movies'),
            actions: <Widget>[
              /////////change shape of arrow//////////
              if (clickarrow)
                IconButton(
                  icon: new Icon(Icons.arrow_drop_down, color: Colors.white),
                  onPressed: () {
                    clickarrow = false;
                  },
                )
              else
                IconButton(
                  icon: new Icon(Icons.arrow_drop_up, color: Colors.white),
                  onPressed: () {
                    clickarrow = true;
                  },
                )
            ],
          ),
          body: Material(
              color: Colors.black12,
              child: filmlist.length == 0
                  ? Center(
                      child: Text("No Films in favorite list"),
                    )
                  : Column(
                      children: <Widget>[
                        FlatButton(
                          child: Text(
                            'No Internet Connection',
                            style: TextStyle(color: Colors.red, fontSize: 18),
                          ),
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                      title: Text('Connect to Network'),
                                      content: Text(
                                        'To use this app , turn on mobile data or connect to Wi-Fi',
                                        style: TextStyle(color: Colors.black45),
                                      ),
                                      contentPadding: EdgeInsets.all(13),
                                      actions: <Widget>[
                                        FlatButton(
                                          color: Colors.black12,
                                          child: Text('OK'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        )
                                      ],
                                    ));
                          },
                        ),
                        Expanded(
                          child: GridView.count(
                              crossAxisCount: 2,
                              children: List.generate(filmlist.length, (index) {
                                return GestureDetector(
                                  child: Card(
                                      //  margin:  EdgeInsets.all(10),
                                      child: Center(
                                          child: Column(children: <Widget>[
                                    Image.network(
                                      "http://image.tmdb.org/t/p/w500${filmlist[index].path}",
                                      height: 110,
                                    ),
                                    Center(
                                      child: Text('id:${filmlist[index].id}'),
                                    )
                                  ]))),
                                );
                              })),
                        )
                      ],
                    )));
    }
  }

  /////////////////// reformat text ////////////////
  String reformat(String titt) {
    String g = '';
    for (int i = 0; i < titt.length; i++) {
      if (titt[i] == ':') {
        break;
      }
      g += titt[i];
    }
    return g;
  }

  ///////////////insert to db //////////////////////

  Future insertfilm(BuildContext, int index) async {
    var f = Film(res[index].id, res[index].posterPath);
    await helper.insertIntoTable(f);
    Toast.show('Saved', context);
  }

  //////////////////delete to db //////////////////
  Future deletefilm(
    BuildContext,
    int index,
  ) async {
    int result = await helper.deletefromtable(res[index].id);
    if (result != 0) {
      Toast.show(' deleted successfully', context);
    }
  }

  /////////////////select from db///////////////////

  Future<List<Film>> select(BuildContext context) async {
    if (clickarrow) {
      filmlist = await helper.getNotes('ASC');
    } else {
      filmlist = await helper.getNotes('DESC');
    }

    return filmlist;
  }
}

/////////////details of each film ///////////////
class mysecondscreen extends StatelessWidget {
  var textconrtroller = TextEditingController();
  var comment;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    Results args = ModalRoute.of(context).settings.arguments;
    List details = [
      args.title,
      args.overview,
      args.releaseDate,
      args.originalLanguage,
    ];
    List words = ["title", "overview", "release_date", "original_language"];
    return Scaffold(
        ///////////Menu of page ///////////////////
        endDrawer: SideDrawer(),
        appBar: AppBar(title: Text("Detais of Film")),
        body: Material(
          color: Colors.black12,
          child: Card(
              margin: EdgeInsets.all(20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(17.0),
              ),
              child: ListView.builder(
                itemCount: details.length,
                itemBuilder: (context, index) => Row(children: <Widget>[
                  Card(
                      margin: EdgeInsets.only(
                          right: 2, top: 15, bottom: 15, left: 5),
                      color: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17.0),
                      ),
                      child: Center(
                          child: Text(
                        '    ${words[index]}    ',
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      ))),
                  Text('  '),
                  Expanded(
                    child: Text('${details[index]} '),
                  )
                ]),
              )),
        ));
  }
}
///////////////////class drawer/////////////////
class SideDrawer extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return new SizedBox(
      width: MediaQuery.of(context).size.width * 0.70,
      child: Drawer(
          child: ListView(
            children: <Widget>[
              new UserAccountsDrawerHeader(accountName: Text('Rana Mahmoud')
                , accountEmail: Text('Rana Mahmoud @gmail.com'),
                currentAccountPicture: new CircleAvatar(
                  backgroundColor: Colors.white,
                  child:Image.asset("lib/ahmed.jpg") ,

                ),
              ),
//              DrawerHeader(
//
//                  decoration: BoxDecoration(
//                    color: Colors.blue,
//                  ),
//                  child: Center(
//                    child: Text(
//                      'Movies',
//                      style: TextStyle(fontSize: 20, color: Colors.white),
//                    ),
//                  )),

              ListTile(
                leading: Icon(Icons.favorite_border),
                title: Text(
                  'Favourites',
                  style: TextStyle(fontSize: 15),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/third');
                },
              ),
              ListTile(
                leading: Icon(Icons.tv),
                title: Text('Films', style: TextStyle(fontSize: 15)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/first');
                },
              ),
              ListTile(
                leading: Icon(Icons.perm_identity),
                title: Text('Profile', style: TextStyle(fontSize: 15)),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          )),
    );
  }
}
///////////////////data base////////////////////

class mysthirdcreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => mysthirdcreenstate();
}

class mysthirdcreenstate extends State<mysthirdcreen> {
  var db = MyHelper();
  List<Film> filmlist;
  bool click = true;

  @override
  Widget build(BuildContext context) {
    Future<List<Film>> favouraitefilms = select(context);
    favouraitefilms.then((filmlist) // result of the mehod select
        {
      setState(() {
        this.filmlist = filmlist;
      });
    });

    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          title: Text('Favourite Movies'),
          actions: <Widget>[
            if (click)
              IconButton(
                icon: new Icon(Icons.arrow_drop_down, color: Colors.white),
                onPressed: () {
                  click = false;
                },
              )
            else
              IconButton(
                icon: new Icon(Icons.arrow_drop_up, color: Colors.white),
                onPressed: () {
                  click = true;
                },
              )
          ],
        ),
        body: Material(
          color: Colors.black12,
          child: filmlist.length == 0
              ? Center(
                  child: Text("No Films in your favorite list"),
                )
              : GridView.count(
                  crossAxisCount: 2,
                  children: List.generate(filmlist.length, (index) {
                    return GestureDetector(
                      child: Card(
                          child: Center(
                              child: Column(children: <Widget>[
                        Image.network(
                          "http://image.tmdb.org/t/p/w500${filmlist[index].path}",
                          height: 110,
                        ),
                        Center(
                          child: Text('id:${filmlist[index].id}'),
                        )
                      ]))),
                    );
                  })),
        ));
  }

  /////////////select from db ///////////////
  Future<List<Film>> select(BuildContext context) async {
    if (click) {
      filmlist = await db.getNotes('ASC');
    } else {
      filmlist = await db.getNotes('DESC');
    }

    return filmlist;
  }
}
