// ignore_for_file: avoid_print

import 'package:http/http.dart' as http;
import 'package:webfeed/webfeed.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:auto_size_text/auto_size_text.dart';


class GrantMagFeed extends StatefulWidget {
  const GrantMagFeed({super.key});
  
  @override State<GrantMagFeed> createState() => _GrantMagFeedState(); 
}

class _GrantMagFeedState extends State<GrantMagFeed> {
  static const String FEED_URL = 'https://backfeed.app/jkLTDA9LpqPBIVdrjl/https://grantmagazine.com/feed/rss'; 
  RssFeed? _feed; GlobalKey<RefreshIndicatorState>? _refreshKey; 
  
  
  @override void initState() {
    super.initState(); _refreshKey = GlobalKey<RefreshIndicatorState>(); 
    load(); 
  } 
  
  Future<void> load() async {
    final result = await loadFeed(); 
    if (!mounted) return; 
    setState(() => _feed = result); 
  } 
  
  Future<RssFeed> loadFeed() async { 
    try { 
      final response = await http.get(Uri.parse(FEED_URL));
      debugPrint(response.body);
      return RssFeed.parse(response.body); 
    } 
    catch (_) { return RssFeed(items: []); } 
  }

  bool isFeedEmpty() => _feed == null || _feed!.items == null; 
  Widget list() { 
    return ListView.builder( 
      itemCount: _feed?.items?.length ?? 0, 
      itemBuilder: (context, index) { final item = _feed!.items![index]; 
      return ListTile( title: Text(item.title ?? ''), onTap: () { 
        Navigator.push( context, MaterialPageRoute( builder: (_) => ArticlePage(article: item), ), 
          ); 
        },
      ); 
    }, 
  );
} 

@override Widget build(BuildContext context) { 
  if (isFeedEmpty()) { 
    return const Center(child: CircularProgressIndicator()); 
    } 
  return RefreshIndicator( key: _refreshKey, onRefresh: load, child: list(), ); 
  } 
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
      appBar: AppBar(
        toolbarHeight: 100, // max height
        title: AutoSizeText(
          article.title ?? 'Article',
          style: TextStyle(fontSize: 24), // max font size
          maxLines: 3,                      // wrap up to 
          minFontSize: 12,                  // scale down min
          overflow: TextOverflow.ellipsis,  // overflow protection
        ),
      ),

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

class GrantMagRSSPage extends StatelessWidget {
  const GrantMagRSSPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Grant Magazine')),
      body: const GrantMagFeed(),
    );
  }
}