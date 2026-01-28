import 'package:flutter/material.dart';
import 'package:grant_mag_app/articles.dart';
import 'package:grant_mag_app/profile_model.dart';
import 'package:grant_mag_app/theme_model.dart';
import 'package:grant_mag_app/settings.dart';
import 'package:grant_mag_app/profile.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:grant_mag_app/noti_service.dart';
import 'rss.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  NotiService().initNotif();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeModel()),
        ChangeNotifierProvider(create: (_) => ProfileModel()),
      ],
      child: GrantMagApp(),
    ),
  );
}

class GrantMagApp extends StatelessWidget {
  const GrantMagApp({super.key});
  static const appTitle = 'Home Page';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.blueGrey,
        primarySwatch: Colors.teal,
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

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _counter = 0;

  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();
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
                    title: 'Title!',
                    body: 'Body!',
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
    return Consumer<ThemeModel>(
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
                leading: Icon(Icons.settings_outlined),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SettingsPage()),
                ),
              ),
              ListTile(
                title: const Text('Profile'),
                leading: Icon(Icons.person_outline_outlined),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ProfilePage()),
                ),
              ),
              ListTile(
                title: const Text('Games'),
                leading: Icon(Icons.videogame_asset),
                onTap: () {},
              ),
              ListTile(
                title: const Text('Feedback'),
                leading: Icon(Icons.chat_rounded),
                onTap: () {},
              ),
              ListTile(
                title: const Text('About'),
                leading: Icon(Icons.person_pin_rounded),
                onTap: () {},
              ),
              ListTile(
                title: const Text('Credits'),
                leading: Icon(Icons.source_rounded),
                onTap: () {},
              ),
            ],
          ),
        ),
        body: getBody(),
        bottomNavigationBar: NavigationBar(
          onDestinationSelected: (index) => setState(() => _counter = index),
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
                icon: Badge(child: Icon(Icons.star)), label: 'Features'),
            NavigationDestination(
                icon: Badge(child: Icon(Icons.record_voice_over_outlined)),
                label: 'Opinion'),
            NavigationDestination(
                icon: Badge(child: Icon(Icons.bookmark)), label: 'Bookmark'),
            NavigationDestination(
                icon: Badge(child: Icon(Icons.search)), label: 'Search'),
          ],
        ),
      ),
    );
  }
}
