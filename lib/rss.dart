// ignore_for_file: avoid_print

import 'package:webfeed/webfeed.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_html/flutter_html.dart';




class GrantMagRSS extends StatefulWidget{
  GrantMagRSS() : super();
  final String title = 'Grant Mag RSS Feed';
  @override
  GrantMagRSState createState() => GrantMagRSState();
}

class ArticlePage extends StatelessWidget {
  final RssItem article;
   const ArticlePage({required this.article});
   @override
   Widget build(BuildContext context){
    double screenWidth = MediaQuery.of(context).size.width;
    String html = article.content?.value ?? '';
      html = html.replaceAll(RegExp(r'style="width:\s*\d+px"'), '');
      html = html.replaceAll(RegExp(r'width="\d+"'), '');
      html = html.replaceAll(RegExp(r'height="\d+"'), '');
      html = html.replaceAll(RegExp(r'srcset="[^"]+"'), '');
      html = html.replaceAll(RegExp(r'sizes="[^"]*"'), '');
debugPrint(html);
      return Scaffold(
      appBar: AppBar(title: Text(article.title ?? 'Article')),
      body: SingleChildScrollView(
        child: SizedBox(
           width: MediaQuery.of(context).size.width,
           child: 
            Html( 
              data: html,
              style: {
                "figure": Style(
                  width: Width(screenWidth),
                  fontSize: FontSize(11),
                  height: Height.auto(),
                  display: Display.block,
                  textAlign: TextAlign.center,
                  padding: HtmlPaddings.only(right: 16.0),
                ),
              },
            ),
          ),
       ),
    );
   }
}

class GrantMagRSState extends State<GrantMagRSS>{
  static const String FEED_URL = 'https://grantmagazine.com/feed/';
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
  _title = title;
});
print('updatestitle');
}

updateFeed(feed){
setState(() {
  _feed = feed;
});
}

Future<void> openFeed(String url) async{
  if(await canLaunchUrl(Uri.parse(url))){
    await launchUrl(Uri.parse(url));
    return;
  }
  updateTitle(feedOpenError);
}

load() async {
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

Future<RssFeed> loadFeed() async{
  print('loadfeedexecutes');
  try{
    print('trygiven');
    final client = http.Client();
    print('FEED_URL: $FEED_URL');
    final response = await client
      .get(Uri.parse(FEED_URL));
    print(response.body);
    print('urlparsed');
    return RssFeed.parse(response.body);
  }
  catch (e){
    throw UnimplementedError();
  }
}

  @override
  void initState() {
    print("test");
    print("test2");
    print('initstate goes');
    super.initState();
    _refreshKey = GlobalKey<RefreshIndicatorState>();
   print('debug0 start');
    updateTitle(widget.title);
    final banned = ['PDF Issues'];
    _feed?.items?.removeWhere((item){
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

subtitle(dynamic value) {
  final String displaySubTitle;
  if (value == null) {
    displaySubTitle = '';
  } else {
    print(value.runtimeType);
    //displaySubTitle = value.toString();
    displaySubTitle = "";
  }

  return Text(
    displaySubTitle,
    style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.w100),
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
  );
}

  thumbnail(imgUrl){
    return Padding(
      padding: EdgeInsetsGeometry.only(left:15.0),
      child: CachedNetworkImage(
        placeholder: (context, url) => Image.asset(placeholder),
        imageUrl: imgUrl ?? placeholder,
        height: 50,
        width: 70,
        alignment: Alignment.center,
        fit: BoxFit.fill,
      )
    );
  }

  rightIcon(){
    return Icon(Icons.keyboard_arrow_right, color: Colors.grey, size: 30.0);
  }

  list(){
    print('callslist');
    return ListView.builder(itemCount: _feed?.items?.length,
    itemBuilder: (BuildContext context, int index) {
      final item = _feed?.items?[index];
      return ListTile(
        title: title(item!.title),
        subtitle: subtitle(item.pubDate),
        leading: (item.img?.url != null && item.img!.url!.startsWith('http'))
        ? thumbnail(item.img!.url!)
        : const Icon(Icons.image_not_supported),
        trailing: rightIcon(),
        contentPadding: EdgeInsets.all(5.0),
        onTap: () {
          Navigator.push(
          context,
          MaterialPageRoute(
          builder: (context) => ArticlePage(article: item),
    ),
  );
},
      );
    },
    );
    
  }

  isFeedEmpty(){
    // ignore: unnecessary_null_comparison
    return null == _feed || null == _feed?.items;
  }

  body(){
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

extension on RssItem {
  get img => null;
}