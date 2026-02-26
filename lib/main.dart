import 'package:flutter/material.dart';
import 'package:grant_mag_app/articles.dart';
import 'package:grant_mag_app/profile_model.dart';
import 'package:grant_mag_app/settings_model.dart';
import 'package:grant_mag_app/settings.dart';
import 'package:grant_mag_app/profile.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//import 'package:flutter_checklist/checklist.dart';
import 'package:grant_mag_app/noti_service.dart';
import 'rss.dart';

void main() { 
  WidgetsFlutterBinding.ensureInitialized();
  //initialize notifications
  NotiService().initNotification();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsModel()),
        ChangeNotifierProvider(create: (_) => ProfileModel()),
      ],
      child: GrantMagApp(),
    ),
  );
}

class GrantMagApp extends StatelessWidget { //base widget constructor
  const GrantMagApp({super.key});
  static const appTitle = 'Home Page';

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsModel>(
      builder: (context, settingsModel, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            scaffoldBackgroundColor: const Color.fromARGB(255, 42, 100, 127), // use listener to get provider info
            primarySwatch: Colors.blueGrey,
            textTheme: Theme.of(context).textTheme.apply(
              fontSizeFactor: settingsModel.TextSize / 100
          )
        ),
        home: HomePage(title: appTitle),
        routes: {
          '/homepage': (context) => const HomePage(title: appTitle),
          '/examplearticlepage': (context) => ExampleArticlePage(),
        },
        title: appTitle,
        );  
      }
    );
  }
}

class HomePage extends StatefulWidget { //home page constructor
  const HomePage({super.key, required this.title});

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
    service.initNotification();
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
      Item(title: 'Breaking News', isChecked: false),
      Item(title: 'Culture', isChecked: false),
      Item(title: 'Opinion', isChecked: false),
      Item(title: 'Profiles', isChecked: false),
      Item(title: 'Other/Updates', isChecked: false)
    ];

  // void onChanged(List<ChecklistLine> lines) {
  //   print(lines.toString());
  // }

  bool _isChecked = false;

  Widget getBody() {
    switch (_counter) {
      case 0:
        return SingleChildScrollView(
          child: Column(
            children: [
              ElevatedButton(
                child: Text('Open Dialogsssssss'),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('I am a...'),
                      actions: [
                        TextButton(
                            child: Text('Student.'),
                            style: TextButton.styleFrom(foregroundColor: Colors.black),
                            onPressed: () => Navigator.pop(context)),
                        TextButton(
                            child: Text('Parent'),
                            style: TextButton.styleFrom(foregroundColor: Colors.black),
                            onPressed: () => Navigator.pop(context))
                      ],
                    ),
                  );
                },
              ),
              ElevatedButton(
                onPressed: () {
                  NotiService().showNotification(
                    notifId: 0,
                    notifTitle: 'Title!',
                    notifBody: 'Body!',
                  );
                },
                child: const Text("Teachers"),
              ),
            ],
          ),
        );
      case 1:
        return const GrantMagFeed(); 
      default:
        return Center(child: Text('Content coming soon'));
    }
  }

  @override
Widget build(BuildContext context) {
  return Consumer<SettingsModel>(
    builder: (context, value, child) => Scaffold(
      appBar: AppBar(
        backgroundColor: value.ThemeLabel!.headerColor,
        title: const Text(GrantMagApp.appTitle),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.bento),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: Drawer(
        backgroundColor: value.ThemeLabel!.shelfColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.grey),
              child: Text('Customization'),
            ),
            ListTile(
              title: const Text('Settings'),
              leading: const Icon(Icons.settings_outlined),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SettingsPage()),
              ),
            ),
            ListTile(
              title: const Text('Profile'),
              leading: const Icon(Icons.person_outline_outlined),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProfilePage()),
              ),
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          if (_counter == 0)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                child: const Text('Open Dialog'),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('I am a...'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            makeStudent();
                          },
                          child: const Text('Student'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            makeParent();
                          },
                          child: const Text('Parent'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

          Expanded(
            child: getBody(),
          ),
        ],
      ),

      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (index) =>
            setState(() => _counter = index),
        selectedIndex: _counter,
        indicatorColor: Colors.amber,
        destinations: const [
          NavigationDestination(
              selectedIcon: Icon(Icons.home),
              icon: Icon(Icons.home_outlined),
              label: 'Home'),
          NavigationDestination(
              icon: Badge(child: Icon(Icons.newspaper_rounded)),
              label: 'News'),
          NavigationDestination(
              icon: Badge(child: Icon(Icons.star)),
              label: 'Features'),
          NavigationDestination(
              icon: Badge(child: Icon(Icons.record_voice_over_outlined)),
              label: 'Opinion'),
          NavigationDestination(
              icon: Badge(child: Icon(Icons.bookmark)),
              label: 'Bookmark'),
          NavigationDestination(
              icon: Badge(child: Icon(Icons.search)),
              label: 'Search'),
        ],
      ),
    ),
  );
}
}

class CustomSearchDelegate extends SearchDelegate {

  List<String> titles = [
    'machine learning',
    'Ray Tate',
    'One of the boys',
    'A new perspective',
    'Budget "whats"',
  ];

  List<String> authors = [
    'Eliot Logan',
    'Logan Hendrickson',
    'Margot Kalmanson',
    'Amelia Shaw',
    'Zoe Shaw',
  ];

  List<String> decks = [
    'Three days after the Bondi Beach shooting, Grant High School\’s Jewish Student Alliance put up two posters at the school honoring the victims.',
    'As artificial intelligence sweeps the nation, Portland Public Schools is exploring its use in education.',
    'This year, Grantasia featured a production in collaboration with a nonprofit organization called Sing Me a Story. The performance celebrates joy, creativity and inclusion through student choreography and original music.',
    'Grant High School math teacher Ray Tate’s worsening kidney disease has kept him from the classroom. Now, he is requesting a kidney donation from a living donor.',
    'Grant Magazine is now taking applications for the 2024 – 2025 school year. Complete the application, found at this link, and email a copy with editing access for anyone with the link to grantmagazine1@gmail.com. Applications are due by February 13, 2024. No late applications will be accepted.',
  ];

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: const Icon(Icons.clear),)
    ];
  }
  
  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed:  () {
        close(context, null);
      },
    );
  }
  
  @override
  Widget buildResults(BuildContext context) {
    List<String> matchQuery = [];

    // check titles
    for (var fruit in titles) {
      if (fruit.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(fruit);
      }
    }

    // check authors
    for (var fruit in authors) {
      if (fruit.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(fruit);
      }
    }

    // check decks
    for (var fruit in decks) {
      if (fruit.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(fruit);
      }
    }
    
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return ListTile(
          title: Text(result),
        );
      },
    );
  }
  
  @override
  Widget buildSuggestions(BuildContext context) {
    List<String> matchQuery = [];

    // check titles
    for (var fruit in titles) {
      if (fruit.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(fruit);
      }
    }

    // check authors
    for (var fruit in authors) {
      if (fruit.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(fruit);
      }
    }

    // check decks
    for (var fruit in decks) {
      if (fruit.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(fruit);
      }
    }
    
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return ListTile(
          title: Text(result),
        );
      },
    );
  }
}

class Item {
  String title;
  bool isChecked;

  Item({required this.title, required this.isChecked});
}