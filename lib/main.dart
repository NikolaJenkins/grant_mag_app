import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:grant_mag_app/articles.dart';
import 'package:grant_mag_app/theme_model.dart';
import 'package:grant_mag_app/settings.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    // const MyApp()
    ChangeNotifierProvider(
      create: (context) => ThemeModel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
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

  final List<String> entries = <String>['A', 'B', 'C', 'D', 'E', 'F'];
  final List<int> colorCodes = <int>[600, 500, 100, 50];

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(builder: (context, value, child) => Scaffold(

      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor : value.ThemeLabel!.headerColor,
        // Here we take the value from the HomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text(MyApp.appTitle),
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
                Navigator.push(context,
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
                Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage())
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
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Container(
                color: value.ThemeLabel!.shelfColor,
                child: ListTile(
                  leading: Text('bee movie'),
                  trailing: Text('buzz'),
                  onTap: () => Navigator.push(context, 
                  MaterialPageRoute(builder: (context) => ExampleArticlePage())),
                )
              ),
            ],
          )
        )
      )
      // body: ListView.separated(
      //   padding: const EdgeInsets.all(24),
      //   itemCount: entries.length,
      //   // itemBuilder: (BuildContext context, int index) {
      //   //   return Container(
      //   //     height: 50,
      //   //     color: Colors.amber[colorCodes[index]],
      //   //     child: Center(child: Text('Entry ${entries[index]}'))
      //   //     );
      //   // },

      //   children: <Widget>[
      //     Container(
      //       height: 50,
      //       color: Colors.amber[colorCodes[0]],
      //       child: const Center(child: Text('The Bee Movie')),
      //     ),
      //     Container(
      //       height: 50,
      //       color: Colors.amber[colorCodes[1]],
      //       child: const Center(child: Text('Boo')),
      //     ),
      //     Container(
      //       height: 50,
      //       color: Colors.amber[colorCodes[2]],
      //       child: const Center(child: Text('Buzz')),
      //     )
      //   ],
      //   separatorBuilder: (BuildContext context, int index) => const Divider(),
      //   )
      ),
      );
  }
}