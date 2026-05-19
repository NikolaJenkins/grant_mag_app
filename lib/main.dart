import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:grant_mag_app/profile_model.dart';
import 'package:grant_mag_app/settings_model.dart';
import 'package:grant_mag_app/settings.dart';
import 'package:grant_mag_app/profile.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:flutter_checklist/checklist.dart';
import 'package:grant_mag_app/noti_service.dart';
import 'package:shared_preferences_android/shared_preferences_android.dart';
import 'package:http/http.dart' as http;
import 'package:webfeed_plus/webfeed_plus.dart';
import 'package:circular_progress_with_logo/circular_progress_with_logo.dart';
import 'package:transparent_image/transparent_image.dart';



import 'rss.dart';
import 'featured.dart';
import 'opinion.dart';
import 'bookmarks.dart';
import 'search.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("BG message: ${message.notification?.title}");
}

void main() async{ //initialize
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();// initialize
  debugPrint("app start");
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseMessaging.instance.requestPermission(); // push notif token passing
  await FirebaseMessaging.instance.subscribeToTopic("news");

  debugPrint("permission granted");
 String? token = await FirebaseMessaging.instance.getToken();
 debugPrint("FCM TOKEN: $token");
  debugPrint("firebase initialized");

  NotiService().initNotification();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  // FlutterNativeSplash.preserve(widgetsBinding: WidgetsBinding.instance);
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsModel()),
        ChangeNotifierProvider(create: (_) => ProfileModel()),
      ],
      child: GrantMagApp(),
    ),
  );
  FlutterNativeSplash.remove();
}

class GrantMagApp extends StatelessWidget {
  //base widget constructor
  const GrantMagApp({super.key});
  final keyIsFirstLoaded = 'is_first_loaded';
  static const appTitle = 'Grant Magazine';

