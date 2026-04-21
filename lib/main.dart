import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:grant_mag_app/articles.dart';
import 'package:grant_mag_app/profile_model.dart';
import 'package:grant_mag_app/settings_model.dart';
import 'package:grant_mag_app/settings.dart';
import 'package:grant_mag_app/profile.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter_checklist/checklist.dart';
import 'package:grant_mag_app/noti_service.dart';
import 'package:shared_preferences_android/shared_preferences_android.dart';
import 'package:http/http.dart' as http;
import 'package:webfeed_plus/webfeed_plus.dart';
import 'rss.dart';
import 'search.dart';


void main() async{ //initialize
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  debugPrint("Firebase initialized successfully");
 // final fcmToken = await FirebaseMessaging.instance.getToken(); //this is the push notifs token setup

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
  GrantMagApp({super.key});
  static const appTitle = 'Home Page';

  @override
  Widget build(BuildContext context) {
    // creates listeners to pass information between pages
    return Consumer<SettingsModel>(
      builder: (context, settingsModel, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            scaffoldBackgroundColor: const Color.fromARGB(255, 255, 255, 255), // use listener to get provider info
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
  const HomePage({required this.title, super.key});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();

  
}

class _HomePageState extends State<HomePage> {
  int _counter = 0;
  // to distinguish between students/parents
  int whoAreYou = 0;
  List<String> notificationSelections = [];

  RssFeed? _feed;
  
  final FlutterLocalNotificationsPlugin notificationsPlugin = 
  FlutterLocalNotificationsPlugin();

  final Map<String, Future<String>> imageCache = {};
  CarouselSliderController articleCarouselController = CarouselSliderController();

  @override
  void initState() {
    
    NotiService service = NotiService();
    service.initNotification();
    super.initState();
    loadFeed();
  }
  void makeStudent() {
    whoAreYou = 1;
  }
  
  void makeParent() {
    whoAreYou = 2;
  }

  static const String FEED_URL = 'https://grantmagazine.com/feed/';

  Future<RssFeed> load() async {
    try { 
      final response = await http.get(Uri.parse(FEED_URL));
      return RssFeed.parse(response.body);
    } catch (_) { 
      return RssFeed(items: []); 
    } 
  }

  Future<void> loadFeed() async {
    final result = await load();
    if (!mounted) return;
    setState(() => _feed = result);
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

  bool _isChecked = false;

  Widget getBody() {
    switch (_counter) {
      case 0:

        // gets latest article
        final latestArticle = _feed?.items?[0];
        final latestImage= latestArticle?.getFeaturedImage();
      
        // gets articles with carousel category
        final carouselItems = _feed?.items
                    ?.where((item) =>
                      (item.categories?.map((c) => c.value).join(', ') ?? '').toLowerCase().contains('Carousel'.toLowerCase())
                    )
                .toList();

        return SingleChildScrollView(
          child: Column(
            children: [
              // ListTile(
              //   title: Text(latestArticle?.title ?? ''),
              //   subtitle: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //                 Text(latestArticle?.author ?? ''),
              //                 FutureBuilder<String>(
              //                   future: imageCache.putIfAbsent(
              //                     '',
              //                     () => latestImage ?? Future<String>(() => ''),
              //                   ),
              //                   builder: (context, snapshot) {
              //                     return FadeInImage.assetNetwork(
              //                         placeholder: 'assets/cupertino_activity_indicator_square_large.gif',
              //                         placeholderCacheWidth: 1,
              //                         placeholderCacheHeight: 1, 
              //                         fadeInCurve: Curves.linear,
              //                         image: snapshot.data ?? '',
              //                       );
              //                   },
              //                 )
              //               ]
              //   )
              // ),
              CarouselSlider(
                items: carouselItems?.map((item) {
                  return Builder(
                    builder: (BuildContext context) {
                      return ListTile(
                        title: Text(item.title ?? ''),
                        subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.author ?? ''),
                                FutureBuilder<String>(
                                  future: imageCache.putIfAbsent(
                                    item.link ?? '',
                                    () => item.getFeaturedImage(),
                                  ),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                      return const SizedBox.shrink();
                                    }
                                    return FadeInImage.assetNetwork(
                                        placeholder: 'assets/cupertino_activity_indicator_square_large.gif',
                                        placeholderCacheWidth: 1,
                                        placeholderCacheHeight: 1, 
                                        fadeInCurve: Curves.linear,
                                        image: snapshot.data!
                                      );
                                  },
                                )
                              ]),
                        onTap:() => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ArticlePage(article: item),
                              )
                            ),
                      );
                    }
                  );
                }).toList(),
                carouselController: articleCarouselController,
                options: CarouselOptions(
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 6),
                  enlargeCenterPage: false,
                  viewportFraction: 1.0,
                  height: 300.0,
                  aspectRatio: 9.0 / 16.0,
                  initialPage: 0,
                )
              ),
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
                    notifTitle: 'Did you commit today?',
                    notifBody: 'Mr. Mandell won\'t be happy',
                  );
                },
                child: const Text("Teachers"),
              ),
            ],
          ),
        );
      case 1:
        if (_feed == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return GrantMagFeed(feed: _feed!);

      case 2:
        return Center(child: Text('Content coming soon'));

      case 3:
        return Center(child: Text('Content coming soon'));
        
      case 4:
        if (_feed == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return GrantMagBookmarks(feed: _feed!);

      default:
        if (_feed == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return GrantMagSearch(feed: _feed!,);
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
                child: const Text('SOpen Dialogaaaaaaaa'),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('I am a...'),
                      actions: [
                        TextButton(
                          child: const Text('Student'),
                          onPressed: () {
                            Navigator.pop(context);
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("Select your preferences"),
                                content: Column(
                                      children: [
                                        SizedBox( //Show checklist dialog when student is clicked
                                          height: 300.0,
                                          width: double.maxFinite,
                                          child: ListView.builder(
                                          itemCount: items.length,
                                          itemBuilder: (context, index) {
                                            final item = items[index];
                                            return CheckboxListTile(
                                              title: Text(item.title),
                                              value: item.isChecked,
                                              onChanged: (bool? newValue) {
                                                setState(() {
                                                  item.isChecked = newValue!;
                                                });
                                              },
                                              activeColor: Colors.blue,
                                              checkColor: Colors.blueGrey,
                                              controlAffinity: ListTileControlAffinity.leading,
                                              );
                                            }
                                            ),
                                          ),
                                        TextButton(
                                          onPressed: () {Navigator.pop(context);}, 
                                          child: Text("Confirm")
                                          )
                                      ],
                                    )
                              ),
                            );
                          }
                          
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            makeParent();
                             showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("Select your preferences"),
                                content: Column(
                                      children: [
                                        SizedBox( //Show checklist dialog when parent is clicked
                                          height: 300.0,
                                          width: double.maxFinite,
                                          child: ListView.builder(
                                          itemCount: items.length,
                                          itemBuilder: (context, index) {
                                            final item = items[index];
                                            return CheckboxListTile(
                                              title: Text(item.title),
                                              value: item.isChecked,
                                              onChanged: (bool? newValue) {
                                                setState(() {
                                                  item.isChecked = newValue!;
                                                });
                                              },
                                              activeColor: Colors.blue,
                                              checkColor: Colors.blueGrey,
                                              controlAffinity: ListTileControlAffinity.leading,
                                              );
                                            }
                                            ),
                                          ),
                                        TextButton(
                                          onPressed: () {Navigator.pop(context);}, 
                                          child: Text("Confirm")
                                          )
                                      ],
                                    )
                              ),
                            );
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

      bottomNavigationBar: NavigationBar( //nav bar for menu icons
        onDestinationSelected: (index) =>
            setState(() => _counter = index),
        selectedIndex: _counter,
        indicatorColor: Colors.amber,
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(
            fontSize: 11.0,
          )
        ),
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
              label: 'Bookmarks'),
          NavigationDestination(
              icon: Badge(child: Icon(Icons.search)),
              label: 'Search'),
        ],
      ),
    ),
  );
}
}

class Item {
  String title;
  bool isChecked;

  Item({required this.title, required this.isChecked});
}
