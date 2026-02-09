import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:grant_mag_app/articles.dart';
import 'package:grant_mag_app/profile_model.dart';
import 'package:grant_mag_app/theme_model.dart';
import 'package:grant_mag_app/settings.dart';
import 'package:grant_mag_app/profile.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_checklist/checklist.dart';
import 'package:grant_mag_app/noti_service.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  //initialize notifications
  NotiService().initNotif();
  
  runApp(
    // const GrantMagApp()
    // ChangeNotifierProvider(
    //   create: (context) => ThemeModel(),
    //   child: const GrantMagApp(),
    // ),
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeModel()),
        ChangeNotifierProvider(create: (_) => ProfileModel()),
      ],
      child: GrantMagApp(),
      )
  );
}
class GrantMagApp extends StatelessWidget {
  const GrantMagApp({super.key});
  static const appTitle = 'Home Page';

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.amber, // use listener to get provider info
        primarySwatch: Colors.amber
      ),
      home: HomePage(title: appTitle),
      routes: {
        '/homepage': (context) => const HomePage(title: appTitle),
        '/examplearticlepage': (context) => ExampleArticlePage(),
      },
      title: appTitle,
    );
  }
}

class Multiselect extends StatefulWidget {
  //final List<String> items;
  //const Multiselect({super.key});

  @override
  State<Multiselect> createState() => _MultiselectState();
}

