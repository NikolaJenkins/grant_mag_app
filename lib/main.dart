import 'package:flutter/material.dart';
import 'package:grant_mag_app/articles.dart';
import 'package:grant_mag_app/profile_model.dart';
import 'package:grant_mag_app/settings_model.dart';
import 'package:grant_mag_app/settings.dart';
import 'package:grant_mag_app/profile.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:grant_mag_app/noti_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  //initialize notifications
  NotiService().initNotification();
  
  runApp(
    // const GrantMagApp()
    // ChangeNotifierProvider(
    //   create: (context) => ThemeModel(),
    //   child: const GrantMagApp(),
    // ),
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsModel()),
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
        scaffoldBackgroundColor: Colors.amber
        , // use listener to get provider info
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
  int _counter = 1;
  
  final FlutterLocalNotificationsPlugin notificationsPlugin = 
  FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    NotiService service = NotiService();
    service.initNotification();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsModel>(builder: (context, value, child) => Scaffold(
      body: Center(),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            _counter = index;
          });
          if (index == 3) {
            NotiService test = NotiService();
            test.showInstantNotification(
              id: 0,
              title: 'Cool people commit',
              body: 'Did you push today?',
              );
          } else if (index == 5) {
            showSearch(
              context: context, 
              delegate: CustomSearchDelegate(),);
          }
          print(index);
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