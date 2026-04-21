// ignore_for_file: avoid_print

import 'dart:collection';

import 'package:http/http.dart' as http;
import 'package:webfeed_plus/domain/media/group.dart';
import 'package:webfeed_plus/domain/media/group.dart';
import 'package:webfeed_plus/webfeed_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:shared_preferences/shared_preferences.dart';


class GrantMagFeed extends StatefulWidget {
  final RssFeed feed;

  const GrantMagFeed({required this.feed, super.key});
  
  @override 
  State<GrantMagFeed> createState() => GrantMagFeedState(); 
}

class GrantMagFeedState extends State<GrantMagFeed> {
  final GlobalKey<RefreshIndicatorState> _refreshKey = GlobalKey<RefreshIndicatorState>();
  final Map<String, Future<String>> imageCache = {};

  @override
  void initState() {
    super.initState();
  }

  Future<void> addBookmark(String? link, String? title) async {
    if (link == null) return;
    final prefs = await SharedPreferences.getInstance();
    List<String> bookmarks = prefs.getStringList('bookmarks') ?? [];
    if (!bookmarks.contains(link)) {
      bookmarks.add(link);
      await prefs.setStringList('bookmarks', bookmarks);
      await prefs.setString('bookmark_title_$link', title ?? link);
    }
  }

  Widget list() {
    const excludedCategories = {'PDF Issues', 'Flipbooks'};

    final filteredItems = widget.feed.items
        ?.where((item) {
          final categories = item.categories?.map((c) => c.value).toSet() ?? {};
          return categories.intersection(excludedCategories).isEmpty;
        })
        .toList() ?? [];

    return ListView.builder(
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        final item = filteredItems[index];
        return ListTile(
          title: Text(item.title ?? ''),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.categories?.map((c) => c.value).join(', ') ?? ''),
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
                  return Image.network(
                    snapshot.data!,
                    fit: BoxFit.contain,
                  );
                },
              )
            ]),
          trailing: IconButton(
            icon: const Icon(Icons.bookmark_add),
            onPressed: () => addBookmark(item.link, item.title),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ArticlePage(article: item),
              ),
            );
          },
        );
      },
    );
  }

  @override 
  Widget build(BuildContext context) {
    return RefreshIndicator(
      key: _refreshKey,
      onRefresh: () async {
        imageCache.clear();
        setState(() {});
      }, // no-op for now
      child: list(),
    );
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
  String? url;

  @override
  void initState() {
    super.initState();
    _loadFeaturedImage(); // async fetch starts here
  }

  void _showLargeImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(2),
          title: Container(
            decoration: BoxDecoration(),
            width: MediaQuery.of(context).size.width,
            child: Image.network(
              imageUrl,
              fit: BoxFit.fitWidth
              ),
          ),
        );
      },
    );
  }

  Future<void> _loadFeaturedImage() async { //fetches html and loads image
    url = widget.article.link;
    if (url == null) return;
    try {
      final encodedUrl = Uri.encodeComponent(url!);
      final response = await http.get(Uri.parse(url!));//url parse

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
    //article builder
   @override
   Widget build(BuildContext context){
    final screenWidth = MediaQuery.of(context).size.width;
    String html = widget.article.content?.value ?? widget.article.description ?? '';
      debugPrint('HTML: ');
      debugPrint(html);

      return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100, //max height
        title: AutoSizeText(
          widget.article.title ?? 'Article',
          maxLines: 3,                      
          minFontSize: 18,                  
          overflow: TextOverflow.ellipsis,   //title bounds and wrapping
        ),
      ),

       body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (loadingImage) const LinearProgressIndicator(), //loading bar 
            if (!loadingImage && featuredImage != null)
              GestureDetector( //makes featured images clickable using a GestureDetector
                onTap: () => _showLargeImage(context, featuredImage!),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    featuredImage!,
                    width: screenWidth,
                    fit: BoxFit.fitWidth,
                    loadingBuilder: (context, child, loadingProgress) =>
                      (loadingProgress == null) ? child : CircularProgressIndicator(),
                  ),
                ),
              ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Html(
                data: html,
                extensions: [
                  TagExtension(
                    tagsToExtend: {"img"}, //handles img rendering in a seperate builder
                    builder: (context) {
                      final src = context.attributes['src'] ?? '';
                      if (src.isEmpty) return const SizedBox.shrink();
                      return Padding( //padding details for imgs
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Image.network(
                          src,
                          width: screenWidth,
                          fit: BoxFit.fitWidth, //uses flutter boxfit for proper aspect ratio rendering
                        ),
                      );
                    },
                  ),
                ],

                style: { //html style rendering for figs (captions) and text
                  "figure": Style(
                    width: Width(screenWidth),
                    fontSize: FontSize(11), //captions
                    height: Height.auto(),
                    display: Display.block,
                    textAlign: TextAlign.center,
                    margin: Margins.symmetric(vertical: 16),
                    padding: HtmlPaddings.only(right: 16.0),
                  ),

                  "p": Style(
                    fontSize: FontSize(14.0)
                  ),
                }
              ),
            )
          ],
        ),
      ),
    );
  }
}

extension ImageParsing on RssItem {
  Future<String> getFeaturedImage() async {
    final url = link;
    String featuredImage = '';
    if (url == null) {
      return '';
    }
    try {
      final response = await http.get(Uri.parse(url //featured image fetch RECONVERT WHEN SERVER UP
      ));//url parse

      if (response.statusCode != 200) return '';
      final html = response.body;

      final ogMatch = RegExp( //og syntax for fallback
        r'<meta property="og:image" content="([^"]+)"',
        caseSensitive: false,
      ).firstMatch(html);

      if (ogMatch != null) {
        featuredImage = ogMatch.group(1) ?? '';
      } else {
        final photoMatch = RegExp( //wordpress specific featured image grabber
          r'<div class="photowrap">[\s\S]*?<img[^>]+src="([^"]+)"',
          caseSensitive: false,
        ).firstMatch(html);
        featuredImage = photoMatch?.group(1) ?? ''; //sets featured image to variable
      }
    } catch (e) {
      debugPrint('Image scrape failed: $e'); //error catch
    }
    // final response = await http.get(Uri.parse(url));
    // final html = response.body;
    // final ogMatch = RegExp( //og syntax for fallback
    //   r'<meta property="og:image" content="([^"]+)"',
    //   caseSensitive: false,
    // ).firstMatch(html);
    return featuredImage; //error catch
  }
}

class GrantMagBookmarks extends StatefulWidget {
  final RssFeed feed;

  const GrantMagBookmarks({required this.feed, super.key});

  @override 
  State<GrantMagBookmarks> createState() => GrantMagBookmarksState();
}

class GrantMagBookmarksState extends State<GrantMagBookmarks> {
  List<String> bookmarks = [];

  @override
  void initState() {
    super.initState();
    loadBookmarks();
  }

  Future<void> loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      bookmarks = prefs.getStringList('bookmarks') ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookmarkedItems = widget.feed.items
        ?.where((item) => bookmarks.contains(item.link))
        .toList() ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text("Bookmarked Articles")),
      body: bookmarkedItems.isEmpty
          ? const Center(child: Text("No bookmarks yet"))
          : ListView.builder(
              itemCount: bookmarkedItems.length,
              itemBuilder: (context, index) {
                final item = bookmarkedItems[index];
                return ListTile(
                  title: Text(item.title ?? ''),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ArticlePage(article: item),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
