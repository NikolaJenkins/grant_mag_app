import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:grant_mag_app/articles.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static const appTitle = 'Home Page';

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blueGrey),
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
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
      backgroundColor: Colors.blueGrey,

      drawer: Drawer(
        backgroundColor: const Color.fromARGB(255, 31, 80, 104),
        child: ListView( // lets user scroll through options if they need more vertical space
          // remove padding from ListView
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blueGrey),
              child: Text('Customization'),
            ),
            ListTile(
              title: const Text('Settings'),
              onTap: () {
                // update state of the app
                // then close the drawer
                Navigator.pop(context);
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
                // update state of the app
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
      builder: (BuildContext context, BoxConstraints viewportConstraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: viewportConstraints.maxHeight))
        )
      }
    );
  }
}