  @override
  Widget build(BuildContext context) {
    Timer(Duration(seconds: 7), () {FlutterNativeSplash.remove();});
    // creates listeners to pass information between pages
    return Consumer<SettingsModel>(
      builder: (context, settingsModel, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            scaffoldBackgroundColor: const Color.fromARGB(255, 214, 214, 214), // use listener to get provider info
            primarySwatch: Colors.blueGrey,
            textTheme: Theme.of(context).textTheme.apply(
              fontSizeFactor: settingsModel.TextSize / 100
            ),
            appBarTheme: AppBarTheme(
              iconTheme: IconThemeData(
                color: Colors.white, //Makes white the default color for icons in the app bar
              ),
            )
        ),
        home: HomePage(title: appTitle),
        routes: {
          '/homepage': (context) => const HomePage(title: appTitle),
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
  //TODO: don't redefine notificationSelections every time app is closed and reopened
  // final Future<SharedPreferencesWithCache> _prefs = 
  //   SharedPreferencesWithCache.create(
  //     cacheOptions: const SharedPreferencesWithCacheOptions()
  //   );

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

    // FOREGROUND messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notif = message.notification;
      if (notif != null) {
        service.showNotification(
          notifId: notif.hashCode,
          notifTitle: notif.title ?? "New Notification",
          notifBody: notif.body ?? "",
        );
      }
    });

    // When user taps notification (app in background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("Notification clicked!");
      // you can navigate here later
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _checkFirstSeen());
    loadFeed();
  }

  Future<void> _checkFirstSeen() async {
    // SharedPreferences.setMockInitialValues({'isFirstRun': true});
    bool isFirstRun = await getBool();
    List<String> notificationSelections = await getList();

    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.getNotificationSettings();
    bool authorizationState = switch(settings.authorizationStatus) {
      AuthorizationStatus.authorized => true,
      AuthorizationStatus.denied => false,
      AuthorizationStatus.notDetermined => false,
      AuthorizationStatus.provisional => false
    };

    if (isFirstRun && authorizationState) {
      showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text("Select your notification preferences"),
            content: Column(
              children: [
                SizedBox(
                  //Show checklist dialog when student is clicked
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
                          if (item.isChecked) {
                            notificationSelections.add(item.title);
                            saveList(notificationSelections);
                          } else {
                            notificationSelections.remove(item.title);
                            saveList(notificationSelections);
                          }
                        },
                        activeColor: Colors.blue,
                        checkColor: Colors.blueGrey,
                        controlAffinity: ListTileControlAffinity.leading,
                      );
                    },
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Confirm"),
                ),
              ],
            ),
          ),
        ),
      );
      await saveBool(false);
    }
  }

  void makeStudent() {
    whoAreYou = 1;
  }

  void makeParent() {
    whoAreYou = 2;
  }

  static const String FEED_URL = 'https://grantmagazine.com/feed/';

  Future<RssFeed> load() async { // overall feed loader
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

  Future<void> saveList(List<String> items) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('Preferences', items);
  }

  Future<List<String>> getList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('Preferences') ?? [];
  }

  Future<void> saveBool(bool hasStarted) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstRun', hasStarted);
  }

  Future<bool> getBool() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isFirstRun') ?? true;
  }

  final bool isAuthenticated = false;
  final List<int> colorCodes = <int>[600, 500, 100, 50];
  final List<Item> items = [
    Item(title: 'News', isChecked: false),
    Item(title: 'Features', isChecked: false),
    Item(title: 'Opinion', isChecked: false),
    Item(title: 'Profiles', isChecked: false),
  ];

  Widget getBody() {
    switch (_counter) {
      case 0:

        // gets latest four articles
        final latestArticles = _feed?.items?.take(4).toList() ?? [];
      
        // gets articles with carousel category
        final carouselItems = _feed?.items
                    ?.where((item) =>
                      (item.categories?.map((c) => c.value).join(', ') ?? '').toLowerCase().contains('Carousel'.toLowerCase())
                    )
                .toList();

        return SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // FutureBuilder(
              //   future: getList(),
              //   builder: (context, asyncSnapshot) {
              //     final notiSelect = asyncSnapshot.data ?? [];
              //     return Container(
              //     padding: EdgeInsets.all(16),
              //     color: Colors.blue[50],
              //     child: Column(
              //       children: notiSelect.map((value) => Text(value)).toList()
              //     )
              //     );
              //   },
              // ),
              CarouselSlider(
                items: carouselItems?.map((item) {
                  return Builder(
                    builder: (BuildContext context) {
                      return GestureDetector(
                        child: Stack(
                          alignment: AlignmentDirectional.bottomCenter,
                          children: <Widget>[
                            Container(
                              child: FutureBuilder<String>(
                                future: imageCache.putIfAbsent(
                                  item.link ?? '',
                                  () => item.getFeaturedImage(),
                                ),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                    return const SizedBox.shrink();
                                  }
                                  return Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      SizedBox(
                                        height: 75,
                                        width: 75,
                                        child: Image.asset('assets/blendertimer-load-37.gif'),
                                      ),
                                      FadeInImage.memoryNetwork(
                                        placeholder: kTransparentImage,
                                        // placeholderCacheWidth: 50,
                                        // placeholderCacheHeight: 50, 
                                        // placeholderScale: .25,tima
                                        fadeInCurve: Curves.linear,
                                        image: snapshot.data!,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                      )
                                    ],
                                  );
                                },
                              )
                            ),
                            Container(
                              color: Color.fromRGBO(50, 50, 50, 0.8),
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(horizontal: 10.0),
                              constraints: BoxConstraints.tightForFinite(
                                height: 75, 
                              ),
                              child: Text(
                                item.title ?? '', 
                                textAlign: TextAlign.center,
                                style: GoogleFonts.merriweather(
                                  textStyle: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                )
                              ),
                            )
                          ]
                        ),
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

              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Container(
                  color: Color.fromRGBO(25, 25, 25, .9),
                  padding: EdgeInsets.all(20.0),
                  alignment: Alignment.center,
                  child: Text(
                    "Recent Articles",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.merriweather(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold)
                    ),
                  ),
              ),

              GridView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: latestArticles.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 5.0,
                  mainAxisSpacing: 5.0,
                  childAspectRatio: 0.5,
                ),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final item = latestArticles[index];

                return ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: GestureDetector(
                    child: Column(
                      children: [
                        Container(
                                color: Color.fromRGBO(25, 25, 25, .9),
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                constraints: BoxConstraints.tightForFinite(
                                  height: 75, 
                                ),
                                child: Text(
                                  item.title ?? '', 
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.merriweather(
                                    textStyle: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                  )
                                ),
                              ),
                        Container(
                          height: 299,
                          child: FutureBuilder<String>(
                            future: imageCache.putIfAbsent(
                              item.link ?? '',
                              () => item.getFeaturedImage(),
                            ),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return const SizedBox.shrink();
                              }
                              return Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                        height: 75,
                                        width: 75,
                                        child: Image.asset('assets/blendertimer-load-37.gif'),
                                      ),
                                  FadeInImage.memoryNetwork(
                                    placeholder: kTransparentImage,
                                    placeholderCacheWidth: 1,
                                    placeholderCacheHeight: 1, 
                                    placeholderFit: BoxFit.fitHeight,
                                    fadeInCurve: Curves.linear,
                                    image: snapshot.data!,
                                    fit: BoxFit.cover,
                                    height: double.infinity,
                                  )
                                ],
                              );
                            },
                          )
                        ),
                      ]
                    ),
                    onTap:() => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ArticlePage(article: item),
                      ),
                    ),
                  ),
                );
                //   return ListTile(
                //     title: Text(item.title ?? ''),
                //     subtitle: Column(
                //       crossAxisAlignment: CrossAxisAlignment.start,
                //       children: [
                //         Text(item.categories?.map((c) => c.value).join(', ') ?? ''),
                //         Text(item.author ?? ''),
                //         FutureBuilder<String>(
                //           future: imageCache.putIfAbsent(
                //             item.link ?? '',
                //             () => item.getFeaturedImage(),
                //           ),
                //           builder: (context, snapshot) {
                //             if (!snapshot.hasData || snapshot.data!.isEmpty) {
                //               return const SizedBox.shrink();
                //             }
                //             return Image.network(
                //               snapshot.data!,
                //               fit: BoxFit.contain,
                //             );
                //           },
                //         ),
                //       ]),
                //     onTap: () {
                //       Navigator.push(
                //         context,
                //         MaterialPageRoute(
                //           builder: (_) => ArticlePage(article: item),
                //         ),
                //       );
                //     },
                //   );
                // },            
                }
              ),

              // ElevatedButton(
              //   child: Text('Open Dialogsssssss'),
              //   onPressed: () {
              //     showDialog(
              //       context: context,
              //       builder: (context) => AlertDialog(
              //         title: Text('I am a...'),
              //         actions: [
              //           TextButton(
              //               child: Text('Student.'),
              //               style: TextButton.styleFrom(foregroundColor: Colors.black),
              //               onPressed: () => Navigator.pop(context)),
              //           TextButton(
              //               child: Text('Parent'),
              //               style: TextButton.styleFrom(foregroundColor: Colors.black),
              //               onPressed: () => Navigator.pop(context))
              //         ],
              //       ),
              //     );
              //   },
              // ),
            ],
          ),
        );
      case 1:
        if (_feed == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return GrantMagFeed(feed: _feed!);

      case 2:
        if (_feed == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return FeaturedArticles(feed: _feed!);

      case 3:
        if (_feed == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return OpinionatedArticles(feed: _feed!);
        
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
  
  return Consumer<SettingsModel>( // drawer scaffolding
    builder: (context, value, child) => Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 35,
        backgroundColor: Colors.black,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Align(
          alignment: Alignment(-0.4,0.0),
          child: const Text(GrantMagApp.appTitle, 
            style: TextStyle(
              fontFamily: 'Georgia',
              color: Colors.white
              ),
           ),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.notifications, 
              color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      // drawer: Drawer(
      //   backgroundColor: value.ThemeLabel!.shelfColor,
      //   child: ListView(
      //     padding: EdgeInsets.zero,
      //     children: [
      //       const DrawerHeader(
      //         decoration: BoxDecoration(color: Colors.grey),
      //         child: Text('Customization'),
      //       ),
      //       ListTile(
      //         title: const Text('Settings'),
      //         leading: const Icon(Icons.settings_outlined),
      //         onTap: () => Navigator.push(
      //           context,
      //           MaterialPageRoute(builder: (_) => SettingsPage()),
      //         ),
      //       ),
      //       ListTile(
      //         title: const Text('Profile'),
      //         leading: const Icon(Icons.person_outline_outlined),
      //         onTap: () => Navigator.push(
      //           context,
      //           MaterialPageRoute(builder: (_) => ProfilePage()),
      //         ),
      //       ),
      //     ],
      //   ),
      // ),

      body: Column(
        children: [
          if (_counter == 0)
            Padding(
              padding: const EdgeInsets.all(8.0),
            ),

            Expanded(child: getBody()),
          ],
        ),

      bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: NavigationBar( //nav bar for menu icons
          onDestinationSelected: (index) =>
              setState(() => _counter = index),
          selectedIndex: _counter,
          indicatorColor: Colors.amber,
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(
              fontSize: 11.0,
              color: Colors.white,
              fontFamily: 'Georgia'
            )
          ),
          backgroundColor: Colors.black,
          destinations: const [
            NavigationDestination(
                selectedIcon: Icon(
                  Icons.home,
                  color: Colors.white
                  ),
                icon: Icon(
                  Icons.home_outlined,
                  color: Colors.white
                  ),
                label: 'Home'),
            NavigationDestination(
                icon: Icon(
                  Icons.newspaper_rounded,
                  color: Colors.white
                  ),
                selectedIcon: Icon(
                  Icons.newspaper_rounded,
                  color: Colors.white,
                  fill: 1.0
                  ),
                label: 'News'),
            NavigationDestination(
                icon: Icon(
                  Icons.star_border,
                  color: Colors.white
                  ),
                selectedIcon: Icon(
                  Icons.star,
                  color: Colors.white
                  ),
                label: 'Features'),
            NavigationDestination(
                icon: Icon(
                  Icons.record_voice_over_outlined,
                  color: Colors.white
                  ),
                selectedIcon: Icon(
                  Icons.record_voice_over,
                  color: Colors.white
                  ),
                label: 'Opinion'),
            NavigationDestination(
                icon: Icon(
                  Icons.bookmark_outline,
                  color: Colors.white
                  ),
                selectedIcon: Icon(
                  Icons.bookmark,
                  color: Colors.white
                  ),
                label: 'Bookmarks'),
            NavigationDestination(
                icon: Icon(
                  Icons.search,
                  color: Colors.white
                ),
                selectedIcon: Icon(
                  Icons.saved_search_outlined,
                  color: Colors.white,
                  fill: 1.0
                ),
                label: 'Search'),
          ],
        ),
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
        icon: const Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
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
        return ListTile(title: Text(result));
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
        return ListTile(title: Text(result));
      },
    );
  }
}

class Item {
  String title;
  bool isChecked;

  Item({required this.title, required this.isChecked});
}
