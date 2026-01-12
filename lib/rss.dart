// ignore_for_file: avoid_print

import 'package:webfeed/webfeed.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:auto_size_text/auto_size_text.dart';


class GrantMagRSS extends StatefulWidget{ //stateful widget for async purposes (html arrives late)
  GrantMagRSS({super.key}); 
  final String title = 'Grant Mag RSS Feed';

  @override
  GrantMagRSState createState() => GrantMagRSState();
}

class ArticlePage extends StatefulWidget { //declares article page widget
  final RssItem article;
  const ArticlePage({required this.article, super.key}); //passes RSS widget key

  @override
  State<ArticlePage> createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> {
  String? featuredImage;
  bool loadingImage = true;

  @override
  void initState() {
    super.initState();
    _loadFeaturedImage(); // async fetch starts here
  }

  Future<void> _loadFeaturedImage() async { //fetches html and loads image
    final url = widget.article.link; 
    if (url == null) return;
    try {
      final response = await http.get(Uri.parse(url)); //url parse
      if (response.statusCode != 200) return;
      final html = response.body;

      final ogMatch = RegExp( //og syntax for fallback
        r'<meta property="og:image" content="([^"]+)"',
        caseSensitive: false,
      ).firstMatch(html);

      if (ogMatch != null) {
        featuredImage = ogMatch.group(1);
      } else {
        final photoMatch = RegExp( //wordpress specific featured image grabber
          r'<div class="photowrap">[\s\S]*?<img[^>]+src="([^"]+)"',
          caseSensitive: false,
        ).firstMatch(html);
        featuredImage = photoMatch?.group(1); //sets featured image to variable
      }
    } catch (e) {
      debugPrint('Image scrape failed: $e'); //error catch
    }

    if (mounted) { //fallback for disposed widget
      setState(() => loadingImage = false);
    }
  }

  @override
  Widget build(BuildContext context) { //builds article page widget
    final screenWidth = MediaQuery.of(context).size.width;

    String html = widget.article.content?.value ?? widget.article.description ?? ''; //regex cleanup
    html = html.replaceAll(RegExp(r'style="width:\s*\d+px"'), '');
    html = html.replaceAll(RegExp(r'width="\d+"'), '');
    html = html.replaceAll(RegExp(r'height="\d+"'), '');
    html = html.replaceAll(RegExp(r'srcset="[^"]+"'), '');
    html = html.replaceAll(RegExp(r'sizes="[^"]*"'), '');

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        title: AutoSizeText(
          widget.article.title ?? 'Article',
          maxLines: 3,
          minFontSize: 12,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (loadingImage) const LinearProgressIndicator(),
            if (!loadingImage && featuredImage != null)
              Image.network(
                featuredImage!,
                width: screenWidth,
                fit: BoxFit.cover,
              ),
            
            Padding( //article body render
              padding: const EdgeInsets.all(12.0),
              child: Html(
                data: html,
                style: {
                  "figure": Style(
                    width: Width(screenWidth),
                    textAlign: TextAlign.center,
                  ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GrantMagRSState extends State<GrantMagRSS>{ //main page state 
  static const String FEED_URL = 'https://backfeed.app/jkLTDA9LpqPBIVdrjl/https://grantmagazine.com/feed/rss';
  RssFeed? _feed;
  String _title = '';
  static const String loadingFeedMsg = 'Loading...';
  static const String loadError = 'Error Loading Feed';
  static const String feedOpenError = 'Error Opening Feed';
  static const String placeholder = 'assets/Image-not-found.png';
  GlobalKey<RefreshIndicatorState>? _refreshKey;

updateTitle(title){
print('updateTitle called with type: ${title.runtimeType}');
setState(() {
  _title = 'Grant Magazine';
});
print('updatestitle');
}

updateFeed(feed){
setState(() {
  _feed = feed;
});
}

Future<void> openFeed(String url) async{ //url parser
  if(await canLaunchUrl(Uri.parse(url))){
    await launchUrl(Uri.parse(url));
    return;
  }
  updateTitle(feedOpenError);
}

load() async { //load feed into builder 
  print('calledload');
  updateTitle(loadingFeedMsg);
  loadFeed().then((result){
    print('calledloadfeed');
    // ignore: unnecessary_null_comparison
    if(null == result || result.toString().isEmpty){
      updateTitle(loadError);
      print('didnotload');
      return;
    }
    print('loadedfeed');
    updateFeed(result);
    print('updatedfeed');
    updateTitle(_feed?.title.toString());
  });
}

Future<RssFeed> loadFeed() async{ //combination of parser and loader, returns response
  print('loadfeedexecutes');
  try{
    print('trygiven');
    final client = http.Client();
    print('FEED_URL: $FEED_URL');
    final response = await client
      .get(Uri.parse(FEED_URL));
    debugPrint('STATUS: ${response.statusCode}');
    debugPrint(response.body);
    print('HEADER: ${response.body.substring(0, 200)}');
    print('urlparsed');
    return RssFeed.parse(response.body);
  }
  catch (e, st) {
    debugPrint('RSS load/parse error: $e');
    debugPrint('$st');
    return RssFeed(items: []);
  }
}

  @override
  void initState() { //initial build
    print("test"); 
    print("test2");
    print('initstate goes');
    super.initState();
    _refreshKey = GlobalKey<RefreshIndicatorState>();
   print('debug0 start');
    updateTitle(widget.title);
    final banned = ['PDF Issues'];
    _feed?.items?.removeWhere((item){ //removes banned items
      return item.categories?.any((c) => banned.contains(c)) ?? false;
    });
    load();
  }

  title(apptitle){
    final String displayTitle;
    if (apptitle == null){
      displayTitle = '';
    } else {
      displayTitle = (apptitle is DateTime) ? (apptitle).toIso8601String() : apptitle?.toString() ?? '';
    }
    return Text(
      displayTitle,
      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  rightIcon(){
    return Icon(Icons.keyboard_arrow_right, color: Colors.grey, size: 30.0);
  }

  list(){ //main list builder
    print('callslist');
    return ListView.builder(itemCount: _feed?.items?.length,
    itemBuilder: (BuildContext context, int index) {
      final item = _feed?.items?[index];
      return ListTile( //creates each tile
        title: title(item!.title),
        subtitle: Text(item.categories?.map((c) => c.value).join(', ') ?? '',),
        leading: const Icon(Icons.image_not_supported),
        trailing: rightIcon(),
        contentPadding: EdgeInsets.all(5.0),
        onTap: () { //on click function
          print("tile clicked");
          print("item: $item");
          print("item.title: ${item.title}");
          try {
            Navigator.push(
              context,
              MaterialPageRoute(
              builder: (_) => ArticlePage(article: item),
              ),
            );
          } catch (e, st) {
              print("NAVIGATION CRASH: $e");
              print(st);
          }
        },
      );
    },
    );
  }

  isFeedEmpty(){ //null protectio
    // ignore: unnecessary_null_comparison
    return null == _feed || null == _feed?.items;
  }

  body(){ //refresher
    return isFeedEmpty() ? Center(child: CircularProgressIndicator(),)
    : RefreshIndicator(
      key: _refreshKey,
      child: list(),
      onRefresh: () => load(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_title),),
      body: body(),
    );
  }
}