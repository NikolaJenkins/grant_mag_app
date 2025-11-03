// ignore_for_file: avoid_print

import 'package:webfeed/webfeed.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

class GrantMagRSS extends StatefulWidget{
  GrantMagRSS() : super();
  final String title = 'Grant Mag RSS Feed';
  @override
  GrantMagRSState createState() => GrantMagRSState();
}

class GrantMagRSState extends State<GrantMagRSS>{
  static const String FEED_URL = 'http://grantcompsci.com/test.rss';
  RssFeed? _feed;
  String _title = '';
  static const String loadingFeedMsg = 'Loading...';
  static const String loadError = 'Error Loading Feed';
  static const String placeholder = 'assets/Image-not-found.png';

updateTitle(title){
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
    updateTitle(_feed?.title);
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
    super.initState();
    print('debug0 start');
    updateTitle(widget.title);
    load();

  }

  title(title){
    return Text(
      title,
      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  subtitle(title){
    return Text(
      title,
      style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w100),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  thumbnail(imgUrl){
    return Padding(
      padding: EdgeInsetsGeometry.only(left:15.0),
      child: CachedNetworkImage(
        placeholder: (context, url) => Image.asset('placeholder'),
        imageUrl: imgUrl, 
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
        leading: thumbnail(item.img?.url),
        trailing: rightIcon(),
        contentPadding: EdgeInsets.all(5.0),
        onTap: () {

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
    : list();
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