class _MultiselectState extends State<Multiselect> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _counter = 0;
  int whoAreYou = 0;
  List<String> notificationSelections = [];
  
  final FlutterLocalNotificationsPlugin notificationsPlugin = 
  FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    
    NotiService service = NotiService();
    service.initNotif();
    super.initState();
  }
  void makeStudent() {
    whoAreYou = 1;
  }
  
  void makeParent() {
    whoAreYou = 2;
  }

  Set<String> _selected = {'News'}; //LIST OF CURRENTLY SELECTED VALUES

  Set<String> updateSelected(Set<String> newSelection) {
    setState(() {
      _selected = newSelection;
    });
    return _selected;
  }
  
  void showMultiSelect() async {
    List<String>? results = await showDialog(
      context: context, 
      builder: (BuildContext context) {
        return Text("");
      }
    );
    results = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Text("MultiSelect(items: items,);");
      }
    );

    if (results != null) {
      notificationSelections = results;
      //NAO DO NOTIFICATIONS THING HERE
    }
  }

  final List<int> colorCodes = <int>[600, 500, 100, 50];
  final List<Item> items = [
      Item(title: 'Breaking News'),
      Item(title: 'Culture'),
      Item(title: 'Opinion'),
      Item(title: 'Profiles'),
      Item(title: 'Other/Updates')
    ];

  void onChanged(List<ChecklistLine> lines) {
    print(lines.toString());
  }

  bool _isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(builder: (context, value, child) => Scaffold(
      body: Column(
        children: [
          ElevatedButton(
          child: Text('Open Dialogsss'),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('I am a...', textAlign: TextAlign.center, style: TextStyle(fontSize: 50)),
                content: SizedBox(
                  width: double.maxFinite,
                  child: Column(
                  children: [
                    Text(''),
                    TextButton(
                      style: ButtonStyle(alignment: Alignment.topLeft),
                      onPressed: () {
                        Navigator.pop(context); 
                        makeStudent();
                        showDialog(
                          context: context,
                          builder: (context) =>
                        AlertDialog(
                          title: Text("What are your notification preferences?", textAlign: TextAlign.center, style: TextStyle(fontSize: 25)),
                          content: Column(
                            children: [
                              SizedBox(
                                width: double.maxFinite,
                                height: 300.0,
                                child: ListView.builder(
                                  itemCount: items.length,
                                  itemBuilder: (context, index) {
                                    final item = items[index];
                                    return CheckboxListTile(
                                      title: Text(item.title),
                                      value: item.isChecked,
                                      onChanged: (bool? newValue) {
                                        setState(() {
                                          item.isChecked = newValue ?? false;
                                        });
                                      },
                                      activeColor: Colors.blue,
                                      checkColor: Colors.blueGrey,
                                      controlAffinity: ListTileControlAffinity.leading,
                                      );
                                  }
                                  )
                              ),
                              TextButton(
                                onPressed: () {
                                    Navigator.pop(context);
                                  }, 
                                child: const Text('Confirm')
                              ),
                            ],
                          )

                          // Column(
                          //   children: [
                              // Text(''),
                              // SegmentedButton(
                              //   multiSelectionEnabled: true,
                              //   selected: _selected,
                              //   onSelectionChanged: (Set<String> newSelection) {
                              //     setState(() {
                              //         _selected = newSelection.isNotEmpty ? newSelection :  _selected;
                              //     });
                              //   },
                              //   showSelectedIcon: false,
                              //   style: ButtonStyle(fixedSize: MaterialStateProperty.all(Size.fromWidth(500))),
                              //   segments:
                              //     <ButtonSegment<String>>[
                              //       ButtonSegment<String>(
                              //         value: 'News',
                              //         label: Text('News')
                              //       ),
                              //       ButtonSegment<String>(
                              //         value: 'Opinion',
                              //         label: Text('Opinion')
                              //       ),
                              //       ButtonSegment<String>(
                              //         value: 'Other',
                              //         label: Text('Other')
                              //       ),
                              //     ]
                              // )
                          //   ]
                          // )
                        )
                        );
                        },
                      child: Column(
                        children: [
                        Text('Studentss', style: TextStyle(fontSize: 20)),
                        const Align(alignment: Alignment.bottomLeft,),
                        ],
                      
                      ),
                    ),
                    Text(''),
                    Text(''),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        makeParent();
                      },
                      child: Column(
                        children: [
                        Text('Parent', style: TextStyle(fontSize: 20)),
                        const Align(alignment: Alignment.bottomLeft,),
                        ],
                      
                      ),
                    ),
                  ]
                  )
                )
              ),
            );
          }
        ),
        ElevatedButton(
        onPressed: () {
          NotiService test = new NotiService();
          test.showNotification(
            title: 'Title!',
            body: 'Body!',
            );
        },
        child: const Text("Teachers"),
        )
        ]
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            _counter = index;
          });
        },
        indicatorColor: Colors.amber,
        selectedIndex: _counter,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Badge(child: Icon(Icons.newspaper_rounded)),
            label: 'News',
          ),
          NavigationDestination(
            icon: Badge(child: Icon(Icons.star)),
            label: 'Features',
          ),
          NavigationDestination(
            icon: Badge(child: Icon(Icons.record_voice_over_outlined)),
            label: 'Opinion',
          ),
          NavigationDestination(
            icon: Badge(child: Icon(Icons.bookmark)),
            label: 'Bookmark',
          ),
          NavigationDestination(
            icon: Badge(child: Icon(Icons.search)),
            label: 'Search',
          ),
        ],
      ),
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor : value.ThemeLabel!.headerColor,
        // Here we take the value from the HomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text(GrantMagApp.appTitle),
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.bento),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      
        // drawer on side
      drawer: Drawer(
        backgroundColor: value.ThemeLabel!.shelfColor,
        child: ListView( // lets user scroll through options if they need more vertical space
          // remove padding from ListView
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.grey/*value.ThemeLabel.headerColor*/),
              child: Text('Customization'),
            ),
            ListTile(
              title: const Text('Settings'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage())
              );
              },
              leading: Icon(Icons.settings_outlined),
            ),
            ListTile(
              title: const Text('Games'),
              onTap: () {
                // update state of the app
              },
              leading: Icon(Icons.videogame_asset)
            ),
            ListTile(
              title: const Text('Profile'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage())
                );
              },
              leading: Icon(Icons.person_outline_outlined)
            ),
            ListTile(
              title: const Text('Feedback'),
              onTap: () {
                // update state of the app
              },
              leading: Icon(Icons.chat_rounded)
            ),
            ListTile(
              title: const Text('About'),
              onTap: () {
                // update state of the app
              },
              leading: Icon(Icons.person_pin_rounded)
            ),
            ListTile(
              title: const Text('Credits'),
              onTap: () {
                // update state of the app
              },
              leading: Icon(Icons.source_rounded)
            ),
          ],
        ),
      ),

      // scroll through articles
      
      
    ),
    );
  }
}

class Item {
  String title;
  bool isChecked;

  Item({required this.title, this.isChecked = false});
}