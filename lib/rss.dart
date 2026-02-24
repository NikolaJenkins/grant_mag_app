// ignore_for_file: avoid_print

import 'package:http/http.dart' as http;
import 'package:webfeed_plus/webfeed_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:auto_size_text/auto_size_text.dart';


class GrantMagFeed extends StatefulWidget {
  const GrantMagFeed({super.key});
  
  @override State<GrantMagFeed> createState() => _GrantMagFeedState(); 
}

class _GrantMagFeedState extends State<GrantMagFeed> {
  static const String FEED_URL = 'https://grantmag-backend-production.up.railway.app/feed'; 
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
      print(response.body);
      return RssFeed.parse(response.body); 
    } 
    catch (_) { return RssFeed(items: []); } 
  }

  bool isFeedEmpty() => _feed == null || _feed!.items == null; 
  Widget list() { 
    return ListView.builder( 
      itemCount: _feed?.items?.length ?? 0, 
      itemBuilder: (context, index) { final item = _feed!.items![index]; 
      return ListTile( title: Text(item.title ?? ''),  subtitle: Text(item.categories?.map((c) => c.value).join(', ') ?? '',), onTap: () { 
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
   Widget build(BuildContext context){
    final screenWidth = MediaQuery.of(context).size.width;
    String html = widget.article.content?.value ?? widget.article.description ?? '';
      html = html.replaceAll(RegExp(r'style="width:\s*\d+px"'), '');
      html = html.replaceAll(RegExp(r'width="\d+"'), '');
      html = html.replaceAll(RegExp(r'height="\d+"'), '');
      html = html.replaceAll(RegExp(r'srcset="[^"]+"'), '');
      html = html.replaceAll(RegExp(r'sizes="[^"]*"'), '');
      debugPrint('HTML: ');
      debugPrint(html);
      return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100, // max height
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
            
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Html(
                data: html,
                style: {
                  "figure": Style(
                    width: Width(screenWidth),
                    fontSize: FontSize(11),
                    height: Height.auto(),
                    display: Display.block,
                    textAlign: TextAlign.center,
                    padding: HtmlPaddings.only(right: 16.0)
                  )
                }
              ),
            )
          ],
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